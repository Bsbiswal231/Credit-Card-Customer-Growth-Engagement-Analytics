-- 01. How many customers are Active vs Inactive?
SELECT engagement_status,
       count(*) AS customer_count
FROM customers
GROUP BY engagement_status;

-- 02. Which segment drives most of the revenue?
SELECT engagement_status,
       ROUND(SUM(total_spend):: NUMERIC,2) AS total_revenue
FROM customers
GROUP BY engagement_status;

-- 03. Who are the top high-value customers?
SELECT credit_card_num,
       total_spend,
	   transaction_count
FROM customers
ORDER BY total_spend DESC
LIMIT 5;

-- 04. Which inactive customers still have high value?
SELECT credit_card_num,
       total_spend,
	   days_since_last_transaction
FROM customers
WHERE engagement_status = 'Inactive'
ORDER BY total_spend DESC
LIMIT 5;

-- 05. How does transaction behavior differ by engagement status?
SELECT c.engagement_status,
       count(t.*) AS transaction_count,
	   ROUND(SUM(t.amt):: NUMERIC,2) AS transaction_revenue
FROM transactions AS t
JOIN customers AS c
  ON t.credit_card_num = c.credit_card_num
GROUP BY c.engagement_status;

-- 06. Where do engaged customers spend the most?
SELECT t.category,
       ROUND(SUM(t.amt)::NUMERIC,2) AS total_spend
FROM transactions AS t
JOIN customers as c
   ON t.credit_card_num = c.credit_card_num
WHERE c.engagement_status = 'Active'
GROUP BY t.category
ORDER BY total_spend DESC
LIMIT 5;

-- 07. Which customers are close to becoming inactive?
SELECT credit_card_num,
       days_since_last_transaction,
	   total_spend
FROM customers
WHERE days_since_last_transaction BETWEEN 45 AND 50
ORDER BY days_since_last_transaction DESC;

-- 08. Which customers contribute the most revenue within each engagement segment?
SELECT engagement_status,
       credit_card_num,
       total_spend
FROM (
    SELECT engagement_status,
           credit_card_num,
           total_spend,
           RANK() OVER (
               PARTITION BY engagement_status
               ORDER BY total_spend DESC
           ) AS spend_rank
    FROM customers
) ranked_customers
WHERE spend_rank <= 5
ORDER BY engagement_status, total_spend DESC;

-- 09. How does customer spending behavior differ between Active and Inactive segments?
SELECT engagement_status,
       ROUND(AVG(total_spend)::NUMERIC, 2) AS avg_total_spend,
       ROUND(AVG(transaction_count)::NUMERIC, 1)  AS avg_transaction_count,
       ROUND(AVG(avg_spend)::NUMERIC, 2) AS avg_ticket_size
FROM customers
GROUP BY engagement_status;

-- 10. Which months generate higher revenue from Active customers?
SELECT DATE_TRUNC('month', t.transaction_date) AS month,
       ROUND(SUM(t.amt)::NUMERIC, 2) AS active_customer_revenue
FROM transactions AS t
JOIN customers 	AS c
  ON t.credit_card_num = c.credit_card_num
WHERE c.engagement_status = 'Active'
GROUP BY month
ORDER BY active_customer_revenue DESC
LIMIT 5;













