# Databricks notebook source
# Passo 7: PDFs de RI e notícias depositados pelo Power Automate no volume landing.
(
    spark.readStream.format("cloudFiles")
    .option("cloudFiles.format", "binaryFile")
    .load("/Volumes/benchmarking/bronze/landing/ri/")
    .writeStream
    .option("checkpointLocation", "/Volumes/benchmarking/bronze/landing/_chk/ri")
    .trigger(availableNow=True)
    .toTable("benchmarking.bronze.documentos_ri")
)
