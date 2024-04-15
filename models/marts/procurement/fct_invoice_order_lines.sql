{{ config(materialized="view") }}

with
    invoice_lines as (select * from {{ ref("int_consolidated_invoice_orders") }}),
    --suppliers as (select * from {{ ref("int_consolidated_suppliers") }}),

    combined as (
        select invoice_lines.* --, supplier
        from invoice_lines
        --left join suppliers on suppliers.supplier_id = invoice_lines.supplier_id
    )

select *
from combined
