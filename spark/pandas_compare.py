import time
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd


DATA_PATH = Path(__file__).resolve().parents[1] / "douban_movies.csv"
OUT_PATH = Path(__file__).resolve().parent / "results" / "pandas_vs_spark.png"
OUT_PATH.parent.mkdir(parents=True, exist_ok=True)


def timed(label, func):
    start = time.perf_counter()
    result = func()
    elapsed = time.perf_counter() - start
    print(f"{label}: {elapsed:.3f}s")
    return elapsed, result


def pandas_genre_top10():
    df = pd.read_csv(DATA_PATH)
    df = df.dropna(subset=["rating_score", "genres"])
    df["genre"] = df["genres"].astype(str).str.split("/")
    exploded = df.explode("genre")
    return (
        exploded.groupby("genre")
        .agg(movie_count=("movie_id", "count"), avg_rating=("rating_score", "mean"))
        .query("movie_count >= 10")
        .sort_values(["avg_rating", "movie_count"], ascending=False)
        .head(10)
    )


elapsed, result = timed("pandas_genre_top10", pandas_genre_top10)
print(result)

labels = ["Pandas", "PySpark-1 executor", "PySpark-2 executors"]
times = [elapsed, 0, 0]

plt.figure(figsize=(8, 4.5))
plt.bar(labels, times)
plt.ylabel("Seconds")
plt.title("Genre Top10 Query Runtime")
plt.tight_layout()
plt.savefig(OUT_PATH, dpi=160)
print(f"Saved chart to {OUT_PATH}")
