# data-warehouse-project

## 1. Introduction
&nbsp;&nbsp;&nbsp;Trong thời đại số hiện nay, khả năng chuyển đổi các dữ liệu thô thành những thông tin chi tiết có giá trị chính là lợi thế cạnh tranh cốt lõi. Tuy nhiên, nhiều doanh nghiệp hiện nay vẫn đang sử dụng **hệ cơ sở dữ liệu phân tán**, dữ liệu bị phân tán ở khắp nơi khiến cho việc thu thập và xử lý dữ liệu mất rất nhiều thời gian mà hiệu quả lại không cao, làm chậm tiến trình ra quyết định.

![data-flow (old systems)](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(old%20systems).png)

Project này được xây dựng để giải quyết những thách thức trên thông qua việc xây dựng hệ thống Data Warehouse. Bằng cách gom dữ liệu từ khắp nơi tập trung lại một chỗ, làm sạch và chuẩn hóa lại các nguồn dữ liệu rời rạc, hệ thống này sẽ loại bỏ những hạn chế của việc thu thập dữ liệu thủ công lặp đi lặp lại. Thay vào đó, nó tạo ra một **nguồn dữ liệu duy nhất đáng tin cậy**, sẵn sàng phục vụ cho các báo cáo BI chuyên sâu, dự báo xu hướng và hỗ trợ ra quyết định chiến lược.

Mục tiêu của tôi là chứng minh rằng một quy trình dữ liệu (data pipeline) được thiết kế bài bản có thể chuyển đổi sự phức tạp trong vận hành thành sự linh hoạt trong kinh doanh, biến dữ liệu thô thành một tài sản chiến lược vô giá.



Data warehouse (kho dữ liệu) là một hệ thống lưu trữ dữ liệu từ nhiều nguồn, nhiều môi trường khác nhau như: phần mềm bán hàng, kế toán, nhân sự,… giúp tăng cường hiệu suất truy vấn cho việc làm báo cáo và phân tích. Do đó, việc xây dựng và duy trì tính ổn định của nhà kho này đóng góp rất lớn vào việc tối ưu thời gian, chi phí và nguồn nhân lực đối với một doanh nghiệp.
 
- Hệ thống Data Warehouse giúp chuẩn hóa và làm sạch dữ liệu đầu vào bán tự động, tuân thủ theo quy trình ETL (Extract - Transform - Load)
- Data đầu vào bao gồm dữ liệu thuộc 3 nhóm customers (khách hàng), products (sản phẩm) và sales (bán hàng); được lấy từ 2 nguồn chính là CRM và ERP dưới định dạng csv.
- Lợi ích:
- Mục đích: giúp người dùng có cái nhìn tổng quan nhất, sử dụng để phân tích xu hướng của dữ liệu và làm báo cáo
## 2. Architecture
**Data Architecture là gì? Bài này sử dụng PP nào? Giới thiệu... bài này sử dụng Medallion Architecture...**
Data Flow:
- Nguồn lấy dữ liệu (Resources): Dữ liệu thô sẽ được lấy từ 2 nguồn ERP và CRM để đưa vào data warehouse. Dữ liệu trước khi được sử dụng cần phải đi qua 3 tầng xử lý khác nhau mới đủ điều kiện sử dụng để phân tích và làm báo cáo.
- Datawarehouse: **gồm 3 tầng,...**
  + Bronze Layer: Tầng đầu tiên này chỉ có vai trò thu thập đủ data tại địa chỉ được chỉ định, không can thiệp vào quá trình sửa đổi dữ liệu.
  + Silver Layer: Tầng thứ hai sẽ tập trung vào việc làm sạch và chuẩn hóa dữ liệu, bao gồm xử lý những dữ liệu rỗng và sai định dạng, đảm bảo độ tin cậy trước khi được đưa đến tầng Gold
  + Gold Layer: Đảm bảo dữ liệu xử lý để đáp ứng theo nhu cầu phân tích và sử dụng của doanh nghiệp, kết nối các bảng dữ liệu thành các nhóm Objects (đối tượng), dữ liệu được chia thành 2 nhóm Fact (dữ liệu số, phục vụ cho quá trình tính toán) và Dim (dữ liệu định tính, mô tả chi tiết cho các dữ liệu số).
- Analyze: 
![data-warehouse-architecture](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Data-warehouse-architecture.png)
- Công cụ sử dụng: SQL Server
## 3. Mô hình hóa dữ liệu (Data Modelling)
- **Giới thiệu các bảng chính để phân tích:**

- Conceptual Data Model (Mô hình Khái niệm)
- Logical Data Model (Mô hình Logic)
## 4. Key Features
- Cleansing như nào?
- Transform như nào
- Handle lỗi như nào?
## 5. Usage
- Cách vận hành hệ thống, thứ tự chạy những scripts nào? Lưu ý gì?
## 6. Data Dictionary
- Link tới file data_catalog, thuộc tính, mô tả giá trị của từng cột
