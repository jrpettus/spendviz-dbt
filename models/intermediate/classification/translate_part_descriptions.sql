{{ config(materialized="incremental", unique_key="proxy_part_id") }}

with
    parts as (select * from {{ ref("int_fr_unique_order_parts") }} limit 5),

    classified as (
        select
            proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description,
            snowflake.cortex.translate(description,'fr','en') as description_translated
        from parts
    
    )

select *
from classified
{% if is_incremental() %}
    where
        proxy_part_id
        not in (select proxy_part_id from {{ this }} where description_translated is not null)
{% endif %}
