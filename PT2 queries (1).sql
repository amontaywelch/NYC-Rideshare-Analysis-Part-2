-- Rideshare Analysis Part 2
-- This part focuses on the impact of the congestion fee, one year after implementation. 
-- Key metrics here are trip volume, net revenue, and driver pay. 
-- Part 3 will dive into Uber vs Lyft
 
 
 
-- combining 2024 table with part 1 2024 table
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024` AS
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_10`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_11`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_12`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare_pt2.2024_all`;
 
 
 
 
-- combining 2025 table with part 1 2025 table
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025` AS
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_02`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_03`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_04`
UNION ALL
SELECT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare_pt2.2025_all`;
 
 
 
 
-- data quality checks to identify nulls, zero values, negative values, and outliers before cleaning (2024)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(pickup_datetime IS NULL) AS null_pickup_datetime,
  COUNTIF(dropoff_datetime IS NULL) AS null_dropoff_datetime,
  COUNTIF(PULocationID IS NULL) AS null_pickup_location,
  COUNTIF(DOLocationID IS NULL) AS null_dropoff_location,
  COUNTIF(trip_miles IS NULL) AS null_trip_miles,
  COUNTIF(trip_time IS NULL) AS null_trip_time,
  COUNTIF(base_passenger_fare IS NULL) AS null_fare,
  COUNTIF(tips IS NULL) AS null_tips,
  COUNTIF(trip_miles = 0) AS zero_miles,
  COUNTIF(trip_time = 0) AS zero_time,
  COUNTIF(base_passenger_fare = 0) AS zero_fare,
  COUNTIF(base_passenger_fare < 0) AS negative_fare,
  COUNTIF(trip_miles < 0) AS negative_miles,
  COUNTIF(trip_time < 0) AS negative_time,
  COUNTIF(trip_miles > 100) AS trips_over_100_miles,
  COUNTIF(trip_time > 7200) AS trips_over_2_hours,
  COUNTIF(base_passenger_fare > 500) AS fares_over_500,
  ROUND(MIN(trip_miles), 2) AS min_miles,
  ROUND(MAX(trip_miles), 2) AS max_miles,
  ROUND(MIN(base_passenger_fare), 2) AS min_fare,
  ROUND(MAX(base_passenger_fare), 2) AS max_fare,
  MIN(pickup_datetime) AS earliest_trip,
  MAX(pickup_datetime) AS latest_trip
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`;
 
 
 
 
-- checking for duplicate trips in 2024
SELECT
  pickup_datetime,
  dropoff_datetime,
  PULocationID,
  DOLocationID,
  trip_miles,
  COUNT(*) AS total_trips_duplicated
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`
GROUP BY pickup_datetime, dropoff_datetime, PULocationID, DOLocationID, trip_miles
HAVING COUNT(*) > 1
ORDER BY total_trips_duplicated DESC;   -- 169 rows of duplicate trips, will be removed as it does not impact analysis
 
 
 
 
-- creating cleaned 2024 table to exclude illogical values
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS
SELECT DISTINCT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`
WHERE 
  trip_miles > 0
  AND trip_miles IS NOT NULL
  AND trip_time > 0
  AND trip_time IS NOT NULL
  AND base_passenger_fare > 0
  AND base_passenger_fare <= 500
  AND base_passenger_fare >= 0
  AND trip_miles <= 100
  AND PULocationID IS NOT NULL
  AND DOLocationID IS NOT NULL
  AND pickup_datetime IS NOT NULL
  AND dropoff_datetime IS NOT NULL;
 
 
 
 
-- confirming cleaning impact, target is less than 5% of rows removed
SELECT 
  COUNT(*) AS clean_rows,
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`) AS original_rows,
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`) - COUNT(*) AS rows_removed,
  ROUND(((SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`) - COUNT(*)) / 
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024`) * 100, 2) AS pct_removed
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`;  -- 0.05% of original rows removed
 
 
 
 
-- data quality checks to identify nulls, zero values, negative values, and outliers before cleaning (2025)
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(pickup_datetime IS NULL) AS null_pickup_datetime,
  COUNTIF(dropoff_datetime IS NULL) AS null_dropoff_datetime,
  COUNTIF(PULocationID IS NULL) AS null_pickup_location,
  COUNTIF(DOLocationID IS NULL) AS null_dropoff_location,
  COUNTIF(trip_miles IS NULL) AS null_trip_miles,
  COUNTIF(trip_time IS NULL) AS null_trip_time,
  COUNTIF(base_passenger_fare IS NULL) AS null_fare,
  COUNTIF(tips IS NULL) AS null_tips,
  COUNTIF(trip_miles = 0) AS zero_miles,
  COUNTIF(trip_time = 0) AS zero_time,
  COUNTIF(base_passenger_fare = 0) AS zero_fare,
  COUNTIF(base_passenger_fare < 0) AS negative_fare,
  COUNTIF(trip_miles < 0) AS negative_miles,
  COUNTIF(trip_time < 0) AS negative_time,
  COUNTIF(trip_miles > 100) AS trips_over_100_miles,
  COUNTIF(trip_time > 7200) AS trips_over_2_hours,
  COUNTIF(base_passenger_fare > 500) AS fares_over_500,
  ROUND(MIN(trip_miles), 2) AS min_miles,
  ROUND(MAX(trip_miles), 2) AS max_miles,
  ROUND(MIN(base_passenger_fare), 2) AS min_fare,
  ROUND(MAX(base_passenger_fare), 2) AS max_fare,
  MIN(pickup_datetime) AS earliest_trip,
  MAX(pickup_datetime) AS latest_trip
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`;
 
 
 
 
-- checking for duplicate trips in 2025
SELECT
  pickup_datetime,
  dropoff_datetime,
  PULocationID,
  DOLocationID,
  trip_miles,
  COUNT(*) AS total_trips_duplicated
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`
GROUP BY pickup_datetime, dropoff_datetime, PULocationID, DOLocationID, trip_miles
HAVING COUNT(*) > 1
ORDER BY total_trips_duplicated DESC;   -- 186 rows of duplicate trips, will be removed as it does not impact analysis
 
 
 
 
-- creating cleaned 2025 table to exclude illogical values
CREATE OR REPLACE TABLE `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS
SELECT DISTINCT *
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`
WHERE 
  trip_miles > 0
  AND trip_miles IS NOT NULL
  AND trip_time > 0
  AND trip_time IS NOT NULL
  AND base_passenger_fare > 0
  AND base_passenger_fare <= 500
  AND base_passenger_fare >= 0
  AND trip_miles <= 100
  AND PULocationID IS NOT NULL
  AND DOLocationID IS NOT NULL
  AND pickup_datetime IS NOT NULL
  AND dropoff_datetime IS NOT NULL;
 
 
 
 
