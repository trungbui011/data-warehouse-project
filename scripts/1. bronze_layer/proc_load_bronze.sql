/*
The data processing workflow for the Bronze layer is as follows:
- The system creates a staging table for each target table to filter incoming data before loading it into the Bronze layer.
+ For records with duplicate IDs within each table, the data is updated based on the most recent timestamp (to prevent data duplication errors).
+ For records with new IDs, the system automatically ingests them into the Bronze layer while filtering out any null (NULL) rows.

Quy trình xử lý data của tầng Bronze như sau:
- Hệ thống sẽ tạo 1 bảng tạm cho từng Table để sàng lọc data đầu vào trước khi nạp vào tầng Bronze
+ Với dữ liệu trùng id ở mỗi bảng, data sẽ được cập nhật theo thời gian thực gần nhất (tránh lỗi duplicate data).
+ Với dữ liệu có id mới, hệ thống sẽ tự động nạp data vào tầng Bronze, nó cũng sẽ lọc những dòng data rỗng (NULL)
*/

EXEC bronze.load_bronze -- Câu lệnh này chỉ được sử dụng sau khi lưu scripts bên dưới vào trong database. EXEC là câu lệnh load scripts đã được lưu vào database bằng cách gọi tên chúng

-- CREATE STORED PROCEDURE
CREATE OR ALTER PROCEDURE [BRONZE].[load_bronze] AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET NOCOUNT ON;

	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';		
		PRINT '================================================';
		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';
		
