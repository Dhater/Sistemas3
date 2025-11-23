#!/usr/bin/env python3
"""
Análisis automático de Wordcount
Procesa todos los archivos *_wordcount.txt en local_data y genera visualizaciones comparativas.
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from wordcloud import WordCloud
from datetime import datetime
import json

# Configuración de estilo
sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (12, 8)
plt.rcParams['font.size'] = 10

DATA_DIR = "../local_data"
RESULTS_DIR = "./results"
os.makedirs(RESULTS_DIR, exist_ok=True)

def load_wordcount(filepath):
    """Cargar resultados de wordcount desde archivo TSV"""
    data = []
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            parts = line.strip().split('\t')
            if len(parts) == 2:
                word, count = parts
                try:
                    data.append({'word': word, 'count': int(count)})
                except ValueError:
                    continue
    return pd.DataFrame(data)

def generate_wordcloud(df, title, output_path, colormap='Blues'):
    word_freq = dict(zip(df['word'], df['count']))
    wc = WordCloud(width=1200, height=800, background_color='white',
                   colormap=colormap, max_words=100, relative_scaling=0.5).generate_from_frequencies(word_freq)
    plt.figure(figsize=(15,10))
    plt.imshow(wc, interpolation='bilinear')
    plt.axis('off')
    plt.title(title, fontsize=20, fontweight='bold')
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Wordcloud guardado: {output_path}")

def generate_bar_chart(df, title, output_path, top_n=20, color='steelblue'):
    top_words = df.head(top_n).copy()
    plt.figure(figsize=(12,8))
    plt.barh(top_words['word'][::-1], top_words['count'][::-1], color=color)
    plt.xlabel("Frecuencia")
    plt.title(title, fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Gráfico de barras guardado: {output_path}")

def calculate_statistics(df):
    total_words = df['count'].sum()
    unique_words = len(df)
    lexical_diversity = unique_words / total_words if total_words > 0 else 0
    top_words = df.head(10)[['word','count']].to_dict('records')
    return {
        "total_words": int(total_words),
        "unique_words": int(unique_words),
        "lexical_diversity": round(lexical_diversity,4),
        "top_words": top_words
    }

def main():
    print("="*70)
    print("ANÁLISIS AUTOMÁTICO DE PALABRAS - LOCAL DATA")
    print("="*70)

    # Detectar archivos *_wordcount.txt
    files = [f for f in os.listdir(DATA_DIR) if f.endswith("_wordcount.txt")]
    datasets = {}
    
    for f in files:
        name = f.replace("_wordcount.txt","")
        path = os.path.join(DATA_DIR,f)
        df = load_wordcount(path)
        datasets[name] = df
        print(f"[Cargado] {name}: {len(df)} palabras únicas")
        
        # Wordcloud
        generate_wordcloud(df, f"Vocabulario {name}", os.path.join(RESULTS_DIR,f"wordcloud_{name}.png"))
        
        # Barra top 20
        generate_bar_chart(df, f"Top 20 Palabras {name}", os.path.join(RESULTS_DIR,f"top20_{name}.png"))

    # Comparaciones entre pares
    if "yahoo" in datasets and "llm" in datasets:
        yahoo_df = datasets["yahoo"]
        llm_df = datasets["llm"]
        # Tabla comparativa top 50
        top_n = 50
        yahoo_top = yahoo_df.head(top_n)
        llm_top = llm_df.head(top_n)
        comparison = pd.DataFrame({
            "Rank": range(1,top_n+1),
            "Yahoo_Word": yahoo_top['word'].values,
            "Yahoo_Count": yahoo_top['count'].values,
            "LLM_Word": llm_top['word'].values,
            "LLM_Count": llm_top['count'].values
        })
        comp_file = os.path.join(RESULTS_DIR, "comparison_top50.csv")
        comparison.to_csv(comp_file,index=False,encoding='utf-8')
        print(f"✓ Tabla comparativa guardada: {comp_file}")
        
        # Estadísticas
        stats = {
            "yahoo": calculate_statistics(yahoo_df),
            "llm": calculate_statistics(llm_df),
            "common_words": len(set(yahoo_df['word']) & set(llm_df['word'])),
            "yahoo_exclusive": len(set(yahoo_df['word']) - set(llm_df['word'])),
            "llm_exclusive": len(set(llm_df['word']) - set(yahoo_df['word'])),
            "vocabulary_overlap_percent": round(len(set(yahoo_df['word']) & set(llm_df['word'])) / len(set(yahoo_df['word']) | set(llm_df['word']))*100,2)
        }
        stats_file = os.path.join(RESULTS_DIR, "analysis_report.json")
        with open(stats_file,'w',encoding='utf-8') as f:
            json.dump(stats,f, indent=2, ensure_ascii=False)
        print(f"✓ Reporte de análisis guardado: {stats_file}")

    print("="*70)
    print("ANÁLISIS COMPLETADO")
    print("="*70)

if __name__ == "__main__":
    main()
