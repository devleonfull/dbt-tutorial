with

customers as (

    select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

fct_orders as (

    select * from {{ ref('fct_orders') }}

),

orders_summary_by_user as (

    select
        fct_orders.customer_id,
        min(orders.order_date) as first_order_date,
        max(orders.order_date) as most_recent_order_date,
        count(distinct fct_orders.order_id) as total_orders,
        sum(fct_orders.total) as lifetime_value 

    from fct_orders
    left join orders on fct_orders.order_id = orders.order_id
    group by 1

),

final as (

    select
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        orders_summary_by_user.first_order_date,
        orders_summary_by_user.most_recent_order_date,
        coalesce(orders_summary_by_user.total_orders, 0) as total_orders,
        coalesce(orders_summary_by_user.lifetime_value, 0) as lifetime_value

    from customers

    left join
        orders_summary_by_user
        on customers.customer_id = orders_summary_by_user.customer_id

)

select * from final 