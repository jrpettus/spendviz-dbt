with
    source as (select * from {{ source("procurement_usa", "order_headers") }}),

    renamed as (select * from source)

select *
from renamed