-- confirming cleaning impact, target is less than 5% of rows removed
SELECT 
  COUNT(*) AS clean_rows,
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`) AS original_rows,
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`) - COUNT(*) AS rows_removed,
  ROUND(((SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`) - COUNT(*)) / 
  (SELECT COUNT(*) FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025`) * 100, 2) AS pct_removed
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`;  -- 0.18% of original rows removed, 0.23% in total for both years
 
 
 
 
-- PRIMARY METRICS --
 
 
 
 
-- overall 2024 vs 2025 base metrics
WITH base_metrics_2024 AS (
  SELECT
    EXTRACT(YEAR FROM pickup_datetime) AS year,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_miles), 2) AS avg_trip_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_trip_minutes,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(tips), 2) AS avg_tip,
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS avg_tip_pct,
    ROUND(AVG(CASE WHEN shared_request_flag = 'Y' THEN 1 ELSE 0 END) * 100, 2) AS shared_ride_pct
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE EXTRACT(YEAR FROM pickup_datetime) = 2024
  GROUP BY year
),
base_metrics_2025 AS (
  SELECT
    EXTRACT(YEAR FROM pickup_datetime) AS year,
    COUNT(*) AS total_trips,
    ROUND(AVG(trip_miles), 2) AS avg_trip_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_trip_minutes,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(tips), 2) AS avg_tip,
    ROUND(AVG(tips / NULLIF(base_passenger_fare, 0)) * 100, 2) AS avg_tip_pct,
    ROUND(AVG(CASE WHEN shared_request_flag = 'Y' THEN 1 ELSE 0 END) * 100, 2) AS shared_ride_pct
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE EXTRACT(YEAR FROM pickup_datetime) = 2025
  GROUP BY year
)
SELECT * FROM base_metrics_2024
UNION ALL
SELECT * FROM base_metrics_2025;
 
 
 
 
-- total 2024 trip volume MoM growth
WITH month_trip_volume_2024 AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY month
),
growth_rates AS (
  SELECT
    month,
    total_trips,
    LAG(total_trips) OVER(ORDER BY month) AS prev_month_trips,
    (total_trips - LAG(total_trips) OVER(ORDER BY month)) AS trip_diff,
    ROUND(((total_trips - LAG(total_trips) OVER(ORDER BY month)) / LAG(total_trips) OVER(ORDER BY month)) * 100, 2) AS growth_pct
  FROM month_trip_volume_2024
)
SELECT *
FROM growth_rates
ORDER BY month;
 
 
 
 
-- total 2025 trip volume MoM growth
WITH month_trip_volume_2025 AS (
  SELECT 
    EXTRACT(MONTH FROM pickup_datetime) AS month,
    COUNT(*) AS total_trips
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY month
),
growth_rates AS (
  SELECT
    month,
    total_trips,
    LAG(total_trips) OVER(ORDER BY month) AS prev_month_trips,
    (total_trips - LAG(total_trips) OVER(ORDER BY month)) AS trip_diff,
    ROUND(((total_trips - LAG(total_trips) OVER(ORDER BY month)) / LAG(total_trips) OVER(ORDER BY month)) * 100, 2) AS growth_pct
  FROM month_trip_volume_2025
)
SELECT *
FROM growth_rates
ORDER BY month;
 
 
 
 
-- net rideshare platform revenue YoY
WITH revenue_2024 AS (
  SELECT  
    ROUND((SUM(base_passenger_fare) - SUM(driver_pay)), 2) AS net_revenue_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
),
revenue_2025 AS (
  SELECT  
    ROUND((SUM(base_passenger_fare) - SUM(driver_pay)), 2) AS net_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
)
SELECT 
  net_revenue_2024,
  net_revenue_2025,
  ROUND((net_revenue_2025 - net_revenue_2024), 2) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS growth_pct
FROM revenue_2024
CROSS JOIN revenue_2025;
 
 
 
 
-- driver pay (excluding tips) YoY
WITH driver_earnings_2024 AS (
  SELECT 
    ROUND(SUM(driver_pay), 2) AS driver_pay_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
),
driver_earnings_2025 AS (
  SELECT
    ROUND(SUM(driver_pay), 2) AS driver_pay_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
)
SELECT
  driver_pay_2024,
  driver_pay_2025,
  ROUND((driver_pay_2025 - driver_pay_2024), 2) AS pay_diff,
  ROUND(((driver_pay_2025 - driver_pay_2024) / driver_pay_2024) * 100, 2) AS growth_pct
FROM driver_earnings_2024
CROSS JOIN driver_earnings_2025;
 
 
 
 
-- citywide tips YoY
WITH tips_2024 AS (
  SELECT 
    ROUND(SUM(tips), 2) AS total_tips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
),
tips_2025 AS (
  SELECT
    ROUND(SUM(tips), 2) AS total_tips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
)
SELECT
  total_tips_2024,
  total_tips_2025,
  ROUND((total_tips_2025 - total_tips_2024), 2) AS tips_diff,
  ROUND(((total_tips_2025 - total_tips_2024) / total_tips_2024) * 100, 2) AS growth_pct
FROM tips_2024
CROSS JOIN tips_2025;
 
 
 
 
-- total driver earnings (driver pay + tips) YoY
WITH earnings_2024 AS (
  SELECT 
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
),
earnings_2025 AS (
  SELECT
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
)
SELECT
  total_earnings_2024,
  total_earnings_2025,
  ROUND((total_earnings_2025 - total_earnings_2024), 2) AS earnings_diff,
  ROUND(((total_earnings_2025 - total_earnings_2024) / total_earnings_2024) * 100, 2) AS growth_pct
FROM earnings_2024
CROSS JOIN earnings_2025;
 
 
 
 
-- congestion fee breakdown (2025 only)
SELECT
  COUNTIF(cbd_congestion_fee > 0) AS trips_charged_fee,
  COUNTIF(cbd_congestion_fee = 0) AS trips_not_charged,
  COUNT(*) AS total_after_trips,
  ROUND(COUNTIF(cbd_congestion_fee > 0) / COUNT(*) * 100, 2) AS pct_trips_charged,
  ROUND(AVG(CASE WHEN cbd_congestion_fee > 0 THEN cbd_congestion_fee END), 2) AS avg_fee_when_charged,
  ROUND(MIN(CASE WHEN cbd_congestion_fee > 0 THEN cbd_congestion_fee END), 2) AS min_fee,
  ROUND(MAX(cbd_congestion_fee), 2) AS max_fee,
  ROUND(SUM(cbd_congestion_fee), 2) AS total_fees_collected
FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`;
 
 
 
 
-- congestion zone YoY: trip volume, net revenue, and driver earnings
-- Note: 2024 uses Manhattan borough as proxy; 2025 uses cbd_congestion_fee > 0 for true zone isolation
WITH congestion_zone_2024 AS (
  SELECT
    COUNT(*) AS total_trips_2024,
    ROUND(SUM(r.base_passenger_fare) - SUM(r.driver_pay), 2) AS net_revenue_2024,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_driver_earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE t.borough = "Manhattan"
),
congestion_zone_2025 AS (
  SELECT
    COUNT(*) AS total_trips_2025,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue_2025,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE cbd_congestion_fee > 0
)
SELECT
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS trip_growth_pct,
  net_revenue_2024,
  net_revenue_2025,
  (net_revenue_2025 - net_revenue_2024) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS revenue_growth_pct,
  total_driver_earnings_2024,
  total_driver_earnings_2025,
  (total_driver_earnings_2025 - total_driver_earnings_2024) AS earnings_diff,
  ROUND(((total_driver_earnings_2025 - total_driver_earnings_2024) / total_driver_earnings_2024) * 100, 2) AS earnings_growth_pct
FROM congestion_zone_2024
CROSS JOIN congestion_zone_2025;
 
 
 
 
-- UBER VS LYFT PERFORMANCE (basic metrics, will cover more in Part 3) --
 
 
 
 
-- total trip volume comparison for Uber
WITH uber_trip_count_2024 AS (
  SELECT
    hvfhs_license_num,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE hvfhs_license_num = "HV0003"
  GROUP BY hvfhs_license_num
),
uber_trip_count_2025 AS (
  SELECT 
    hvfhs_license_num,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE hvfhs_license_num = "HV0003"
  GROUP BY hvfhs_license_num
)
SELECT
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM uber_trip_count_2024
JOIN uber_trip_count_2025 USING(hvfhs_license_num);
 
 
 
 
-- total trip volume comparison for Lyft
WITH lyft_trip_count_2024 AS (
  SELECT
    hvfhs_license_num,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE hvfhs_license_num = "HV0005"
  GROUP BY hvfhs_license_num
),
lyft_trip_count_2025 AS (
  SELECT 
    hvfhs_license_num,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE hvfhs_license_num = "HV0005"
  GROUP BY hvfhs_license_num
)
SELECT
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM lyft_trip_count_2024
JOIN lyft_trip_count_2025 USING(hvfhs_license_num);
 
 
 
 
-- peak rideshare times for Uber
WITH uber_peak_times_2024 AS (
  SELECT 
    hvfhs_license_num,
    FORMAT_TIMESTAMP('%I %p', pickup_datetime) AS hour_am_pm,
    COUNT(PULocationID) AS trip_count_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE hvfhs_license_num = "HV0003"
  GROUP BY hvfhs_license_num, FORMAT_TIMESTAMP('%I %p', pickup_datetime)
),
uber_peak_times_2025 AS (
  SELECT 
    hvfhs_license_num,
    FORMAT_TIMESTAMP('%I %p', pickup_datetime) AS hour_am_pm,
    COUNT(PULocationID) AS trip_count_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE hvfhs_license_num = "HV0003"
  GROUP BY hvfhs_license_num, FORMAT_TIMESTAMP('%I %p', pickup_datetime)
)
SELECT 
  hvfhs_license_num,
  hour_am_pm,
  trip_count_2024,
  trip_count_2025,
  (trip_count_2025 - trip_count_2024) AS trip_diff,
  ROUND(((trip_count_2025 - trip_count_2024) / trip_count_2024) * 100, 2) AS diff_pct
FROM uber_peak_times_2024
JOIN uber_peak_times_2025 USING(hvfhs_license_num, hour_am_pm)
ORDER BY diff_pct DESC;
 
 
 
 
-- peak rideshare times for Lyft
WITH lyft_peak_times_2024 AS (
  SELECT 
    hvfhs_license_num,
    FORMAT_TIMESTAMP('%I %p', pickup_datetime) AS hour_am_pm,
    COUNT(PULocationID) AS trip_count_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE hvfhs_license_num = "HV0005"
  GROUP BY hvfhs_license_num, FORMAT_TIMESTAMP('%I %p', pickup_datetime)
),
lyft_peak_times_2025 AS (
  SELECT 
    hvfhs_license_num,
    FORMAT_TIMESTAMP('%I %p', pickup_datetime) AS hour_am_pm,
    COUNT(PULocationID) AS trip_count_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE hvfhs_license_num = "HV0005"
  GROUP BY hvfhs_license_num, FORMAT_TIMESTAMP('%I %p', pickup_datetime)
)
SELECT 
  hvfhs_license_num,
  hour_am_pm,
  trip_count_2024,
  trip_count_2025,
  (trip_count_2025 - trip_count_2024) AS trip_diff,
  ROUND(((trip_count_2025 - trip_count_2024) / trip_count_2024) * 100, 2) AS diff_pct
FROM lyft_peak_times_2024
JOIN lyft_peak_times_2025 USING(hvfhs_license_num, hour_am_pm)
ORDER BY diff_pct DESC;
 
 
 
 
-- SUPPORTING METRICS --
 
 
 
 
-- trip volume change for each borough
-- expectation: Manhattan will decline as it's the focal point of the congestion fee
WITH borough_trips_2024 AS (
  SELECT 
    t.borough,
    COUNT(r.PULocationID) AS trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  GROUP BY t.borough
),
borough_trips_2025 AS (
  SELECT 
    t.borough,
    COUNT(r.PULocationID) AS trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  GROUP BY t.borough
)
SELECT 
  borough,
  trips_2024,
  trips_2025,
  ROUND((trips_2025 - trips_2024), 2) AS trip_diff,
  ROUND(((trips_2025 - trips_2024) / trips_2024) * 100, 2) AS growth_pct
FROM borough_trips_2024
JOIN borough_trips_2025 USING(borough);
 
 
 
 
-- net revenue change for each borough
WITH borough_revenue_2024 AS (
  SELECT 
    t.borough,
    SUM(r.base_passenger_fare) - SUM(r.driver_pay) AS net_revenue_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  GROUP BY t.borough
),
borough_revenue_2025 AS (
  SELECT 
    t.borough,
    SUM(r.base_passenger_fare) - SUM(r.driver_pay) AS net_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  GROUP BY t.borough
)
SELECT 
  borough,
  net_revenue_2024,
  net_revenue_2025,
  ROUND((net_revenue_2025 - net_revenue_2024), 2) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS growth_pct
FROM borough_revenue_2024
JOIN borough_revenue_2025 USING(borough);
 
 
 
 
-- total driver earnings for each borough YoY
WITH total_pay_2024 AS (
  SELECT 
    t.borough,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON t.LocationID = r.PULocationID
  GROUP BY t.borough
),
total_pay_2025 AS (
  SELECT 
    t.borough,
    ROUND(SUM(r.driver_pay) + SUM(r.tips), 2) AS total_earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON t.LocationID = r.PULocationID
  GROUP BY t.borough
)
SELECT
  borough,
  total_earnings_2024,
  total_earnings_2025,
  (total_earnings_2025 - total_earnings_2024) AS earnings_diff,
  ROUND(((total_earnings_2025 - total_earnings_2024) / total_earnings_2024) * 100, 2) AS growth_pct
FROM total_pay_2024
JOIN total_pay_2025 USING(borough);
 
 
 
 
-- trip volume grouped and compared by day of week
WITH dow_2024 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY day_of_week
),
dow_2025 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY day_of_week
)
SELECT 
  day_of_week,
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM dow_2024
JOIN dow_2025 USING(day_of_week)
ORDER BY growth_pct DESC;
 
 
 
 
-- net revenue growth by day of week
WITH dow_revenue_2024 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(base_passenger_fare) - SUM(driver_pay) AS net_revenue_2024
  FROM `project-715687c4-6754-4729-854.nyc_rideshare.rideshare_2024_clean`
  GROUP BY day_of_week
),
dow_revenue_2025 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(base_passenger_fare) - SUM(driver_pay) AS net_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY day_of_week
)
SELECT 
  day_of_week,
  net_revenue_2024,
  net_revenue_2025,
  (net_revenue_2025 - net_revenue_2024) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS growth_pct
