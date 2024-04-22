with
    invoice_details as (
        select * from {{ ref("int_fr_invoice_to_order_details") }}
    ),

    fx_rates as (select * from {{ ref("int_fill_fx_data") }}),

    converted as (
        select
            invoice_details.*,
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
