with
    source as (select * from {{ source("procurement_france", "order_headers") }}),

    renamed as (select * from source)

select *
from renamed
