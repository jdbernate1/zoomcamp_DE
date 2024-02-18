import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test
from datetime import datetime, timedelta



@data_loader
def load_data_from_api(*args, **kwargs):

    def generate_month_list(start_date_str, end_date_str):
        start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
        end_date = datetime.strptime(end_date_str, "%Y-%m-%d")
    
        months = []
        current_date = start_date.replace(day=1)  # Start from the first day of the start month
        while current_date <= end_date:
            months.append(current_date.strftime("%Y-%m"))
            current_date = current_date + timedelta(days=32)
            current_date = current_date.replace(day=1)
        return months
    
    start_date = kwargs['configuration'].get('start_date')
    end_date = kwargs['configuration'].get('end_date')
    periods = generate_month_list(start_date,end_date)


    dfs = []
    taxi_dtypes = {
                'VendorID': pd.Int64Dtype(),
                'passenger_count': pd.Int64Dtype(),
                'trip_distance': float,
                'RatecodeID':pd.Int64Dtype(),
                'store_and_fwd_flag':str,
                'PULocationID':pd.Int64Dtype(),
                'DOLocationID':pd.Int64Dtype(),
                'payment_type': pd.Int64Dtype(),
                'fare_amount': float,
                'extra':float,
                'mta_tax':float,
                'tip_amount':float,
                'tolls_amount':float,
                'improvement_surcharge':float,
                'total_amount':float,
                'congestion_surcharge':float
            }
    parse_dates = ['tpep_pickup_datetime', 'tpep_dropoff_datetime']
    url_base = kwargs['configuration'].get('url_source')

    for p in periods:
        url = url_base+'yellow_tripdata_'+p+'.csv.gz'
        print(url)
        df_raw = pd.read_csv(url, sep=',', compression='gzip', dtype=taxi_dtypes, parse_dates=parse_dates)
        dfs.append(df_raw)
    
    data = pd.concat(dfs)

    return data
