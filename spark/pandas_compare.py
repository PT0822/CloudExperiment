import argparse
import csv
import html
import time
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DATA = ROOT / "douban_movies.csv"
DEFAULT_PERF = ROOT / "evidence" / "spark_perf_compare" / "perf_summary.csv"
DEFAULT_OUT = ROOT / "spark" / "results" / "pandas_vs_pyspark_genre_top10.svg"


def timed(label, func):
    start = time.perf_counter()
    result = func()
    elapsed = time.perf_counter() - start
    print(f"[TIME] {label}: {elapsed:.3f}s")
    return elapsed, result


def pandas_genre_top10(data_path: Path):
    df = pd.read_csv(data_path)
    df = df.dropna(subset=["rating_score", "genres"])
    df["genre"] = df["genres"].astype(str).str.split("/")
    exploded = df.explode("genre")
    result = (
        exploded.groupby("genre")
        .agg(movie_count=("movie_id", "count"), avg_rating=("rating_score", "mean"))
        .query("movie_count >= 10")
        .sort_values(["avg_rating", "movie_count"], ascending=False)
        .head(10)
    )
    result["avg_rating"] = result["avg_rating"].round(2)
    return result


def read_pyspark_times(perf_csv: Path):
    times = {}
    if not perf_csv.exists():
        return times
    with perf_csv.open(newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            if row.get("query") == "genre_top10" and row.get("engine") == "PySpark":
                times[f"PySpark-{row['parallelism']} executor"] = float(row["seconds"])
    return times


def write_svg(times, out: Path):
    labels = list(times.keys())
    values = [times[k] for k in labels]
    width, height = 860, 480
    left, bottom, top = 90, 380, 70
    chart_h = bottom - top
    bar_w = 150
    gap = 70
    maxv = max(values) if values else 1.0
    colors = ["#4c78a8", "#f58518", "#54a24b", "#e45756"]
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}">',
        '<rect width="100%" height="100%" fill="white"/>',
        '<text x="430" y="36" text-anchor="middle" font-size="22" font-family="Arial">A-3 Genre Top-10 Runtime: Pandas vs PySpark</text>',
        f'<line x1="{left}" y1="{bottom}" x2="800" y2="{bottom}" stroke="#333"/>',
        f'<line x1="{left}" y1="{top}" x2="{left}" y2="{bottom}" stroke="#333"/>',
        '<text x="28" y="225" transform="rotate(-90 28 225)" text-anchor="middle" font-size="15" font-family="Arial">Seconds</text>',
    ]
    for i, (label, value) in enumerate(zip(labels, values)):
        x = left + 65 + i * (bar_w + gap)
        bar_h = int(value / maxv * (chart_h - 10))
        y = bottom - bar_h
        color = colors[i % len(colors)]
        safe_label = html.escape(label)
        parts.append(f'<rect x="{x}" y="{y}" width="{bar_w}" height="{bar_h}" fill="{color}"/>')
        parts.append(f'<text x="{x + bar_w/2}" y="{y - 10}" text-anchor="middle" font-size="14" font-family="Arial">{value:.3f}s</text>')
        parts.append(f'<text x="{x + bar_w/2}" y="410" text-anchor="middle" font-size="14" font-family="Arial">{safe_label}</text>')
    parts.append('</svg>')
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text("\n".join(parts), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description="A-3 Pandas vs PySpark runtime comparison")
    parser.add_argument("--data", type=Path, default=DEFAULT_DATA)
    parser.add_argument("--perf-csv", type=Path, default=DEFAULT_PERF)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()

    pandas_time, pandas_result = timed("pandas_genre_top10", lambda: pandas_genre_top10(args.data))
    print("=== Pandas Genre Top-10 ===")
    print(pandas_result)

    times = {"Pandas-single": pandas_time}
    times.update(read_pyspark_times(args.perf_csv))

    print("=== Runtime Summary ===")
    for label, value in times.items():
        print(f"{label},{value:.3f}")

    write_svg(times, args.out)
    print(f"Saved chart to {args.out}")


if __name__ == "__main__":
    main()
