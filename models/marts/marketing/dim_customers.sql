{{ config(materialized="table") }}

WITH customers AS (

    SELECT * FROM {{ ref('stg_jaffle_shop__customers') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_jaffle_shop__orders') }}

),

payments AS (

    SELECT * FROM {{ ref('stg_stripe__payments') }}

),

customer_orders AS (

    SELECT
        orders.customer_id,
        min(orders.order_date) AS first_order_date,
        max(orders.order_date) AS most_recent_order_date,
        sum(payments.payment_amount) AS lifetime_value,
        count(orders.order_id) AS number_of_orders

    FROM orders
    LEFT JOIN payments ON payments.order_id = orders.order_id

    GROUP BY orders.customer_id

),

final AS (

    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customer_orders.first_order_date,
        customer_orders.most_recent_order_date,
        coalesce(customer_orders.number_of_orders, 0) AS number_of_orders,
        coalesce(customer_orders.lifetime_value, 0) AS lifetime_value

    FROM customers

    LEFT JOIN
        customer_orders
        ON customers.customer_id = customer_orders.customer_id

)

SELECT * FROM final
