-- ==================================
-- Section: Exploratory Data Analysis
-- Author: Lemuel Herrera
-- Date: 23June2025
-- ==================================

-- 1. Basic Summary Stats

-- Get the total number of transactions

SELECT COUNT(*)
FROM retail_sales_final;

-- Calculate the total revenue generated

SELECT SUM(total_spent_cleaned) total_revenue
FROM retail_sales_final;

-- Determine the average number of items per transaction

SELECT AVG(quantity_cleaned) avg_quantity_per_transaction
FROM retail_sales_final;

-- Calculate the average total amount spent per transaction

SELECT AVG(total_spent_cleaned) avg_spent_per_transaction
FROM retail_sales_final;

-- 2. Customer Behavior Analysis

-- Identify top 10 customers based on total spending

SELECT customer_id, SUM(total_spent_cleaned) total_spent
FROM retail_sales_final
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Compute the average total spend per customer

SELECT AVG(total_spent) AS avg_spent_per_customer
FROM
(
SELECT customer_id, SUM(total_spent_cleaned) AS total_spent
FROM retail_sales_final
GROUP BY customer_id
) AS customer_summary;

-- Compare number of one-time vs returning customers

SELECT 
  COUNT(*) FILTER (WHERE txn_count = 1) one_time_customers,
  COUNT(*) FILTER (WHERE txn_count > 1) returning_customers
FROM 
(
  SELECT customer_id, COUNT(*) txn_count
  FROM retail_sales_final
  GROUP BY customer_id
) AS customer_txn_counts;

-- Get the most frequently purchased item for each customer

WITH ranked_items AS
(
  SELECT customer_id, item, COUNT(*) AS purchase_count,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rn
  FROM retail_sales_final
  GROUP BY customer_id, item
)
SELECT customer_id, item, purchase_count
FROM ranked_items
WHERE rn = 1
ORDER BY customer_id;

-- 3. Product & Category Performance

-- Identify the top 10 most sold items based on quantity

SELECT item, SUM(quantity_cleaned) total_quantity_sold
FROM retail_sales_final
GROUP BY item
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Get total revenue per product category

SELECT category, SUM(total_spent_cleaned) total_revenue
FROM retail_sales_final
GROUP BY category
ORDER BY total_revenue DESC;

-- Calculate the average price per unit by category

SELECT category, AVG(price_per_unit_cleaned) avg_unit_price
FROM retail_sales_final
GROUP BY category
ORDER BY avg_unit_price DESC;

-- 4. Time Series & Trend Analysis

-- Analyze daily revenue trends

SELECT transaction_date_cleaned AS date,
SUM(total_spent_cleaned) AS daily_revenue
FROM retail_sales_final
GROUP BY date
ORDER BY date;

-- Analyze monthly revenue trends

SELECT DATE(DATE_TRUNC('month', transaction_date_cleaned)) AS month,
SUM(total_spent_cleaned) total_revenue
FROM retail_sales_final
GROUP BY month
ORDER BY month;

-- Identify top 10 days with highest sales

SELECT transaction_date_cleaned AS date, SUM(total_spent_cleaned) daily_revenue
FROM retail_sales_final
GROUP BY date
ORDER BY daily_revenue DESC
LIMIT 10;

-- 5. Discounts Analysis

-- Compare revenue between discounted and non-discounted transactions

SELECT discount_applied_cleaned AS discount_status,
COUNT(*) AS transaction_count,
SUM(total_spent_cleaned) AS total_revenue
FROM retail_sales_final
GROUP BY discount_applied_cleaned;

-- Analyze average spend per transaction based on discount status

SELECT discount_applied_cleaned AS discount_status,
AVG(total_spent_cleaned) AS avg_spent_per_transaction
FROM retail_sales_final
GROUP BY discount_status;

-- 6. Payment & Location Insights

-- Analyze revenue by payment method

SELECT payment_method, SUM(total_spent_cleaned) total_revenue
FROM retail_sales_final
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Analyze revenue by store location

SELECT location, SUM(total_spent_cleaned) total_revenue
FROM retail_sales_final
GROUP BY location
ORDER BY total_revenue DESC;
















