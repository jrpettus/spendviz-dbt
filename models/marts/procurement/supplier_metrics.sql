with
    invoice_lines as (select * from {{ ref("int_consolidated_invoice_orders") }}),
    suppliers as (select * from {{ ref("int_consolidated_suppliers") }}),

    metrics_by_supplier as (
        select
            supplier_id,
            round(sum(invoice_amount_usd),2) as total_spend,
            sum(case when is_contracted_item then 1 else 0 end) as total_catalog_spend,
            min(invoice_date) as first_invoice_date,
            max(invoice_date) as most_recent_invoice_date,
            count(1) as invoice_line_count,
            sum(case when is_contracted_item = true then invoice_amount_usd else 0 end)
            / total_spend as catalog_spend_rate,
            sum(case when is_contracted_item = true then 1 else 0 end)
            / invoice_line_count as catalog_transaction_rate
        from invoice_lines
        group by supplier_id
    ),

    top_category_by_supplier as (
        select
            supplier_id,
            item_category_or_other,
            sum(invoice_amount_usd) as category_spend
        from invoice_lines
        group by supplier_id, item_category_or_other
        qualify
            row_number() over (
                partition by supplier_id order by sum(invoice_amount_usd) desc
            )
            = 1
        order by category_spend desc
    ),

    merged as (
        select
            metrics_by_supplier.supplier_id,
            supplier,
            primary_category,
            total_spend,
            first_invoice_date,
            most_recent_invoice_date,
            invoice_line_count,
            catalog_spend_rate,
            catalog_transaction_rate,
            top_category_by_supplier.item_category_or_other as top_category
        from metrics_by_supplier
        inner join suppliers on suppliers.supplier_id = metrics_by_supplier.supplier_id
        left join
            top_category_by_supplier
            on suppliers.supplier_id = top_category_by_supplier.supplier_id
    )

select *
from merged
where top_category is not null
