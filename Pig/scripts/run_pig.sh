#!/usr/bin/env bash
set -e


# Este script se ejecuta en el contenedor pig (`yahoo_pig`) y lanza Pig contra HDFS
# Asegúrate de que /pig-scripts contiene wordcount.pig y stopwords.txt


# Copiar stopwords al HDFS (si no existe)
docker exec -it hadoop_namenode bash -c "hdfs dfs -mkdir -p /stopwords || true"
docker exec -it hadoop_namenode bash -c "hdfs dfs -put -f /data/pig-scripts/stopwords.txt /stopwords/stopwords.txt"


# Ejecutar pig — usamos pig -x mapreduce
docker exec -it yahoo_pig bash -lc "pig -x mapreduce /pig-scripts/wordcount.pig"


# Al final, copiamos resultados de HDFS al volumen compartido /data/pig_output para inspección
docker exec -it hadoop_namenode bash -c "hdfs dfs -mkdir -p /output || true"
# Copiar output desde HDFS a /data/pig_output (en el NameNode el volumen dataset_volume está montado en /data)
docker exec -it hadoop_namenode bash -c "hdfs dfs -getmerge /output/human_top /data/pig_output/human_top.csv || true"
docker exec -it hadoop_namenode bash -c "hdfs dfs -getmerge /output/llm_top /data/pig_output/llm_top.csv || true"


echo "Ejecución Pig finalizada. Resultados en /data/pig_output/"