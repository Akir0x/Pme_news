-- Passo 7 (silver): extração estruturada com IA.
-- Pré-requisito: benchmarking.silver.documentos_ri_texto (path, texto), gerada com
-- ai_parse_document (se disponível no workspace) ou uma biblioteca de PDF.
-- Usar somente o endpoint de LLM homologado pela empresa.
CREATE OR REPLACE TABLE benchmarking.silver.extracoes_ri AS
SELECT
  path,
  ai_query(
    'endpoint-llm-homologado',
    CONCAT(
      'Leia o documento e retorne JSON com: banco, periodo, ',
      'carteira_pme_rs_bi, crescimento_anual_pct, clientes_pj_mi, ',
      'inadimplencia_pj_pct, destaques_estrategia (ate 3 frases), ',
      'trecho_fonte de cada numero. Use null se nao houver. Nao estime. ',
      texto
    )
  ) AS extracao,
  'pendente' AS status_revisao
FROM benchmarking.silver.documentos_ri_texto;

-- Passo 8: só registros com status_revisao = 'aprovado' seguem para o gold.
