-- models/intermediate/int_order_details.sql
with orders as (
    select * from {{ ref('stg_orders') }}
),
items as (
    select * from {{ ref('stg_order_products') }}
),
prod as (
    select * from {{ ref('stg_products') }}
)
select
    o.order_id,
    o.customer_id,
    o.order_sequence,
    o.order_day_of_week,
    o.order_hour_of_day,
    o.days_since_prior_order,
    i.product_id,
    p.product_name,
    p.department_name,
    p.aisle_name,
    i.add_to_cart_order,
    i.reordered
from orders o
join items i on o.order_id = i.order_id
left join prod p on i.product_id = p.product_id
