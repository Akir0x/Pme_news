# Especificação — Painel de Benchmarking de Bancos

Painel automático e visual que compara os principais bancos do mercado, por segmento de atuação, usando dados públicos do Banco Central e relatórios de RI, com resumos gerados por IA. Foco atual: segmento **Pessoa Jurídica (PMEs)**.

> Versão viva e editável: https://claude.ai/artifact/61q8AyRv31z4raFSPgvNEe
> Protótipo executivo: [`../dashboard/painel-benchmarking-pj.html`](../dashboard/painel-benchmarking-pj.html)

## Simulação com dados reais — 2T26 (abr–jun 2026)

| Banco | Lucro recorrente 2T26 | ROE 2T26 |
|---|---|---|
| Itaú Unibanco | R$ 12,4 bi | 24,3% |
| Bradesco | R$ 7,05 bi | 16,2% |
| Santander Brasil | R$ 3,0 bi | 12,5% (ROAE) |
| Banco do Brasil | R$ 3,9 bi (ajustado) | 8,3% (ROAE) |

Fontes: [Peers — Resultados dos bancos no 2T26](https://peers.com.br/resultados-dos-bancos-no-2t26-e-o-impacto-na-rentabilidade/) · [Seu Dinheiro — Bradesco 2T26](https://www.seudinheiro.com/2026/empresas/bradesco-bbdc4-balanco-2t26-lucro-resultado-rentabilidade-roe-miql/) · [InfoMoney — BB 2T26](https://www.infomoney.com.br/mercados/banco-do-brasil-bbas3-resultados-segundo-trimestre-2026/)

### Painel com dados reais — Pessoa Jurídica

Simulação focada em PJ, com incumbentes e entrantes digitais (Nubank, Inter, BTG, Mercado Pago, PagBank): carteira de PMEs por banco, base de clientes PJ dos entrantes, inadimplência e juros do mercado PJ, ranking de reclamações e destaques de estratégia. Os dados ficam em [`../data/players_pj_amostra.csv`](../data/players_pj_amostra.csv) e o visual no protótipo HTML. Os períodos variam por banco (1T26 ou 2T26); no painel real, a API do Banco Central padroniza tudo no mesmo trimestre.

## 1. Objetivo

- Acompanhar participação de mercado, preço e qualidade de atendimento dos concorrentes em cada segmento.
- Atualizar o painel automaticamente, sem trabalho manual.
- Disponibilizar o painel para toda a área, com filtros por banco, segmento e período.

## 2. Fontes de dados

| Fonte | O que traz | Frequência |
|---|---|---|
| IF.data | Balanço, carteira de crédito por modalidade, PF/PJ, porte de cliente, captação, lucro, Basileia, agências, clientes | Trimestral |
| Taxas de juros por instituição | Taxa praticada por modalidade de crédito e por banco | Semanal |
| Tarifas bancárias | Valores de tarifas e pacotes por instituição | Conforme atualização |
| Ranking de reclamações | Reclamações procedentes e índice por instituição | Trimestral |
| Relatórios de RI (PDF) | Guidance, estratégia, destaques por segmento | Trimestral |
| Notícias | Lançamentos, movimentos estratégicos | Diária/semanal |

## 3. Indicadores do painel

### Participação de mercado
- Market share da carteira de crédito por modalidade e porte.
- Evolução trimestral da carteira PF e PJ.
- Crescimento anual por segmento comparado ao mercado.

### Preço
- Taxa média por modalidade, banco a banco (capital de giro, desconto de duplicatas, conta garantida).
- Comparativo de tarifas e pacotes.

### Solidez e escala
- Lucro líquido, ROE e índice de Basileia.
- Captação total, número de clientes e agências.

### Qualidade
- Posição no ranking de reclamações e evolução do índice.

### Inteligência (IA)
- Resumo trimestral do que mudou em cada concorrente.
- Alertas de variações relevantes (ex.: queda de taxa ou ganho de share acima de um limite).

### Estratégia e divulgações dos concorrentes (IA)

| Fonte | O que revela | Como extrair |
|---|---|---|
| Teleconferências e cartas da administração (RI) | Prioridades, metas e segmentos em foco | Alerta de e-mail do RI dispara o fluxo; IA resume |
| Fatos relevantes (CVM e RI) | Aquisições, parcerias, reestruturações | Dados abertos da CVM (IPE) |
| Notícias do setor | Lançamentos e campanhas | Feeds RSS ou Google Alerts |
| Atualizações dos apps | Funcionalidades digitais | Serviço licenciado ou consulta manual (sem raspagem das lojas) |
| Vagas | Áreas e tecnologias em que o banco investe | Alertas de vaga por e-mail; sem coleta automática no LinkedIn |
| Formulário de Referência (CVM) | Estratégia, riscos e prioridades declaradas | Download anual; IA compara com o ano anterior |
| Relatórios anuais e Investor Days | Metas de médio prazo | Download nos sites de RI; IA extrai metas por segmento |
| Relatórios de corretoras | Leitura externa | Somente dentro da licença da área |
| APIs públicas do Open Finance | Produtos, taxas e tarifas padronizados | Job agendado chamando as APIs |
| Biblioteca de Anúncios da Meta | Campanhas e públicos em foco | Somente pela API oficial |
| Reclame Aqui | Reação dos clientes | Consulta manual |
| Eventos (ex.: Febraban Tech) e posts de executivos | Direção estratégica | Acompanhamento manual ou alertas |

## 4. Arquitetura

### 4.1 Extração
- APIs públicas: jobs agendados no Databricks, chamando as APIs do Banco Central direto dos notebooks.
- PDFs de RI e notícias: o Power Automate deposita os arquivos no volume `landing` para o Databricks ler.
- Um agente de IA lê os PDFs e extrai números e destaques num formato padrão.

### 4.2 Armazenamento
- Base única com histórico no Databricks (Delta Lake e Unity Catalog), nas camadas bronze, silver e gold.
- Chave comum: CNPJ-8 da instituição + data de referência.

### 4.3 Tratamento
- Padronizar nomes de bancos e conglomerados.
- Calcular market share e variações na camada gold.

### 4.4 Visualização
- Power BI conectado ao SQL Warehouse, lendo só o schema `gold`, com atualização agendada.
- Páginas: visão geral PJ, carteira por porte, taxas, qualidade, entrantes, insights.
- Publicado no workspace da área com acesso controlado.

## 5. Etapas de implementação

1. Definir a lista de bancos e de segmentos prioritários.
2. Testar as APIs e mapear os campos de cada fonte.
3. Criar o catálogo e as tabelas no Databricks.
4. Construir os jobs de extração e agendar.
5. Montar o painel no Power BI.
6. Adicionar a camada de IA (resumos e alertas).
7. Validar com a área e ajustar.

## 6. Pontos de atenção

- Defasagem: o IF.data é trimestral e sai com 2 a 3 meses de atraso; deixar a data de referência visível no painel.
- Mudanças de layout das APIs podem quebrar os jobs; configurar alertas de falha.
- Conferir com compliance o uso de dados públicos, de fontes de notícias e da ferramenta de IA homologada.
- Licenças: Power BI Pro ou Premium/Fabric para compartilhar com a área.

## 7. Classificação das fontes por permissão de coleta

O projeto usa apenas fontes cuja coleta é permitida; nada de raspagem onde os termos proíbem. Classificação preliminar — o jurídico deve validar antes da implementação.

| Fonte | Classificação | Como usar |
|---|---|---|
| APIs do Banco Central (IF.data, taxas, tarifas, reclamações) | Permitida | Dados abertos oficiais via API |
| Dados abertos da CVM | Permitida | Portal de dados abertos da CVM |
| APIs públicas do Open Finance | Permitida | APIs oficiais e padronizadas |
| Biblioteca de Anúncios da Meta | Permitida | Somente pela API oficial |
| Alertas de e-mail de RI, Google Alerts e RSS | Permitida | Assinatura dos alertas e feeds |
| PDFs públicos dos sites de RI | Permitida com cuidado | Checar termos de cada site |
| Notícias via RSS | Permitida com cuidado | Ler e resumir para uso interno; não reproduzir matérias inteiras |
| LinkedIn (vagas e posts) | Evitar coleta automática | Acompanhamento manual ou alertas por e-mail |
| Reclame Aqui | Evitar coleta automática | Consulta manual |
| App Store e Google Play | Evitar coleta automática | Serviço licenciado ou consulta manual |
| Relatórios de corretoras | Somente dentro da licença | Sem redistribuição |

## 8. Passo a passo de implementação no Databricks

A ingestão roda em três camadas: o **bronze** guarda o dado bruto de cada fonte, o **silver** padroniza e revisa, e o **gold** entrega as tabelas do painel e dos insights. O Power BI lê só o gold.

```
APIs Banco Central ─┐
Dados abertos CVM ──┤                                   ┌─► Power BI (área)
PDFs de RI (PA) ────┼─► Bronze ─► Silver ─► Gold ───────┤
Notícias RSS (PA) ──┘    bruto    padroniza  painel e   └─► Insights IA (trimestral)
                                  IA + revisão  insights
```

Endpoints e nomes de campos devem ser conferidos na primeira chamada de cada API.

| Passo | O que fazer | Script |
|---|---|---|
| 0 | Catálogo `benchmarking`, schemas bronze/silver/gold, volume `landing`; liberar rede para `olinda.bcb.gov.br`, `api.bcb.gov.br` e `dados.cvm.gov.br`; secret scope; SQL Warehouse | [`00_setup.sql`](../databricks/00_setup.sql) |
| 1 | Cadastro de players pelo CNPJ-8 (incluir o nosso banco) | [`01_dim_players.sql`](../databricks/01_dim_players.sql) |
| 2 | Taxas de juros PJ por banco, API `taxaJuros` (semanal) | [`02_ingest_taxas_juros.py`](../databricks/02_ingest_taxas_juros.py) |
| 3 | Carteira PJ por porte, API `IFDATA` (trimestral): `ListaDeRelatorio`, `IfDataCadastro`, `IfDataValores` | [`03_ingest_ifdata.py`](../databricks/03_ingest_ifdata.py) |
| 4 | Ranking de reclamações, portal de dados abertos do Banco Central (trimestral) | — |
| 5 | Indicadores de mercado, SGS: `api.bcb.gov.br/dados/serie/bcdata.sgs.{codigo}/dados?formato=json` (mensal); códigos em `silver.dim_series_sgs` | — |
| 6 | Fatos relevantes, dados abertos da CVM (IPE, diário); Nubank, Inter e PagBank listados nos EUA vão pelo passo 7 | — |
| 7 | PDFs de RI e notícias: Power Automate → volume `landing` → Auto Loader → extração com `ai_query` | [`07_autoloader_documentos_ri.py`](../databricks/07_autoloader_documentos_ri.py), [`07_extracao_ia.sql`](../databricks/07_extracao_ia.sql) |
| 8 | Qualidade: taxa entre 0% e 20% a.m., saldo não negativo, variação trimestral > 30% gera alerta; fila de revisão humana, só `aprovado` vai ao gold | — |
| 9 | Camada gold: `pj_taxas`, `pj_carteira_porte`, `pj_reclamacoes`, `pj_mercado`, `pj_destaques`, `pj_insights` | [`09_gold.sql`](../databricks/09_gold.sql) |
| 10 | Insights trimestrais com quatro lentes (escala x crescimento, preço x risco, relacionamento x crédito, mudança de rota), revisados pelo consultor | [`10_insights.sql`](../databricks/10_insights.sql) |
| 11 | Orquestração no Databricks Workflows (tabela abaixo), com e-mail em caso de falha | — |
| 12 | Power BI no SQL Warehouse, modo Import com atualização após os jobs | — |
| 13 | Monitoramento: alerta de dado desatualizado, revisão mensal dos endpoints, clusters com desligamento automático | — |

### Orquestração (Databricks Workflows)

| Job | Passos | Frequência |
|---|---|---|
| `bcb_taxas_semanal` | 2 → silver → gold | Toda segunda, 7h |
| `bcb_trimestral` | 3, 4 → silver → gold | Toda segunda; só grava se houver trimestre novo |
| `bcb_sgs_mensal` | 5 → silver → gold | Dia 5 de cada mês |
| `documentos_diario` | 6, 7 → extração IA → fila de revisão | Todo dia, 6h |
| `insights_trimestral` | 10 | Após o IF.data novo e a revisão |
