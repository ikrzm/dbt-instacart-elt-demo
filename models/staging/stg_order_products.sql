-- models/staging/stg_order_products.sql
with raw as (
    select *
    from {{ source('instacart_raw', 'order_products') }}
)
select
    order_id,
    product_id,
    add_to_cart_order,
    reordered
from raw
