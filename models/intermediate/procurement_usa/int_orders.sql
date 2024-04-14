with
    order_headers as (select * from {{ ref('stg_order_headers') }}),

    order_lines as (select * from {{ ref("stg_order_lines") }}),

    merged as (
        select
            *
        from order_lines
        left join
            order_headers
            on order_headers.order_number = order_lines.order_number
    )

select *
from merged