FROM dow_revenue_2024
JOIN dow_revenue_2025 USING(day_of_week)
ORDER BY growth_pct DESC;
 
 
 
 
-- Manhattan specific net revenue growth by day of week
-- drill down to confirm whether weekday revenue growth is congestion zone driven
WITH dow_revenue_2024 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(r.base_passenger_fare) - SUM(r.driver_pay) AS net_revenue_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE t.borough = "Manhattan"
  GROUP BY day_of_week
),
dow_revenue_2025 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(r.base_passenger_fare) - SUM(r.driver_pay) AS net_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
    ON r.PULocationID = t.LocationID
  WHERE t.borough = "Manhattan"
  GROUP BY day_of_week
)
SELECT 
  day_of_week,
  net_revenue_2024,
  net_revenue_2025,
  (net_revenue_2025 - net_revenue_2024) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS growth_pct
FROM dow_revenue_2024
JOIN dow_revenue_2025 USING(day_of_week)
ORDER BY growth_pct DESC;
 
 
 
 
-- total driver earnings by day of week
WITH dow_earnings_2024 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(tips) + SUM(driver_pay) AS earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY day_of_week
),
dow_earnings_2025 AS (
  SELECT
    CASE
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 1 THEN "Sunday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 2 THEN "Monday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 3 THEN "Tuesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 4 THEN "Wednesday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 5 THEN "Thursday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 6 THEN "Friday"
      WHEN EXTRACT(DAYOFWEEK FROM pickup_datetime) = 7 THEN "Saturday"
      ELSE "Unknown"
    END AS day_of_week,
    SUM(tips) + SUM(driver_pay) AS earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY day_of_week
)
SELECT 
  day_of_week,
  earnings_2024,
  earnings_2025,
  (earnings_2025 - earnings_2024) AS earnings_diff,
  ROUND(((earnings_2025 - earnings_2024) / earnings_2024) * 100, 2) AS growth_pct
