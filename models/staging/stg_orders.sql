-- models/staging/stg_orders.sql
with raw as (
    select *
    from {{ source('instacart_raw', 'orders') }}
)
select
    order_id,
    user_id as customer_id,           -- Renamed for clarity
    order_number as order_sequence,   -- Sequence number of the order for a customer
    order_dow as order_day_of_week,
    order_hour_of_day,
    days_since_prior_order
from raw
