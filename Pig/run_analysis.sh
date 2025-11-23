#!/bin/bash
set -e

echo "=== Iniciando análisis Pig con HDFS (hardcodeado) ==="

# Crear directorios locales
mkdir -p /app/data

# Crear directorios HDFS que coincidan con los paths hardcodeados en Pig
hdfs dfs -mkdir -p /input
hdfs dfs -mkdir -p /stopwords
hdfs dfs -mkdir -p /output

# Subir archivos de entrada a HDFS
hdfs dfs -put -f /app/data/* /input/

# Subir stopwords a HDFS
hdfs dfs -put -f /app/scripts/scripts/stopwords_*.txt /stopwords/

echo "[1/2] Archivos en HDFS:"
hdfs dfs -ls /input
hdfs dfs -ls /stopwords

# Ejecutar scripts Pig en modo MapReduce directamente, sin variables
echo "[Ejecutando Pig] Yahoo Answers ..."
pig -x mapreduce /app/scripts/scripts/wordcount_yahoo.pig

echo "[Ejecutando Pig] LLM Answers ..."
pig -x mapreduce /app/scripts/scripts/wordcount_llm.pig

echo "[2/2] Resultados generados en HDFS:"
hdfs dfs -ls /output

# Traer resultados combinados a local
hdfs dfs -getmerge /output/yahoo /app/data/yahoo_wordcount.txt
echo "✓ Yahoo → /app/data/yahoo_wordcount.txt"

hdfs dfs -getmerge /output/llm /app/data/llm_wordcount.txt
echo "✓ LLM → /app/data/llm_wordcount.txt"

echo ""
echo "=== Pig batch completado ==="
echo "El contenedor seguirá corriendo. Presiona CTRL+C para salir o inspecciona los archivos."

# Mantener el contenedor corriendo
tail -f /dev/null
