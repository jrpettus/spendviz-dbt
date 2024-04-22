with
    date_series as (select * from {{ ref("create_dates") }}),

    fx_rates as (select * from {{ ref("stg_fx_price") }}),

    adjusted_rates as (
        select
            date_ymd,
            fx_average_price,
            avg(fx_average_price) over (
                order by date_ymd rows between 10 preceding and 10 following
            ) as fx_average_price_rolling,
            coalesce(fx_average_price,fx_average_price_rolling) as fx_average_price_adj
        from date_series
        left join fx_rates on fx_date = date_ymd
    )

select *
from adjusted_rates