-- 1. Bảng 1: crm_cust_info
		SET @start_time = GETDATE();
		CREATE TABLE #temp_crm_cust_info( 
			cst_id NVARCHAR(50),
			cst_key NVARCHAR(50),
			cst_firstname NVARCHAR(50),
			cst_lastname NVARCHAR(50),
			cst_marital_status NVARCHAR(50),
			cst_gndr NVARCHAR(50),
			cst_create_date NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table crm_cust_info'
		BULK INSERT #temp_crm_cust_info
		FROM 'D:\datasets\source_crm\cust_info.csv'
		WITH (
			FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		PRINT '>>> Merging data into bronze.crm_cust_info'
		MERGE bronze.crm_cust_info AS Target
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY (SELECT NULL)) AS rn
				FROM #temp_crm_cust_info -- Loại bỏ dòng trống, NULL
				WHERE cst_id IS NOT NULL AND cst_id <> '' 
			) t WHERE t.rn = 1
		) AS Source
		ON (Target.cst_id = Source.cst_id) 
		WHEN MATCHED THEN 
		UPDATE SET  
			Target.cst_key = Source.cst_key,
			Target.cst_firstname = Source.cst_firstname, 
			Target.cst_lastname = Source.cst_lastname,
			Target.cst_marital_status = Source.cst_marital_status,
			Target.cst_gndr = Source.cst_gndr,
			Target.cst_create_date = TRY_CAST(REPLACE(Source.cst_create_date, CHAR(13), '') AS DATE),
			Target.dwh_create_date = GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date, dwh_create_date)
		VALUES (Source.cst_id, Source.cst_key, Source.cst_firstname, Source.cst_lastname, Source.cst_marital_status, Source.cst_gndr, TRY_CAST(REPLACE(Source.cst_create_date, CHAR(13), '') AS DATE), GETDATE());

		DROP TABLE #temp_crm_cust_info; 
			
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (crm_cust_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------'

-- 2. Bảng 2: crm_prd_info
		SET @start_time = GETDATE();
		CREATE TABLE #temp_crm_prd_info(
			prd_id NVARCHAR(50),
			prd_key NVARCHAR(50),
			prd_nm NVARCHAR(50),
			prd_cost NVARCHAR(50),
			prd_line NVARCHAR(50),
			prd_start_dt NVARCHAR(50),
			prd_end_dt NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table crm_prd_info'
		BULK INSERT #temp_crm_prd_info
		FROM 'D:\datasets\source_crm\prd_info.csv'
		WITH (
			FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		PRINT 'Merging data into bronze.crm_prd_info'
		MERGE bronze.crm_prd_info AS TARGET
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY prd_id ORDER BY (SELECT NULL)) AS rn
				FROM #temp_crm_prd_info -- Loại bỏ dòng trống
				WHERE prd_id IS NOT NULL AND prd_id <> ''
			) t WHERE t.rn = 1
		) AS SOURCE
		ON (TARGET.prd_id = TRY_CAST(SOURCE.prd_id AS INT))
		WHEN MATCHED THEN
		UPDATE SET
			TARGET.prd_key = SOURCE.prd_key,
			TARGET.prd_nm = SOURCE.prd_nm,
			TARGET.prd_cost = TRY_CAST(SOURCE.prd_cost AS INT),
			TARGET.prd_line = SOURCE.prd_line,
			TARGET.prd_start_dt = TRY_CAST(SOURCE.prd_start_dt AS DATE),
			TARGET.prd_end_dt = TRY_CAST(REPLACE(SOURCE.prd_end_dt, CHAR(13), '') AS DATE),
			TARGET.dwh_create_date = GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(prd_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt, dwh_create_date)
		VALUES(TRY_CAST(SOURCE.prd_id AS INT), SOURCE.prd_key, SOURCE.prd_nm, TRY_CAST(SOURCE.prd_cost AS INT), SOURCE.prd_line, TRY_CAST(SOURCE.prd_start_dt AS DATE), TRY_CAST(REPLACE(SOURCE.prd_end_dt, CHAR(13), '') AS DATE), GETDATE());
		
		DROP TABLE #temp_crm_prd_info;
	
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (crm_prd_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

	-- 3. Bảng 3. crm_sales_details
		SET @start_time = GETDATE();
		CREATE TABLE #temp_crm_sales_details(
			sls_ord_num NVARCHAR(50),
			sls_prd_key NVARCHAR(50),
			sls_cust_id NVARCHAR(50),
			sls_order_dt NVARCHAR(50),
			sls_ship_dt NVARCHAR(50),
			sls_due_dt NVARCHAR(50),
			sls_sales NVARCHAR(50),
			sls_quantity NVARCHAR(50),
			sls_price NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table crm_sales_details'
		BULK INSERT #temp_crm_sales_details
		FROM 'D:\datasets\source_crm\sales_details.csv'
		WITH (
			FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		PRINT 'Merging data into bronze.crm_sales_details'
		MERGE bronze.crm_sales_details AS TARGET
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY sls_ord_num, sls_prd_key ORDER BY (SELECT NULL)) AS rn
				FROM #temp_crm_sales_details -- Loại bỏ dòng trống
				WHERE sls_ord_num IS NOT NULL AND sls_ord_num <> ''
			) t WHERE t.rn = 1
		) AS SOURCE
		ON TARGET.sls_ord_num = SOURCE.sls_ord_num 
		AND TARGET.sls_prd_key = SOURCE.sls_prd_key
			
		WHEN MATCHED THEN
		UPDATE SET
			TARGET.sls_cust_id = SOURCE.sls_cust_id,
			TARGET.sls_order_dt = SOURCE.sls_order_dt,
			TARGET.sls_ship_dt = SOURCE.sls_ship_dt,
			TARGET.sls_due_dt = SOURCE.sls_due_dt,
			TARGET.sls_sales = SOURCE.sls_sales,
			TARGET.sls_quantity = SOURCE.sls_quantity,
			TARGET.sls_price = REPLACE(SOURCE.sls_price, CHAR(13), ''), 
			TARGET.dwh_create_date = GETDATE()
			
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price, dwh_create_date)
		VALUES(SOURCE.sls_ord_num, SOURCE.sls_prd_key, SOURCE.sls_cust_id, SOURCE.sls_order_dt, SOURCE.sls_ship_dt, SOURCE.sls_due_dt, SOURCE.sls_sales, SOURCE.sls_quantity, REPLACE(SOURCE.sls_price, CHAR(13), ''), GETDATE());
		
		DROP TABLE #temp_crm_sales_details;
	
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (crm_sales_details): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

