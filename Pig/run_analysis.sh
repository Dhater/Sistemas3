#!/bin/bash
set -e

echo "=== Iniciando análisis Pig ==="

DATA_DIR=/app/data
INPUT_DIR=/input
STOPWORDS_DIR=/stopwords
OUTPUT_BASE=/output

# Crear directorios si no existen
mkdir -p $INPUT_DIR
mkdir -p $STOPWORDS_DIR
mkdir -p $OUTPUT_BASE

# Copiar stopwords
cp -f /app/scripts/scripts/stopwords_*.txt $STOPWORDS_DIR/

echo "[1/4] Archivos de entrada y stopwords:"
ls -l $INPUT_DIR
ls -l $STOPWORDS_DIR

# Función para ejecutar un script Pig
run_pig() {
    SCRIPT=$1
    NAME=$2
    OUT_DIR=$OUTPUT_BASE/$NAME

    # Eliminar output previo
    if [ -d "$OUT_DIR" ]; then
        echo "Eliminando output previo $OUT_DIR..."
        rm -rf "$OUT_DIR"
    fi

    echo "[Ejecutando Pig] $NAME ..."
    if ! pig -x local -param INPUT_DIR=$INPUT_DIR -param OUTPUT_DIR=$OUT_DIR -f /app/scripts/scripts/$SCRIPT; then
        echo "⚠️ Error en $NAME, se continúa con los siguientes scripts"
    fi
}

# Ejecutar las 4 variantes
run_pig wordcount_yahoo.pig yahoo
run_pig wordcount_yahoo_simple.pig yahoo_simple
run_pig wordcount_llm.pig llm
run_pig wordcount_llm_simple.pig llm_simple

echo "[2/4] Resultados generados:"
ls -l $OUTPUT_BASE

# Combinar los part-r-00000 en un único txt dentro de /app/data
for FILE in yahoo yahoo_simple llm llm_simple; do
    SRC="$OUTPUT_BASE/$FILE/part-r-00000"
    DEST="$DATA_DIR/${FILE}_wordcount.txt"
    if [ -f "$SRC" ]; then
        cat "$SRC" > "$DEST"
        echo "✓ $FILE → $DEST"
    else
        echo "⚠️ No se encontró $SRC"
    fi
done

echo "[3/4] Generando visualizaciones..."
python3 /app/analyze_wordcount.py 2>&1 | grep -E "(✓|Guardado)"

echo ""
echo "=== Pig batch completado ==="
echo "El contenedor seguirá corriendo. Presiona CTRL+C para salir o inspecciona los archivos."

# Mantener el contenedor corriendo
tail -f /dev/null
