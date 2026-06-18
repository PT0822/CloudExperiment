from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("WordCountOperatorDemo").getOrCreate()
sc = spark.sparkContext

lines = [
    "cloud computing course design",
    "kubernetes spark operator wordcount",
    "cloud kubernetes redis spark",
    "student 2023112554 2023112557",
]

counts = (
    sc.parallelize(lines, 2)
    .flatMap(lambda line: line.split())
    .map(lambda word: (word, 1))
    .reduceByKey(lambda a, b: a + b)
    .sortBy(lambda item: item[0])
)

print("=== wordcount.py result ===")
for word, count in counts.collect():
    print(f"{word}\t{count}")

spark.stop()
