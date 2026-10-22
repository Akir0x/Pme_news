# PME News — Benchmarking PJ de bancos e entrantes

Painel de benchmarking do segmento **Pessoa Jurídica (PMEs)** para a área de consultoria: compara incumbentes (Itaú, Bradesco, Banco do Brasil, Santander, BTG) e entrantes digitais (Nubank, Inter, Mercado Pago, PagBank, C6) usando dados públicos do Banco Central, divulgações de RI e imprensa, com insights gerados por IA e revisados por consultores.

## Conteúdo

| Pasta | O que tem |
|---|---|
| `dashboard/` | Protótipo executivo em HTML (abre direto no navegador), com dados públicos reais de 2025 a out/2026 |
| `docs/` | Especificação completa do painel: fontes, indicadores, arquitetura, classificação das fontes por permissão de coleta e passo a passo no Databricks |
| `databricks/` | Scripts SQL e Python do pipeline (bronze, silver, gold) para rodar no Databricks |
| `data/` | Amostra dos dados usados no protótipo, com período e fonte de cada número |

## Como ver o protótipo

Abra `dashboard/painel-benchmarking-pj.html` no navegador. O arquivo é autocontido.

## Arquitetura (resumo)

1. **Fontes:** APIs do Banco Central (taxas por instituição, IF.data, SGS, ranking de reclamações), dados abertos da CVM, PDFs de RI e notícias (RSS).
2. **Ingestão:** jobs no Databricks para as APIs; Power Automate deposita PDFs e notícias no volume `landing`, lidos via Auto Loader.
3. **Camadas:** `bronze` (dado bruto) → `silver` (padronizado, extração por IA e revisão humana) → `gold` (tabelas do painel e dos insights).
4. **Consumo:** Power BI conectado ao SQL Warehouse, lendo só o schema `gold`.

Detalhes e ordem de execução em [`docs/especificacao-painel-benchmarking.md`](docs/especificacao-painel-benchmarking.md).

## Antes de rodar o pipeline

- Confirmar na primeira chamada de cada API os nomes de campos, o código do relatório de carteira PJ por porte no IF.data e os códigos das séries do SGS.
- Conferir os CNPJs do cadastro de players (`databricks/01_dim_players.sql`) e incluir o nosso banco.
- Validar com jurídico e compliance a classificação das fontes (seção 7 da especificação).
- Usar apenas o endpoint de LLM homologado pela empresa nas chamadas `ai_query`.

## Observações

- Dados do protótipo são públicos e têm períodos diferentes por player; no painel automatizado o IF.data padroniza tudo no mesmo trimestre.
- Os insights são interpretação da consultoria a partir de dados públicos e devem ser validados com dados internos antes de virar recomendação.
