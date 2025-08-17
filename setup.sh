#!/usr/bin/env bash

# Exit on any error
set -e

# Version parameters - easy to update
FLINK_VERSION="1.20.2"
FLUSS_VERSION="0.7.0"

echo "Starting Flink ${FLINK_VERSION} and Fluss ${FLUSS_VERSION} setup..."

# Check Java version
echo "Checking Java version..."
if ! command -v java &> /dev/null; then
    echo "❌ Error: Java is not installed or not in PATH"
    echo "Please install Java 17"
    exit 1
fi

# Extract Java version - handle both "17" and "17.0.15" formats
JAVA_VERSION_STRING=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
JAVA_VERSION=$(echo "$JAVA_VERSION_STRING" | cut -d'.' -f1)

# Handle cases where version might be like "1.8.0_292" (Java 8)
if [ "$JAVA_VERSION" = "1" ]; then
    JAVA_VERSION=$(echo "$JAVA_VERSION_STRING" | cut -d'.' -f2)
fi

if [ "$JAVA_VERSION" -ne 17 ]; then
    echo "❌ Error: Java version $JAVA_VERSION is not supported"
    echo "Flink and Fluss require Java 17"
    echo "Current Java version: $JAVA_VERSION_STRING"
    exit 1
fi

echo "✓ Java version check passed: $(java -version 2>&1 | head -n 1)"

# Check Docker installation
echo "Checking Docker installation..."
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>&1)
    echo "✓ Docker found: $DOCKER_VERSION"
else
    echo "⚠ Warning: Docker is not installed or not in PATH"
fi

# Check Docker Compose installation (docker compose v2+ or docker-compose v1)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(docker-compose --version 2>&1)
    echo "✓ Docker Compose found: $DOCKER_COMPOSE_VERSION"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(docker compose version --short 2>/dev/null)
    echo "✓ Docker Compose found (v2+): $DOCKER_COMPOSE_VERSION"
else
    echo "⚠ Warning: Docker Compose is not installed or not in PATH"
fi



# Clean up any files from previous runs if any...
echo "Cleaning up previous installation files..."
CLEANED=0
if [ -d "flink-${FLINK_VERSION}" ]; then
    rm -rf "flink-${FLINK_VERSION}"
    echo "  - Removed directory: flink-${FLINK_VERSION}"
    CLEANED=1
fi
if [ -d "fluss-${FLUSS_VERSION}" ]; then
    rm -rf "fluss-${FLUSS_VERSION}"
    echo "  - Removed directory: fluss-${FLUSS_VERSION}"
    CLEANED=1
fi
if [ $CLEANED -eq 0 ]; then
    echo "  - Nothing to clean."
fi

# Create fresh directories
mkdir -p "flink-${FLINK_VERSION}"
mkdir -p "fluss-${FLUSS_VERSION}"

# Download compressed tar files / binary distribution if they do not already exist
if [ -f "flink-${FLINK_VERSION}-bin-scala_2.12.tgz" ]; then
    echo "Flink ${FLINK_VERSION} archive already exists, skipping download."
else
    echo "Downloading Flink ${FLINK_VERSION}..."
    wget -O "flink-${FLINK_VERSION}-bin-scala_2.12.tgz" "https://archive.apache.org/dist/flink/flink-${FLINK_VERSION}/flink-${FLINK_VERSION}-bin-scala_2.12.tgz"
fi

if [ -f "fluss-${FLUSS_VERSION}-bin.tgz" ]; then
    echo "Fluss ${FLUSS_VERSION} archive already exists, skipping download."
else
    echo "Downloading Fluss ${FLUSS_VERSION}..."
    wget -O "fluss-${FLUSS_VERSION}-bin.tgz" "https://github.com/alibaba/fluss/releases/download/v${FLUSS_VERSION}/fluss-${FLUSS_VERSION}-bin.tgz"
fi

# Extract the tar files
echo "Extracting Flink..."
tar -xzf "flink-${FLINK_VERSION}-bin-scala_2.12.tgz"
echo "Extracting Fluss..."
tar -xzf "fluss-${FLUSS_VERSION}-bin.tgz"

# Copy Flink configuration
echo "Copying Flink configuration..."
if [ -f "config/flink/config.yaml" ]; then
    cp config/flink/config.yaml "flink-${FLINK_VERSION}/conf/"
    echo "✓ Flink config.yaml copied"
else
    echo "⚠ Warning: config/flink/config.yaml not found"
fi

# Copy Fluss configuration
echo "Copying Fluss configuration..."
if [ -f "config/fluss/server.yaml" ]; then
    cp config/fluss/server.yaml "fluss-${FLUSS_VERSION}/conf/"
    echo "✓ Fluss server.yaml copied"
else
    echo "⚠ Warning: config/fluss/server.yaml not found"
fi

# Copy Flink libraries
echo "Copying Flink libraries..."
if [ -d "jar/flink/lib" ] && [ "$(ls -A jar/flink/lib 2>/dev/null)" ]; then
    echo "📦 Found Flink JAR files:"
    for jar in jar/flink/lib/*.jar; do
        if [ -f "$jar" ]; then
            echo "   📄 $(basename "$jar") → flink-${FLINK_VERSION}/lib/"
        fi
    done
    cp -r jar/flink/lib/* "flink-${FLINK_VERSION}/lib/"
    echo "✓ Flink libraries copied"
elif [ -d "jar/flink/lib" ]; then
    echo "ℹ️  jar/flink/lib directory is empty - no custom libraries to copy"
else
    echo "ℹ️  jar/flink/lib directory not found - no custom libraries to copy"
fi

# Copy Fluss libraries
echo "Copying Fluss libraries..."
if [ -d "jar/fluss/lib" ] && [ "$(ls -A jar/fluss/lib 2>/dev/null)" ]; then
    echo "📦 Found Fluss JAR files:"
    for jar in jar/fluss/lib/*.jar; do
        if [ -f "$jar" ]; then
            echo "   📄 $(basename "$jar") → fluss-${FLUSS_VERSION}/lib/"
        fi
    done
    cp -r jar/fluss/lib/* "fluss-${FLUSS_VERSION}/lib/"
    echo "✓ Fluss libraries copied"
elif [ -d "jar/fluss/lib" ]; then
    echo "ℹ️  jar/fluss/lib directory is empty - no custom libraries to copy"
else
    echo "ℹ️  jar/fluss/lib directory not found - no custom libraries to copy"
fi

# Copy Fluss plugins
echo "Copying Fluss plugins..."
if [ -d "jar/fluss/plugins" ] && [ "$(ls -A jar/fluss/plugins 2>/dev/null)" ]; then
    echo "📦 Found Fluss plugin files:"
    for jar in jar/fluss/plugins/*.jar; do
        if [ -f "$jar" ]; then
            echo "   📄 $(basename "$jar") → fluss-${FLUSS_VERSION}/plugins/"
        fi
    done
    cp -r jar/fluss/plugins/* "fluss-${FLUSS_VERSION}/plugins/"
    echo "✓ Fluss plugins copied"
elif [ -d "jar/fluss/plugins" ]; then
    echo "ℹ️  jar/fluss/plugins directory is empty - no custom plugins to copy"
else
    echo "ℹ️  jar/fluss/plugins directory not found - no custom plugins to copy"
fi



echo "Setup completed successfully!"
echo "Flink is available in: flink-${FLINK_VERSION}/"
echo "Fluss is available in: fluss-${FLUSS_VERSION}/"
