{{
    config(
        materialized="incremental",
        unique_key="metadata_content_key",
        tags=["cortex_enabled"],
    )
}}

with
    contracts as (select * from {{ ref("int_contracts_meta_to_supplier_ids") }}),

    -- load the contract if it isn't there yet
    processed as (
        select *, procure_agent.public.load_documents(file_name) as contract_load_status,
        current_timestamp() as processed_at
        from contracts
    )

select *
from processed
{% if is_incremental() %}
    where metadata_last_modified > (select max(metadata_last_modified) from {{ this }})
{% endif %}
