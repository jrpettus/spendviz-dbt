USE WAREHOUSE procure_warehouse;

USE ROLE procure_role;

-- See the results of Cortex for translating
SELECT *
FROM procure_agent.dbt_rpettus.int_translate_part_descriptions
LIMIT 50;

-- See the results of Cortex for classification task
SELECT *
FROM procure_agent.dbt_rpettus.int_classify_part_descriptions
LIMIT 50;

-- See the results of consolidated invoice lines
SELECT *
FROM procure_agent.dbt_rpettus.int_consolidated_invoice_orders
WHERE COUNTRY_ORIGIN = 'FRANCE'
LIMIT 50;

--
SELECT *
FROM procure_agent.dbt_rpettus.int_contracts_extract_terms;

-- overall fact table
SELECT *
FROM procure_agent.dbt_rpettus.fct_invoice_order_lines
LIMIT 50;

-- supplier metrics
SELECT *
FROM procure_agent.dbt_rpettus.supplier_metrics
WHERE has_contract = TRUE --payment_terms is not null
ORDER BY total_spend DESC
LIMIT 50;

-- supplier metrics
SELECT *
FROM procure_agent.dbt_rpettus.supplier_metrics
where has_contract = TRUE 
LIMIT 50;

