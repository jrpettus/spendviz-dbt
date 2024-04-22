{% macro convert_euro_to_usd(euro_amount, usdeur_rate) %}

    -- converting EUR to USD
     ({{ euro_amount }} * (1 / {{ usdeur_rate }}))

{% endmacro %}
