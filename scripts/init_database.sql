/*
==========================================================================================================================================
                                      DATA WAREHOUSE INITIALIZATION & SCHEMAS PROVISIONING
==========================================================================================================================================
SCRIPT PURPOSE:
  - Provisions the core 'DataWarehouse' database from scratch.
  - Establishes the foundation for the Medallion Architecture by creating three distinct logical layers: bronze, silver and gold.
  - Seamlessly handles database recreation by safely terminating active connections and dropping any existing instance of 'DataWarehouse'.

CRITICAL WARNING:
  - This script is DESTRUCTIVE. Running it will force-drop any existing database named 'DataWarehouse'. All existing tables, schemas and data will be PERMANENTLY & IRREVERSIBLY LOST.
  - Please ensure a full backup is secured or rename your existing database prior to execution.
==========================================================================================================================================

*****************************************************************************************************************************************************************************************

==========================================================================================================================================================
                                               KHỞI TẠO DATABASE & PHÂN TẦNG KIẾN TRÚC MEDALLION
==========================================================================================================================================================
MỤC ĐÍCH:
  - Tạo mới cơ sở dữ liệu 'DataWarehouse'.
  - Thiết lập nền tảng cho Kiến trúc Medallion (Medallion Architecture) thông qua việc phân tách thành 3 tầng chuẩn hóa dữ liệu: Bronze, Silver và Gold.
  - Tự động ngắt toàn bộ kết nối đang hoạt động,  xóa bỏ cơ sở dữ liệu cũ trước khi tái cấu trúc.

CẢNH BÁO:
  - Scripts này có thể sẽ ghi đè hoặc xóa dữ liệu nếu trên hệ thống của bạn đã có database mang tên 'Datawarehouse'.
  - Hãy sao lưu (backup) hoặc đổi tên database cũ trước khi chạy scripts này.
=========================================================================================================================================================
*/

USE MASTER;
GO

-- DROP DATABASE 'DATAWAREHOUSE' NẾU NÓ ĐÃ TỒN TẠI
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- TẠO DATABASE 'DATAWAREHOUSE'
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- TẠO SCHEMAS
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
