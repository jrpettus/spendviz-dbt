{{ config(materialized="table") }}

with
    order_details as (select * from {{ ref("int_fr_invoice_to_order_details") }}),

    grouped as (
        select
            {{ dbt_utils.generate_surrogate_key(["supplier_id", "supplier_part"]) }}
            as proxy_part_id,
            supplier_id,
            supplier_part,
            item_number,
            description,
            invoice_loaded_at as first_invoice_loaded_at

        from order_details
        qualify
            row_number() over (
                partition by supplier_id, supplier_part order by invoice_loaded_at asc
            )
            = 1

    )

select *
from grouped
