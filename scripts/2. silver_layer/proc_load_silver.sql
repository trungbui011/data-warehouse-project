/*
Stored Procedure: Load Silver Layer (Import Data from Bronze to Silver)
- This stored procedure truncate all data from every single table in Silver Layer before loading, transforming and cleansing data from Bronze layer into the Silver schema
- Run 'EXEC silver.load_silver' will run the script below automatically.

- Stored Produce: sẽ xóa toàn bộ dữ liệu trước đó trong từng bảng của tầng Silver trước khi load dữ liệu của các bảng ở tầng Bronze vào tầng Silver
- Script này sẽ có nhiệm vụ xóa hết dữ liệu trước đó của các bảng ở tầng Silver nhưng vẫn giữ lại cấu trúc các bảng; sau đó load, transform và làm sạch dữ liệu của tầng Bronze trước khi load data vào tầng Silver
- Câu lệnh EXEC silver.load_silver dùng để load tự động script bên dưới.
*/
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME 
	--------------- 1.
		SET @batch_start_time = GETDATE()
		PRINT'========================================================================='
		PRINT'                            LOADING SILVER LAYER'
		PRINT'========================================================================='
		PRINT'-------------------------------------------------------------------------'
		PRINT' 1. LOADING CRM TABLE'
		PRINT'-------------------------------------------------------------------------'
		
		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT'>>> Inserting data into: silver.crm_cust_info';

		INSERT INTO SILVER.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
		SELECT	cst_id, 
				cst_key, 
				TRIM(cst_firstname) AS cst_firstname, 
				TRIM(cst_lastname) AS cst_lastname, 
				CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
						WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
						ELSE 'n/a'
				END as cst_marital_status,  
				CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
						WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
						ELSE 'n/a'
				END as cst_gndr, 
				cst_create_date
		FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS flag_last FROM BRONZE.crm_cust_info) B 
		WHERE flag_last = 1 AND CST_ID IS NOT NULL
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		------------ 2.
		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>>> Inserting data into: silver.crm_prd_info';

		INSERT INTO silver.crm_prd_info (prd_id, prd_key, cat_id, short_prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
		SELECT	prd_id, -- không trùng, OK!
				prd_key, -- Là PK, tổng có 295 key, có 77 bị trùng từ 2-3 lần
				REPLACE(SUBSTRING(PRD_KEY,1,5),'-','_') AS cat_id, -- cột id của table erp_px_cat_g1v2 (xx_xx)
				SUBSTRING(PRD_KEY, 7, LEN(PRD_KEY)) AS short_prd_key, -- cột sls_prd_key của table crm_sales_details (xx-xxxx-xx)
				TRIM(PRD_NM) AS prd_nm, 
				ISNULL(PRD_COST,0) AS prd_cost,
				CASE WHEN UPPER(TRIM(PRD_LINE)) = 'M' THEN 'Mountain'
						WHEN UPPER(TRIM(PRD_LINE)) = 'R' THEN 'Road'
						WHEN UPPER(TRIM(PRD_LINE)) = 'S' THEN 'other Sales'
						WHEN UPPER(TRIM(PRD_LINE)) = 'T' THEN 'Touring'
						ELSE 'n/a'
				END AS prd_line, 
				prd_start_dt, 
				LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt
		FROM BRONZE.crm_prd_info
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		----------- 3.
		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT'>>> Inserting data into: silver.crm_sales_details';

		INSERT INTO  SILVER.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
		SELECT  TRIM(sls_ord_num) AS sls_ord_num,
				TRIM(sls_prd_key) AS sls_prd_key,
  				TRIM(sls_cust_id) AS sls_cust_id,
				CASE WHEN ISDATE(SLS_ORDER_DT) = 1 THEN CAST(sls_order_dt AS DATE)
						ELSE NULL
				END AS sls_order_dt,
				CASE WHEN ISDATE(SLS_SHIP_DT) = 1 THEN CAST(sls_SHIP_dt AS DATE)
						ELSE NULL
				END AS sls_ship_dt,
				CASE WHEN ISDATE(SLS_DUE_DT) = 1 THEN CAST(sls_DUE_dt AS DATE)
						ELSE NULL
				END AS sls_due_dt,
				CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
						THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
				END AS sls_sales,
				sls_quantity,
				CASE WHEN sls_price IS NULL THEN ABS(sls_sales)/NULLIF(sls_quantity,0)
						WHEN sls_price < 0 THEN ABS(sls_price)
						ELSE sls_price
				END AS sls_price
		FROM BRONZE.crm_sales_details
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		----------- 4.
		PRINT'-------------------------------------------------------------------------'
		PRINT' 2. LOADING ERP TABLE'
		PRINT'-------------------------------------------------------------------------'

		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>>> Inserting data into: silver.erp_cust_az12';

		INSERT INTO SILVER.erp_cust_az12 (cid, bdate, gen)
		SELECT CASE WHEN UPPER(RIGHT(TRIM(cid),10)) LIKE 'NASAW%' THEN UPPER(RIGHT(TRIM(cid), 10))
					WHEN UPPER(RIGHT(TRIM(cid),10)) LIKE 'AW%' THEN UPPER(RIGHT(TRIM(cid), 10))
					ELSE cid
				END AS cid,
				CASE WHEN bdate > GETDATE() THEN NULL
					ELSE bdate
				END AS bdate, -- Tuổi dương từ 40 -> 110, có 1 số giá trị âm -> Âm thì NULL, những số dương thì trao đổi với các phòng ban nắm data
				CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
					WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
					ELSE 'n/a'
				END AS gen
		FROM BRONZE.erp_cust_az12
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		-----------5.
		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT'>>> Inserting data into: silver.erp_loc_a101';

		INSERT INTO SILVER.erp_loc_a101 (cid, cntry)
		SELECT TRIM(REPLACE(cid,'-','')) AS cid,
				CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
					WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
					WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				ELSE TRIM(cntry)
				END AS cntry
		FROM BRONZE.erp_loc_a101
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		---------6.
		SET @start_time = GETDATE()
		PRINT'>>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT'>>> Inserting data into: silver.erp_px_cat_g1v2';

		INSERT INTO SILVER.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
		SELECT TRIM(id) AS id, 
				TRIM(cat) AS cat,
				TRIM(subcat) AS subcat,
				TRIM(maintenance) AS maintenance
		FROM BRONZE.erp_px_cat_g1v2
		SET @end_time = GETDATE()
		PRINT'>>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
		SET @batch_end_time = GETDATE()

		PRINT'-------------------------------------------------------------------------'
		PRINT'>>> Loading Silver Layer Completed'
		PRINT'>>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT'-------------------------------------------------------------------------'
	END TRY
	BEGIN CATCH
		PRINT'=================================================================='
		PRINT'ERROR OCCURED DURING LOADING SILVER LAYER'
		PRINT'ERROR MESSAGE:' + ERROR_MESSAGE()
		PRINT'ERROR MESSAGE:' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT'ERROR MESSAGE:' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT'=================================================================='
	END CATCH
END;
GO
