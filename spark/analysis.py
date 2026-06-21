import os
import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window


DATA_PATH = os.getenv("DATA_PATH", "douban_movies.csv")


def timed(label, func):
    start = time.perf_counter()
    result = func()
    elapsed = time.perf_counter() - start
    print(f"[TIME] {label}: {elapsed:.3f}s")
    return result


spark = SparkSession.builder.appName("DoubanMovieAnalysis").getOrCreate()

raw = (
    spark.read.option("header", True)
    .option("inferSchema", True)
    .option("multiLine", True)
    .option("escape", '"')
    .csv(DATA_PATH)
)

print("=== Schema ===")
raw.printSchema()
print("=== First 5 Rows ===")
raw.show(5, truncate=40)

total = raw.count()
print(f"Raw rows: {total}")

print("=== Missing Ratio ===")
missing_exprs = [
    (F.sum(F.when(F.col(c).isNull() | (F.col(c) == ""), 1).otherwise(0)) / F.lit(total)).alias(c)
    for c in raw.columns
]
raw.select(missing_exprs).show(truncate=False)

# Keep only rows that can participate in year trend, score analysis, and genre
# aggregation. Other descriptive fields are filled to preserve usable records.
clean = raw.dropna(subset=["year", "rating_score", "genres"])
clean = clean.fillna({"summary": "暂无简介", "directors": "未知导演", "countries": "未知地区"})
clean = clean.withColumn("year", F.col("year").cast("int"))
clean = clean.withColumn("rating_score", F.col("rating_score").cast("double"))
clean = clean.withColumn("rating_count", F.col("rating_count").cast("long"))
clean = clean.withColumn("collect_count", F.col("collect_count").cast("long"))

print(f"Clean rows: {clean.count()}")
print("=== Numeric Summary ===")
clean.select("year", "rating_score", "rating_count", "collect_count").summary().show()

print("=== Non-null Counts After Cleaning ===")
nonnull_exprs = [
    F.sum(F.when(F.col(c).isNotNull() & (F.col(c) != ""), 1).otherwise(0)).alias(c)
    for c in clean.columns
]
clean.select(nonnull_exprs).show(truncate=False)

clean.createOrReplaceTempView("movies")

genre_df = clean.withColumn("genre", F.explode(F.split(F.col("genres"), "/")))
genre_df.createOrReplaceTempView("movie_genres")

print("=== Query 1: GROUP BY Genre Aggregation ===")
timed(
    "genre_aggregation",
    lambda: spark.sql(
        """
        SELECT
            genre,
            COUNT(*) AS movie_count,
            ROUND(AVG(rating_score), 3) AS avg_rating,
            ROUND(AVG(rating_count), 1) AS avg_rating_count
        FROM movie_genres
        WHERE genre IS NOT NULL AND genre <> ''
        GROUP BY genre
        ORDER BY movie_count DESC
        LIMIT 15
        """
    ).show(15, truncate=False),
)

print("=== Query 2: ORDER BY Top-N Movies ===")
timed(
    "topn_movies",
    lambda: spark.sql(
        """
        SELECT title, original_title, year, rating_score, rating_count, collect_count
        FROM movies
        ORDER BY rating_score DESC, rating_count DESC
        LIMIT 10
        """
    ).show(10, truncate=False),
)

print("=== Query 3: Time Trend By Year ===")
timed(
    "year_trend",
    lambda: spark.sql(
        """
        SELECT
            year,
            COUNT(*) AS movie_count,
            ROUND(AVG(rating_score), 3) AS avg_rating,
            ROUND(AVG(rating_count), 1) AS avg_rating_count
        FROM movies
        WHERE year BETWEEN 2000 AND 2021
        GROUP BY year
        ORDER BY year
        """
    ).show(30, truncate=False),
)

print("=== Query 4: Window Function Top Movies In Each Genre ===")
genre_window = Window.partitionBy("genre").orderBy(F.col("rating_score").desc(), F.col("rating_count").desc())
timed(
    "window_top_movies_by_genre",
    lambda: genre_df.where(F.col("genre").isNotNull() & (F.col("genre") != ""))
    .withColumn("rank_in_genre", F.row_number().over(genre_window))
    .where(F.col("rank_in_genre") <= 3)
    .select("genre", "title", "original_title", "year", "rating_score", "rating_count", "rank_in_genre")
    .orderBy("genre", "rank_in_genre")
    .show(40, truncate=False),
)

spark.stop()
