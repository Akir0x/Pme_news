# Databricks notebook source
# Passo 3: carteira PJ por porte, IF.data (trimestral), API Olinda.
# 1) ListaDeRelatorio  -> descobrir o código do relatório de carteira PJ por porte do tomador
# 2) IfDataCadastro    -> mapear instituições/conglomerados ao CNPJ-8
# 3) IfDataValores     -> valores por trimestre
import requests
import pandas as pd
from pyspark.sql import functions as F

BASE = "https://olinda.bcb.gov.br/olinda/servico/IFDATA/versao/v1/odata/"
CODIGO_RELATORIO = "CODIGO_DO_RELATORIO"   # preencher após consultar ListaDeRelatorio
TIPO_INSTITUICAO = 1                       # conferir no ListaDeRelatorio/documentação
TRIMESTRES = ["202512", "202603", "202606"]

for anomes in TRIMESTRES:
    url = (
        BASE + "IfDataValores(AnoMes=@AnoMes,TipoInstituicao=@Tipo,Relatorio=@Rel)"
        f"?@AnoMes={anomes}&@Tipo={TIPO_INSTITUICAO}&@Rel='{CODIGO_RELATORIO}'&$format=json"
    )
    v = requests.get(url, timeout=300).json()["value"]
    (
        spark.createDataFrame(pd.DataFrame(v))
        .withColumn("anomes", F.lit(anomes))
        .withColumn("_ingestao", F.current_timestamp())
        .write.mode("append")
        .saveAsTable("benchmarking.bronze.ifdata_valores")
    )

# COMMAND ----------
# Silver esperado: benchmarking.silver.fato_carteira_pj
# colunas: cnpj8, data_base, porte (micro/pequena/media/grande), modalidade, saldo
# O IF.data sai 2 a 3 meses após o fim do trimestre: o job roda toda semana e só grava trimestre novo.
