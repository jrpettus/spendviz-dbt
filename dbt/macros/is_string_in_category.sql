{% macro is_string_in_category(model, column_name, category_list) %}

    -- Returns true if the category is valid, false otherwise (for use within SELECT)
    case
        when
            {{ column_name }} is not null
            and {{ column_name }} not in (
                {% for category in category_list %}
                    {{ "'" ~ category ~ "'" }}{{ "," if not loop.last }}
                {% endfor %}
            )
        then false
        else true
    end

{% endmacro %}
