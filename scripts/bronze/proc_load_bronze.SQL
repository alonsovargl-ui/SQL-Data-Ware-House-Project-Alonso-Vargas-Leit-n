/*
======================================================================================

Stored Procedure: Load Bronzer Layer (Source -> Bronze)

======================================================================================

Script Purpose: 
Bulk Insert the data into tables with the sourcer info for the bronze layer from 
external csv files performing the folowing actions:
  - Truncate the bronze tables before loading data to avoid repetition.
  - Uses 'BULK INSERT' to load data from csv files to bronze tables.

Parameters: None.
  This process does not accept any parameters or returns any values.

  
Use example: 
  EXEC bronze.load_bronze;

======================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE  @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GETDATE(); 
		PRINT '========================================================================='
		PRINT 'Loading Bronze Layer'
		PRINT '========================================================================='

		PRINT '-------------------------------------------------------------------------'
		PRINT 'Loading CRM TABLES'
		PRINT '-------------------------------------------------------------------------'

		-- crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> Truncating  Truncating Table: bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting Data Into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 

		SELECT * FROM bronze.crm_cust_info
		SELECT COUNT(*) FROM bronze.crm_cust_info

		-- cust_info
		SET @start_time = GETDATE();
			PRINT '>> Truncating  Truncating Table: bronze.bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;

			PRINT '>> Inserting Data Into: bronze.bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds'; 

		SELECT * FROM bronze.crm_prd_info
		SELECT COUNT(*) FROM bronze.crm_prd_info

		-- sales_details
		SET @start_time = GETDATE();
			PRINT '>> Truncating  Truncating Table: bronze.crm_sls_info'
		TRUNCATE TABLE bronze.crm_sls_info;

			PRINT '>> Inserting Data Into: bronze.crm_sls_info'
		BULK INSERT bronze.crm_sls_info
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		SELECT * FROM bronze.crm_sls_info
		SELECT COUNT(*) FROM bronze.crm_prd_info


		PRINT '-------------------------------------------------------------------------'
		PRINT 'Loading ERP TABLES'
		PRINT '-------------------------------------------------------------------------'
	
		-- az12
		SET @start_time = GETDATE();
			PRINT '>> Truncating  Truncating Table: bronze.erp_az12_'
		TRUNCATE TABLE bronze.erp_az12_;
			PRINT '>> Inserting Data Into: bronze.erp_az12_'
		BULK INSERT bronze.erp_az12_
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		
		SELECT * FROM bronze.erp_az12_
		SELECT COUNT(*) FROM bronze.erp_az12_

		-- loc_a101
		SET @start_time = GETDATE();
			PRINT '>> Truncating  Truncating Table: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101;

			PRINT '>> Inserting Data Into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';

		SELECT * FROM bronze.erp_loc_a101
		SELECT COUNT(*) FROM bronze.erp_loc_a101

		-- PX_CAT_G1V2
		SET @start_time = GETDATE();
			PRINT '>> Truncating  Truncating Table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

			PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\PC\OneDrive\Desktop\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			);

		SELECT * FROM bronze.erp_px_cat_g1v2
		SELECT COUNT(*) FROM bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE();
		PRINT '>> Load Duration; ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '------------------------------------'

		SET @batch_end_time = GETDATE();
		PRINT '======================================='
		PRINT 'Loading Layer Completed';
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error message' + ERROR_MESSAGE();
		PRINT 'Error message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '======================================'
	END CATCH
END
