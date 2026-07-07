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
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';
		-- 1
		SET @start_time = GETDATE();
		CREATE TABLE #temp_crm_cust_info( -- Tạo bảng tạm để kiểm tra data sắp được nạp vào. Nếu dữ liệu bị lặp (duplicate) -> update thời gian cập nhật, nếu ID mới -> thêm vào bảng chính
			cst_id NVARCHAR(50),
			cst_key CHAR(10),
			cst_firstname NVARCHAR(50),
			cst_lastname NVARCHAR(50),
			cst_marital_status NVARCHAR(50),
			cst_gndr NVARCHAR(50),
			cst_create_date DATE,
			dwh_create_date DATETIME DEFAULT GETDATE()
		);

		PRINT '>>> Inserting data into temp table'
		BULK INSERT #temp_crm_cust_info
		FROM 'D:\Desktop\Workplace\dwh_project\datasets\source_crm\cust_info.csv'
		WITH (
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FIRSTROW = 2,
			TABLOCK -- Khóa bảng trong khi loading data
		);
		PRINT '>>> Merging data into bronze.crm_cust_info'
		-- Dùng Merge để upsert data, nếu trùng ID thì sẽ update những cột khác, nếu khác ID sẽ insert vô, tránh lỗi duplicate
		MERGE bronze.crm_cust_info AS Target
    	USING #temp_crm_cust_info AS Source
   		ON (Target.cst_id = Source.cst_id) -- Điều kiện, xem ID khách hàng này đã tồn tại trong data warehouse hay chưa?
		-- Nếu trùng ID -> cập nhật data cột dwh-create-date
		WHEN MATCHED THEN -- Nếu trùng ID -> cập nhật thông tin các cột còn lại và update thời gian nạp dữ liệu
        UPDATE SET 
			Target.cst_key = Source.cst_key,
            Target.cst_firstname = Source.cst_firstname, -- Cập nhật luôn thông tin nếu có thay đổi
            Target.cst_lastname = Source.cst_lastname,
			Target.cst_marital_status = Source.cst_marital_status,
			Target.cst_gndr = Source.cst_gndr,
			Target.cst_create_date = Source.cst_create_date,
            Target.dwh_create_date = GETDATE()

		-- Nếu gặp ID mới: Thêm mới hoàn toàn
    	WHEN NOT MATCHED BY TARGET THEN
        INSERT (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date, dwh_create_date)
        VALUES (Source.cst_id, Source.cst_key, Source.cst_firstname, Source.cst_lastname, Source.cst_marital_status, Source.cst_gndr, Source.cst_create_date, GETDATE());
    	-- 4. Xóa bảng tạm
    	DROP TABLE #temp_crm_cust_info; 
			
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
