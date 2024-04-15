with
    order_details as (select * from {{ ref("int_fr_invoice_to_order_details") }}),

    grouped as (
        select
            {{
                dbt_utils.generate_surrogate_key(
                    ["supplier_id", "supplier_part", "item_number"]
                )
            }} as proxy_part_id, supplier_id, supplier_part, item_number, description,

        from order_details
        qualify
            row_number() over (
                partition by supplier_id, supplier_part, item_number
                order by order_date desc
            )
            = 1

    )

select *
from grouped
