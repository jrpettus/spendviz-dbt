{% macro test_string_length(model, max_length) %}

select *
from {{ model }}
where length(item_category) > {{ max_length }}

{% endmacro %}