# TỪ ĐIỂN DỮ LIỆU TẦNG GOLD

## 1. gold.dim_customers
* **Mục đích:** Lưu trữ thông tin chi tiết của khách hàng.

| Tên cột (Column name) | Kiểu dữ liệu | Mô tả chi tiết | Ghi chú |
| :---: | :---: | :--- | :--- |
| **customer_key** | INT | Khóa thay thế (Surrogate key) giúp định danh duy nhất mỗi bản ghi khách hàng trong bảng. | Khóa chính (Primary Key) |
| **customer_id** | INT | Mã định danh khách hàng bằng số từ hệ thống nguồn. | Khóa tự nhiên (Natural Key) |
| **customer_number** | VARCHAR(15) | Mã khách hàng dạng chuỗi ký tự (chữ và số), dùng để theo dõi và đối chiếu trên toàn hệ thống. | |
| **first_name** | NVARCHAR(50) | Tên của khách hàng. | |
| **last_name** | NVARCHAR(50) | Họ và tên đệm của khách hàng. | |
| **country** | NVARCHAR(50) | Quốc gia khách hàng sinh sống. | |
| **marital_status** | VARCHAR(10) | Tình trạng hôn nhân của khách hàng ('Single', 'Married'). | |
| **gender** | VARCHAR(10) | Giới tính ('Male', 'Female', 'n/a'). | |
| **birthdate** | DATE | Ngày sinh của khách hàng, định dạng: yyyy-mm-dd. | |
| **create_date** | DATE | Thời gian tạo lập thông tin khách hàng trên hệ thống, định dạng: yyyy-mm-dd. | |

---

## 2. gold.dim_products
* **Mục đích:** Cung cấp thông tin chi tiết và các thuộc tính của sản phẩm.

| Tên cột (Column name) | Kiểu dữ liệu | Mô tả chi tiết | Ghi chú |
| :---: | :---: | :--- | :--- |
| **product_key** | INT | Khóa thay thế (Surrogate key) giúp định danh duy nhất mỗi bản ghi sản phẩm trong bảng. | Khóa chính (Primary Key) |
| **product_id** | INT | Mã định danh sản phẩm bằng số, duy nhất từ hệ thống nguồn. | Khóa tự nhiên (Natural Key) |
| **product_number** | VARCHAR(15) | Mã sản phẩm dạng chuỗi ký tự (chữ và số) để theo dõi và đối chiếu. | |
| **product_name** | NVARCHAR(100) | Tên sản phẩm. | |
| **category_id** | VARCHAR(10) | Mã định danh của danh mục sản phẩm. | |
| **category** | NVARCHAR(50) | Tên danh mục sản phẩm. | |
| **sub_category** | NVARCHAR(50) | Tên danh mục con của sản phẩm. | |
| **maintenance** | VARCHAR(5) | Sản phẩm có yêu cầu bảo trì hay không ('Yes', 'No', 'n/a'). | |
| **cost** | DECIMAL(18,2) | Giá gốc của sản phẩm. | |
| **product_line** | VARCHAR(20) | Dòng sản phẩm cụ thể ('Mountain', 'Road', 'Touring', 'other Sales', 'n/a'). | |
| **start_date** | DATE | Ngày sản phẩm bắt đầu được mở bán trên hệ thống. | |

---

## 3. gold.fact_sales
* **Mục đích:** Lưu trữ dữ liệu giao dịch bán hàng phục vụ cho mục đích phân tích và báo cáo hiệu suất kinh doanh.

| Tên cột (Column name) | Kiểu dữ liệu | Mô tả chi tiết | Ghi chú |
| :---: | :---: | :--- | :--- |
| **order_number** | VARCHAR(15) | Mã đơn hàng (chữ và số) duy nhất cho mỗi giao dịch bán hàng. | |
| **product_key** | INT | Khóa thay thế liên kết dòng đơn hàng với bảng sản phẩm (gold.dim_products). | Khóa ngoại (Foreign Key) |
| **customer_key** | INT | Khóa thay thế liên kết dòng đơn hàng với bảng khách hàng (gold.dim_customers). | Khóa ngoại (Foreign Key) |
| **order_date** | DATE | Ngày khách hàng đặt hàng. | |
| **ship_date** | DATE | Ngày đơn hàng được giao cho đơn vị vận chuyển hoặc khách hàng. | |
| **due_date** | DATE | Hạn chót thanh toán của đơn hàng. | |
| **sales_amount** | DECIMAL(18,2) | Tổng giá trị bằng tiền của dòng sản phẩm trong đơn hàng. | |
| **quantity** | INT | Số lượng sản phẩm được đặt mua. | |
| **price** | DECIMAL(18,2) | Đơn giá của từng sản phẩm. | |
