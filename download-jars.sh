#!/usr/bin/env bash

# Exit on any error
set -e


echo "📥 Downloading JAR files from Maven repositories..."
echo "=================================================="
echo

# Create directories if they don't exist
mkdir -p jar/flink/lib
mkdir -p jar/fluss/lib
mkdir -p jar/fluss/plugins/paimon

# Function to download JAR with progress
download_jar() {
    local url="$1"
    local target_file="$2"
    local description="$3"

    echo "📦 Downloading: $description"
    echo "   URL: $url"
    echo "   Target: $target_file"

    if [ -f "$target_file" ]; then
        echo "   ℹ️  File already exists, skipping..."
    else
        wget -O "$target_file" "$url"
        echo "   ✅ Downloaded successfully"
    fi
    echo
}

# Maven Central base URL
MAVEN_CENTRAL="https://repo1.maven.org/maven2"

echo "🔧 Flink Libraries (jar/flink/lib/)"
echo "-----------------------------------"

# Flink shaded Hadoop
download_jar \
   "https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar" \
   "jar/flink/lib/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar" \
   "Flink Shaded Hadoop 2 Uber"

# Fluss Flink integration
download_jar \
    "https://repo1.maven.org/maven2/com/alibaba/fluss/fluss-flink-1.20/0.7.0/fluss-flink-1.20-0.7.0.jar" \
    "jar/flink/lib/fluss-flink-1.20-0.7.0.jar" \
    "Fluss Flink 1.20 Integration"

# Fluss Lake Paimon
download_jar \
   "https://repo1.maven.org/maven2/com/alibaba/fluss/fluss-lake-paimon/0.7.0/fluss-lake-paimon-0.7.0.jar" \
   "jar/flink/lib/fluss-lake-paimon-0.7.0.jar" \
   "Fluss Lake Paimon"

# Paimon Flink connector
download_jar \
    "https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-flink-1.20/1.0.1/paimon-flink-1.20-1.0.1.jar" \
    "jar/flink/lib/paimon-flink-1.20-1.0.1.jar" \
    "Paimon Flink 1.20-1.0.1 Connector"

# Paimon S3
download_jar \
    "https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-s3/1.0.1/paimon-s3-1.0.1.jar" \
    "jar/flink/lib/paimon-s3-1.0.1.jar" \
    "Paimon S3 1.0.1"

echo "🔧 Fluss Libraries (jar/fluss/lib/)"
echo "-----------------------------------"

# Fluss FS S3
download_jar \
    "https://repo1.maven.org/maven2/com/alibaba/fluss/fluss-fs-s3/0.7.0/fluss-fs-s3-0.7.0.jar" \
    "jar/fluss/lib/fluss-fs-s3-0.7.0.jar" \
    "Fluss FS S3"

echo "🔌 Fluss Plugins (jar/fluss/plugins/)"
echo "-------------------------------------"

# Paimon S3 plugin
download_jar \
    "https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-s3/1.0.1/paimon-s3-1.0.1.jar" \
    "jar/fluss/plugins/paimon/paimon-s3-1.0.1.jar" \
    "Paimon S3 Plugin"

echo "✅ All JAR files downloaded successfully!"
echo
echo
echo "💡 To copy these files to Flink/Fluss installations, run: ./setup.sh"
