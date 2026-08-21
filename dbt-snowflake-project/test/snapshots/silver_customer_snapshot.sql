{% snapshot silver_customers_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='CUSTOMER_ID',
        strategy='timestamp',
        updated_at='source_updated_at'
    )
}}

SELECT
   *

FROM {{ ref('silver_customers') }}

{% endsnapshot %}