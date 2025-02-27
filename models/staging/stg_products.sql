-- models/staging/stg_products.sql
with prod as (
    select *
    from {{ source('instacart_raw', 'products') }}
),
aisle as (
    select *
    from {{ source('instacart_raw', 'aisles') }}
),
dept as (
    select *
    from {{ source('instacart_raw', 'departments') }}
)
select
    p.product_id,
    p.product_name,
    p.aisle_id,
    a.aisle as aisle_name,
    p.department_id,
    d.department as department_name
from prod p
left join aisle a on p.aisle_id = a.aisle_id
left join dept d on p.department_id = d.department_id
