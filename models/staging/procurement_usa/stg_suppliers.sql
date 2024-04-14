with
    source as (select * from {{ source("procurement_usa", "suppliers") }}),

    renamed as (select * from source)

select *
from renamed
