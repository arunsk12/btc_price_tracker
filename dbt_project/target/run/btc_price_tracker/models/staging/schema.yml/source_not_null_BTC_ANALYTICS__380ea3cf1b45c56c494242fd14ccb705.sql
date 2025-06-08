
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select INGESTION_TIMESTAMP
from BTC_ANALYTICS.RAW.COINGECKO_RAW_BTC_PRICE
where INGESTION_TIMESTAMP is null



  
  
      
    ) dbt_internal_test