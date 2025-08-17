#!/usr/bin/env bash


# Exit on any error
set -e

echo "🔍 JAR Files Copy Overview"
echo "=========================="
echo

# Show Flink JAR files
echo "📦 Flink Libraries (jar/flink/lib/ → flink-1.20.2/lib/)"
echo "--------------------------------------------------------"
if [ -d "jar/flink/lib" ] && [ "$(ls -A jar/flink/lib 2>/dev/null)" ]; then
    for jar in jar/flink/lib/*.jar; do
        if [ -f "$jar" ]; then
            size=$(du -h "$jar" | cut -f1)
            echo "   📄 $(basename "$jar") (${size}) → flink-1.20.2/lib/"
        fi
    done
else
    echo "   ℹ️  No JAR files found in jar/flink/lib/"
fi
echo

# Show Fluss JAR files
echo "📦 Fluss Libraries (jar/fluss/lib/ → fluss-0.7.0/lib/)"
echo "------------------------------------------------------"
if [ -d "jar/fluss/lib" ] && [ "$(ls -A jar/fluss/lib 2>/dev/null)" ]; then
    for jar in jar/fluss/lib/*.jar; do
        if [ -f "$jar" ]; then
            size=$(du -h "$jar" | cut -f1)
            echo "   📄 $(basename "$jar") (${size}) → fluss-0.7.0/lib/"
        fi
    done
else
    echo "   ℹ️  No JAR files found in jar/fluss/lib/"
fi
echo

# Show Fluss plugin files
echo "🔌 Fluss Plugins (jar/fluss/plugins/ → fluss-0.7.0/plugins/)"
echo "-------------------------------------------------------------"
if [ -d "jar/fluss/plugins" ] && [ "$(ls -A jar/fluss/plugins 2>/dev/null)" ]; then
    for jar in jar/fluss/plugins/*.jar; do
        if [ -f "$jar" ]; then
            size=$(du -h "$jar" | cut -f1)
            echo "   📄 $(basename "$jar") (${size}) → fluss-0.7.0/plugins/"
        fi
    done
else
    echo "   ℹ️  No JAR files found in jar/fluss/plugins/"
fi
echo

# Show total count
total_jars=$(find jar/ -name "*.jar" -type f 2>/dev/null | wc -l)
echo "📊 Summary: $total_jars total JAR files found"
echo
echo "💡 To download these files from Maven repositories, run: ./download-jars.sh"
echo
echo "💡 To copy these files, run: ./setup.sh"
