````markdown
# 🧠 Análisis Lingüístico Offline con Hadoop y Pig

**Universidad Diego Portales — Sistemas Distribuidos, Entrega 3**  
**Integrantes:** Leandro Norambuena, Gonzalo Gaete  
**Profesor:** Nicolás Hidalgo  
**Fecha:** 23 de noviembre de 2025

---

## 📘 Descripción del Proyecto

Este proyecto realiza un **análisis lingüístico distribuido** de datos textuales utilizando **Hadoop HDFS** y **Pig** para procesamiento offline.  
El objetivo es **limpiar, tokenizar y analizar** los datos, generando estadísticas y visualizaciones como **top 20 palabras más frecuentes** y **wordclouds**.

El análisis permite:

* Identificar patrones de frecuencia de palabras.
* Visualizar información relevante de los textos procesados.
* Evaluar el efecto de la filtración de palabras ignoradas en el análisis.

---

## 🏗 Arquitectura del Sistema

### Componentes Principales

1. **Hadoop HDFS**

   * Almacena los datos de manera distribuida.
   * Permite procesamiento escalable y tolerante a fallos.

2. **Pig Scripts**

   * Limpieza de datos crudos.
   * Tokenización y cálculo de frecuencias.
   * Generación de archivos intermedios para análisis.

3. **Python Scripts**

   * Preprocesamiento y post-procesamiento opcional.
   * Generación de resultados finales y visualizaciones.

4. **Visualizaciones**

   * Gráficos de frecuencia (Top 20).
   * Wordclouds para cada dataset analizado.

---
## 🔄 Flujo de Datos

1. Antes de ejecutar el análisis final, se exportan los datos y se generan los CSV/TXT necesarios usando el pipeline dentro del contenedor:

```bash
docker exec -it yahoo_pipeline python /pipeline/pipeline.py
````

2. Una vez que los datos están listos y los archivos generados por el pipeline están disponibles, se ejecuta el análisis final:

```bash
python analyze_wordcount.py
```

3. El script Python genera:

   * Top 20 palabras más frecuentes.
   * Visualizaciones tipo wordcloud.

**Importante:** El análisis final **solo debe ejecutarse después de que el pipeline haya terminado**, ya que depende de los CSV y TXT generados.

```

6. El script Python genera:

   * Top 20 palabras más frecuentes.
   * Visualizaciones tipo wordcloud.
   * Archivos listos para anexar al informe LaTeX.

**Importante:** El análisis final **solo debe ejecutarse después de que todos los pasos previos estén completos**, ya que depende de los archivos generados por Pig y los CSV/TXT exportados a HDFS.

---

## ⚙ Tecnologías Utilizadas

| Tecnología        | Rol en el Proyecto                      |
| ----------------- | --------------------------------------- |
| Hadoop HDFS       | Almacenamiento distribuido              |
| Pig               | Procesamiento y transformación de datos |
| Python            | Análisis final y visualización          |
| Docker (opcional) | Despliegue aislado y reproducible       |

---

## 📈 Resultados

Los resultados se guardan en la carpeta `output/`, incluyendo:

* `top20_yahoo.png` / `top20_yahoo_simple.png`
* `top20_llm.png` / `top20_llm_simple.png`
* `wordcloud_yahoo.png`
* `wordcloud_llm.png`

> Las versiones "incluyendo palabras ignoradas" muestran cómo funciona la filtración de stopwords.

---

## 📚 Referencias

* [Hadoop Documentation](https://hadoop.apache.org/docs/)
* [Pig Documentation](https://pig.apache.org/docs/r0.17.0/)
* [Python Documentation](https://docs.python.org/3/)

```

Con esto queda **clarísimo que primero hay que ejecutar el bash que sube CSV y TXT a HDFS** antes de correr el `analyze_wordcount.py`.  

Si quieres, puedo también agregar un **mini-diagrama de flujo** ASCII del pipeline para que quede más visual. ¿Quieres que haga eso?
```
