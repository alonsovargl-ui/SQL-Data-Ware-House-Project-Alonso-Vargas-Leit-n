/*
=====================================================================================================================
DDL Script:
=====================================================================================================================

Script propuse:
  This script creates views for the Gold layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables (Star Schema)

  Each view performs transformations and comnbines data from the Silver Layer
  to produce a clean, enriched and business ready data set. 

Usage:
  -These views can be required directly for analytics and reporting.
=====================================================================================================================
*/

--==================================================================================
-- Create dimenison: gold.dim_customers
--==================================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IF NOT NULL 
	DROP VIEW gold.dim_customers;

GO 
 
CREATE gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS customer_first_name,
	ci.cst_lastname AS customer_last_name,
	la. cntry AS country,
	ci.cst_marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the master for Mender info 
	ELSE COALESCE(ca.gen, 'n/a')
	END AS gender,
	ca.bdate AS bithdate, 
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_az12_ ca
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid

--==================================================================================
-- Create dimenison: gold.dim_products
--==================================================================================

IF OBJECT_ID('gold.dim_products', 'V') IF NOT NULL 
	DROP VIEW gold.dim_products;

GO 

CREATE gold.dim_products AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY  pn.prd_start_dt, pn.prd_key) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	COALESCE(pc.cat, 'N/A') AS category,			 -- Reemplaza NULL por 'N/A'
    COALESCE(pc.subcat, 'N/A') AS subcategory,		 -- Reemplaza NULL por 'N/A'
    COALESCE(pc.maintenance, 'N/A') AS maintenace,	 -- Reemplaza NULL por 'N/A'
	pn.prd_cost AS product_cost,
	pn.prd_line AS product_line,
    pn.prd_start_dt AS product_start_date
FROM silver.crm_prd_info pn
LEFT JOIN  silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL

--==================================================================================
-- Create Fact: gold.fact_sales
--==================================================================================

IF OBJECT_ID('gold.fact_sales', 'V') IF NOT NULL 
	DROP VIEW gold.fact_sales;


