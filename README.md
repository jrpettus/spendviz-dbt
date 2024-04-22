# LLM-Powered Workflows with Snowflake & dbt

This project is centered on a procurement-themed business case for a luxury resort company, which has resort properties across the USA and now in France. Using dbt & Snowflake, a data pipeline is demonstrated to show how:

- Snowflake Cortex AI features turn text into meaningful insights for supplier management and strategic sourcing
- dbt orchestrates the workflow for efficient processing

## Key Flows

This project contains the following key flows:

1. **Sources** - Procurement source data from different ERP systems is simulated for the USA vs. France plus supplier contracts
2. **Key Intermediate Model Flows**
   1. **Invoice/Order Merging** - Various invoice and order details are merged to create a more holistic view of invoice transactions (US and France processes separated for business reasons)
   2. **Currency Conversion** - France line items are merged with **FX rates** to convert invoice amounts into USD
   3. **Language Translations** - France line item descriptions are ranslated into English **using Cortex**
   4. **Spend Classification** - Line descriptions are classified into spend categories **using Cortex**
   5. **Consolidated US + France Transactions** - Consolidates US and France transactions into a single view
   6. **Contract Vector Database Loading** Contracts are processed using UDF which calls FastAPI application deployed via **Snowpark Container Services**
   7. **Contract Key Term Extraction** Filtered Retrieval Augmented Generation used to provide Cortex context for contract key term Extraction
3. **Marts**
   1. **Invoice order line detail fact table** Provides a wide view of orders for downstream analytics consumption
   1. **Supplier Metrics** Provides a view for every supplier in the system including key metrics and contract terms

## Item Description Translation with Cortex
**Business Value:**
- Downstream users get a single language to power insights using Snowflake Cortex
- Efficient orchestration and prevention of duplicate Cortex processing with incremental models

<img src="https://github.com/jrpettus/spendviz-dbt/blob/main/dbt/assets/Cortex%20Translations.jpg" width=60% height=60% >

## Item Classification with Cortex
**Business Value:**
- Downstream users get classification into spend to power insights using Snowflake Cortex
- Efficient orchestration and prevention of duplicate Cortex processing with incremental models

<img src="https://github.com/jrpettus/spendviz-dbt/blob/main/dbt/assets/Cortex%20Item%20Classification.jpg" width=60% height=60% >

## Vector Database Loading with dbt and Snowflake Container Services
**Business Value:**
- Key concepts from large unstructured documents turned into structured outputs for actionable supplier insights
- dbt efficiently orchestrates the data workflow

<img src="https://github.com/jrpettus/spendviz-dbt/blob/main/dbt/assets/Contract%20Vector%20Database%20Loading.jpg" width=60% height=60% >

## Retrieval Augmented Generation with dbt and Snowflake Container Services
**Business Value:**
- Key concepts from large unstructured documents turned into structured outputs for actionable supplier insights
- dbt efficiently orchestrates the data workflow to facilitate retrieval augmented generation

<img src="https://github.com/jrpettus/spendviz-dbt/blob/main/dbt/assets/RAG.jpg" width=67% height=67% >


