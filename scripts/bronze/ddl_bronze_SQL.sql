/*
CREATE BRONZE TABLES
- This script creates tables in the Bronze schema and drops existing tables if they already existed

TẠO CÁC BẢNG CHO LỚP BRONZE
- Script này dùng để tạo cấu trúc cho các bảng của lớp Bronze, những bảng trùng tên đã tồn tại từ trước sẽ bị xóa đi để xây dựng cấu trúc mới.

*/

IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.crm_cust_info
CREATE TABLE bronze.crm_cust_info (
	cst_id NVARCHAR(50),
	cst_key CHAR(10),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO

IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info (
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO

IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.crm_sales_details	
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id NVARCHAR(50)),
	sls_order_dt NVARCHAR(50),
	sls_ship_dt NVARCHAR(50),
	sls_due_dt NVARCHAR(50),
	sls_sales NVARCHAR(50),
	sls_quantity NVARCHAR(50),
	sls_price NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.erp_cust_az12	
CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.erp_loc_a101	
CREATE TABLE bronze.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL -- Nếu bảng không tồn tại -> Trả về rỗng (NULL); Nếu bảng tồn tại (không rỗng) -> Drop table
DROP TABLE bronze.erp_px_cat_g1v2
CREATE TABLE bronze.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO
