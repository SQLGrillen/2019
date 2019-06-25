# Databricks notebook source
from pyspark.ml import Pipeline
from pyspark.ml.classification import DecisionTreeClassifier
from pyspark.ml.feature import StringIndexer, Tokenizer, HashingTF
from pyspark.ml.evaluation import MulticlassClassificationEvaluator
from pyspark.ml.tuning import CrossValidator, ParamGridBuilder
import mlflow
import mlflow.mleap

# COMMAND ----------

df = spark.read.parquet("/databricks-datasets/news20.binary/data-001/training").select("text", "topic")
df.cache()
display(df)

# COMMAND ----------

labelIndexer = StringIndexer(inputCol="topic", outputCol="label", handleInvalid="keep")

# COMMAND ----------

tokenizer = Tokenizer(inputCol="text", outputCol="words")

# COMMAND ----------

hashingTF = HashingTF(inputCol="words", outputCol="features")

# COMMAND ----------

dt = DecisionTreeClassifier()

# COMMAND ----------

pipeline = Pipeline(stages=[labelIndexer, tokenizer, hashingTF, dt])

# COMMAND ----------

def fit_model():
  # Start a new MLflow run
  with mlflow.start_run() as run:
    # Fit the model, performing cross validation to improve accuracy
    paramGrid = ParamGridBuilder().addGrid(hashingTF.numFeatures, [250,500,1000, 2000]).build()
    cv = CrossValidator(estimator=pipeline, evaluator=MulticlassClassificationEvaluator(), estimatorParamMaps=paramGrid)
    cvModel = cv.fit(df)
    model = cvModel.bestModel
  
    # Log the model within the MLflow run
    mlflow.mleap.log_model(spark_model=model, sample_input=df, artifact_path="model")

# COMMAND ----------

fit_model()

# COMMAND ----------

# MAGIC %md
# MAGIC 
# MAGIC ## MLFlow overview
# MAGIC 
# MAGIC Each MLFlow run contains the following properties
# MAGIC 
# MAGIC - Source: Name of the notebook we used
# MAGIC - Version: Notebook revision if run from a notebook or Git commit hash.
# MAGIC - Start & end time: Start and end time of the run.
# MAGIC - Parameters: Key-value model parameters. Both keys and values are strings.
# MAGIC - Tags: Key-value run metadata that can be updated during and after a run completes. Both keys and values are strings.
# MAGIC - Metrics: Key-value model evaluation metrics.
# MAGIC - Artifacts: Output files for our project

# COMMAND ----------

