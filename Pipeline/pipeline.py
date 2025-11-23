import os
import psycopg2
import subprocess
import pandas as pd
from pathlib import Path

# --------------------------
# Rutas locales y HDFS
# --------------------------
DATA_DIR = Path("/data")
CSV_LOCAL_PATH = DATA_DIR / "base_preguntas.csv"
YAHOO_TXT = DATA_DIR / "yahoo_answers.txt"
LLM_TXT = DATA_DIR / "llm_answers.txt"
HDFS_PATH = "/input/base_preguntas.csv"

HADOOP_CONTAINER = "hadoop_namenode"

# --------------------------
# Funciones auxiliares
# --------------------------
def ensure_dirs():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

def run(cmd):
    print(f"\n$ {cmd}")
    result = subprocess.run(cmd, shell=True)
    if result.returncode != 0:
        raise RuntimeError(f"❌ Comando falló: {cmd}")

# --------------------------
# 1) EXPORTAR CSV DESDE POSTGRES
# --------------------------
def export_csv_psycopg():
    print("\n📤 Exportando datos desde Postgres usando psycopg2...")

    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "database"),
        port=os.getenv("DB_PORT", 5432),
        dbname=os.getenv("DB_NAME", "yahoo_qa"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "password123")
    )

    # UNION ALL para crear columna 'source' para Yahoo y LLM
    query = """
    COPY (
        SELECT 'yahoo' AS source, human_answer AS answer
        FROM questions
        WHERE human_answer IS NOT NULL AND human_answer <> ''

        UNION ALL

        SELECT 'llm' AS source, llm_answer AS answer
        FROM questions
        WHERE llm_answer IS NOT NULL AND llm_answer <> ''
    )
    TO STDOUT WITH CSV HEADER;
    """

    with conn, conn.cursor() as cur:
        with open(CSV_LOCAL_PATH, "w", encoding="utf-8") as f:
            cur.copy_expert(query, f)

    print(f"✅ CSV exportado correctamente: {CSV_LOCAL_PATH}")

# --------------------------
# 2) DIVIDIR CSV EN TXT PARA PIG
# --------------------------
def split_csv_to_txt():
    if not CSV_LOCAL_PATH.exists():
        print(f"⚠️ CSV no encontrado: {CSV_LOCAL_PATH}")
        return

    df = pd.read_csv(CSV_LOCAL_PATH)
    if "source" not in df.columns or "answer" not in df.columns:
        print("❌ CSV debe tener columnas 'source' y 'answer'")
        return

    # Yahoo
    yahoo_df = df[df["source"].str.lower() == "yahoo"]
    yahoo_df["answer"].astype(str).to_csv(YAHOO_TXT, index=False, header=False)
    print(f"✓ Yahoo: {len(yahoo_df)} líneas → {YAHOO_TXT.name}")

    # LLM
    llm_df = df[df["source"].str.lower() == "llm"]
    llm_df["answer"].astype(str).to_csv(LLM_TXT, index=False, header=False)
    print(f"✓ LLM: {len(llm_df)} líneas → {LLM_TXT.name}")

# --------------------------
# 3) SUBIR CSV A HDFS
# --------------------------
def upload_to_hdfs():
    print("\n📤 Subiendo CSV a HDFS...")
    # Copiar archivo al contenedor namenode
    run(f"docker cp {CSV_LOCAL_PATH} {HADOOP_CONTAINER}:/tmp/base_preguntas.csv")
    # Crear carpeta /input si no existe
    run(f"docker exec {HADOOP_CONTAINER} hdfs dfs -mkdir -p /input")
    # Borrar archivo previo
    run(f"docker exec {HADOOP_CONTAINER} hdfs dfs -rm -f {HDFS_PATH}")
    # Subir archivo a HDFS
    run(f"docker exec {HADOOP_CONTAINER} hdfs dfs -put -f /tmp/base_preguntas.csv {HDFS_PATH}")
    print(f"✅ Archivo subido a HDFS en {HDFS_PATH}")

# --------------------------
# MAIN
# --------------------------
if __name__ == "__main__":
    print("\n===============================")
    print("  PIPELINE: EXPORTAR + SPLIT + HDFS")
    print("===============================\n")

    ensure_dirs()
    export_csv_psycopg()
    split_csv_to_txt()
    upload_to_hdfs()

    print("\n🎉 PIPELINE COMPLETO 🎉")
