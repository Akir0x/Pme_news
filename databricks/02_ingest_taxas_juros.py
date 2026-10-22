# Databricks notebook source
# Passo 2: taxas de juros por instituição (semanal), API Olinda do Banco Central.
# Conferir nomes de campos na primeira chamada.
import requests
import pandas as pd
from pyspark.sql import functions as F

URL = (
    "https://olinda.bcb.gov.br/olinda/servico/taxaJuros/versao/v2/odata/"
    "TaxasJurosDiariaPorInicioPeriodo?$format=json&$top=100000"
)

dados = requests.get(URL, timeout=120).json()["value"]

df = (
    spark.createDataFrame(pd.DataFrame(dados))
    .withColumn("_ingestao", F.current_timestamp())
)
df.write.mode("append").saveAsTable("benchmarking.bronze.taxas_juros")

# COMMAND ----------
# Silver: segmento PJ, taxas numéricas, join com dim_players pelo CNPJ-8, sem duplicados.
# Ajuste os nomes das colunas (Segmento, Modalidade, cnpj8, InicioPeriodo, TaxaJurosAoMes)
# conforme o retorno real da API.
spark.sql("""
CREATE OR REPLACE TABLE benchmarking.silver.taxas_pj AS
SELECT DISTINCT
  t.cnpj8,
  p.nome_painel,
  p.tipo,
  t.Modalidade AS modalidade,
  CAST(t.InicioPeriodo AS DATE) AS inicio_periodo,
  CAST(t.FimPeriodo AS DATE) AS fim_periodo,
  CAST(t.TaxaJurosAoMes AS DOUBLE) AS taxa_am,
  CAST(t.TaxaJurosAoAno AS DOUBLE) AS taxa_aa
FROM benchmarking.bronze.taxas_juros t
JOIN benchmarking.silver.dim_players p ON t.cnpj8 = p.cnpj8
WHERE upper(t.Segmento) LIKE '%JUR%'
""")
