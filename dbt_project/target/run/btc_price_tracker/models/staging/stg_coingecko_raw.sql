
  create or replace   view BTC_ANALYTICS.ANALYTICS_RAW.stg_coingecko_raw
  
   as (
    

SELECT
    API_RESPONSE,
    INGESTION_TIMESTAMP
FROM BTC_ANALYTICS.RAW.COINGECKO_RAW_BTC_PRICE
  );

