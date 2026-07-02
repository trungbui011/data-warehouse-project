# data-warehouse-project

## 1. Introduction

&nbsp;&nbsp;&nbsp;Trong kỷ nguyên số, khả năng chuyển đổi dữ liệu thô thành những thông tin có giá trị chính là lợi thế cạnh tranh cốt lõi của mọi doanh nghiệp. Tuy nhiên, tình trạng dữ liệu phân mảnh giữa các phòng ban khiến việc tổng hợp dữ liệu trở nên thủ công, tốn kém thời gian và làm chậm trễ các quyết định chiến lược.

![data-flow (old systems)](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(old%20systems).png)

&nbsp;&nbsp;&nbsp;Dự án này được xây dựng nhằm giải quyết triệt để những thách thức trên thông qua việc thiết kế và triển khai một kho dữ liệu tập trung (data warehouse). Hệ thống đóng vai trò như một kho lưu trữ hợp nhất, thu thập dữ liệu từ đa dạng các nguồn nghiệp vụ như bán hàng, kế toán, nhân sự... ở mọi thời điểm giúp tối ưu hóa hiệu suất truy vấn cho các hoạt động phân tích và báo cáo.

![data-warehouse](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(new-system).png)

&nbsp;&nbsp;&nbsp;Bằng việc tự động hóa quá trình thu thập, làm sạch và chuẩn hóa các nguồn dữ liệu rời rạc, hệ thống này thiết lập một "Nguồn dữ liệu duy nhất đáng tin cậy" (Single Source of Truth). Từ đó, loại bỏ sự phụ thuộc vào các quy trình thủ công lặp lại, cung cấp một nền tảng vững chắc để thực hiện các báo cáo BI chuyên sâu, dự báo xu hướng và hỗ trợ ra quyết định chiến lược tối ưu thời gian và chi phí.

## 2. Architecture
Trước khi bắt tay vào xây dựng "nhà kho", ta cần một "bản thiết kế" thật tốt tùy theo yêu cầu của từng doanh nghiệp. Trong lĩnh vực phân tích dữ liệu, người ta gọi nó là Data Architecture (Kiến trúc dữ liệu). Kiến trúc dữ liệu giúp chúng ta thiết kế đường đi của thông tin dữ liệu, giúp doanh nghiệp tìm đúng thông tin cần thiết để nhanh chóng đưa ra quyết dịnh phù hợp trong nhiều trường hợp.

- Kiến trúc hệ thống
- Giới thiệu các PP
- Vì sao chọn Medallion

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
