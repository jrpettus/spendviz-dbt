{{
    config(
        materialized="incremental",
        unique_key="proxy_part_id",
        tags=["cortex_enabled"],
    )
}}

{% set category_list = var("categories") %}
{% set formatted_categories = category_list | map("string") | join(", ") %}

with
    parts_us as (select * from {{ ref("int_unique_order_parts") }}),
    parts_fr as (
        select
            proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description_translated as description,
            first_invoice_loaded_at

        from {{ ref("int_translate_part_descriptions") }}
    ),

    merged as (
        select *
        from parts_us
        union all
        (select * 
        from parts_fr)
    ),

    classified as (
        select
            proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description,
            first_invoice_loaded_at,
            snowflake.cortex.complete(
                'mixtral-8x7b',  -- mistral-7b
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
                    
                    Examples:
                    Erasers premium 50 units - Office Supplies
                    Hot Beverage Machine - Food & Beverage Equipment
                    Eco-Friendly Cleaning Supplies - Operating Supplies

                    {description}
                    RESPONSE:',
                    description
                )
            ) as item_category,
            {{ check_if_category_else_other("item_category") }}
            as item_category_or_other

        from merged

    )

select *
from classified
{% if is_incremental() %}
    where
        first_invoice_loaded_at > (select max(first_invoice_loaded_at) from {{ this }})
{% endif %}
