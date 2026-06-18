/*
Stored Procedure: Load Bronze Layer (Import Data from Sources to Bronze)
- This stored procedure truncate all data from every single table before loading data from ERP and CRM CSV file into the Bronze schema
- BULK INSERT is used for loading data from sources into Bronze layer.
- Run 'EXEC bronze.load_bronze' will run the script below automatically.

- Stored Produce sẽ xóa toàn bộ dữ liệu trước đó trong từng bảng của lớp Bronze trước khi load dữ liệu (file CSV) từ các nguồn ERP hoặc CRM vào cấu trúc Bronze
- Câu lệnh BULK INSERT dùng để tải lên một lượng lớn dữ liệu từ nguồn đến lớp Bronze
- Câu lệnh EXEC bronze.load_bronze dùng để load tự động script bên dưới.
*/

EXEC bronze.load_bronze

-- CREATE STORED PROCEDURE
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME,@batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';		
		PRINT '================================================';
		-- BULK LOAD EVERY SINGLE TABLE FROM CRM AND ERP SOURCES INTO BRONZE LAYER'S TABLE
		-- 1.
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>>> Inserting Data Into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_crm\cust_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK -- Locking Table while loading
		);
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------'

		-- 2.
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>>> Inserting Data Into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_crm\prd_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

		-- 3.
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>>> Inserting Data Into: crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_crm\sales_details.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT' Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		-- 4.
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12

		PRINT '>>> Inserting Data Into: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_erp\cust_az12.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

		-- 5.
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101

		PRINT '>>> Inserting Data Into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_erp\loc_a101.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

		-- 6.
		SET @start_time = GETDATE();
		PRINT '>>> Truncating Table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2

		PRINT '>>> Inserting Data Into: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';
		SET @batch_end_time = GETDATE();
		
		PRINT'------------------------------------------------';
		PRINT 'Loading Bronze Layer Completed';
		PRINT '>>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

	END TRY
	BEGIN CATCH
		PRINT '============================================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '============================================================';
	END CATCH
END;