FROM dow_earnings_2024
JOIN dow_earnings_2025 USING(day_of_week)
ORDER BY growth_pct DESC;
 
 
 
 
-- trip volume comparison by hour of day
WITH hourly_trips_2024 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    COUNT(*) AS total_trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY hour_24, hour_ampm
),
hourly_trips_2025 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    COUNT(*) AS total_trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY hour_24, hour_ampm
)
SELECT
  hour_24,
  hour_ampm,
  total_trips_2024,
  total_trips_2025,
  (total_trips_2025 - total_trips_2024) AS trip_diff,
  ROUND(((total_trips_2025 - total_trips_2024) / total_trips_2024) * 100, 2) AS growth_pct
FROM hourly_trips_2024
JOIN hourly_trips_2025 USING(hour_24, hour_ampm)
ORDER BY growth_pct DESC;
 
 
 
 
-- net revenue comparison by hour of day
WITH hourly_revenue_2024 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    SUM(base_passenger_fare) - SUM(driver_pay) AS net_revenue_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY hour_24, hour_ampm
),
hourly_revenue_2025 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    SUM(base_passenger_fare) - SUM(driver_pay) AS net_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY hour_24, hour_ampm
)
SELECT
  hour_24,
  hour_ampm,
  net_revenue_2024,
  net_revenue_2025,
  (net_revenue_2025 - net_revenue_2024) AS revenue_diff,
  ROUND(((net_revenue_2025 - net_revenue_2024) / net_revenue_2024) * 100, 2) AS growth_pct
