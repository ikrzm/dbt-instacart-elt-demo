-- models/marts/fct_department_sales.sql
select
    department_name,
    count(distinct order_id) as orders_count,
    count(*) as total_items_sold,
    count(distinct customer_id) as customers_count,
    count(*) * 1.0 / count(distinct order_id) as avg_items_per_order
from {{ ref('int_order_details') }}
group by department_name
