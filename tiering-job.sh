#!/usr/bin/env bash

# Exit on any error
set -e

# Download the tiering JAR if you don't have it
JAR_FILE="fluss-flink-tiering-0.7.0.jar"
if [ ! -f "$JAR_FILE" ]; then
  wget "https://repo1.maven.org/maven2/com/alibaba/fluss/fluss-flink-tiering/0.7.0/$JAR_FILE"
else
  echo "$JAR_FILE already exists, skipping download."
fi

# Submit the tiering job
if [ ! -d "./flink-1.20.2" ]; then
  echo "❌ Flink directory ./flink-1.20.2 does not exist. Please run setup.sh first."
  exit 1
fi


./flink-1.20.2/bin/flink run \
  $JAR_FILE \
  --fluss.bootstrap.servers localhost:9123 \
  --datalake.format paimon \
  --datalake.paimon.metastore filesystem \
  --datalake.paimon.warehouse s3://fluss/data \
  --datalake.paimon.s3.endpoint http://localhost:9000 \
  --datalake.paimon.s3.access-key minioadmin \
  --datalake.paimon.s3.secret-key minioadmin \
  --datalake.paimon.s3.path.style.access true
