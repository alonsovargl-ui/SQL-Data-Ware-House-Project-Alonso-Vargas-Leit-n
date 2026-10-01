/* 
==================================================================================================
DDL Script: Create Bronze Layer
==================================================================================================

Script purpuse:
  This script create tables in the 'bronze' schema, droping existing tables if they already exist. 
  Run this script to re-define the DDL structure of 'bronze' tables.
===================================================================================================
*/

-- CRM Source
--crm_cust_info
IF OBJECT_ID('bronze.crm_cust_info', 'U') NOT NULL 
  DROP TABLE  bronze.crm_cust_info;
GO
  CREATE TABLE bronze.crm_cust_info(
  cst_id INT,
  cst_key NVARCHAR (50),
  cst_firstname NVARCHAR (50),
  cst_lastname NVARCHAR (50),
  cst_marital_status NVARCHAR (50),
  cst_gndr NVARCHAR (50),
  cst_create_date DATE
  ); 

--crm_prd_info
IF OBJECT_ID('bronze.crm_prd_info', 'U') NOT NULL 
  DROP TABLE  bronze.crm_cust_info;
GO
  CREATE TABLE bronze.crm_prd_info(
  prd_id INT,
  prd_key NVARCHAR (50),
  prd_nm NVARCHAR (50),
  prd_cost INT,
  prd_line NVARCHAR (50),
  prd_start_dt DATETIME,
  prd_end_dt DATETIME
  ); 

--crm_sls_info
IF OBJECT_ID('bronze.crm_sls_info', 'U') NOT NULL 
  DROP TABLE  bronze.crm_sls_info(;
GO
  CREATE TABLE bronze.crm_sls_info(
  sls_ord_num NVARCHAR (50),
  sls_prd_key NVARCHAR (50),
  sls_cust_id INT,
  sls_order_dt INT,
  sls_ship_dt INT,
  sls_due_dt INT,
  sls_sales INT,
  sls_quantity INT,
  sls_price INT
  );

-- ERP Sorcer
--Cust_AZ12
IF OBJECT_ID('bronze.erp_az12_', 'U') NOT NULL 
  DROP TABLE  bronze.erp_az12_;
GO
  CREATE TABLE bronze.erp_az12_(
	CID NVARCHAR(50),
	BDATE DATE,
	GEN NVARCHAR(50)
);

--LOC_A101
IF OBJECT_ID('bronze.erp_loc_a101', 'U') NOT NULL 
  DROP TABLE  bronze.crm_cust_info;
GO
  CREATE TABLE bronze.erp_loc_a101(
	CID NVARCHAR(50),
	CNTRY NVARCHAR(50)
);

--PX_CAT_G1V2
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') NOT NULL 
  DROP TABLE  bronze.erp_px_cat_g1v2;
GO
  CREATE TABLE bronze.erp_px_cat_g1v2(
	ID NVARCHAR(50),
	CAT NVARCHAR(50),
	SUBCAT NVARCHAR(50),
	MAINTENANCE NVARCHAR(50)
);
