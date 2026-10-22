-- Passo 9: camada gold (o Power BI lê apenas este schema)

-- Saldo e market share por porte e modalidade
CREATE OR REPLACE TABLE benchmarking.gold.pj_carteira_porte AS
SELECT
  c.data_base,
  p.nome_painel,
  p.tipo,
  c.porte,
  SUM(c.saldo) AS saldo,
  SUM(c.saldo) / SUM(SUM(c.saldo)) OVER (PARTITION BY c.data_base, c.porte) AS share
FROM benchmarking.silver.fato_carteira_pj c
JOIN benchmarking.silver.dim_players p USING (cnpj8)
GROUP BY c.data_base, p.nome_painel, p.tipo, c.porte;

-- Taxas PJ por banco e modalidade
CREATE OR REPLACE TABLE benchmarking.gold.pj_taxas AS
SELECT nome_painel, tipo, modalidade, inicio_periodo, fim_periodo, taxa_am, taxa_aa
FROM benchmarking.silver.taxas_pj;

-- Demais tabelas gold previstas:
--   gold.pj_reclamacoes  (índice e posição por banco, trimestral)
--   gold.pj_mercado      (inadimplência e juros médios PJ, SGS, mensal)
--   gold.pj_destaques    (estratégia e números de RI aprovados, com fonte)
--   gold.pj_insights     (ver 10_insights.sql)
