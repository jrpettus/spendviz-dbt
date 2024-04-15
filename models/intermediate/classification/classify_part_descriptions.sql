{{ config(materialized="incremental", unique_key="proxy_part_id") }}

{% set category_list = var("categories") %}
{% set formatted_categories = category_list | map("string") | join(", ") %}

with
    parts as (select * from {{ ref("int_unique_order_parts") }} limit 10),

    classified as (
        select
            proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description,
            snowflake.cortex.complete(
                'mistral-7b',
                concat(
                    '
                    You are an expert in classifying invoice descriptions into procurement spend categories.
                    Classify the below description into ONE and ONLY ONE of these categories for downstream reporting 
                    matching these categories exactly
                    ## CATEGORY LIST:
                    ',
                    '{{ formatted_categories }}',
                    '
                    ## FINAL INSTRUCTIONS
                    DO NOT INCLUDE YOUR REASONING EXTRA NOTES, OR PERIODS OR OTHER PUNCTUATION NOT IN THE LIST 
                    JUST SIMPLY PROVIDE THE CATEGORY AND NOTHING ELSE!!!

                    {description}
                    RESPONSE:',
                    description
                )
            ) as item_category

        from parts
    -- where item_category IS NULL
    )

select *
from classified
{% if is_incremental() %}
    where
        proxy_part_id
        not in (select proxy_part_id from {{ this }} where item_category is not null)
{% endif %}
