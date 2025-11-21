-- wordcount.pig
-- Entrada: /input/questions_export.csv (CSV con header: id,human_answer,llm_answer,created_at)
-- Salidas: /output/human_top, /output/llm_top


REGISTER piggybank.jar IF EXISTS; -- opcional si usas UDFs externas


-- Cargar CSV con encabezado: usamos PigStorage con comilla y escape
questions = LOAD '/input/questions_export.csv' USING PigStorage(',')
AS (id:chararray, human_answer:chararray, llm_answer:chararray, created_at:chararray);


-- Función para normalizar texto: minúsculas y eliminar signos de puntuación
-- Pig no tiene regex replace global muy potente sin UDF; usaremos REPLACE varias veces


DEFINE LOWER org.apache.pig.FuncHelperLower(); -- placeholder: si no tienes UDF, usar LOWER() builtin


-- Tokenización y limpieza para una columna dada
-- Transformación para respuestas humanas
human_lines = FOREACH questions GENERATE id, LOWER((chararray)human_answer) as text;
llm_lines = FOREACH questions GENERATE id, LOWER((chararray)llm_answer) as text;


-- Reemplazos básicos de puntuación (coma, punto, ; : ? ! " ( ) [ ] { } - _ / \ )
-- Aplicamos una serie de REPLACE encadenadas
clean_human = FOREACH human_lines GENERATE id,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(text, '\\"', ' '), '\\'',' '), '\\(', ' '), '\\)', ' '), '\\[', ' '), '\\]', ' '), '\\{', ' '), '\\}', ' '), '\\.', ' '), ',', ' '), ';', ' '), ':', ' '), '!', ' '), '\\?', ' ') as text;


clean_llm = FOREACH llm_lines GENERATE id,
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(text, '\\"', ' '), '\\'',' '), '\\(', ' '), '\\)', ' '), '\\[', ' '), '\\]', ' '), '\\{', ' '), '\\}', ' '), '\\.', ' '), ',', ' '), ';', ' '), ':', ' '), '!', ' '), '\\?', ' ') as text;


-- Tokenizar: TOKENIZE no es builtin; usamos STRSPLIT o TOKENIZE UDF. Simplificamos con TOKENIZE si disponible.
-- Usaremos builtin TOKENIZE disponible en Pig 0.17 (si no, hay alternativas con UDF)


human_tokens = FOREACH clean_human GENERATE FLATTEN(TOKENIZE(text)) AS token;
llm_tokens = FOREACH clean_llm GENERATE FLATTEN(TOKENIZE(text)) AS token;


-- Quitar tokens vacíos y números solos
human_filtered = FILTER human_tokens BY (token IS NOT NULL) AND (token != '') AND (NOT token MATCHES '\\d+');
llm_filtered = FILTER llm_tokens BY (token IS NOT NULL) AND (token != '') AND (NOT token MATCHES '\\d+');


-- Cargar stopwords desde archivo en HDFS en /stopwords/stopwords.txt (uno por línea)
stop = LOAD '/stopwords/stopwords.txt' USING PigStorage('\n') AS (sw:chararray);
stop_lower = FOREACH stop GENERATE LOWER(sw) as sw;


-- Anti-join para filtrar stopwords
human_pairs = FOREACH human_filtered GENERATE LOWER(token) as token;
llm_pairs = FOREACH llm_filtered GENERATE LOWER(token) as token;


human_nostop = FILTER human_pairs BY (NOT (token IN (stop_lower)));
llm_nostop = FILTER llm_pairs BY (NOT (token IN (stop_lower)));


-- WordCount
human_grouped = GROUP human_nostop BY token;
human_counted = FOREACH human_grouped GENERATE group as word, COUNT(human_nostop) as freq;
human_sorted = ORDER human_counted BY freq DESC;


llm_grouped = GROUP llm_nostop BY token;
llm_counted = FOREACH llm_grouped GENERATE group as word, COUNT(llm_nostop) as freq;
llm_sorted = ORDER llm_counted BY freq DESC;


-- Guardar top N (ej: top 100)
STORE human_sorted INTO '/output/human_top' USING PigStorage(',');
STORE llm_sorted INTO '/output/llm_top' USING PigStorage(',');