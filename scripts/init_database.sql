/*
====================================================================                      
                      CREATE DATABASE AND SCHEMAS
====================================================================

SCRIPT PURPOSE:
  - This script creates a new database named 'DataWarehouse'.
  - If the database already exists, it will be dropped and recreated.
  - The script sets up 3 schemas for Medallion Architecture: 'bronze', 'silver' and 'gold'.

WARNING:
  - If you already have a database named 'DataWarehouse', please take a backup or rename it before running this script. 
  - Otherwise, all your existing data will be PERMANENTLY DELETED.
====================================================================
*/

USE MASTER;
GO

-- DROP 'DATAWAREHOUSE' DATABASE IF IT EXISTS
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- CREATE THE 'DATAWAREHOUSE' DATABASE
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- CREATE SCHEMAS
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
