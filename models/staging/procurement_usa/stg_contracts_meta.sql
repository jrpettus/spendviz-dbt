with
    source as (select * from {{ source("procurement_contracts", "contracts_meta") }}),

    renamed as (select * from source)

select *
from renamed