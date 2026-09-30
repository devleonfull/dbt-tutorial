 
WITH 

payments AS (

   SELECT * FROM {{ ref('stg_stripe__payments') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_jaffle_shop__orders') }}

),

order_payments AS (

    SELECT 
       order_id,
       sum(CASE WHEN payment_status='success' THEN payment_amount END) AS total_payment
    FROM payments
    GROUP BY 1

),

final as (

    SELECT 
        orders.order_id,
        orders.customer_id,
        order_payments.total_payment AS payment_amount

    FROM orders
    LEFT JOIN  order_payments ON order_payments.order_id = orders.order_id

)

SELECT * FROM final
