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



payments_order AS (

    SELECT
        order_id,
        sum(CASE
            WHEN payment_status = 'success' THEN payment_amount
            ELSE 0
        END) AS total_payment

    FROM payments

    GROUP BY order_id

),

order_total AS (
    SELECT
        orders.*,
        payments_order.total_payment

    FROM orders
    LEFT JOIN payments_order ON orders.order_id = payments_order.order_id
),

customers_orders AS (

    SELECT
        customer_id,
        max(order_date) AS most_recent_order_date,
        min(order_date) AS first_order_date,
        count(*) AS total_orders,
        sum(total_payment) AS total_value

    FROM order_total

    GROUP BY customer_id

),

final AS (

    SELECT
        customers.customer_id,
        customers.first_name,
        customers.last_name,
        customers_orders.first_order_date,
        customers_orders.most_recent_order_date,
        coalesce(customers_orders.total_orders, 0) AS number_of_orders,
        coalesce(customers_orders.total_value, 0) AS lifetime_value

    FROM customers

    LEFT JOIN
        customers_orders
        ON customers.customer_id = customers_orders.customer_id

)

SELECT * FROM final
