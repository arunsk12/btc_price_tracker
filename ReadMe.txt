Username: ARUNSK12
Dedicated Login URL: https://dvnwqnt-tx56682.snowflakecomputing.com



mkdir.exe btc_price_tracker
cd btc_price_tracker

mkdir.exe ingestion
mkdir.exe dbt_project
mkdir.exe dbt_project/models
mkdir.exe dbt_project/models/staging
mkdir.exe dbt_project/models/marts
mkdir.exe dbt_project/tests

ls

-- If you are not ACCOUNTADMIN, you might need to use a role that has permissions to create roles/warehouses.
-- For simplicity on personal accounts, SYSADMIN often works.

USE ROLE ACCOUNTADMIN; -- Or a role with sufficient privileges

-- Create a dedicated role (optional, but good practice for security)
CREATE ROLE IF NOT EXISTS BTC_TRACKER_ROLE;
-- Grant this role to SNOWFLAKE_USER
GRANT ROLE BTC_TRACKER_ROLE TO USER ARUNSK12;

-- Create a warehouse for compute
CREATE WAREHOUSE IF NOT EXISTS BTC_TRACKER_WH WITH WAREHOUSE_SIZE = 'XSMALL' AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
GRANT USAGE ON WAREHOUSE BTC_TRACKER_WH TO ROLE BTC_TRACKER_ROLE;

---> set the Warehouse
USE WAREHOUSE BTC_TRACKER_WH;

-- Create database and schemas
CREATE DATABASE IF NOT EXISTS BTC_ANALYTICS;
CREATE SCHEMA IF NOT EXISTS BTC_ANALYTICS.RAW;
CREATE SCHEMA IF NOT EXISTS BTC_ANALYTICS.ANALYTICS;

-- Grant permissions to your role for the database and schemas
GRANT USAGE ON DATABASE BTC_ANALYTICS TO ROLE BTC_TRACKER_ROLE;
GRANT USAGE ON SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT USAGE ON SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;

-- Grant table creation rights on schemas
GRANT CREATE TABLE ON SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT CREATE TABLE ON SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;

-- Grant DML (Data Manipulation Language) permissions on existing tables/views
GRANT INSERT, SELECT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON ALL TABLES IN SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON ALL VIEWS IN SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON ALL VIEWS IN SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;

-- Grant future DML permissions on new tables/views created in these schemas
GRANT INSERT, SELECT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON FUTURE TABLES IN SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA BTC_ANALYTICS.RAW TO ROLE BTC_TRACKER_ROLE;
GRANT INSERT, SELECT, UPDATE, DELETE ON FUTURE VIEWS IN SCHEMA BTC_ANALYTICS.ANALYTICS TO ROLE BTC_TRACKER_ROLE;

-- Set context for table creation
USE SCHEMA BTC_ANALYTICS.RAW;

-- Create the raw table for CoinGecko API responses
CREATE TABLE IF NOT EXISTS COINGECKO_RAW_BTC_PRICE (
    API_RESPONSE VARIANT,
    INGESTION_TIMESTAMP TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);


============================

docker-compose down --volumes --rmi all

docker-compose build

docker-compose up -d --build

docker ps --filter "name=btc_price_tracker-dbt" --format "{{.Names}}"

docker exec -it btc_price_tracker-dbt-1 bash

--docker-compose down
docker-compose up -d --build dbt ingestion

dbt run 

dbt debug 

dbt test



