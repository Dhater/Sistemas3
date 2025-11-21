#!/usr/bin/env bash
set -e


# Copia el CSV exportado al HDFS (espera a que NameNode esté listo)
CSV_PATH=${1:-/data/questions_export.csv}
HDFS_INPUT=${2:-/input/questions_export.csv}


# Intentos para esperar a NameNode
for i in {1..30}; do
docker exec -it hadoop_namenode bash -c "hdfs dfs -test -d / || echo no" >/dev/null 2>&1 && break || sleep 2
done


# Crear directorio y subir
docker exec -it hadoop_namenode bash -c "hdfs dfs -mkdir -p /input || true"
# Copiamos el archivo desde el volumen compartido (dataset_volume) que está montado en el namenode en /data
docker exec -it hadoop_namenode bash -c "hdfs dfs -put -f $CSV_PATH $HDFS_INPUT"


echo "CSV subido a HDFS:$HDFS_INPUT"