-- 1. Khởi tạo bảng danh mục Khách hàng (Dimension)
CREATE TABLE gold.dim_customers (
    customer_key INT IDENTITY(1,1) PRIMARY KEY, -- Tự động tăng, cố định vĩnh viễn
    customer_id INT,
    customer_number NVARCHAR(50),
    first_name NVARCHAR(100),
    last_name NVARCHAR(100),
    country NVARCHAR(100),
    marital_status NVARCHAR(50),
    gender NVARCHAR(50),
    birthdate DATE,
    create_date DATE
);

-- 2. Khởi tạo bảng danh mục Sản phẩm (Dimension)
CREATE TABLE gold.dim_products (
    product_key INT IDENTITY(1,1) PRIMARY KEY, -- Tự động tăng, cố định vĩnh viễn
    product_id INT,
    product_number NVARCHAR(50),
    product_name NVARCHAR(150),
    category_id NVARCHAR(50),
    category NVARCHAR(100),
    sub_category NVARCHAR(100),
    maintenance NVARCHAR(100),
    cost DECIMAL(18,4),
    product_line NVARCHAR(50),
    start_date DATE
);

-- 3. Khởi tạo bảng Doanh số giao dịch (Fact)
CREATE TABLE gold.fact_sales (
    order_number NVARCHAR(50),
    product_key INT,    -- Đã chuẩn hóa sang Surrogate Key của Dim Product
    customer_key INT,   -- Đã chuẩn hóa sang Surrogate Key của Dim Customer
    order_date DATE,
    ship_date DATE,
    due_date DATE,
    sales_amount DECIMAL(18,4),
    quantity INT,
    price DECIMAL(18,4)
);
