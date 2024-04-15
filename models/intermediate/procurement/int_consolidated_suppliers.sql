with
    us_suppliers as (select * from {{ ref("stg_suppliers") }}),
    fr_suppliers as (select * from {{ ref("stg_france_suppliers") }}),

    combined as (
        select *
        from us_suppliers
        union all
        (select * from fr_suppliers)
    )

select *
from combined
