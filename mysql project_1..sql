CREATE DATABASE school;
USE school;
DROP TABLE IF EXISTS sales_copy;
 
CREATE TABLE sales (
    transaction_id VARCHAR(20),
    customer_id VARCHAR(20),
    customer_name VARCHAR(50),
    customer_age INT,
    gender VARCHAR(20),
    product_id VARCHAR(20),
    product_name VARCHAR(50),
    product_category VARCHAR(30),
    quantiy INT,
    prce DECIMAL(10,2),
    payment_mode VARCHAR(20),
    purchase_date VARCHAR(20),
    time_of_purchase VARCHAR(20),
    status VARCHAR(20)
);
SELECT * FROM sales;

ALTER TABLE sales
MODIFY purchase_date DATE;
SET SQL_SAFE_UPDATES=0;
DESCRIBE sales;
  
-- check duplicate  
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY transaction_id
           ) AS row_num
    FROM sales
)
SELECT *
FROM CTE
WHERE transaction_id IN (
    'TXN855235',
    'TXN342128',
    'TXN240646',
    'TXN981773'
);
-- remove duplicates

DELETE s
FROM sales s
JOIN (
    SELECT transaction_id,
           ROW_NUMBER() OVER (
               PARTITION BY transaction_id
               ORDER BY transaction_id
           ) AS row_num,
           ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS rn
    FROM sales
    WHERE transaction_id IN ('TXN855235','TXN342128','TXN240646','TXN981773')
) AS duplicates
ON s.transaction_id = duplicates.transaction_id
AND duplicates.rn > 1;
 
 SET SQL_SAFE_UPDATES=0;
 
 -- correction header
ALTER TABLE sales
RENAME COLUMN quantiy TO quantity ;
ALTER TABLE sales
RENAME COLUMN  prce TO price ;

-- check datatype
 DESCRIBE sales;
 
-- CHECK NULL VALUES
SELECT * FROM sales
WHERE transaction_id IS NULL
OR 
customer_id IS NULL
OR
 customer_name IS NULL;
 -- DISTINCT GENDER
 SELECT DISTINCT gender FROM sales;
 
UPDATE sales
SET gender = 'F'
WHERE gender = 'Female';

UPDATE sales
SET gender = 'M'
WHERE gender = 'Male';

-- TOTAL STATUS COUNT 
SELECT status,COUNT(*) FROM sales
GROUP BY status ;

 -- DISTINCT PAYMENT MODE
 SELECT DISTINCT  payment_mode FROM sales;
 
UPDATE sales
SET payment_mode = 'Credit Card'
WHERE payment_mode = 'CC';

 SELECT DISTINCT status FROM sales;
-- top 5 product selling by Quantity
SELECT * FROM sales 
WHERE status = 'delivered' 
AND quantity >= 5  
LIMIT 5;

SELECT product_name,COUNT(*) FROM sales 
WHERE status = 'delivered' 
AND quantity >= 5  
GROUP BY product_name
LIMIT 5;

-- top 5 product that got cancel
SELECT * FROM sales 
WHERE status = 'cancelled' 
AND quantity >= 5  
LIMIT 5;

SELECT product_name,COUNT(*) FROM sales 
WHERE status = 'cancelled' 
AND quantity >= 5  
GROUP BY product_name
LIMIT 5;

-- WHAT TIME OF DAY THAT HAS HEIGHEST PURCHASE

SELECT
    CASE
        WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN HOUR(time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM sales
GROUP BY
    CASE
        WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
        WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
        WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
        WHEN HOUR(time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
    END
ORDER BY total_orders DESC;
-- TOP 5 SPENDING CUSTOMER
SELECT customer_name,
 CONCAT('₹', FORMAT(SUM(price * quantity), 0,'en-IN')) AS total_spend
FROM SALES
GROUP BY customer_name 
ORDER BY SUM(price * quantity) DESC 
LIMIT 5;
 
 
--  WHICH PRODUCT CATEGORIES GENERATE HEIGHEST REVENUE  
SELECT product_category,
 CONCAT('₹', FORMAT(SUM(price * quantity), 0,'en-IN')) AS heighest_sales
FROM sales
GROUP BY product_category
ORDER BY  SUM(price * quantity) DESC;

-- WHAT IS THE RETURN/CANCELLATION RATE PRODUCT CATEGORIES
-- CANCEL
SELECT * FROM sales;
SELECT product_category,
CONCAT(FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'2'),'%' ) AS cancelled_percentage
FROM sales
GROUP BY product_category
ORDER BY  cancelled_percentage DESC;

-- RETURNED
SELECT product_category,
CONCAT(FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'2'),'%' ) AS  returned_percentage
FROM sales
GROUP BY product_category
ORDER BY  returned_percentage DESC;

-- WHAT IS MOST PREFFERED PAYMENT METHOD
SELECT payment_mode,COUNT(*) AS total_payment_number
FROM sales
GROUP BY payment_mode
ORDER BY total_payment_number DESC;

-- WHICH AGE GROUP SHOPTHE MOST
SELECT MIN(customer_age),MAX(customer_age) FROM sales;
SELECT 
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
         WHEN customer_age BETWEEN 26 AND 35 THEN '18-35'
		 WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
          WHEN customer_age BETWEEN 46 AND 60 THEN '46-60'
    END AS customer_age,
    CONCAT('₹', FORMAT(SUM(price * quantity), 0,'en-IN'))  AS total_purchase 
FROM sales
GROUP BY CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
         WHEN customer_age BETWEEN 26 AND 35 THEN '18-35'
		 WHEN customer_age BETWEEN 36 AND 45 THEN '36-45'
          WHEN customer_age BETWEEN 46 AND 60 THEN '46-60'
    END
ORDER BY  SUM(price * quantity) DESC;

-- WHAT IS THE SALES TREND ?
SELECT * FROM sales;

SELECT 
    DATE_FORMAT(purchase_date, '%Y-%m') AS Month_Year,
    CONCAT('₹', FORMAT(SUM(price * quantity), 0)) AS total_sale,
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY DATE_FORMAT(purchase_date, '%Y-%m')
ORDER BY DATE_FORMAT(purchase_date, '%Y-%m'); 

-- CERTAIN GENDER BUYING SPECIFIC CATEGORY ?
-- METHOD-1
SELECT gender,product_category,COUNT(product_category) AS total_purchase 
FROM sales
GROUP BY gender,product_category
ORDER BY  gender;

-- METHOD-2
SELECT
    product_category,
    COUNT(CASE WHEN gender = 'F' THEN 1 END) AS Female_Count,
    COUNT(CASE WHEN gender = 'M' THEN 1 END) AS Male_Count
FROM sales
GROUP BY product_category
ORDER BY product_category;

    
    
    
    