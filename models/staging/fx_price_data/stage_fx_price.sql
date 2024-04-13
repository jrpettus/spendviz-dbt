with
    source as (

        select *
        from {{ source("fx_price_data", "sample_fx_view") }}
        where "Symbol" = 'USDEUR'
        limit 10

    ),

    renamed as (

        select

            "Symbol" as symbol,
            to_date("Date") as fx_date,
            "FixingTime" as fixing_time,
            "Open" as open_price,
            "High" as high_price,
            "Low" as low_price,
            "Close" as close_price,

        from source

    )

select *
from renamed
