{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='CUSTOMER_ID'
    )
}}

WITH silver_customer_data AS (

    SELECT
        CUSTOMER_ID,
        NAME,
        SOURCE_TIMESTAMP,
        source_updated_at,
        bronze_ingestion_time,
        DBT_RUN_ID,

        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_ID, NAME
            ORDER BY
                source_updated_at DESC,
                bronze_ingestion_time DESC
        ) AS RN

    FROM {{ ref('customers') }}

    {% if is_incremental() %}

    WHERE bronze_ingestion_time > (
        SELECT MAX(bronze_ingestion_time)
        FROM {{ this }}
    )

    {% endif %}

)

SELECT
    CUSTOMER_ID as customer_id,
    NAME as customer_name,
    source_updated_at,
    bronze_ingestion_time,
    DBT_RUN_ID,
    CONVERT_TIMEZONE('UTC', CURRENT_TIMESTAMP()) AS silver_ingestion_time,

FROM silver_customer_data

WHERE RN = 1