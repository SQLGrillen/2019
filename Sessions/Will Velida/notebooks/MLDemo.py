# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC # ML Demo

# COMMAND ----------

# importing necessary libraries
from pyspark.ml.regression import LinearRegression

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC # Basic Logistical Regression Sample

# COMMAND ----------

dailyActivitiesDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/activities_2019.csv")

# COMMAND ----------

lr = LinearRegression(maxIter=10, regParam=0.3, elasticNetParam=0.8)

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC # Apply ML here

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC # Export our model here

# COMMAND ----------

