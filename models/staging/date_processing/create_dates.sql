with
    date_series as (
    {{ dbt_date.get_base_dates(start_date="2019-01-01", end_date="2025-01-01") }}
    )

select *,
    date(date_day) as date_ymd
from date_series