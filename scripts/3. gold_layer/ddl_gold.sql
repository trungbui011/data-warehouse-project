-- Create Dimension Customers
CREATE VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY cc.cst_id) AS customer_key, -- Surrogate Key: làm khóa chính cho bảng object
	cc.cst_id AS customer_id, 
	cc.cst_key AS customer_number, 
	cc.cst_firstname AS first_name, 
	cc.cst_lastname AS last_name,
	el.cntry AS country,
	cc.cst_marital_status AS marital_status, 
	CASE WHEN cc.cst_gndr != 'n/a' THEN cc.cst_gndr -- Giả sử đã xác nhận nguồn data tin cậy từ người cung cấp CRM data
		 ELSE COALESCE(ec.gen,'n/a')
	END AS gender,
	ec.bdate AS birthdate,
	cc.cst_create_date AS create_date
FROM silver.crm_cust_info cc
LEFT JOIN silver.erp_cust_az12 ec ON cc.cst_key = ec.cid
LEFT JOIN silver.erp_loc_a101 el ON cc.cst_key = el.cid

-- Create Dimension Products
CREATE VIEW gold.dim_products AS
SELECT  ROW_NUMBER() OVER(ORDER BY cp.prd_start_dt, cp.short_prd_key) AS product_key,
		cp.prd_id AS product_id,
		cp.short_prd_key AS product_number,
		cp.prd_nm AS product_name,
		cp.cat_id AS category_id,
		CASE WHEN ec.cat IS NULL THEN 'n/a'
			 ELSE ec.cat
		END AS category,
		CASE WHEN ec.subcat IS NULL THEN 'n/a' 
			 ELSE ec.subcat
		END AS sub_category,
		CASE WHEN ec.maintenance IS NULL THEN 'n/a'
			 ELSE ec.maintenance
		END AS maintenance,		
		cp.prd_cost AS cost, 
		cp.prd_line AS product_line, 
		cp.prd_start_dt AS 'start_date'
FROM silver.crm_prd_info cp
LEFT JOIN silver.erp_px_cat_g1v2 ec ON cp.cat_id = ec.id

-- Foreign Key Integrity (Dimensions)
CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_ord_num AS order_number, 
	dp.product_number, 
	dc.customer_id, 
	sd.sls_order_dt AS order_date, 
	sd.sls_ship_dt AS ship_date, 
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,	
	sd.sls_quantity AS quantity, 
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp ON sd.sls_prd_key= dp.product_number
LEFT JOIN gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id
