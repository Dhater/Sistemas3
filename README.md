Claro, aquí tienes tu Markdown actualizado para que sea **copiable** y deje claro que antes hay que ejecutar el bash que sube los datos a HDFS y genera CSV y TXT:

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

1. Antes de ejecutar el análisis, **asegúrate de subir los datos y stopwords a HDFS**, generando los CSV y TXT necesarios. Ejecuta:

```bash
./setup_hdfs.sh
````

2. Los datos se colocan en la carpeta `data/` y se suben a HDFS.
3. Se ejecutan los scripts Pig para limpieza, tokenización y conteo de palabras.
4. Se generan archivos intermedios con resultados de frecuencia.
5. **Una vez finalizado el procesamiento**, se ejecuta el análisis final con:

```bash
python analyze_wordcount.py
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
