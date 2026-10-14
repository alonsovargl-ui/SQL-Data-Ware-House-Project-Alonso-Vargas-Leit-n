/*
====================================================================================
Quality Checks
====================================================================================
Script Prurpose:
  This script performs varios quality chjecks for data consistency, accuracy, 
  and standarization across the 'silve schema. it includes checks for:
  - Null or duplicates primary keys.
  - Unwanted spaces in string fields.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage notes:
  - Run thes checks after loading Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
====================================================================================
*/ 

-- ====================================================================================
-- Cheking 'silver.crm_cust_info'
-- ====================================================================================
-- Check for nulls or duplicates in primary key
--expectation: No Results.
SELECT 
cst_id,
COUNT (*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces in cust_info, for the String values... 
--Expectation: No Results... 
SELECT cst_firstname
FROM silver.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname)

 -- Data  standarization & consistency.
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info 


-- ====================================================================================
-- Cheking 'silver.crm_prd_info'
-- ====================================================================================
 -- Check for nulls or duplicates in primary key
--expectation: No Results.
SELECT 
prd_id,
COUNT (*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check for unwanted spaces in cust_info, for the String values... 
--Expectation: No Results... 
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- check for NULLS or negative #s 
--Expectation: No Results..

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost <0 OR prd_cost IS NULL 

 -- Data  standarization & consistency.
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for invalid dates (END DATE MUST NOT BE SMALLER THAN START )
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt


-- ====================================================================================
-- Cheking 'silver.crm_sls_info'
-- ====================================================================================
-- Check for invalid Date Orders 
-- No Results
SELECT DISTINCT
 sls_sales,
 sls_quantity,
 sls_price
FROM silver.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL 
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price


-- ====================================================================================
-- Cheking 'silver.erp_az12_'
-- ====================================================================================
-- identify out-of-range date
SELECT DISTINCT 
BDATE
FROM silver.erp_az12_
WHERE BDATE < '1924' OR BDATE > GETDATE()


-- ====================================================================================
-- Cheking 'silver.erp_loc_a101'
-- ====================================================================================
-- Data Standarization & consistency
SELECT DISTINCT 
cntry
FROM silver.erp_loc_a101
ORDER BY cntry

