with
    source as (select * from {{ source("procurement_usa", "invoice_headers") }}),

    renamed as (

        select
            invoice_number,
            order_number,
            order_date as invoice_date,
            supplier_id,
            location,
            supplier_invoice,
            loaded_at

        from source
    )

select *
from renamed
