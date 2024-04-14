with
    source as (select * from {{ source("procurement_usa", "items") }}),

    renamed as (select * from source)

select *
from renamed
