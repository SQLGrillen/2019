// Databricks notebook source
// MAGIC %md
// MAGIC 
// MAGIC ## MLeap Demo
// MAGIC 
// MAGIC - A common serialization format and execution engine for machine learning pipelines
// MAGIC - Support Spark for training pipelines and exporting them into a bundle
// MAGIC - These bundles can then be sent back to Spark for either Batch ML processing or real-time scoring

// COMMAND ----------

import ml.combust.bundle.BundleFile
import ml.combust.mleap.spark.SparkSupport._
import org.apache.spark.ml.bundle.SparkBundleContext
import resource._
import org.apache.spark.ml.{Pipeline, PipelineModel}
import org.apache.spark.ml.classification.DecisionTreeClassifier
import org.apache.spark.ml.evaluation._
import org.apache.spark.ml.feature._
import org.apache.spark.ml.tuning._

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## MLlib concepts
// MAGIC 
// MAGIC We'll also use this demo to discuss the basic components of building a pipeline in MLlib

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## DataFrames
// MAGIC 
// MAGIC - The MLlib API uses DataFrames so that we can apply machine learning to a variety of different data types
// MAGIC - In addition to the usual types that are supported, DataFrames can also use Vector types

// COMMAND ----------

val df = spark.read.parquet("/databricks-datasets/news20.binary/data-001/training")
  .select("text", "topic")
df.cache()
display(df)

// COMMAND ----------

df.printSchema()

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ### Pipelines
// MAGIC 
// MAGIC - Here, we're setting up our Pipeline for our model
// MAGIC - Basically consists of stages (either a transformer or estimator)
// MAGIC - These are run in order, transforming the input DataFrame as it passes through each stage

// COMMAND ----------

// get a number of indicies for our topic column 
val labelIndexer = new StringIndexer()
  .setInputCol("topic")
  .setOutputCol("label")
  .setHandleInvalid("keep")

// COMMAND ----------

// Break into individual words
val tokenizer = new Tokenizer().setInputCol("text").setOutputCol("words")
// put them into fixed length feature vectors
val hashingTF = new HashingTF().setInputCol("words").setOutputCol("features")

// COMMAND ----------

// Create a new DecisionTreeClassifier
val dt = new DecisionTreeClassifier()
// Set up our pipeline
val pipeline = new Pipeline()
  .setStages(Array(labelIndexer, tokenizer, hashingTF, dt))

// COMMAND ----------

val paramGrid = new ParamGridBuilder()
  .addGrid(hashingTF.numFeatures, Array(1000, 2000))
  .build()
val cv = new CrossValidator()
  .setEstimator(pipeline)
  .setEvaluator(new MulticlassClassificationEvaluator())
  .setEstimatorParamMaps(paramGrid)

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## Estimators
// MAGIC 
// MAGIC - Basically fits our model on the data
// MAGIC - We use fit(), which takes our DataFrame and produces a model.
// MAGIC - We then use .bestModel to get our best model

// COMMAND ----------

val cvModel = cv.fit(df)

// COMMAND ----------

val model = cvModel.bestModel.asInstanceOf[PipelineModel]

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## Transformers
// MAGIC 
// MAGIC - This is an abstraction that includes features and learned models
// MAGIC - Like the example code below, we implement transform(), which converts one DataFrame into another.

// COMMAND ----------

val sparkTransformed = model.transform(df)

display(sparkTransformed)

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC Now we can export our trained model into our Blob Storage Account container

// COMMAND ----------

implicit val context = SparkBundleContext().withDataset(sparkTransformed)

(for(modelFile <- managed(BundleFile("jar:file:/tmp/mleap_scala_model_export/20news_pipeline-json.zip"))) yield {
  model.writeBundle.save(modelFile)(context)
}).tried.get

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC Let's see if it's in there!

// COMMAND ----------

dbutils.fs.mkdirs("mnt/dailyexercisefiles/mleapModels")
display(dbutils.fs.ls("dbfs:/mnt/dailyexercisefiles"))

// COMMAND ----------

dbutils.fs.cp("file:/tmp/mleap_scala_model_export/20news_pipeline-json.zip", "dbfs:/mnt/dailyexercisefiles/mleapModels/20news_pipeline-json.zip")
display(dbutils.fs.ls("dbfs:/mnt/dailyexercisefiles/mleapModels"))

// COMMAND ----------

// MAGIC %md
// MAGIC 
// MAGIC ## Importing our trained model to use on new data

// COMMAND ----------

val zipBundle = (for(bundle <- managed(BundleFile("jar:file:/tmp/mleap_scala_model_export/20news_pipeline-json.zip"))) yield {
  bundle.loadSparkBundle().get
}).opt.get

// COMMAND ----------

val loadedModel = zipBundle.root

// COMMAND ----------

val test_df = spark.read.parquet("/databricks-datasets/news20.binary/data-001/test")
  .select("text", "topic")
test_df.cache()
display(test_df)

// COMMAND ----------

val exampleResults = loadedModel.transform(test_df)

display(exampleResults)

// COMMAND ----------

