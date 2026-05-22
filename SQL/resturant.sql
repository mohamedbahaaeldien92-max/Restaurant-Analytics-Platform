-- Databricks notebook source
CREATE TABLE resturant_table
USING DELTA
AS
SELECT *
FROM read_files(
  '/Volumes/workspace/default/resturant/*.csv',
  format => 'csv',
  header => true
);

-- COMMAND ----------

SELECT COUNT(*) FROM resturant_table;

-- COMMAND ----------

CREATE TABLE resturant_json_table
USING DELTA
AS
SELECT *
FROM read_files(
  '/Volumes/workspace/default/resturant/*.json',
  format => 'json'
);

-- COMMAND ----------

SELECT COUNT(*) FROM resturant_json_table;

-- COMMAND ----------

SELECT * FROM resturant_json_table;

-- COMMAND ----------

SELECT * FROM resturant_table;


-- COMMAND ----------

-- DBTITLE 1,Cell 8
CREATE OR REPLACE TABLE final_table_clean
USING DELTA
AS

-- CSV DATA
SELECT 
  CAST(order_id AS BIGINT)                AS order_id,
  to_date(order_date)                     AS order_date,
  CAST(hour AS INT)                       AS hour,
  category,
  item_name,
  CAST(price AS DOUBLE)                   AS price,
  CAST(quantity AS INT)                   AS quantity,
  CAST(discount AS DOUBLE)                AS discount,
  CAST(total_amount AS DOUBLE)            AS total_amount,
  branch,
  payment_method,
  order_type,
  CAST(customer_id AS BIGINT)             AS customer_id,
  CAST(rating AS DOUBLE)                  AS rating,
  CAST(is_weekend AS BOOLEAN)             AS is_weekend,
  'CSV'                                   AS source
FROM resturant_table

UNION ALL

-- JSON DATA
SELECT 
  try_cast(order_id AS BIGINT)            AS order_id,
  to_date(order_date)                     AS order_date,
  try_cast(hour AS INT)                   AS hour,
  category,
  item_name,
  try_cast(price AS DOUBLE)               AS price,
  try_cast(quantity AS INT)               AS quantity,
  try_cast(discount AS DOUBLE)            AS discount,
  try_cast(total_amount AS DOUBLE)        AS total_amount,
  branch,
  payment_method,
  order_type,
  try_cast(customer_id AS BIGINT)         AS customer_id,
  try_cast(rating AS DOUBLE)              AS rating,
  try_cast(is_weekend AS BOOLEAN)         AS is_weekend,
  'JSON'                                  AS source
FROM resturant_json_table;

-- COMMAND ----------

SELECT COUNT(*) FROM final_table_clean;

-- COMMAND ----------

select* from final_table_clean;

-- COMMAND ----------

--create new table for use in churn analysis
CREATE OR REPLACE TABLE Dim_Customer AS
SELECT 
    customer_id,
    year(MIN(order_date)) AS first_order_year
FROM final_table_clean
GROUP BY customer_id;

-- COMMAND ----------

select* from Dim_customer;

-- COMMAND ----------

SELECT COUNT(*) FROM dim_customer;