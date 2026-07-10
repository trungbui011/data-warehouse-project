/*
Stored Procedure: Load Silver Layer (Import Data from Bronze to Silver)
- This stored procedure truncate all data from every single table in Silver Layer before loading, transforming and cleansing data from Bronze layer into the Silver schema
- Run 'EXEC silver.load_silver' will run the script below automatically.

- Stored Produce: sẽ xóa toàn bộ dữ liệu trước đó trong từng bảng của tầng Silver trước khi load dữ liệu của các bảng ở tầng Bronze vào tầng Silver
- Script này sẽ có nhiệm vụ xóa hết dữ liệu trước đó của các bảng ở tầng Silver nhưng vẫn giữ lại cấu trúc các bảng; sau đó load, transform và làm sạch dữ liệu của tầng Bronze trước khi load data vào tầng Silver
- Câu lệnh EXEC silver.load_silver dùng để load tự động script bên dưới.
*/
EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver
    @is_full_load BIT = 0 -- Bật 1 nếu muốn TRUNCATE và nạp lại toàn bộ; Để mặc định 0 để chạy lũy tiến (Incremental MERGE)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME 
        
        SET @batch_start_time = GETDATE()
        PRINT'========================================================================='
        PRINT'                 LOADING SILVER LAYER (MEDALLION ARCHITECTURE)'
        PRINT'========================================================================='
        PRINT '>>> Mode active: ' + CASE WHEN @is_full_load = 1 THEN 'FULL LOAD (Truncate & Reload)' ELSE 'INCREMENTAL LOAD (Merge/Upsert)' END
        
        -------------------------------------------------------------------------
        PRINT' 1. LOADING CRM TABLES'
        -------------------------------------------------------------------------
        
        -- 1.1 TABLE: silver.crm_cust_info
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.crm_cust_info';
            TRUNCATE TABLE silver.crm_cust_info;
        END

        PRINT'>>> Executing MERGE into: silver.crm_cust_info';
        ;WITH Src_crm_cust_info AS (
            SELECT cst_id, 
                   cst_key, 
                   TRIM(cst_firstname) AS cst_firstname, 
                   TRIM(cst_lastname) AS cst_lastname, 
                   CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                        ELSE 'n/a'
                   END AS cst_marital_status,  
                   CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                        ELSE 'n/a'
                   END AS cst_gndr, 
                   cst_create_date
            FROM (
                SELECT *, ROW_NUMBER() OVER(PARTITION BY CST_ID ORDER BY CST_CREATE_DATE DESC) AS flag_last 
                FROM BRONZE.crm_cust_info
            ) B 
            WHERE flag_last = 1 AND CST_ID IS NOT NULL
        )
        MERGE SILVER.crm_cust_info AS TARGET
        USING Src_crm_cust_info AS SOURCE
        ON TARGET.cst_id = SOURCE.cst_id
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.cst_key = SOURCE.cst_key,
                TARGET.cst_firstname = SOURCE.cst_firstname,
                TARGET.cst_lastname = SOURCE.cst_lastname,
                TARGET.cst_marital_status = SOURCE.cst_marital_status,
                TARGET.cst_gndr = SOURCE.cst_gndr,
                TARGET.cst_create_date = SOURCE.cst_create_date
        WHEN NOT MATCHED THEN
            INSERT (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
            VALUES (SOURCE.cst_id, SOURCE.cst_key, SOURCE.cst_firstname, SOURCE.cst_lastname, SOURCE.cst_marital_status, SOURCE.cst_gndr, SOURCE.cst_create_date);

        SET @end_time = GETDATE()
        PRINT'>>> crm_cust_info Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'

        -- 1.2 TABLE: silver.crm_prd_info
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.crm_prd_info';
            TRUNCATE TABLE silver.crm_prd_info;
        END

        PRINT'>>> Executing MERGE into: silver.crm_prd_info';
        ;WITH Src_crm_prd_info AS (
            SELECT prd_id, 
                   prd_key, 
                   REPLACE(SUBSTRING(PRD_KEY,1,5),'-','_') AS cat_id, 
                   SUBSTRING(PRD_KEY, 7, LEN(PRD_KEY)) AS short_prd_key, 
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
        )
        MERGE silver.crm_prd_info AS TARGET
        USING Src_crm_prd_info AS SOURCE
        ON TARGET.prd_id = SOURCE.prd_id -- So khớp theo khóa prd_id duy nhất
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.prd_key = SOURCE.prd_key,
                TARGET.cat_id = SOURCE.cat_id,
                TARGET.short_prd_key = SOURCE.short_prd_key,
                TARGET.prd_nm = SOURCE.prd_nm,
                TARGET.prd_cost = SOURCE.prd_cost,
                TARGET.prd_line = SOURCE.prd_line,
                TARGET.prd_start_dt = SOURCE.prd_start_dt,
                TARGET.prd_end_dt = SOURCE.prd_end_dt
        WHEN NOT MATCHED THEN
            INSERT (prd_id, prd_key, cat_id, short_prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
            VALUES (SOURCE.prd_id, SOURCE.prd_key, SOURCE.cat_id, SOURCE.short_prd_key, SOURCE.prd_nm, SOURCE.prd_cost, SOURCE.prd_line, SOURCE.prd_start_dt, SOURCE.prd_end_dt);

        SET @end_time = GETDATE()
        PRINT'>>> crm_prd_info Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'

        -- 1.3 TABLE: silver.crm_sales_details
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.crm_sales_details';
            TRUNCATE TABLE silver.crm_sales_details;
        END

        PRINT'>>> Executing MERGE into: silver.crm_sales_details';
        ;WITH Src_crm_sales_details AS (
            SELECT TRIM(sls_ord_num) AS sls_ord_num,
                   TRIM(sls_prd_key) AS sls_prd_key,
                   TRIM(sls_cust_id) AS sls_cust_id,
                   CASE WHEN ISDATE(SLS_ORDER_DT) = 1 THEN CAST(sls_order_dt AS DATE) ELSE NULL END AS sls_order_dt,
                   CASE WHEN ISDATE(SLS_SHIP_DT) = 1 THEN CAST(sls_SHIP_dt AS DATE) ELSE NULL END AS sls_ship_dt,
                   CASE WHEN ISDATE(SLS_DUE_DT) = 1 THEN CAST(sls_DUE_dt AS DATE) ELSE NULL END AS sls_due_dt,
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
        )
        MERGE SILVER.crm_sales_details AS TARGET
        USING Src_crm_sales_details AS SOURCE
        ON TARGET.sls_ord_num = SOURCE.sls_ord_num 
           AND TARGET.sls_prd_key = SOURCE.sls_prd_key 
           AND TARGET.sls_cust_id = SOURCE.sls_cust_id -- So khớp theo bộ khóa tự nhiên của giao dịch
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.sls_order_dt = SOURCE.sls_order_dt,
                TARGET.sls_ship_dt = SOURCE.sls_ship_dt,
                TARGET.sls_due_dt = SOURCE.sls_due_dt,
                TARGET.sls_sales = SOURCE.sls_sales,
                TARGET.sls_quantity = SOURCE.sls_quantity,
                TARGET.sls_price = SOURCE.sls_price
        WHEN NOT MATCHED THEN
            INSERT (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
            VALUES (SOURCE.sls_ord_num, SOURCE.sls_prd_key, SOURCE.sls_cust_id, SOURCE.sls_order_dt, SOURCE.sls_ship_dt, SOURCE.sls_due_dt, SOURCE.sls_sales, SOURCE.sls_quantity, SOURCE.sls_price);

        SET @end_time = GETDATE()
        PRINT'>>> crm_sales_details Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'

        -------------------------------------------------------------------------
        PRINT' 2. LOADING ERP TABLES'
        -------------------------------------------------------------------------

        -- 2.1 TABLE: silver.erp_cust_az12
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.erp_cust_az12';
            TRUNCATE TABLE silver.erp_cust_az12;
        END

        PRINT'>>> Executing MERGE into: silver.erp_cust_az12';
        ;WITH Src_erp_cust_az12 AS (
            SELECT CASE WHEN UPPER(RIGHT(TRIM(cid),10)) LIKE 'NASAW%' THEN UPPER(RIGHT(TRIM(cid), 10))
                        WHEN UPPER(RIGHT(TRIM(cid),10)) LIKE 'AW%' THEN UPPER(RIGHT(TRIM(cid), 10))
                        ELSE cid
                   END AS cid,
                   CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END AS bdate, 
                   CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
                        WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
                        ELSE 'n/a'
                   END AS gen
            FROM BRONZE.erp_cust_az12
        )
        MERGE SILVER.erp_cust_az12 AS TARGET
        USING Src_erp_cust_az12 AS SOURCE
        ON TARGET.cid = SOURCE.cid
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.bdate = SOURCE.bdate,
                TARGET.gen = SOURCE.gen
        WHEN NOT MATCHED THEN
            INSERT (cid, bdate, gen)
            VALUES (SOURCE.cid, SOURCE.bdate, SOURCE.gen);

        SET @end_time = GETDATE()
        PRINT'>>> erp_cust_az12 Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'

        -- 2.2 TABLE: silver.erp_loc_a101
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.erp_loc_a101';
            TRUNCATE TABLE silver.erp_loc_a101;
        END

        PRINT'>>> Executing MERGE into: silver.erp_loc_a101';
        ;WITH Src_erp_loc_a101 AS (
            SELECT TRIM(REPLACE(cid,'-','')) AS cid,
                   CASE WHEN UPPER(TRIM(cntry)) IN ('US', 'USA') THEN 'United States'
                        WHEN cntry = '' OR cntry IS NULL THEN 'n/a'
                        WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
                        ELSE TRIM(cntry)
                   END AS cntry
            FROM BRONZE.erp_loc_a101
        )
        MERGE SILVER.erp_loc_a101 AS TARGET
        USING Src_erp_loc_a101 AS SOURCE
        ON TARGET.cid = SOURCE.cid
        WHEN MATCHED THEN
            UPDATE SET TARGET.cntry = SOURCE.cntry
        WHEN NOT MATCHED THEN
            INSERT (cid, cntry)
            VALUES (SOURCE.cid, SOURCE.cntry);

        SET @end_time = GETDATE()
        PRINT'>>> erp_loc_a101 Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'

        -- 2.3 TABLE: silver.erp_px_cat_g1v2
        SET @start_time = GETDATE()
        IF @is_full_load = 1
        BEGIN
            PRINT'>>> Truncating Table: silver.erp_px_cat_g1v2';
            TRUNCATE TABLE silver.erp_px_cat_g1v2;
        END

        PRINT'>>> Executing MERGE into: silver.erp_px_cat_g1v2';
        ;WITH Src_erp_px_cat_g1v2 AS (
            SELECT TRIM(id) AS id, 
                   TRIM(cat) AS cat,
                   TRIM(subcat) AS subcat,
                   TRIM(maintenance) AS maintenance
            FROM BRONZE.erp_px_cat_g1v2
        )
        MERGE SILVER.erp_px_cat_g1v2 AS TARGET
        USING Src_erp_px_cat_g1v2 AS SOURCE
        ON TARGET.id = SOURCE.id
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.cat = SOURCE.cat,
                TARGET.subcat = SOURCE.subcat,
                TARGET.maintenance = SOURCE.maintenance
        WHEN NOT MATCHED THEN
            INSERT (id, cat, subcat, maintenance)
            VALUES (SOURCE.id, SOURCE.cat, SOURCE.subcat, SOURCE.maintenance);

        SET @end_time = GETDATE()
        PRINT'>>> erp_px_cat_g1v2 Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT'-------------------------------------------------------------------------'
        
        SET @batch_end_time = GETDATE()
        PRINT'========================================================================='
        PRINT'>>> Loading Silver Layer Completed Successfully'
        PRINT'>>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
        PRINT'========================================================================='
    END TRY
    BEGIN CATCH
        PRINT'=================================================================='
        PRINT'CRITICAL ERROR OCCURED DURING LOADING SILVER LAYER'
        PRINT'ERROR MESSAGE: ' + ERROR_MESSAGE()
        PRINT'ERROR NUMBER: '  + CAST(ERROR_NUMBER() AS NVARCHAR)
        PRINT'ERROR STATE: '   + CAST(ERROR_STATE() AS NVARCHAR)
        PRINT'=================================================================='
        -- Thêm dòng THROW để hệ thống quản lý Data Pipeline (như ADF/Airflow) có thể bắt được lỗi và cảnh báo
        ;THROW; 
    END CATCH
END;
GO
