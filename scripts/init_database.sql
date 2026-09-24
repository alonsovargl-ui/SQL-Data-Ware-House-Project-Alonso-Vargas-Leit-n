/*
==========================
Create Database and Schema
==========================
Script propuse: 
  This script create the new database 'DataWarehouse'. Additionally  the scripst sets up three schemas within the database; 'broze', 'silver', and 'gold'.

Warning: 
Running this script will drop the entire 'DataWarehouse' database if exists. 
All data in the database will be permantly deleted. Proceed with caution and ensure you have proper backups before running this script. 

*/

USE master

 --  Create Database 'Datawarehouse'

 CREATE DATABASE DataWarehouse;

 USE DataWarehouse;

 -- create the Schemas (Brnze ,silver, and gold)

 CREATE SCHEMA bronze;
 GO
 CREATE SCHEMA silver;
 GO
 CREATE SCHEMA gold;
 GO
