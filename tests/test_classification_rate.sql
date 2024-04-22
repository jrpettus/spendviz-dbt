{{ config(severity = 'warn') }}

-- Custom test to check percentage of 'other' items
with
    calculated_values as (
        select
            count(*) as total_count,
            count(case when item_category_or_other = 'other' then 1 end) as other_count,
            100.0
            * count(case when item_category_or_other = 'other' then 1 end)
            / count(*) as percentage_other
        from {{ ref('int_classify_part_descriptions') }}
    )

select percentage_other
from calculated_values
where percentage_other > 20  
