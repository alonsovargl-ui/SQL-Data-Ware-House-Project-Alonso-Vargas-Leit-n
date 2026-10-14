/*
====================================================================================
DDL Script: Create Silver Tables
====================================================================================
Script Propuse: 
  This script creates tables in the 'silver'schema, dropping existing tables 
  if they already exist.
  Run this script to re-define the DDL structure of 'bronze tables'
====================================================================================
*/



-- CRM Source
--crm_cust_info
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL 
	DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR (50),
	cst_firstname NVARCHAR (50),
	cst_lastname NVARCHAR (50),
	cst_marital_status NVARCHAR (50),
	cst_gndr NVARCHAR (50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE ()
); 

--crm_prd_info
IF  OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL 
	DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	cat_id NVARCHAR (50),
	prd_key NVARCHAR (50),
	prd_nm NVARCHAR (50),
	prd_cost INT,
	prd_line NVARCHAR (50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE ()
); 

SELECT * FROM silver.crm_prd_info

--crm_sls_info/crm_sales_details
IF  OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL 
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR (50),
	sls_prd_key NVARCHAR (50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE ()
);

SELECT * FROM silver.crm_sales_details

-- ERP Sorcer
--Cust_AZ12
IF OBJECT_ID ('silver.erp_az12_', 'U') IS NOT NULL 
	DROP TABLE  silver.erp_az12_;
CREATE TABLE silver.erp_az12_(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE ()
);

SELECT * FROM silver.erp_az12_

--LOC_A101
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL 
    DROP TABLE silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

SELECT * FROM silver.erp_loc_a101

--PX_CAT_G1V2
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL 
    DROP TABLE silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE ()
);

SELECT* FROM silver.erp_px_cat_g1v2

-- =================================================================================
-- Load Clean DATA into Silver Layers & Stored Procedure
-- =================================================================================
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE  @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE(); 
		PRINT '========================================================================='
		PRINT 'Loading Silver Layer'
		PRINT '========================================================================='

		PRINT '-------------------------------------------------------------------------'
		PRINT 'Loading CRM TABLES'
		PRINT '-------------------------------------------------------------------------'


		--CRM SOURCE
		--cust_info
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.crm_cust_info'
			TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting DATA into: silver.crm_cust_info'
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)

		SELECT
		cst_id,
		cst_key,
		TRIM(cst_firstname) AS cst_firstname,
		TRIM(cst_lastname) AS cst_lastname,
		CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
			 WHEN UPPER(TRIM(cst_marital_status))  = 'M' THEN 'Married'	
			ELSE 'n/a' 
		END marital_status, 
		CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'	
			ELSE 'n/a' 
		END cst_gndr, 
		cst_create_date
		FROM(
			SELECT
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id iS NOT NULL
		)t WHERE flag_last = 1
		


		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'

		--crm_prd_info
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.crm_prd_info'
			TRUNCATE TABLE  silver.crm_prd_info;
		PRINT '>> Inserting DATA into: silver.crm_prd_info'
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost, 0) AS prd_cost,
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'	
			WHEN 'S' THEN 'Other sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a' 
		END prd_line, 
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info

		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'


		--sales_details
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.crm_sales_details'
			TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Inserting DATA into: silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE 
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 	 
				ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)		
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)		
			END AS sls_ship_dt,
			CASE 
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)		
			END AS sls_due_dt,
			CASE 
				WHEN sls_sales IS NULL OR sls_price <= 0  OR sls_sales != sls_quantity * ABS(sls_price) 
				THEN  sls_quantity * ABS(sls_price) 
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0 
				THEN sls_sales / NULLIF(sls_quantity,0)        
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sls_info



		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'


		-- erp_az12_
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.erp_az12_'
		TRUNCATE TABLE silver.erp_az12_;
		PRINT '>> Inserting DATA into: silver.erp_az12_'
		INSERT INTO silver.erp_az12_(
			cid,
			bdate,
			gen
		)
		SELECT
		CASE WHEN CID LIKE 'NAS%'
			 THEN SUBSTRING(CID, 4, LEN(cid)) 
			 ELSE CID 
		END AS cid,
		CASE WHEN BDATE > GETDATE() THEN NULL
			 ELSE BDATE
		END AS bdate,
		CASE WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
			 WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
			 ELSE 'n/a' 
		END AS gen
		FROM bronze.erp_az12_



		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'


		-- erp_loc_a101
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.erp_loc_a101'
			TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Inserting DATA into: silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101
		(cid, cntry)
		SELECT 
			REPLACE(CID, '-', '') cid,
		CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
			 WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
			 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
			 ELSE CNTRY
		END AS cntry
		FROM bronze.erp_loc_a101



		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'


		-- erp_px_CAT_g1v2
		SET @start_time = GETDATE(); 
		PRINT '>> Truncating Table: silver.erp_px_CAT_g1v2'
			TRUNCATE TABLE silver.erp_px_CAT_g1v2;
		PRINT '>> Inserting DATA into: silver.erp_px_CAT_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2
		(	id,
			cat,
			subcat,
			maintenance)
		SELECT 
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat_g1v2


		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'


		SET @batch_end_time = GETDATE();
		PRINT '======================================='
		PRINT 'Loading Layer Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH
		PRINT 'Error detectado en el proceso de carga Silver:';
		PRINT ERROR_MESSAGE();
	END CATCH;
END
