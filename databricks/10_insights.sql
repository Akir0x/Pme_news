-- Passo 10: geração trimestral de insights (revisados pelo consultor antes de publicar)
-- Lentes: escala x crescimento, preço x risco, relacionamento x crédito, mudança de rota.
CREATE TABLE IF NOT EXISTS benchmarking.gold.pj_insights (
  gerado_em DATE,
  insights STRING,
  status_revisao STRING
);

INSERT INTO benchmarking.gold.pj_insights
SELECT
  current_date() AS gerado_em,
  ai_query(
    'endpoint-llm-homologado',
    CONCAT(
      'Compare o trimestre atual com o anterior para cada player no segmento PJ. ',
      'Liste ate 5 movimentos relevantes com o numero que comprova cada um e ',
      'o que significa para o nosso banco. Separe fato (com fonte) de interpretacao. ',
      to_json(collect_list(struct(*)))
    )
  ) AS insights,
  'pendente' AS status_revisao
FROM benchmarking.gold.vw_comparativo_trimestre;
