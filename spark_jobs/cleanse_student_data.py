from pyspark.sql import SparkSession
from pyspark.sql.functions import col, trim

spark = SparkSession.builder.appName("StudentDataCleanse").getOrCreate()

df = spark.read.csv("s3://edu-bucket/raw/student_records.csv", header=True, inferSchema=True)

# Trim whitespace and standardize case
df_clean = df.withColumn("student_id", trim(col("student_id")))\
             .withColumn("term", trim(col("term")))\
             .withColumn("gpa", col("gpa").cast("float"))

df_clean.write.mode("overwrite").parquet("s3://edu-bucket/clean/student_records")
