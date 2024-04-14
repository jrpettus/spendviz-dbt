with
    invoice_headers as (select * from {{ ref("stg_invoice_headers") }}),

    invoice_lines as (select * from {{ ref("stg_invoice_lines") }}),

    order_lines as (select * from {{ ref("stg_order_lines") }}),

    order_headers as (select * from {{ ref("stg_order_headers") }}),

    merged as (
        select
            invoice_headers.invoice_number,
            invoice_headers.order_number,
            invoice_headers.location,
            invoice_headers.invoice_date,
            invoice_headers.supplier_invoice,
            order_headers.supplier_id,
            order_headers.order_date,
            invoice_lines.order_line_number,
            order_lines.item_number,
            invoice_lines.supplier_part,
            invoice_lines.description,
            invoice_lines.invoice_price,
            order_lines.order_price,
            invoice_lines.invoice_quantity,
            order_lines.order_quantity,
            invoice_lines.invoice_amount,
            order_lines.is_contracted_item,
            greatest(datediff(day, order_date, invoice_date),0) as order_lead_time,
            invoice_price - order_price as invoice_price_variance

        from invoice_lines
        left join
            invoice_headers
            on invoice_headers.invoice_number = invoice_lines.invoice_number
        left join
            order_headers
            on order_headers.order_number = invoice_headers.order_number
        left join
            order_lines
            on order_lines.order_number = order_headers.order_number and order_lines.order_line_number = invoice_lines.order_line_number
    )

select *
from merged
