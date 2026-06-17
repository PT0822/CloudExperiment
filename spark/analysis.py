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

clean = raw.dropna(subset=["rating_score", "year"])
clean = clean.fillna({"summary": "暂无简介", "directors": "未知导演", "countries": "未知地区"})
clean = clean.withColumn("year", F.col("year").cast("int"))
clean = clean.withColumn("rating_score", F.col("rating_score").cast("double"))
clean = clean.withColumn("rating_count", F.col("rating_count").cast("long"))
clean = clean.withColumn("collect_count", F.col("collect_count").cast("long"))

print(f"Clean rows: {clean.count()}")
print("=== Numeric Summary ===")
clean.select("year", "rating_score", "rating_count", "collect_count").summary().show()

clean.createOrReplaceTempView("movies")

print("=== Query 1: Year Trend ===")
timed(
    "year_trend",
    lambda: spark.sql(
        """
        SELECT year, COUNT(*) AS movie_count, ROUND(AVG(rating_score), 2) AS avg_rating
        FROM movies
        WHERE year IS NOT NULL
        GROUP BY year
        ORDER BY year
        """
    ).show(30, truncate=False),
)

print("=== Query 2: Genre Top-N ===")
genre_df = clean.withColumn("genre", F.explode(F.split(F.col("genres"), "/")))
genre_df.createOrReplaceTempView("movie_genres")
timed(
    "genre_top10",
    lambda: spark.sql(
        """
        SELECT genre, COUNT(*) AS movie_count, ROUND(AVG(rating_score), 2) AS avg_rating
        FROM movie_genres
        WHERE genre IS NOT NULL AND genre <> ''
        GROUP BY genre
        HAVING movie_count >= 10
        ORDER BY avg_rating DESC, movie_count DESC
        LIMIT 10
        """
    ).show(truncate=False),
)

print("=== Query 3: Country High Rating Top-N ===")
country_df = clean.withColumn("country", F.explode(F.split(F.col("countries"), "/")))
country_df.createOrReplaceTempView("movie_countries")
timed(
    "country_high_rating",
    lambda: spark.sql(
        """
        SELECT country, COUNT(*) AS high_rating_count
        FROM movie_countries
        WHERE rating_score >= 8.5 AND country IS NOT NULL AND country <> ''
        GROUP BY country
        ORDER BY high_rating_count DESC
        LIMIT 10
        """
    ).show(truncate=False),
)

print("=== Query 4: Director Best Movie Window ===")
director_window = Window.partitionBy("directors").orderBy(F.col("rating_score").desc(), F.col("rating_count").desc())
timed(
    "director_best_movie",
    lambda: clean.where(F.col("directors") != "未知导演")
    .withColumn("rn", F.row_number().over(director_window))
    .where(F.col("rn") == 1)
    .select("directors", "title", "year", "rating_score", "rating_count")
    .orderBy(F.col("rating_score").desc(), F.col("rating_count").desc())
    .show(20, truncate=False),
)

spark.stop()
