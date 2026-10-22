-- Passo 1: cadastro de players. O CNPJ-8 é a chave usada pelo Banco Central.
-- Conferir CNPJs e códigos de conglomerado no IfDataCadastro e incluir o nosso banco.
CREATE TABLE IF NOT EXISTS benchmarking.silver.dim_players (
  cnpj8 STRING,
  nome_painel STRING,
  conglomerado STRING,
  tipo STRING,      -- 'incumbente' ou 'entrante'
  ativo BOOLEAN
);

INSERT INTO benchmarking.silver.dim_players VALUES
 ('60701190','Itaú','Itaú Unibanco','incumbente',true),
 ('60746948','Bradesco','Bradesco','incumbente',true),
 ('00000000','Banco do Brasil','BB','incumbente',true),
 ('90400888','Santander','Santander','incumbente',true),
 ('30306294','BTG Pactual','BTG Pactual','incumbente',true),
 ('18236120','Nubank','Nu','entrante',true),
 ('00416968','Inter','Inter','entrante',true),
 ('10573521','Mercado Pago','Mercado Pago','entrante',true),
 ('08561701','PagBank','PagSeguro','entrante',true),
 ('31872495','C6 Bank','C6','entrante',true);
