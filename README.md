# SQL-Data-Cleaning-in-Google-BigQuery

## PROJECT OVERVIEW
  This project demonstrates the process of cleaning, standardizing, and deduplicating customer order data using SQL in Google BigQuery. It covers handling inconsistent data formats, missing values, and identifying duplicate orders through exact and fuzzy matching techniques.

## DATASET DESCRIPTION
  The dataset used in this project was individually generated to simulate customer order records for a fictional retail company. It contains approximately 15 rows and includes fields such as order ID, customer name, email, order date, product name, quantity, price, country, order status, and notes.

The dataset was intentionally created to include common data quality issues that often arise in real-world data, including:
- Multiple inconsistent date formats (e.g., YYYY-MM-DD, MM/DD/YYYY, YYYY/MM/DD)
- Variations in product names due to inconsistent casing and spelling
- Missing values in important fields such as customer name, email, and price
- Duplicate orders with slight differences in product names, prices, or order status
- Malformed or inconsistent email addresses
- Country names in varying formats and cases
This synthetic dataset provided a realistic scenario for testing data cleaning and deduplication techniques using BigQuery SQL.

## CLEANING AND TRANSFORMATION

![Issues Log][queries\issues_log.png]

- Standardized `order_status` into clear categories: Delivered, Pending, Shipped, etc.  
- Normalized product names to a consistent format (e.g., "Apple Watch").  
- Parsed various date formats into a single `YYYY-MM-DD` format using regex and BigQuery date functions.  
- Cleaned quantity column by converting textual numbers to integers.  
- Corrected email and country case and removed invalid formats.  
- Tagged duplicates using window functions (ROW_NUMBER) for exact and loose matching.

## FINDINGS AND CHALLENGES
  During the data cleaning process, several null or missing values were identified in key fields such as customer name, email, and price. These nulls were intentionally left in the dataset because they require further investigation and validation by relevant stakeholders or other departments before removal or correction. This approach ensures that potentially important records are not prematurely discarded, maintaining data integrity and allowing for informed decision-making.

  Additionally, duplicates were carefully tagged rather than immediately deleted to allow for review of edge cases where slight variations could represent valid distinctions. Handling inconsistent formats, especially in dates and product names, also presented challenges that were addressed with regex-based parsing and standardization techniques.

## NOTES ON DEDUPLICATION
  The deduplicated dataset provided in this project was created primarily for demonstration purposes. In a real-world scenario, before removing any duplicate records entirely, I would collaborate closely with stakeholders and domain experts to validate which entries should be retained or merged. This ensures that important nuances are preserved and that the data cleaning process supports business needs and decision-making without unintended data loss.