-- 4. Bảng 4. erp_cust_az12
		SET @start_time = GETDATE();
		CREATE TABLE #temp_erp_cust_az12(
			cid NVARCHAR(50),
			bdate NVARCHAR(50),
			gen NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table erp_cust_az12'
		BULK INSERT #temp_erp_cust_az12
		FROM 'D:\datasets\source_erp\cust_az12.csv'
		WITH (FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		MERGE bronze.erp_cust_az12 AS TARGET
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY cid ORDER BY (SELECT NULL)) AS rn
				FROM #temp_erp_cust_az12 -- Loại bỏ dòng trống
				WHERE cid IS NOT NULL AND cid <> ''
			) t WHERE t.rn = 1
		) AS SOURCE
		ON TARGET.cid = SOURCE.cid
		WHEN MATCHED THEN
		UPDATE SET
			TARGET.bdate = TRY_CAST(SOURCE.bdate AS DATE),
			TARGET.gen = REPLACE(SOURCE.gen, CHAR(13), ''), 
			TARGET.dwh_create_date = GETDATE()
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(cid, bdate, gen, dwh_create_date)
		VALUES(SOURCE.cid, TRY_CAST(SOURCE.bdate AS DATE), REPLACE(SOURCE.gen, CHAR(13), ''), GETDATE());

		DROP TABLE #temp_erp_cust_az12;
			
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (erp_cust_az12): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

-- 5. Bảng 5. erp_loc_a101
		SET @start_time = GETDATE();
		CREATE TABLE #temp_erp_loc_a101(
			cid NVARCHAR(50),
			cntry NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table erp_loc_a101'
		BULK INSERT #temp_erp_loc_a101
		FROM 'D:\datasets\source_erp\loc_a101.csv'
		WITH (FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		MERGE bronze.erp_loc_a101 AS TARGET
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY cid ORDER BY (SELECT NULL)) AS rn
				FROM #temp_erp_loc_a101 -- Loại bỏ dòng trống
				WHERE cid IS NOT NULL AND cid <> ''
			) t WHERE t.rn = 1
		) AS SOURCE
		ON TARGET.cid = SOURCE.cid
		
		WHEN MATCHED THEN
		UPDATE SET
			TARGET.cntry = REPLACE(SOURCE.cntry, CHAR(13), ''), 
			TARGET.dwh_create_date = GETDATE()
		
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(cid, cntry, dwh_create_date)
		VALUES(SOURCE.cid, REPLACE(SOURCE.cntry, CHAR(13), ''), GETDATE());

		DROP TABLE #temp_erp_loc_a101;
			
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (erp_loc_a101): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT'------------------------------------------------';

-- 6. Bảng 6: erp_px_cat_g1v2
		SET @start_time = GETDATE();
		CREATE TABLE #temp_erp_px_cat_g1v2(		
			id NVARCHAR(50),
			cat NVARCHAR(50),
			subcat NVARCHAR(50),
			maintenance NVARCHAR(50)
		);

		PRINT '>>> Inserting data into temp table erp_px_cat_g1v2'
		BULK INSERT #temp_erp_px_cat_g1v2
		FROM 'D:\datasets\source_erp\px_cat_g1v2.csv'
		WITH (FIELDTERMINATOR = ',', 
			ROWTERMINATOR = '\n', 
			FIRSTROW = 2, 
			TABLOCK);

		MERGE bronze.erp_px_cat_g1v2 AS TARGET
		USING (
			SELECT * FROM (
				SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY (SELECT NULL)) AS rn
				FROM #temp_erp_px_cat_g1v2 -- Loại bỏ dòng trống
				WHERE id IS NOT NULL AND id <> ''
			) t WHERE t.rn = 1
		) AS SOURCE
		ON TARGET.id = SOURCE.id
		
		WHEN MATCHED THEN
		UPDATE SET
			TARGET.cat = SOURCE.cat,
			TARGET.subcat = SOURCE.subcat,
			TARGET.maintenance = REPLACE(SOURCE.maintenance, CHAR(13), ''), 
			TARGET.dwh_create_date = GETDATE()
		
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(id, cat, subcat, maintenance, dwh_create_date)
		VALUES(SOURCE.id, SOURCE.cat, SOURCE.subcat, REPLACE(SOURCE.maintenance, CHAR(13), ''), GETDATE());

		DROP TABLE #temp_erp_px_cat_g1v2;
			
		SET @end_time = GETDATE();
		PRINT'>>> Load Duration (erp_px_cat_g1v2): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
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
		PRINT 'Error Message: ' + ERROR_MESSAGE();
		PRINT 'Error Number: ' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State: ' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '============================================================';
	END CATCH
END;
GO