FROM hourly_revenue_2024
JOIN hourly_revenue_2025 USING(hour_24, hour_ampm)
ORDER BY hour_24;
 
 
 
 
-- total driver earnings comparison by hour of day
WITH hourly_earnings_2024 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    SUM(driver_pay) + SUM(tips) AS total_driver_earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY hour_24, hour_ampm
),
hourly_earnings_2025 AS (
  SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hour_24,
    FORMAT_TIMESTAMP('%l %p', pickup_datetime) AS hour_ampm,
    SUM(driver_pay) + SUM(tips) AS total_driver_earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY hour_24, hour_ampm
)
SELECT
  hour_24,
  hour_ampm,
  total_driver_earnings_2024,
  total_driver_earnings_2025,
  (total_driver_earnings_2025 - total_driver_earnings_2024) AS earnings_diff,
  ROUND(((total_driver_earnings_2025 - total_driver_earnings_2024) / total_driver_earnings_2024) * 100, 2) AS growth_pct
FROM hourly_earnings_2024
JOIN hourly_earnings_2025 USING(hour_24, hour_ampm)
ORDER BY hour_24;
 
 
 
 
-- trip volume trends by season
WITH season_trends_2024 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2024-03-20' AND '2024-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2024-06-21' AND '2024-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2024-09-23' AND '2024-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    COUNT(PULocationID) AS trip_count_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY season
),
season_trends_2025 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2025-03-20' AND '2025-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2025-06-21' AND '2025-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2025-09-23' AND '2025-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    COUNT(PULocationID) AS trip_count_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY season
)
SELECT
  season,
  trip_count_2024,
  trip_count_2025,
  (trip_count_2025 - trip_count_2024) AS trip_diff,
  ROUND(((trip_count_2025 - trip_count_2024) / trip_count_2024) * 100, 2) AS growth_pct
