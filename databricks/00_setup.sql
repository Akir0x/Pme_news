-- Passo 0: catálogo, camadas e volume de entrada no Unity Catalog
CREATE CATALOG IF NOT EXISTS benchmarking;
CREATE SCHEMA IF NOT EXISTS benchmarking.bronze;
CREATE SCHEMA IF NOT EXISTS benchmarking.silver;
CREATE SCHEMA IF NOT EXISTS benchmarking.gold;
CREATE VOLUME IF NOT EXISTS benchmarking.bronze.landing;

-- Pré-requisitos fora do SQL:
-- * Liberar saída de rede do workspace para olinda.bcb.gov.br, api.bcb.gov.br e dados.cvm.gov.br
-- * Guardar credenciais (ex.: conta de serviço do SharePoint) em um secret scope
-- * Criar um SQL Warehouse para o Power BI
