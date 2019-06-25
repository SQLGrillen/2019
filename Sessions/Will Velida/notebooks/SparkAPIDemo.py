# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC # Getting our data into Databricks

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Mounting Blob Storage

# COMMAND ----------

# mount the storage here
try:
  dbutils.fs.mount(
    source = "wasbs://dailyactivities@velidastorage.blob.core.windows.net",
    mount_point = "/mnt/dailyexercisefiles",
    extra_configs = {"fs.azure.account.key.velidastorage.blob.core.windows.net":dbutils.secrets.get(scope="azurekeyvault", key="storagekeysecret")}
  )
  print("Storage has been mounted!")
except:
  print("Storage account has already been mounted!")

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Importing libraries

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC - We can import libraries that come with out clusters into our workbooks as we would in code!

# COMMAND ----------

# import libraries needed for this workbook
from pyspark.sql.functions import count, min, max, sum, avg, expr
from pyspark.sql.functions import var_pop, stddev_pop, var_samp, stddev_samp
from pyspark.sql.functions import skewness, kurtosis, corr, covar_pop, covar_samp
from pyspark.ml.stat import ChiSquareTest
import pydocumentdb
from pydocumentdb import document_client
from pydocumentdb import documents
import datetime

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Working with DBFS

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC - A distributed file system installed on our clusters
# MAGIC - Files persist to Blob Storage, so we don't lose our data after we terminate our clusters

# COMMAND ----------

# Let's access our DBFS path
display(dbutils.fs.ls("dbfs:/mnt/dailyexercisefiles"))

# COMMAND ----------

# Make a directory in DBFS
dbutils.fs.mkdirs("mnt/dailyexercisefiles/newFolder")

# COMMAND ----------

# Write a new file to that directory!
dbutils.fs.put("mnt/dailyexercisefiles/newFolder/ournewfile.txt", "This is a new file!")

# COMMAND ----------

# Let's view the head of that file!
dbutils.fs.head("mnt/dailyexercisefiles/newFolder/ournewfile.txt")

# COMMAND ----------

# Now let's get rid of it
dbutils.fs.rm("mnt/dailyexercisefiles/newFolder/ournewfile.txt")

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC We can also access DBFS via:
# MAGIC - The Databricks CLI
# MAGIC - Spark APIs
# MAGIC - Local File APIs

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC # Working with our data using the Spark API

# COMMAND ----------

# load the csv as a dataframe
dailyActivitiesDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/activities_2019.csv")
FoodLogDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/FoodLog.csv")
GymWorkoutsDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/GymWorkouts.csv")
TotalExerciseDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/TotalExercise.csv")
TotalSleepDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/TotalSleep.csv")
WeightMeasurementsDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/WeightMeasurements.csv")
CardioWorkoutsDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/CardioWorkouts.csv")

# COMMAND ----------

# do some cool operations here
display(dailyActivitiesDF)

# COMMAND ----------

dailyActivitiesDF.printSchema()

# COMMAND ----------

# Save our Dataframe as a table
dailyActivitiesDF.write.saveAsTable("dailyActivities_2019")
FoodLogDF.write.saveAsTable("FoodLog")
GymWorkoutsDF.write.saveAsTable("GymWorkouts")
TotalExerciseDF.write.saveAsTable("TotalExercise")
TotalSleepDF.write.saveAsTable("TotalSleep")
WeightMeasurementsDF.write.saveAsTable("WeightMeasurements")
CardioWorkoutsDF.write.saveAsTable("CardioWorkouts")

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Aggregations
# MAGIC 
# MAGIC - We can do aggregations, which are available as functions.

# COMMAND ----------

dailyActivitiesDF.select(count("ID")).show()

# COMMAND ----------

# get the min and max amount of calories burned
dailyActivitiesDF.select(min("CaloriesBurned"),max("CaloriesBurned")).show()

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Statistical functions
# MAGIC 
# MAGIC - We can do some basic statistical functions as well using the Spark API

# COMMAND ----------

# standard deviation and variance
dailyActivitiesDF.select(var_pop("CaloriesBurned"),var_samp("CaloriesBurned"),stddev_pop("CaloriesBurned"),stddev_samp("CaloriesBurned")).show()

# COMMAND ----------

# Any extreme points in our data?
dailyActivitiesDF.select(skewness("CaloriesBurned"),kurtosis("CaloriesBurned")).show()

# COMMAND ----------

# Covariance and Correlation
dailyActivitiesDF.select(corr("CaloriesBurned", "Steps"),covar_samp("CaloriesBurned", "Steps"),covar_pop("CaloriesBurned", "Steps")).show()

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Writing our data to Cosmos DB

# COMMAND ----------

writeConfig = {
 "Endpoint" : "https://velidacosmos.documents.azure.com:443/",
 "Masterkey" : "l6dNkRelDRofvYmFwDdzRz747fYAVmp3g4sohwTv0PKacdQZZQbNYLvgsfWk85bygGNrr3T251BDgRkMORSieg==",
 "Database" : "DailyActivities",
 "Collection" : "Activities",
 "Upsert" : "true"
}

dailyActivitiesDF.write.format("com.microsoft.azure.cosmosdb.spark").options(**writeConfig).save()

# COMMAND ----------

