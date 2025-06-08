import requests
import json
import os
from datetime import datetime
import snowflake.connector
from dotenv import load_dotenv

# Load environment variables from .env file (this file will be created later at project root)
load_dotenv()

# --- Snowflake Connection Details ---
# These will be read from the .env file
SNOWFLAKE_ACCOUNT = os.getenv('SNOWFLAKE_ACCOUNT')
SNOWFLAKE_USER = os.getenv('SNOWFLAKE_USER')
SNOWFLAKE_PASSWORD = os.getenv('SNOWFLAKE_PASSWORD')
SNOWFLAKE_ROLE = os.getenv('SNOWFLAKE_ROLE')
SNOWFLAKE_WAREHOUSE = os.getenv('SNOWFLAKE_WAREHOUSE')
SNOWFLAKE_DATABASE = os.getenv('SNOWFLAKE_DATABASE')
SNOWFLAKE_SCHEMA = os.getenv('SNOWFLAKE_SCHEMA_RAW') # Schema for raw ingested data


print(SNOWFLAKE_ACCOUNT)
# --- CoinGecko API Details ---
COINGECKO_API_URL = "https://api.coingecko.com/api/v3/simple/price"
PARAMS = {
    "ids": "bitcoin",
    "vs_currencies": "usd",
    "include_market_cap": "true",
    "include_24hr_vol": "true",
    "include_24hr_change": "true",
    "include_last_updated_at": "true"
}

def fetch_btc_price():
    """Fetches current Bitcoin price data from CoinGecko API."""
    print(f"[{datetime.now()}] Attempting to fetch BTC price from CoinGecko...")
    try:
        response = requests.get(COINGECKO_API_URL, params=PARAMS)
        response.raise_for_status()  # Raise an HTTPError for bad responses (4xx or 5xx)
        data = response.json()
        print(f"[{datetime.now()}] Successfully fetched data: {data}")
        return data
    except requests.exceptions.RequestException as e:
        print(f"[{datetime.now()}] Error fetching data from CoinGecko API: {e}")
        return None

def load_to_snowflake(data):
    """Loads JSON data into Snowflake VARIANT column."""
    if not data:
        print(f"[{datetime.now()}] No data to load to Snowflake.")
        return

    try:
        conn = snowflake.connector.connect(
            user=SNOWFLAKE_USER,
            password=SNOWFLAKE_PASSWORD,
            account=SNOWFLAKE_ACCOUNT,
            role=SNOWFLAKE_ROLE,
            warehouse=SNOWFLAKE_WAREHOUSE,
            database=SNOWFLAKE_DATABASE,
            schema=SNOWFLAKE_SCHEMA
        )
        cursor = conn.cursor()

        # Convert the Python dict to a JSON string for Snowflake
        json_data_str = json.dumps(data)

        # Use parameter binding to prevent SQL injection and handle quotes
        insert_sql = f"""
        INSERT INTO {SNOWFLAKE_DATABASE}.{SNOWFLAKE_SCHEMA}.COINGECKO_RAW_BTC_PRICE (API_RESPONSE)
        SELECT PARSE_JSON(%s);
        """
        cursor.execute(insert_sql, (json_data_str,))
        conn.commit()
        print(f"[{datetime.now()}] Data successfully loaded to Snowflake.")

    except snowflake.connector.Error as e:
        print(f"[{datetime.now()}] Snowflake error: {e}")
    except Exception as e:
        print(f"[{datetime.now()}] An unexpected error occurred during Snowflake load: {e}")
    finally:
        if 'conn' in locals() and conn: # Ensure conn exists before trying to close
            conn.close()
            print(f"[{datetime.now()}] Snowflake connection closed.")

if __name__ == "__main__":
    btc_data = fetch_btc_price()
    if btc_data:
        load_to_snowflake(btc_data)