{% docs __overview__ %}

# LLM-Powered Workflows with Snowflake & dbt

This project shows and end-to-end example of a procurement-themed business case for a luxury resort company, which has resort properties across the USA and now in France.

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


![cortex_complete](assets/cortex_complete.png "Cortex Complete")

{% enddocs %}
