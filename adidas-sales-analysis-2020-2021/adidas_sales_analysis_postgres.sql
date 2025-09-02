use 
CREATE TABLE Sales_Data (
    Retailer VARCHAR(100),
    Retailer_ID INT,
    Invoice_Date DATE,
    Region VARCHAR(50),
    State VARCHAR(100),
    City VARCHAR(100),
    Product VARCHAR(150),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Revenue DECIMAL(15,2),
    Profit DECIMAL(15,2),
    Channel VARCHAR(50),
    Year INT,
    Month_Name VARCHAR(20),
    Quarter VARCHAR(10)
);


COPY Sales_Data(Retailer,Retailer_ID,Invoice_Date,Region,State,City,Product,Unit_Price,Quantity,Revenue,Profit,Channel,Year,Month_Name,Quarter)
FROM   'C:\Addidas_Sales_Data.csv'
DELIMITER ','
CSV HEADER;

select *
from sales_data ;


select sum(revenue) as total_sales
from sales_data;

select sum(profit) as toal_profits
from sales_data;

select count(quantity) as total_quantity
from sales_data;

select distinctco) as total_quantity
from sales_data;

-- What are the top 5 products based on total sales?

select product,sum(revenue) as total_sales
from sales_data
group by product
order by total_sales desc
limit 5 ;

-- What are the top 5 products based on total profit?
select product,sum(profit) as total_profit
from sales_data
group by product
order by total_profit desc
limit 5 ;


-- Who are the top 5 retailers based on total sales?
select retailer,sum(revenue) as total_sales
from sales_data
group by retailer
order by total_sales DESC
LIMIT 5 ;


-- Who are the top 5 retailers based on total profit?

select retailer,sum(profit) as total_profit
from sales_data
group by retailer
order by total_profit DESC
LIMIT 5 ;

-- Top Performers: Identify our top 5 products and top 5 retailers based on both sales and profit.

select retailer,sum(revenue) as Total_Sales,sum(profit) as Total_Profit
from sales_data
group by retailer 
order by Total_Sales desc
limit 5;


Retailer


-- Q4. Geographic Trends

select *
from sales_data ;


-- Which region had the highest total sales?
select region,sum(revenue) as total_sales,sum(profit) as total_profit
from sales_data
group by region
order by total_sales desc
limit 1 ; 

-- Which region was the most profitable?

select region,sum(profit) as total_profit
from sales_data
group by region
order by total_profit DESC ; 

-- Which state had the highest total sales?


select state,sum(revenue) as total_sales,sum(profit) as total_profit
from sales_data
group by state
order by total_sales desc
limit 1 ;

select state,sum(revenue) as high_total_sales
from sales_data
group by state
order by high_total_sales DESC
LIMIT 1 ; 

-- Which state was the most profitable?

select state,sum(revenue) as high_total_profit
from sales_data
group by state
order by high_total_profit DESC
LIMIT 1 

-- Q5. Seasonal Patterns

select *
from sales_data ;

-- How do sales change over different months of the year?
select year,month_name,sum(revenue) as total_sales
from sales_data
group by year,month_name
order by year,min(invoice_date) desc;


-- Which quarter shows the highest sales?
select quarter,sum(revenue) as total_sales
from sales_data
group by quarter
order by total_sales desc
limit 1 ;


-- Are there any noticeable sales trends (increase/decrease) over time?

select year,sum(revenue) as total_sales,sum(profit) as total_profit
from sales_data
group by year
order by year;

-- Q6. Sales Method Efficiency

select channel,sum(revenue) as total_Revenue
from sales_data
group by channel
order by total_Revenue desc ;

-- Compare sales performance by sales method (e.g., Online vs In-store).

select channel,sum(revenue) as total_Revenue
from sales_data
group by channel
order by total_Revenue desc ;
-- Which sales method generated the highest revenue?

select channel,sum(revenue) as total_Revenue
from sales_data
group by channel
order by total_Revenue desc 
limit 1 ;SELECT 
    channel, SUM(profit) AS total_profit
FROM
    sales_data
GROUP BY channel
ORDER BY total_profit DESC;

-- Which sales method generated the highest profit?
SELECT 
    channel, SUM(profit) AS total_profit
FROM
    sales_data
GROUP BY channel
ORDER BY total_profit DESC;











