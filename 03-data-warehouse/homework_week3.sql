CREATE OR REPLACE EXTERNAL TABLE `dezc_w3.external_green_taxi_data`
OPTIONS (
  format = 'parquet',
  uris = ['gs://mage_zoomcamp_jdbv/green_taxi_data_2022.parquet']
);

--CREATE OR REPLACE TABLE `dezc_w3.greentaxi_data`
--AS SELECT * FROM `dezc_w3.external_green_taxi_data`;


CREATE OR REPLACE TABLE `dezc_w3.greentaxi_data`
AS SELECT CAST(TIMESTAMP_MILLIS(CAST(lpep_pickup_datetime/1000000 as Int64)) AS DATETIME) lpep_pickup_datetime,CAST(TIMESTAMP_MILLIS(CAST(lpep_dropoff_datetime/1000000 as Int64)) as DATETIME) lpep_dropoff_datetime, * except(lpep_pickup_datetime, lpep_dropoff_datetime)
from `dezc_w3.external_green_taxi_data`;

--Question 1
SELECT COUNT(1)
FROM `dezc_w3.external_green_taxi_data`;

SELECT COUNT(1)
FROM `dezc_w3.greentaxi_data`;

--Question 2
SELECT COUNT(DISTINCT PULocationID)
FROM
`dezc_w3.external_green_taxi_data`;

SELECT COUNT(DISTINCT(PULocationID))
FROM
`dezc_w3.greentaxi_data`;


--Question 3
SELECT count(1)
FROM
`dezc_w3.external_green_taxi_data`
where fare_amount=0;

--Question 4
CREATE OR REPLACE TABLE `dezoomcampjdbv.dezc_w3.greentaxi_data_partitioned_pu_cluster_puli`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PUlocationID AS (
  SELECT * FROM `dezoomcampjdbv.dezc_w3.greentaxi_data`
);



--Question 5
SELECT DISTINCT PULocationId 
FROM `dezoomcampjdbv.dezc_w3.greentaxi_data`
WHERE lpep_pickup_datetime >= DATE("2022-01-06") and lpep_pickup_datetime <= DATE("2022-06-30");


SELECT DISTINCT PULocationId 
FROM `dezoomcampjdbv.dezc_w3.greentaxi_data_partitioned_pu_cluster_puli`
WHERE lpep_pickup_datetime >= DATE("2022-01-06") and lpep_pickup_datetime <= DATE("2022-06-30")

