with
    invoice_details as (
        select * from {{ ref("int_fr_invoice_to_order_details") }}
    ),

    fx_rates as (select * from {{ ref("int_fill_fx_data") }}),

    converted as (
        select
            country_origin,
            invoice_number,
            order_number,
            location,
            invoice_date,
            supplier_invoice,
            supplier_id,
            order_date,
            order_line_number,
            item_number,
            supplier_part,
            description,
            invoice_price,
            invoice_quantity,
            invoice_amount,
            is_contracted_item,
            order_lead_time,
            invoice_price_variance,
            invoice_loaded_at,
            fx_average_price_adj as currency_conversion,
            round(
                {{ convert_euro_to_usd("invoice_price", "fx_average_price_adj") }}, 2
            ) as invoice_price_usd,
            round(
                {{ convert_euro_to_usd("invoice_amount", "fx_average_price_adj") }}, 2
            ) as invoice_amount_usd

        from invoice_details
        left join fx_rates on fx_rates.date_ymd = invoice_details.invoice_date

    )

select *
from converted
