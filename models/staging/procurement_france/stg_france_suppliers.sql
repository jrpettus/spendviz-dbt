with
    source as (select * from {{ source("procurement_france", "suppliers") }}),

    renamed as (select * from source)

select *
from renamed
