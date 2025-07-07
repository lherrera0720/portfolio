-- ==========================
-- Section: Data Cleaning
-- Author: Lemuel D. Herrera
-- Date: 23June2025
-- ==========================

-- Create the raw sales table to store unprocessed data

CREATE TABLE retail_sales_raw
(
transaction_id VARCHAR PRIMARY KEY,
customer_id VARCHAR,
category VARCHAR,
item VARCHAR,
price_per_unit VARCHAR,
quantity VARCHAR,
total_spent VARCHAR,
payment_method VARCHAR,
location VARCHAR,
transaction_date VARCHAR,
discount_applied VARCHAR
);

-- Duplicate raw data for cleaning and transformation

CREATE TABLE retail_sales_cleaned AS
SELECT *
FROM retail_sales_raw;

-- View total number of records

SELECT COUNT(*)
FROM retail_sales_cleaned;

-- Preview the first 10 records

SELECT *
FROM retail_sales_cleaned
LIMIT 10;

-- Identify duplicate transaction IDs

SELECT transaction_id, COUNT(*) duplicate
FROM retail_sales_cleaned
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- Find invalid customer IDs (should follow the format: CUST_number)

SELECT customer_id
FROM retail_sales_cleaned
WHERE customer_id !~ '^CUST_[0-9]+$';

-- Check the unique values in the category column to spot inconsistencies

SELECT DISTINCT category
FROM retail_sales_cleaned;

-- Standardize category values by trimming spaces and capitalizing words

UPDATE retail_sales_cleaned
SET category = INITCAP(TRIM(category));

-- Verify distinct categories after cleaning

SELECT DISTINCT category
FROM retail_sales_cleaned
LIMIT 10;

-- Check for null or invalid item formats (expected format: Item_number_CODE)

SELECT item, COUNT(*)
FROM retail_sales_cleaned
WHERE item IS NULL OR item !~ '^Item_[0-9]+_[A-Z]+$'
GROUP BY item;

-- Remove non-numeric characters from price_per_unit

UPDATE retail_sales_cleaned
SET price_per_unit = REGEXP_REPLACE(price_per_unit, '[^0-9\.]', '', 'g');

-- Add a new column for cleaned numeric values of price_per_unit

ALTER TABLE retail_sales_cleaned ADD COLUMN price_per_unit_cleaned NUMERIC;

-- Convert cleaned price_per_unit into numeric format

UPDATE retail_sales_cleaned
SET price_per_unit_cleaned = NULLIF(price_per_unit, '')::NUMERIC;

-- Inspect cases where price_per_unit_cleaned is null or zero

SELECT price_per_unit, price_per_unit_cleaned
FROM retail_sales_cleaned
WHERE price_per_unit_cleaned IS NULL OR price_per_unit_cleaned = 0
LIMIT 50;

-- Check for unusual quantity values (e.g. decimals)

SELECT quantity, COUNT(*)
FROM retail_sales_cleaned
GROUP BY quantity;

SELECT quantity, COUNT(*)
FROM retail_sales_cleaned
WHERE quantity ~ '\.\d+'
GROUP BY quantity;

-- Remove non-numeric characters from quantity

UPDATE retail_sales_cleaned
SET quantity = REGEXP_REPLACE(quantity, '[^0-9\.]', '', 'g');

-- Add a new column for cleaned integer quantity

ALTER TABLE retail_sales_cleaned
ADD COLUMN quantity_cleaned INTEGER;

-- Clean and insert integer values into quantity_cleaned

UPDATE retail_sales_cleaned
SET quantity_cleaned = NULLIF(quantity, '')::NUMERIC::INTEGER;

-- Review cleaned quantity values

SELECT DISTINCT quantity_cleaned
FROM retail_sales_cleaned
ORDER BY quantity_cleaned;

-- Identify invalid total_spent entries (non-numeric)

SELECT total_spent
FROM retail_sales_cleaned
WHERE NOT total_spent ~ '^\s*\d+(\.\d+)?\s*$';

-- Add a new column for cleaned numeric total_spent

ALTER TABLE retail_sales_cleaned ADD COLUMN total_spent_cleaned NUMERIC;

-- Remove non-numeric characters from total_spent

UPDATE retail_sales_cleaned
SET total_spent = REGEXP_REPLACE(total_spent, '[^0-9\.]', '', 'g');

-- Convert total_spent to numeric

UPDATE retail_sales_cleaned
SET total_spent_cleaned = NULLIF(total_spent, '')::NUMERIC;

-- View cleaned total_spent values

SELECT total_spent, total_spent_cleaned
FROM retail_sales_cleaned
ORDER BY total_spent
LIMIT 100;

-- Count records with null total_spent_cleaned

SELECT COUNT(*) AS null_count
FROM retail_sales_cleaned
WHERE total_spent_cleaned IS NULL;

-- Check distinct values for payment_method and location

SELECT DISTINCT payment_method
FROM retail_sales_cleaned;

SELECT DISTINCT location
FROM retail_sales_cleaned;

-- Preview raw transaction dates

SELECT transaction_date
FROM retail_sales_cleaned;

-- Add a new column for cleaned transaction_date

ALTER TABLE retail_sales_cleaned ADD COLUMN transaction_date_cleaned DATE;

-- Convert string date into DATE type

UPDATE retail_sales_cleaned
SET transaction_date_cleaned = TO_DATE(transaction_date, 'YYYY-MM-DD');

-- Preview cleaned dates

SELECT transaction_date_cleaned
FROM retail_sales_cleaned;

-- Review discount_applied values

SELECT DISTINCT discount_applied
FROM retail_sales_cleaned;

-- Add a new boolean column for cleaned discount status

ALTER TABLE retail_sales_cleaned ADD COLUMN discount_applied_cleaned BOOLEAN;

-- Convert 'true'/'false' strings to boolean

UPDATE retail_sales_cleaned
SET discount_applied_cleaned =
	CASE
		WHEN LOWER(discount_applied) = 'true' THEN TRUE
		WHEN LOWER(discount_applied) = 'false' THEN FALSE
		ELSE NULL
	END;

-- Review cleaned discount values

SELECT discount_applied_cleaned
FROM retail_sales_cleaned;

-- Drop the original unclean columns after successful transformation

ALTER TABLE retail_sales_cleaned
DROP COLUMN price_per_unit,
DROP COLUMN quantity,
DROP COLUMN total_spent,
DROP COLUMN transaction_date,
DROP COLUMN discount_applied;

-- Check for records with missing essential cleaned values

SELECT *
FROM retail_sales_cleaned
WHERE price_per_unit_cleaned IS NULL
OR quantity_cleaned IS NULL
OR total_spent_cleaned IS NULL;

-- Delete records with nulls in critical columns

DELETE FROM retail_sales_cleaned
WHERE price_per_unit_cleaned IS NULL
OR quantity_cleaned IS NULL
OR total_spent_cleaned IS NULL;

-- Double-check that no nulls remain

SELECT *
FROM retail_sales_cleaned
WHERE price_per_unit_cleaned IS NULL
OR quantity_cleaned IS NULL
OR total_spent_cleaned IS NULL;

-- Final preview of cleaned dataset

SELECT * 
FROM retail_sales_cleaned;

-- Rename the cleaned table to mark it as final

ALTER TABLE retail_sales_cleaned
RENAME TO retail_sales_final;

-- Final check of cleaned and finalized data

SELECT *
FROM retail_sales_final;