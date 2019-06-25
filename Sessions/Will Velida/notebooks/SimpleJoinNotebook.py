# Databricks notebook source
# Try to mount our storage
try:
  dbutils.fs.mount(
    source = "wasbs://dailyactivities@velidastorage.blob.core.windows.net",
    mount_point = "/mnt/dailyexercisefiles",
    extra_configs = {"fs.azure.account.key.velidastorage.blob.core.windows.net":dbutils.secrets.get(scope="azurekeyvault", key="storagekeysecret")}
  )
  print("Storage has been mounted!")
except:
  print("Storage account has already been mounted!")
  
# Get the two dataframes that we need
TotalExerciseDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/TotalExercise.csv")
FoodLogDF = spark.read.format("csv").option("header", "true").option("inferSchema", "true").load("/mnt/dailyexercisefiles/FoodLog.csv")

# Join on date
joinExpression = TotalExerciseDF["ExerciseDate"] == FoodLogDF["FoodLogDate"]

ExerciseAndFoodDF = TotalExerciseDF.join(FoodLogDF, joinExpression)

# Drop the Food Log Date
ExerciseAndFoodDF.drop('FoodLogDate')

# Write the result to a table
ExerciseAndFoodDF.write.saveAsTable("ExerciseAndFood")