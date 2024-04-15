with
    source as (select * from {{ source("procurement_usa", "suppliers") }}),

    renamed as (
        select
            supplier_id,
            trim(supplier) as supplier,
            primary_category,
            country,
            address,
            phone_number,
            loaded_at
        from source
    )

select *
from renamed
