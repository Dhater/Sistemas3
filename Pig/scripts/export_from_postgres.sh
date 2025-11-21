#!/usr/bin/env bash
set -e


# Este script se ejecuta desde el host o dentro de un container con psql instalado.
# Exporta la tabla questions a CSV en el volumen compartido (/data)


DB_CONTAINER=${1:-yahoo_database}
OUT_PATH=${2:-/data/questions_export.csv}
DB_USER=${DB_USER:-${DB_USER}}
DB_NAME=${DB_NAME:-${DB_NAME}}


echo "Exportando desde container: $DB_CONTAINER a $OUT_PATH"


docker exec -u postgres $DB_CONTAINER bash -c "psql -U \"$DB_USER\" -d \"$DB_NAME\" -c \"\copy (SELECT id, COALESCE(human_answer,'') as human_answer, COALESCE(llm_answer,'') as llm_answer, created_at FROM questions) TO '$OUT_PATH' WITH CSV HEADER\""


echo "Export completo: $OUT_PATH"