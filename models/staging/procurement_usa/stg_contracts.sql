with
    source as (select * from {{ source("procurement_usa", "contracts") }}),

    renamed as (select supplier_id, supplier, contract_name from source)

select *
from renamed
