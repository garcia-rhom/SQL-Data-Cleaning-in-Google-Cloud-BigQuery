SELECT * FROM `sql-portfolio-468415.sql_data_cleaning.customer_order`; 

-- Create a new table for the cleaned data

CREATE OR REPLACE TABLE `sql-portfolio-468415.sql_data_cleaning.customer_order_cleaned` AS
SELECT

  order_id,

    -- cleaned customer_name
  INITCAP(customer_name) AS cleaned_customer_name,

  -- cleaned_email
  -- SELECT DISTINCT email FROM `sql-portfolio-468415.sql_data_cleaning.customer_order`;
  REGEXP_REPLACE(email, r'(@{2,})', '@') AS cleaned_email,

  -- cleaned order_date
    CASE
      WHEN REGEXP_CONTAINS(order_date, r'^\d{4}-\d{2}-\d{2}$') 
        THEN CAST(order_date AS DATE)  -- already in YYYY-MM-DD
      WHEN REGEXP_CONTAINS(order_date, r'^\d{2}/\d{2}/\d{4}$') 
        THEN PARSE_DATE('%m/%d/%Y', order_date)  -- MM/DD/YYYY
      WHEN REGEXP_CONTAINS(order_date, r'^\d{2}-\d{2}-\d{4}$') 
        THEN PARSE_DATE('%m-%d-%Y', order_date)  -- MM-DD-YYYY
      WHEN REGEXP_CONTAINS(order_date, r'^\d{4}/\d{2}/\d{2}$') 
        THEN PARSE_DATE('%Y/%m/%d', order_date) -- YYYY/MM/DD
      ELSE NULL  -- unknown formats
    END AS cleaned_order_date,

  -- cleaned product_name
  CASE
    WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
    WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
    WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
    WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'iPhone 14'
    WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
    ELSE 'Other'
  END AS cleaned_product_name,

  -- cleaned_quantity 
  CASE
    WHEN LOWER(quantity) = 'two' THEN 2
    ELSE CAST(quantity AS INT64)
  END AS cleaned_quantity,

  -- cleaned_price
  CASE
    WHEN price IS NULL OR price = 0 THEN NULL
    ELSE CAST(price AS NUMERIC)
  END AS cleaned_price,

  -- cleaned_country
  CASE
    WHEN LOWER(country) IN ('usa', 'us') THEN 'United States'
    WHEN LOWER(country) IN ('uk', 'united kingdom') THEN 'United Kingdom'
    WHEN LOWER(country) = 'india' THEN 'India'
    WHEN LOWER(country) = 'canada' THEN 'Canada'
    WHEN LOWER(country) = 'spain' THEN 'Spain'
    ELSE INITCAP(country)
  END AS cleaned_country,

  -- cleaned_order_status
  CASE
    WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
    WHEN LOWER(order_status) LIKE '%pending%' THEN 'Pending'
    WHEN LOWER(order_status) LIKE '%ship%' THEN 'Shipped'
    WHEN LOWER(order_status) LIKE '%refund%' THEN 'Refunded'
    WHEN LOWER(order_status) LIKE '%return%' THEN 'Returned'
    ELSE 'Other'
  END AS cleaned_order_status,

  notes,

FROM `sql-portfolio-468415.sql_data_cleaning.customer_order`;



SELECT * FROM `sql-portfolio-468415.sql_data_cleaning.customer_order_cleaned`;


-- Tag potential duplicates for further review

WITH dup_check AS(
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY cleaned_customer_name, cleaned_email, cleaned_order_date, cleaned_product_name, cleaned_price
      ORDER BY order_id
    ) AS exact_dupe_rank,

    ROW_NUMBER() OVER(
      PARTITION BY cleaned_customer_name, cleaned_email, cleaned_order_date, cleaned_price
      ORDER BY order_id
    ) AS loose_dupe_rank

  FROM `sql-portfolio-468415.sql_data_cleaning.customer_order_cleaned`
  )

  SELECT
  *,
  CASE
    WHEN exact_dupe_rank > 1 THEN 'Exact Duplicate'
    WHEN loose_dupe_rank > 1 THEN 'Probable Duplicate'
    ELSE 'Unique'
  END AS dupe_flag
FROM dup_check
ORDER BY cleaned_customer_name, cleaned_order_date;

-- CREATE A DEDUPLICATED TABLE FOR ANALYSIS

CREATE OR REPLACE TABLE `sql-portfolio-468415.sql_data_cleaning.customer_order_deduplicated` AS
WITH dup_check AS(
  SELECT *,
    ROW_NUMBER() OVER(
      PARTITION BY cleaned_customer_name, cleaned_email, cleaned_order_date, cleaned_product_name, cleaned_price
      ORDER BY order_id
    ) AS exact_dupe_rank,

    ROW_NUMBER() OVER(
      PARTITION BY cleaned_customer_name, cleaned_email, cleaned_order_date, cleaned_price
      ORDER BY order_id
    ) AS loose_dupe_rank

  FROM `sql-portfolio-468415.sql_data_cleaning.customer_order_cleaned`
  )
SELECT * FROM dup_check
WHERE exact_dupe_rank = 1 AND loose_dupe_rank = 1;

SELECT * FROM `sql-portfolio-468415.sql_data_cleaning.customer_order_deduplicated`;
