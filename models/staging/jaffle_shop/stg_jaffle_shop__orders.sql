with 

source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

renamed as (

    select
        ------- ids
        id AS order_id,
        user_id AS customer_id,

        ------- strings
        status,

        ------- dates
        order_date    

    from source

)

select * from renamed