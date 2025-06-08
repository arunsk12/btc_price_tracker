{{
    config(
        materialized='view',
        schema='RAW' 
    )
}}

SELECT
    API_RESPONSE,
    INGESTION_TIMESTAMP
FROM {{ source('BTC_ANALYTICS', 'COINGECKO_RAW_BTC_PRICE') }}