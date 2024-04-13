with
    source as (

        select *
        from {{ source("fx_price_data", "sample_fx_view") }}
        where "Symbol" = 'USDEUR'

    ),

    renamed as (

        select

            "Symbol" as symbol,
            to_date("Date") as fx_date,
            "FixingTime" as fixing_time,
            "Open" as fx_open_price,
            "High" as fx_high_price,
            "Low" as fx_low_price,
            "Close" as fx_close_price,
            (fx_high_price + fx_low_price) / 2 as fx_average_price

        from source

    )

select *
from renamed
