# Databricks notebook source
# MAGIC %md
# MAGIC 
# MAGIC # Connect to table in Databricks

# COMMAND ----------

# importing necessary libraries
from pyspark.sql.functions import avg

# COMMAND ----------

totalExercise = spark.table("totalexercise")
display(totalExercise.select("*"))

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## Programmatic Dashboards

# COMMAND ----------

display(totalExercise.select("Steps","StepTargetAchieved").groupBy("StepTargetAchieved").agg(avg("Steps")))

# COMMAND ----------

display(totalExercise.select("Date", "CaloriesBurned", "ActivityCalories"))

# COMMAND ----------

boxPlotDF = totalExercise.select("Date", "CaloriesBurned", "StepTargetAchieved", "CalorieTargetAchieved", "ActivityTargetAchieved", "RestDay", "DistanceAchieved")

# COMMAND ----------

display(boxPlotDF)

# COMMAND ----------

display(boxPlotDF)

# COMMAND ----------

display(boxPlotDF)

# COMMAND ----------

display(boxPlotDF)

# COMMAND ----------

display(boxPlotDF)

# COMMAND ----------

