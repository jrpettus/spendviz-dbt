with
    source as (select * from {{ source("procurement_france", "order_lines") }}),

    renamed as (

        select

            order_number,
            order_line_number,
            item_number,
            case
                when item_number is null then false else true
            end as is_contracted_item,
            supplier_part,
            description,
            round(price, 2) as order_price,
            quantity,
            round(amount, 2) as order_amt,
            loaded_at

        from source

    )

select *
from renamed
