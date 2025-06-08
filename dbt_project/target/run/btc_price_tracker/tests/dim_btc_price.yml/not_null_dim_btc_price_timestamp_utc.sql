
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select timestamp_utc
from BTC_ANALYTICS.ANALYTICS_analytics.dim_btc_price
where timestamp_utc is null



  
  
      
    ) dbt_internal_test