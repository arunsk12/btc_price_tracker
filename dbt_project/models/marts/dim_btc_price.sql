{{
    config(
        materialized='incremental',
        unique_key=['timestamp_utc'], 
        schema='analytics' 
    )
}}

WITH raw_data AS (
    SELECT
        API_RESPONSE,
        INGESTION_TIMESTAMP
    FROM {{ ref('stg_coingecko_raw') }}

    {% if is_incremental() %}   
    WHERE INGESTION_TIMESTAMP > (SELECT MAX(timestamp_utc) FROM {{ this }})
    {% endif %}
),

flattened_data AS (
    SELECT
        API_RESPONSE:bitcoin:usd::FLOAT AS price_usd,
        API_RESPONSE:bitcoin:usd_market_cap::FLOAT AS market_cap_usd,
        API_RESPONSE:bitcoin:usd_24h_vol::FLOAT AS volume_24h_usd,
        API_RESPONSE:bitcoin:usd_24h_change::FLOAT AS change_24h_usd_pct,
        TO_TIMESTAMP(API_RESPONSE:bitcoin:last_updated_at::INT) AS last_updated_at_coingecko_utc,
        INGESTION_TIMESTAMP AS ingestion_timestamp_utc
    FROM raw_data
)

SELECT
    last_updated_at_coingecko_utc AS timestamp_utc,
    price_usd,
    market_cap_usd,
    volume_24h_usd,
    change_24h_usd_pct,
    ingestion_timestamp_utc
FROM flattened_data
WHERE last_updated_at_coingecko_utc IS NOT NULL
QUALIFY ROW_NUMBER() OVER (PARTITION BY last_updated_at_coingecko_utc ORDER BY ingestion_timestamp_utc DESC) = 1
ORDER BY timestamp_utc DESC