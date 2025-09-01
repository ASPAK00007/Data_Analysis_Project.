CREATE TABLE superstore (
    row_id INT PRIMARY KEY,
    order_id VARCHAR(20),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(20),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(20),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name VARCHAR(200),
    sales NUMERIC(10,2),
    quantity INT,
    discount NUMERIC(5,2),
    profit NUMERIC(10,2),
    delivery_days INT,
    month_name VARCHAR(20),
    year INT
);


select *
from superstore;



COPY superstore(row_id, order_id, order_date, ship_date, ship_mode, customer_id, customer_name,
                segment, country, city, state, postal_code, region, product_id, category, sub_category,
                product_name, sales, quantity, discount, profit, delivery_days, month_name, year)
FROM   'C:\full_clean_superstore.csv'
DELIMITER ','
CSV HEADER;


select *
from superstore;



-- 1. Total Sales, Total Profit, Total Orders
-- Query to calculate the overall total sales, total profit, and total number of orders.
SELECT SUM(SALES)AS TOTAL_SALES,SUM(PROFIT) AS TOTAL_PROFIT, COUNT(ORDER_ID) AS TOTAL_ORDER
FROM SUPERSTORE ;


-- 2. Sales by Region
-- Query to calculate total sales grouped by each region.
SELECT REGION,SUM(SALES) AS TOTAL_SALES
FROM SUPERSTORE
GROUP BY region
ORDER BY TOTAL_SALES DESC;



-- 3. Sales by Category & Sub-Category
-- Query to calculate total sales for each category and its sub-categories.
SELECT 
CATEGORY,
SUB_CATEGORY,
SUM(SALES) AS TOTAL_SALES
FROM SUPERSTORE
GROUP BY CATEGORY,SUB_CATEGORY 
ORDER BY TOTAL_SALES DESC;


-- 4. Top 10 Customers by Sales
-- Query to list the top 10 customers with the highest total sales.
SELECT customer_name, sum(sales) as total_sales
from superstore
group by customer_name
order by total_sales desc
limit 10;



-- 5. Top 10 Customers by Profit
-- Query to list the top 10 customers generating the highest profit.
SELECT 
    customer_name, SUM(profit) AS total_profits
FROM
    superstore
GROUP BY customer_name
ORDER BY total_profits DESC
LIMIT 10;


-- 6. Products with Negative Profit
-- Query to identify products where profit is less than zero.

SELECT 
    product_name, SUM(profit) AS total_profits
FROM
    superstore
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profits ASC;


-- 7. Sales Trend by Month-Year
-- Query to show total sales grouped by month and year to analyze trends.

SELECT 
    month_name, year, SUM(sales) AS total_sales
FROM
    superstore
GROUP BY month_name , year
ORDER BY total_sales DESC;

-- 8. Region-wise Profit Margin %
-- Query to calculate profit margin percentage (Profit / Sales * 100) for each region.

SELECT 
    region,
    SUM(profit) AS total_profits,
    SUM(sales) AS total_sales,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS region_profit_margin
FROM
    superstore
GROUP BY region
ORDER BY region_profit_margin DESC;



-- 9. State with Highest Sales
-- Query to find the state contributing the maximum sales.

SELECT 
    state, SUM(sales) AS sale
FROM
    superstore
GROUP BY state
ORDER BY sale DESC
LIMIT 1;

-- 10. Average Discount by Category
-- Query to calculate average discount offered per product category.

SELECT 
    category, ROUND(AVG(discount), 2) AS avg_dis
FROM
    superstore
GROUP BY category
ORDER BY avg_dis DESC;

-- 11. Customers who Purchased More than 1 Unique Category
-- Query to identify customers who bought products from more than one category.

SELECT 
    customer_name, COUNT(DISTINCT category) AS category_uni
FROM
    superstore
GROUP BY customer_name
HAVING COUNT(DISTINCT category) < 1
ORDER BY category_uni DESC;

-- 12. Compare Profit vs Discount
-- Query to analyze whether higher discounts are reducing profit (Profit vs Discount correlation).

SELECT 
    discount, ROUND(AVG(profit), 2) AS coor
FROM
    superstore
GROUP BY discount
ORDER BY discount DESC;

-- 13. Fastest and Slowest Delivery
-- Query to calculate delivery duration (Ship Date - Order Date) and find fastest & slowest deliveries.

SELECT 
    order_id,
    customer_name,
    ship_date,
    order_date,
    (ship_date - order_date) AS delevry_days
FROM
    superstore
ORDER BY delevry_days DESC;

-- 14. Most Profitable Segment
-- Query to find which customer segment (Consumer, Corporate, Home Office) generates the most profit.

SELECT 
    segment, SUM(profit) AS profit_segment
FROM
    superstore
GROUP BY segment
ORDER BY profit_segment DESC;

-- 15. Yearly Sales Growth %
-- Query to calculate year-over-year sales growth percentage compared to the previous year.

WITH yearly_sales AS (
    SELECT 
        EXTRACT(YEAR FROM order_date)::INT AS year,   -- extract year as integer
        SUM(sales) AS total_sales
    FROM superstore
    GROUP BY EXTRACT(YEAR FROM order_date)            -- group by the full expression
)
SELECT 
    year,
    total_sales,
    LAG(total_sales) OVER (ORDER BY year) AS prev_year_sales,
    ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY year)) 
          / NULLIF(LAG(total_sales) OVER (ORDER BY year), 0)) * 100, 2) AS yoy_growth_percentage
FROM yearly_sales
ORDER BY year;

