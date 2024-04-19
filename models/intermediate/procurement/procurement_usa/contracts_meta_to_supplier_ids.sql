with
    contracts as (select * from {{ ref("stg_contracts_meta") }}),
    suppliers as (select * from {{ ref("stg_suppliers") }}),

    merged as (select supplier_id, contracts.* from contracts left join suppliers on suppliers.supplier = contracts.supplier_name)

select *
from merged
