# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC # Getting our data into Databricks

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC - We can upload our data using the 'Data' tab UI.
# MAGIC - A more realistic example would be to connect Databricks to an exsiting data store (Such as Azure Storage)

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Mounting Blob Storage

# COMMAND ----------

# mount the storage here
try:
  dbutils.fs.mount(
    source = "wasbs://CONTAINERNAME@STORAGEACCOUNTNAME.blob.core.windows.net",
    mount_point = "/mnt/MOUNTNAME",
    extra_configs = {"fs.azure.account.key.CONTAINERNAME.blob.core.windows.net":dbutils.secrets.get(scope="azurekeyvault", key="storagekeysecret")}
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
# MAGIC ## Working with DBFS (Databricks File System)

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC - A distributed file system installed on our clusters
# MAGIC - Files persist to Blob Storage, so we don't lose our data after we terminate our clusters
# MAGIC - We can access the DBFS via the Databricks CLI tool, DBFS API, Spark API's or Databricks Utilities library

# COMMAND ----------

# Let's access our DBFS path
display(dbutils.fs.ls("dbfs:/mnt/dailyexercisefiles"))

# COMMAND ----------

# Make a directory in DBFS
dbutils.fs.mkdirs("mnt/dailyexercisefiles/newFolder2")

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

display(TotalExerciseDF)

# COMMAND ----------

display(FoodLogDF)

# COMMAND ----------

dailyActivitiesDF.printSchema()

# COMMAND ----------

FoodLogDF.printSchema()

# COMMAND ----------

# Join on date
joinExpression = TotalExerciseDF["ExerciseDate"] == FoodLogDF["FoodLogDate"]

ExerciseAndFoodDF = TotalExerciseDF.join(FoodLogDF, joinExpression)

# Drop the Food Log Date
ExerciseAndFoodDFv1 = ExerciseAndFoodDF.drop('FoodLogDate', 'MinutesSedentary', 'MinutesLightlyActive', 'MinutesFairlyActive', 'MinutesVeryActive', 'Fat', 'Fiber', 'Carbs', 'Sodium', 'Protein', 'Water')

# Write the result to a table
display(ExerciseAndFoodDFv1)

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Tables
# MAGIC 
# MAGIC - In Databricks, we have both global and local tables
# MAGIC - Global tables are available across all clusters and are registered to the Hive metastore
# MAGIC - Local tables are only avaialble to that cluster and is not registered to the Hive metastore
# MAGIC - We can create tables using the UI or programmatically as below

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
# MAGIC ## Multiple languages in one notebook
# MAGIC 
# MAGIC - One cool thing about Databricks is that we can combine languages within a notebook
# MAGIC - So one example of this could be that our Data Scientists are comfortable writing Python, then our Data Engineers optimise that using Scala

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC SELECT Count(Date) as NumberOfDaysCaloriesBurnedOver4000
# MAGIC FROM dailyActivities_2019
# MAGIC WHERE CaloriesBurned >= 4000

# COMMAND ----------

# MAGIC %scala

# COMMAND ----------

# MAGIC %sql
# MAGIC 
# MAGIC SELECT Date, CaloriesBurned, Steps, ActivityCalories
# MAGIC FROM dailyActivities_2019
# MAGIC WHERE CaloriesBurned >= 4000

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Writing our data to Cosmos DB
# MAGIC 
# MAGIC - We can write to a variety of different data sources, provided we've set up the necessary libraries and infrastructure to do so
# MAGIC - Slightly naughty here, should encrypt secrets with Azure Vault Key or Databricks Secrets

# COMMAND ----------

writeConfig = {
 "Endpoint" : "COSMOSENDPOINT",
 "Masterkey" : "PRIMARYKEY",
 "Database" : "DATABASENAME",
 "Collection" : "COLLECTIONNAME",
 "Upsert" : "true"
}

dailyActivitiesDF.write.format("com.microsoft.azure.cosmosdb.spark").options(**writeConfig).save()

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Unmounting our storage account

# COMMAND ----------

dbutils.fs.unmount("/mnt/dailyexercisefiles")