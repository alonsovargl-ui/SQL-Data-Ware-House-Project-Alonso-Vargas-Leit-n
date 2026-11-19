/*
================================================================================
Product Report
================================================================================
Purpose:
	-This report conslidates key product metrics and behaiviors.

Highlights:
	1. Gathers essential fields such as product name, category, subcategoty, and cost.   check (1st query)
	2. Segments products by revenue to identify High-Performers, Mid-Range, Low-Performers.
	3. Aggregates product-level metrics:  check
		- total orders
		- total sales
		- total queantity sold
		- total customers (unique)
		- lifespan (in months)
	4. Calculate vvaluables KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
================================================================================
*/
CREATE VIEW gold.report_products AS 
WITH base_query_products AS (

/*
--------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------------------------
*/ 
	SELECT 
	f.order_number,
	f.sales_amount,
	f.quantity,
	f.customer_key,
	f.order_date,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.product_cost
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE order_date IS NOT NULL
), 

/*
--------------------------------------------------------------------------------
2) Producst Aggregations: Sumarizes key metrics at the product level
--------------------------------------------------------------------------------
*/
product_aggregation AS (
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity_sold,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) total_customers,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) lifespan,
	ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity,0)),1) AS avg_selling_price
FROM base_query_products 
GROUP BY
	product_key,
	product_name,
	category,
	subcategory,
	product_cost
)

-- Final Query..
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	product_cost,
	last_order_date,
	DATEDIFF(MONTH, last_order_date, GETDATE()) recency_in_months,
	CASE
		 WHEN total_sales >= 100000 THEN ' High-Performers '
		 WHEN total_sales >= 50000 THEN ' Mid-Range '
		 ELSE ' Low-Performers'
	END product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_customers,
	avg_selling_price,
	CASE
		WHEN total_orders = 0 THEN 0                -- compute avr order revenue (AOR)
		ELSE total_sales / total_orders 
	END AS avg_order_revenue,
	CASE
		WHEN lifespan = 0 THEN total_sales               -- compute avr monthly revenue 
		 ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregation;

