# data-warehouse-project

## 1. Introduction
- Data warehouse đóng vai trò như một nhà kho chứa thông tin mà các công ty, doanh nghiệp cần. Việc xây dựng và duy trì tính ổn định của nhà kho này góp phần tối ưu thời gian và nhân lực rất lớn đối với một doanh nghiệp.
- Hệ thống Data Warehouse giúp chuẩn hóa và làm sạch dữ liệu đầu vào bán tự động, tuân thủ theo quy trình ETL (Extract - Transform - Load)
- Data đầu vào bao gồm dữ liệu thuộc 3 nhóm customers (khách hàng), products (sản phẩm) và sales (bán hàng); được lấy từ 2 nguồn chính là CRM và ERP dưới định dạng csv.
- Mục đích: giúp người dùng có cái nhìn tổng quan nhất, sử dụng để phân tích xu hướng của dữ liệu và làm báo cáo
## 2. Architecture
- Data flow: Dữ liệu thô sẽ được lấy từ 2 nguồn ERP và CRM để đưa vào data warehouse. Dữ liệu trước khi được sử dụng cần phải đi qua 3 tầng xử lý khác nhau mới đủ điều kiện tiêu chuẩn sử dụng.
+ Bronze Layer:
+ Silver Layer:
+ Gold Layer:
![data-warehouse-architecture](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Data-warehouse-architecture.png)
- Công cụ sử dụng: SQL Server
## 3. Data Model
- Giới thiệu các bảng chính để phân tích
## 4. Key Features
- Cleansing như nào?
- Transform như nào
- Handle lỗi như nào?
## 5. Usage
- Cách vận hành hệ thống, thứ tự chạy những scripts nào? Lưu ý gì?
## 6. Data Dictionary
- Link tới file data_catalog, thuộc tính, mô tả giá trị của từng cột
