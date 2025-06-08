-- back compat for old kwarg name
  
  begin;
    
        
            
                
                
            
        
    

    

    merge into BTC_ANALYTICS.ANALYTICS_analytics.dim_btc_price as DBT_INTERNAL_DEST
        using BTC_ANALYTICS.ANALYTICS_analytics.dim_btc_price__dbt_tmp as DBT_INTERNAL_SOURCE
        on (
                    DBT_INTERNAL_SOURCE.timestamp_utc = DBT_INTERNAL_DEST.timestamp_utc
                )

    
    when matched then update set
        "TIMESTAMP_UTC" = DBT_INTERNAL_SOURCE."TIMESTAMP_UTC","PRICE_USD" = DBT_INTERNAL_SOURCE."PRICE_USD","MARKET_CAP_USD" = DBT_INTERNAL_SOURCE."MARKET_CAP_USD","VOLUME_24H_USD" = DBT_INTERNAL_SOURCE."VOLUME_24H_USD","CHANGE_24H_USD_PCT" = DBT_INTERNAL_SOURCE."CHANGE_24H_USD_PCT","INGESTION_TIMESTAMP_UTC" = DBT_INTERNAL_SOURCE."INGESTION_TIMESTAMP_UTC"
    

    when not matched then insert
        ("TIMESTAMP_UTC", "PRICE_USD", "MARKET_CAP_USD", "VOLUME_24H_USD", "CHANGE_24H_USD_PCT", "INGESTION_TIMESTAMP_UTC")
    values
        ("TIMESTAMP_UTC", "PRICE_USD", "MARKET_CAP_USD", "VOLUME_24H_USD", "CHANGE_24H_USD_PCT", "INGESTION_TIMESTAMP_UTC")

;
    commit;