FROM season_trends_2024
JOIN season_trends_2025 USING(season)
ORDER BY growth_pct DESC;
 
 
 
 
-- net revenue by season
WITH season_revenue_2024 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2024-03-20' AND '2024-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2024-06-21' AND '2024-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2024-09-23' AND '2024-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    SUM(base_passenger_fare) - SUM(driver_pay) AS total_revenue_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY season
),
season_revenue_2025 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2025-03-20' AND '2025-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2025-06-21' AND '2025-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2025-09-23' AND '2025-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    SUM(base_passenger_fare) - SUM(driver_pay) AS total_revenue_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY season
)
SELECT
  season,
  total_revenue_2024,
  total_revenue_2025,
  (total_revenue_2025 - total_revenue_2024) AS revenue_diff,
  ROUND(((total_revenue_2025 - total_revenue_2024) / total_revenue_2024) * 100, 2) AS growth_pct
FROM season_revenue_2024
JOIN season_revenue_2025 USING(season)
ORDER BY growth_pct DESC;
 
 
 
 
-- total driver earnings by season
WITH season_driver_pay_2024 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2024-03-20' AND '2024-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2024-06-21' AND '2024-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2024-09-23' AND '2024-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    SUM(driver_pay) + SUM(tips) AS total_driver_earnings_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  GROUP BY season
),
season_driver_pay_2025 AS (
  SELECT 
    CASE
      WHEN pickup_datetime BETWEEN '2025-03-20' AND '2025-06-20' THEN 'Spring'
      WHEN pickup_datetime BETWEEN '2025-06-21' AND '2025-09-22' THEN 'Summer'
      WHEN pickup_datetime BETWEEN '2025-09-23' AND '2025-12-20' THEN 'Fall'
      ELSE 'Winter'
    END AS season,
    SUM(driver_pay) + SUM(tips) AS total_driver_earnings_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  GROUP BY season
)
SELECT
  season,
  total_driver_earnings_2024,
  total_driver_earnings_2025,
  (total_driver_earnings_2025 - total_driver_earnings_2024) AS earnings_diff,
  ROUND(((total_driver_earnings_2025 - total_driver_earnings_2024) / total_driver_earnings_2024) * 100, 2) AS growth_pct
