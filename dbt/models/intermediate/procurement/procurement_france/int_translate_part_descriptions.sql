{{ config(materialized="incremental", unique_key="proxy_part_id", tags=["cortex_enabled"]) }}

with
    parts as (select * from {{ ref("int_fr_unique_order_parts") }}),

    classified as (
        select
            proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description,
            first_invoice_loaded_at,
            snowflake.cortex.translate(
                description, 'fr', 'en'
            ) as description_translated
        from parts
    )

select *
from classified
{% if is_incremental() %}
    where first_invoice_loaded_at > (select max(first_invoice_loaded_at) from {{ this }})
{% endif %}
