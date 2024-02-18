CREATE OR REPLACE EXTERNAL TABLE `trips_data_all.external_green_taxi_data`
OPTIONS (
  format = 'parquet',
  uris = ['gs://week_4_analytics_eng/green/*.parquet']
);


CREATE OR REPLACE EXTERNAL TABLE `trips_data_all.external_yellow_taxi_data`
OPTIONS (
  format = 'parquet',
  uris = ['gs://week_4_analytics_eng/yellow/*.parquet']
);



CREATE OR REPLACE TABLE `trips_data_all.green_taxi_data`
AS SELECT CAST(TIMESTAMP_MILLIS(CAST(lpep_pickup_datetime/1000000 as Int64)) AS DATETIME) lpep_pickup_datetime,CAST(TIMESTAMP_MILLIS(CAST(lpep_dropoff_datetime/1000000 as Int64)) as DATETIME) lpep_dropoff_datetime,  * except(lpep_pickup_datetime, lpep_dropoff_datetime)
from `trips_data_all.external_green_taxi_data`;



CREATE OR REPLACE TABLE `trips_data_all.yellow_taxi_data`
AS SELECT CAST(TIMESTAMP_MILLIS(CAST(tpep_pickup_datetime/1000000 as Int64)) AS DATETIME) tpep_pickup_datetime,CAST(TIMESTAMP_MILLIS(CAST(tpep_dropoff_datetime/1000000 as Int64)) as DATETIME) tpep_dropoff_datetime, * except(tpep_pickup_datetime, tpep_dropoff_datetime)
from `trips_data_all.external_yellow_taxi_data`

