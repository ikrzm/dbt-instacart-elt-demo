-- models/marts/fct_customer_orders.sql
select
    customer_id,
    count(distinct order_id) as total_orders,
    count(*) as total_items,
    count(*) * 1.0 / count(distinct order_id) as avg_items_per_order,
    min(order_sequence) as first_order_number,
    max(order_sequence) as last_order_number,
    max(order_id) as last_order_id,
    case when count(distinct order_id) = 1 then 1 else 0 end as is_new_customer
from {{ ref('int_order_details') }}
group by customer_id