{{
    config(
        materialized='incremental'
    )
}}

SELECT
    CUSTOMER_ID,
    NAME,
    SOURCE_TIMESTAMP,
    CURRENT_TIMESTAMP() AS LOADED_AT

FROM {{ source('source', 'CUSTOMERS') }}

{% if is_incremental() %}

WHERE SOURCE_TIMESTAMP > (
    SELECT MAX(SOURCE_TIMESTAMP)
    FROM {{ this }}
)

{% endif %}