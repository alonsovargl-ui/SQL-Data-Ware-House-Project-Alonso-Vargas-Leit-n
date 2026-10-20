/* 
================================================================================================
Quality Checks
================================================================================================
Script Purpose:
  This srcipt performs quality checks to validate the intehrity, consistency.
  and accuracy of the Gold Layer. These checks ensure:
  - Uniqueness of surrogote keys in dimmension tables.
  - Referal integrity between fact and dimension tables.
  - Validation of relationships in the data model for analytical purposes.

Usage Notes: 
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies found during checks.
================================================================================================
*/

-- =============================================================================================
--Checking 'gold.dim_customers'
-- =============================================================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No Results

SELECT 
	customer_key,
	COUNT(*) AS duoplicate_count
FROM gold.dim_customers
GROUP BY customer_key 
HAVING COUNT(*) > 1; 

