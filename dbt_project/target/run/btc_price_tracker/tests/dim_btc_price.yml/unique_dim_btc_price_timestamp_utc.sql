
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    timestamp_utc as unique_field,
    count(*) as n_records

from BTC_ANALYTICS.ANALYTICS_analytics.dim_btc_price
where timestamp_utc is not null
group by timestamp_utc
having count(*) > 1



  
  
      
    ) dbt_internal_test