{% macro check_if_category_else_other(column_name) %}

    case
        when
            lower(trim({{ column_name }})) in (
                -- Use Jinja to convert the list into a properly formatted SQL string
                '{{ var("categories") | map("trim") | map("lower") | join("', '") }}'
            )
        then trim({{ column_name }})
        else 'Other'
    end
{% endmacro %}
