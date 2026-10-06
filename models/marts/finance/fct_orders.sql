with 

payments as (

   select * from {{ ref('stg_stripe__payments') }}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

totals_by_order as (

    select 
       order_id,
       sum(case when status='success' then amount end) as total
    from payments
    group by 1

),

final as (

    select 
        orders.order_id,
        orders.customer_id,
        coalesce(totals_by_order.total, 0) as total

    from orders
    left join  totals_by_order on orders.order_id = totals_by_order.order_id

)

select * from final

