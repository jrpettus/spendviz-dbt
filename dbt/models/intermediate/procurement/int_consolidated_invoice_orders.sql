with
    france_invoice_details as (
        select * from {{ ref("int_convert_fr_invoice_details_to_usd") }}
    ),
    us_invoice_details as (select * from {{ ref("int_invoice_to_order_details") }}),
    categorized_items as (select * from {{ ref("int_classify_part_descriptions") }}),

    combined as (
        select *
        from france_invoice_details
        union all
        (select * from us_invoice_details)
    ),

    categorized as (
        select 
            combined.*,
            categorized_items.description as description_english,
            item_category,
            item_category_or_other
        from combined
        left join
            categorized_items
            on combined.supplier_id = categorized_items.supplier_id
            and combined.supplier_part = categorized_items.supplier_part
    )

select *
from categorized
