with
    source as (select * from {{ source("procurement_usa", "locations") }}),

    renamed as (select * from source)

select *
from renamed