FROM season_driver_pay_2024
JOIN season_driver_pay_2025 USING(season)
ORDER BY total_driver_earnings_2025 DESC;
 
 
 
 
-- Spring borough drill down: why did Spring lose trips but lead revenue growth?
WITH borough_trips_2024 AS (
  SELECT 
    t.borough,
    COUNT(r.PULocationID) AS trips_2024
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  WHERE r.pickup_datetime BETWEEN '2024-03-20' AND '2024-06-20'
  GROUP BY t.borough
),
borough_trips_2025 AS (
  SELECT 
    t.borough,
    COUNT(r.PULocationID) AS trips_2025
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean` AS r
  JOIN `project-715687c4-6754-4729-834.nyc_rideshare.taxi_zones` AS t
  ON r.PULocationID = t.LocationID
  WHERE r.pickup_datetime BETWEEN '2025-03-20' AND '2025-06-20'
  GROUP BY t.borough
)
SELECT 
  borough,
  trips_2024,
  trips_2025,
  ROUND((trips_2025 - trips_2024), 2) AS trip_diff,
  ROUND(((trips_2025 - trips_2024) / trips_2024) * 100, 2) AS growth_pct
FROM borough_trips_2024
JOIN borough_trips_2025 USING(borough);
 
 
 
 
-- January 2024 vs January 2025 spotlight: immediate shock of the congestion fee implementation
WITH january_metrics_2024 AS (
  SELECT
    EXTRACT(YEAR FROM pickup_datetime) AS year,
    COUNT(*) AS total_trips,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings,
    ROUND(AVG(trip_miles), 2) AS avg_trip_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_trip_minutes,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2024_clean`
  WHERE EXTRACT(MONTH FROM pickup_datetime) = 1
  GROUP BY year
),
january_metrics_2025 AS (
  SELECT
    EXTRACT(YEAR FROM pickup_datetime) AS year,
    COUNT(*) AS total_trips,
    ROUND(SUM(base_passenger_fare) - SUM(driver_pay), 2) AS net_revenue,
    ROUND(SUM(driver_pay) + SUM(tips), 2) AS total_driver_earnings,
    ROUND(AVG(trip_miles), 2) AS avg_trip_miles,
    ROUND(AVG(trip_time / 60), 2) AS avg_trip_minutes,
    ROUND(AVG(base_passenger_fare), 2) AS avg_fare,
    ROUND(AVG(tips), 2) AS avg_tip
  FROM `project-715687c4-6754-4729-834.nyc_rideshare.rideshare_2025_clean`
  WHERE EXTRACT(MONTH FROM pickup_datetime) = 1
  GROUP BY year
)
SELECT
  '2024 vs 2025' AS comparison,
  j24.total_trips AS total_trips_2024,
  j25.total_trips AS total_trips_2025,
  (j25.total_trips - j24.total_trips) AS trip_diff,
  ROUND(((j25.total_trips - j24.total_trips) / j24.total_trips) * 100, 2) AS trip_growth_pct,
  j24.net_revenue AS net_revenue_2024,
  j25.net_revenue AS net_revenue_2025,
  (j25.net_revenue - j24.net_revenue) AS revenue_diff,
  ROUND(((j25.net_revenue - j24.net_revenue) / j24.net_revenue) * 100, 2) AS revenue_growth_pct,
  j24.total_driver_earnings AS driver_earnings_2024,
  j25.total_driver_earnings AS driver_earnings_2025,
  (j25.total_driver_earnings - j24.total_driver_earnings) AS earnings_diff,
  ROUND(((j25.total_driver_earnings - j24.total_driver_earnings) / j24.total_driver_earnings) * 100, 2) AS earnings_growth_pct,
  j24.avg_trip_miles AS avg_miles_2024,
  j25.avg_trip_miles AS avg_miles_2025,
  j24.avg_trip_minutes AS avg_minutes_2024,
  j25.avg_trip_minutes AS avg_minutes_2025,
  j24.avg_fare AS avg_fare_2024,
  j25.avg_fare AS avg_fare_2025
FROM january_metrics_2024 AS j24
CROSS JOIN january_metrics_2025 AS j25;