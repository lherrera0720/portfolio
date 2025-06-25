-- ==========================
-- Section: Data Cleaning
-- Author: Lemuel D. Herrera
-- Date: 23June2025
-- ==========================

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
FROM (
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

-- 3. Product & Category Performance


































