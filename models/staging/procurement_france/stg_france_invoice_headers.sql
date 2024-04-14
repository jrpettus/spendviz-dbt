with
    source as (select * from {{ source("procurement_france", "invoice_headers") }}),

    renamed as (select * from source)

select *
from renamed
