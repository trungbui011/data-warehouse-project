CREATE OR ALTER PROCEDURE gold.load_gold
    @is_full_load BIT = 0 -- Mặc định = 0 để chạy Lũy tiến/Merge chu kỳ ngắn trong ngày; Bật = 1 khi muốn Truncate làm sạch toàn bộ
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
        SET @batch_start_time = GETDATE()
        
        PRINT'========================================================================='
        PRINT'                          LOADING GOLD LAYER'
        PRINT'========================================================================='
        PRINT '>>> Mode active: ' + CASE WHEN @is_full_load = 1 THEN 'FULL RESET (Truncate & Reload)' ELSE 'HYBRID/INCREMENTAL (Merge/Upsert)' END

        -- CƠ CHẾ XỬ LÝ KHI BẬT FULL LOAD
        IF @is_full_load = 1
        BEGIN
            PRINT '>>> Truncating all Gold Tables...';
            TRUNCATE TABLE gold.fact_sales;
            TRUNCATE TABLE gold.dim_customers;
            TRUNCATE TABLE gold.dim_products;
        END

        -------------------------------------------------------------------------
        PRINT '1. LOADING DIMENSION: gold.dim_customers'
        -------------------------------------------------------------------------
        SET @start_time = GETDATE();
        
        ;WITH Src_dim_customers AS (
            SELECT
                cc.cst_id AS customer_id, 
                cc.cst_key AS customer_number, 
                cc.cst_firstname AS first_name, 
                cc.cst_lastname AS last_name,
                el.cntry AS country,
                cc.cst_marital_status AS marital_status, 
                CASE WHEN cc.cst_gndr != 'n/a' THEN cc.cst_gndr 
                     ELSE COALESCE(ec.gen,'n/a')
                END AS gender,
                ec.bdate AS birthdate,
                cc.cst_create_date AS create_date
            FROM silver.crm_cust_info cc
            LEFT JOIN silver.erp_cust_az12 ec ON cc.cst_key = ec.cid
            LEFT JOIN silver.erp_loc_a101 el ON cc.cst_key = el.cid
        )
        MERGE gold.dim_customers AS TARGET
        USING Src_dim_customers AS SOURCE
        ON TARGET.customer_id = SOURCE.customer_id
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.customer_number = SOURCE.customer_number,
                TARGET.first_name = SOURCE.first_name,
                TARGET.last_name = SOURCE.last_name,
                TARGET.country = SOURCE.country,
                TARGET.marital_status = SOURCE.marital_status,
                TARGET.gender = SOURCE.gender,
                TARGET.birthdate = SOURCE.birthdate,
                TARGET.create_date = SOURCE.create_date
        WHEN NOT MATCHED THEN
            INSERT (customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date)
            VALUES (SOURCE.customer_id, SOURCE.customer_number, SOURCE.first_name, SOURCE.last_name, SOURCE.country, SOURCE.marital_status, SOURCE.gender, SOURCE.birthdate, SOURCE.create_date);

        SET @end_time = GETDATE();
        PRINT '>>> dim_customers Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------------------------------------------------------------'

        -------------------------------------------------------------------------
        PRINT '2. LOADING DIMENSION: gold.dim_products'
        -------------------------------------------------------------------------
        SET @start_time = GETDATE();

        ;WITH Src_dim_products AS (
            SELECT 
                cp.prd_id AS product_id,
                cp.short_prd_key AS product_number,
                cp.prd_nm AS product_name,
                cp.cat_id AS category_id,
                CASE WHEN ec.cat IS NULL THEN 'n/a' ELSE ec.cat END AS category,
                CASE WHEN ec.subcat IS NULL THEN 'n/a' ELSE ec.subcat END AS sub_category,
                CASE WHEN ec.maintenance IS NULL THEN 'n/a' ELSE ec.maintenance END AS maintenance,     
                cp.prd_cost AS cost, 
                cp.prd_line AS product_line, 
                cp.prd_start_dt AS start_date
            FROM silver.crm_prd_info cp
            LEFT JOIN silver.erp_px_cat_g1v2 ec ON cp.cat_id = ec.id
        )
        MERGE gold.dim_products AS TARGET
        USING Src_dim_products AS SOURCE
        ON TARGET.product_id = SOURCE.product_id
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.product_number = SOURCE.product_number,
                TARGET.product_name = SOURCE.product_name,
                TARGET.category_id = SOURCE.category_id,
                TARGET.category = SOURCE.category,
                TARGET.sub_category = SOURCE.sub_category,
                TARGET.maintenance = SOURCE.maintenance,
                TARGET.cost = SOURCE.cost,
                TARGET.product_line = SOURCE.product_line,
                TARGET.start_date = SOURCE.start_date
        WHEN NOT MATCHED THEN
            INSERT (product_id, product_number, product_name, category_id, category, sub_category, maintenance, cost, product_line, start_date)
            VALUES (SOURCE.product_id, SOURCE.product_number, SOURCE.product_name, SOURCE.category_id, SOURCE.category, SOURCE.sub_category, SOURCE.maintenance, SOURCE.cost, SOURCE.product_line, SOURCE.start_date);

        SET @end_time = GETDATE();
        PRINT '>>> dim_products Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        PRINT '-------------------------------------------------------------------------'

        -------------------------------------------------------------------------
        PRINT '3. LOADING FACT: gold.fact_sales'
        -------------------------------------------------------------------------
        SET @start_time = GETDATE();

        -- Đọc dữ liệu từ Silver giao dịch và MAP thẳng sang Surrogate Key vật lý của tầng Gold vừa cập nhật phía trên
        ;WITH Src_fact_sales AS (
            SELECT 
                sd.sls_ord_num AS order_number, 
                dp.product_key,      -- Khóa Surrogate Key chuẩn Star Schema
                dc.customer_key,     -- Khóa Surrogate Key chuẩn Star Schema
                sd.sls_order_dt AS order_date, 
                sd.sls_ship_dt AS ship_date, 
                sd.sls_due_dt AS due_date,
                sd.sls_sales AS sales_amount,   
                sd.sls_quantity AS quantity, 
                sd.sls_price AS price
            FROM silver.crm_sales_details sd
            LEFT JOIN gold.dim_products dp ON sd.sls_prd_key = dp.product_number
            LEFT JOIN gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id
        )
        MERGE gold.fact_sales AS TARGET
        USING Src_fact_sales AS SOURCE
        ON TARGET.order_number = SOURCE.order_number 
           AND TARGET.product_key = SOURCE.product_key 
           AND TARGET.customer_key = SOURCE.customer_key -- Bộ 3 khóa tự nhiên để kiểm tra trùng lặp đơn hàng
        WHEN MATCHED THEN
            UPDATE SET 
                TARGET.order_date = SOURCE.order_date,
                TARGET.ship_date = SOURCE.ship_date,
                TARGET.due_date = SOURCE.due_date,
                TARGET.sales_amount = SOURCE.sales_amount,
                TARGET.quantity = SOURCE.quantity,
                TARGET.price = SOURCE.price
        WHEN NOT MATCHED THEN
            INSERT (order_number, product_key, customer_key, order_date, ship_date, due_date, sales_amount, quantity, price)
            VALUES (SOURCE.order_number, SOURCE.product_key, SOURCE.customer_key, SOURCE.order_date, SOURCE.ship_date, SOURCE.due_date, SOURCE.sales_amount, SOURCE.quantity, SOURCE.price);

        SET @end_time = GETDATE();
        PRINT '>>> fact_sales Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
        
        -- KẾT THÚC QUY TRÌNH BATCH JOB
        SET @batch_end_time = GETDATE()
        PRINT'========================================================================='
        PRINT'>>> Loading Gold Layer Completed Successfully'
        PRINT'>>> Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
        PRINT'========================================================================='
    END TRY
    BEGIN CATCH
        PRINT'=================================================================='
        PRINT'CRITICAL ERROR OCCURED DURING LOADING GOLD LAYER'
        PRINT'ERROR MESSAGE: ' + ERROR_MESSAGE()
        PRINT'ERROR NUMBER: '  + CAST(ERROR_NUMBER() AS NVARCHAR)
        PRINT'ERROR STATE: '   + CAST(ERROR_STATE() AS NVARCHAR)
        PRINT'=================================================================='
        
        -- Dấu dằn mặt ; trước THROW để chống lỗi cú pháp
        ;THROW; 
    END CATCH
END;
GO
