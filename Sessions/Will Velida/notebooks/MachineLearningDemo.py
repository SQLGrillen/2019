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
    paramGrid = ParamGridBuilder().addGrid(hashingTF.numFeatures, [1000, 2000]).build()
    cv = CrossValidator(estimator=pipeline, evaluator=MulticlassClassificationEvaluator(), estimatorParamMaps=paramGrid)
    cvModel = cv.fit(df)
    model = cvModel.bestModel
  
    # Log the model within the MLflow run
    mlflow.mleap.log_model(spark_model=model, sample_input=df, artifact_path="model")

# COMMAND ----------

fit_model()

# COMMAND ----------

