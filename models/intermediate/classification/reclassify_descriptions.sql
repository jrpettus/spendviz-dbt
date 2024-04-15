{{ config(materialized="view") }}

with
    source_data as (
        select
            *,
            {{ is_string_in_category("item_category", var("categories")) }}
            as is_category_valid
        from {{ ref("classify_part_descriptions") }}
    )

select *, is_category_valid
from source_data
