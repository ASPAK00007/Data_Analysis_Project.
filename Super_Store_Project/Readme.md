Superstore Data Analysis Project


Overview


This project provides a complete analysis of a Superstore dataset to find key insights that can help in making strategic business decisions. By using SQL for data analysis and Power BI for visualization, this project helps to identify opportunities to increase profit, optimize sales strategies, and understand customer behavior.

Project Files
superstoreanalysis.sql: This file contains all the SQL queries used to perform the data analysis.

Superstore_Cleaned.ipynb: A Jupyter Notebook used for data cleaning and preprocessing steps, including finding and handling null values.

project.pbix: This Power BI file contains a full dashboard and visualizations created using insights from the SQL analysis.

Key Findings & Recommendations
This analysis highlights useful findings across financial performance, customer segmentation, regional analysis, and the impact of discounts on sales.

Overall Financial Performance
The Superstore has a strong financial foundation with impressive total sales and a good profit margin.

Total Sales: $1,099,862.26

Total Profit: $132,516.24

Total Orders: 5,009

The following SQL query was used to find these key metrics:

SELECT 
    SUM(SALES) AS TOTAL_SALES,
    SUM(PROFIT) AS TOTAL_PROFIT,
    COUNT(ORDER_ID) AS TOTAL_ORDER
FROM
    SUPERSTORE;

Profitability by Customer Segment :
The analysis of customer segments reveals that a specific group contributes a significant portion of the company's profit.

SELECT 
    segment, SUM(profit) AS profit_segment
FROM
    superstore
GROUP BY segment
ORDER BY profit_segment DESC;


Recommendation: To maximize return on investment, the company must focus marketing campaigns and loyalty programs on the most profitable segments.


The Impact of Discounts on Profit
A critical finding is the direct correlation between discounts and profitability. While discounts can help increase sales, they often negatively affect profits and can 
even lead to losses.


SELECT 
    discount, ROUND(AVG(profit), 2) AS correlation
FROM
    superstore
GROUP BY discount
ORDER BY discount DESC;


Recommendation: The current discount strategy should be re-evaluated. Consider setting a minimum profit margin for discounted items or creating a pricing model that balances sales incentives with stable profits.


Regional Performance and Key Products
This section analyzes regional performance, states with the highest sales, and products with negative profit margins.


Region

Total Profits

Total Sales

State Highest Sales

East

$52,445.72

$330,694.65

15.86

West

$47,420.61

$332,443.79

14.26

South

$21,292.81

$190,409.23

11.18

Central

$11,357.10

$246,314.59

4.61


Query to find the top performing state by sales:


SELECT 
    state, SUM(sales) AS sale
FROM
    superstore
GROUP BY state
ORDER BY sale DESC
LIMIT 1;


Query to find the top performing region by sales:

SELECT 
    REGION, SUM(SALES) AS TOTAL_SALES
FROM
    SUPERSTORE
GROUP BY region
ORDER BY TOTAL_SALES DESC;


Products with Negative Profit: This analysis also identified products with a negative profit.


SELECT 
    product_name, SUM(profit) AS total_profits
FROM
    superstore
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profits ASC;


Recommendation: Review the pricing for these products to prevent losses and ensure a stable profit margin.



Methodology
Here's how I approached this analysis:


Data Cleaning & Exploration: First, I cleaned and preprocessed the raw data using a Jupyter Notebook. This involved handling missing values, correcting data types, and making sure the data was in good shape.


Data Analysis: Next, I used SQL to perform a deep-dive analysis on key business questions. I then used those insights and metrics to create a full report and dashboard in Power BI.


Getting Started

Want to try out the project yourself? Here's how to get started.
What you'll need
For SQL: You'll need a relational database system (like MySQL or PostgreSQL) to load and run the SQL queries.

For the Jupyter Notebook: You'll need to have Python installed.

For Power BI: Make sure you have Power BI Desktop installed.

Setting up the project
For Python Dependencies: Open your terminal or command prompt and run this simple command to install the required library for the Jupyter Notebook:

pip install pandas

Running the project
SQL Analysis: Load the raw Superstore dataset into your SQL database. Then, open the superstoreanalysis.sql file and run the queries to see the results.

Data Cleaning: Open the Superstore_Cleaned.ipynb file in a Jupyter environment to follow the data cleaning and preprocessing steps.

Power BI Dashboard: Just open the project.pbix file with Power BI Desktop to interact with the dashboard and visualizations.
