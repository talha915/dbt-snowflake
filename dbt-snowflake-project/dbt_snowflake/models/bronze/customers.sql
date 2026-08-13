{{
    config(
        materialized='incremental'
    )
}}

SELECT
    CUSTOMER_ID,
    NAME,
    SOURCE_TIMESTAMP,
    CURRENT_TIMESTAMP() AS bronze_ingestion_time,
    CONVERT_TIMEZONE('UTC', METADATA$ROW_LAST_COMMIT_TIME) AS updated_at 

FROM {{ source('source', 'CUSTOMERS') }}

{% if is_incremental() %}

WHERE updated_at >= DATEADD(
    'hour',
    -1,
    (
        SELECT MAX(updated_at)
        FROM {{ this }}
    )  
)

{% endif %}