import os
import time

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


DATA_PATH = os.getenv("DATA_PATH", "douban_movies.csv")


def timed(label, func):
    start = time.perf_counter()
    result = func()
    elapsed = time.perf_counter() - start
    print(f"[TIME] {label}: {elapsed:.3f}s")
    return result


spark = SparkSession.builder.appName("DoubanGenreTopNPerf").getOrCreate()

raw = (
    spark.read.option("header", True)
    .option("inferSchema", True)
    .option("multiLine", True)
    .option("escape", '"')
    .csv(DATA_PATH)
)

clean = raw.dropna(subset=["year", "rating_score", "genres"])
clean = clean.withColumn("rating_score", F.col("rating_score").cast("double"))
clean = clean.withColumn("rating_count", F.col("rating_count").cast("long"))

genre_df = clean.withColumn("genre", F.explode(F.split(F.col("genres"), "/")))
genre_df.createOrReplaceTempView("movie_genres")

print("=== A-3 Perf Query: GROUP BY Genre Aggregation ===")
print(f"DATA_PATH={DATA_PATH}")
print(f"Clean rows: {clean.count()}")

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

spark.stop()
