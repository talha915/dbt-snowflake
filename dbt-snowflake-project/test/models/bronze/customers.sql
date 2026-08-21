{{
    config(
        materialized='incremental',
        incremental_strategy = 'append'
    )
}}

SELECT
    CUSTOMER_ID,
    NAME,
    SOURCE_TIMESTAMP,
    CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP()) AS bronze_ingestion_time,
    CONVERT_TIMEZONE('UTC', METADATA$ROW_LAST_COMMIT_TIME) AS source_updated_at,
    
    '{{ invocation_id }}' AS DBT_RUN_ID

FROM {{ source('source', 'CUSTOMERS') }}

{% if is_incremental() %}

-- Only for Late Arriving Data 
WHERE source_updated_at >= DATEADD(
    'minute',
    -1,
    (
        SELECT MAX(source_updated_at)
        FROM {{ this }}
    )
)


{% endif %}