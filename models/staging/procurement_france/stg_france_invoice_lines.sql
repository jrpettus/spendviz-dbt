with
    source as (select * from {{ source("procurement_france", "invoice_lines") }}),

    renamed as (

        select

            invoice_number,
            order_number,
            order_line_number,
            supplier_part,
            description,
            round(price, 2) as invoice_price,
            quantity as invoice_quanity,
            round(amount,2) as invoice_amount,
            loaded_at

        from source

    )

select *
from renamed
