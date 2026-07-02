# BUILDING DATA WAREHOUSE PROJECT
## 1. Introduction

&nbsp;&nbsp;&nbsp;Trong kỷ nguyên số, khả năng chuyển đổi dữ liệu thô thành những thông tin có giá trị chính là lợi thế cạnh tranh cốt lõi của mọi doanh nghiệp. Tuy nhiên, tình trạng dữ liệu phân mảnh giữa các phòng ban khiến việc tổng hợp dữ liệu trở nên thủ công, tốn kém thời gian và làm chậm trễ các quyết định chiến lược.

![data-flow (old systems)](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(old%20systems).png)

&nbsp;&nbsp;&nbsp;Dự án này được xây dựng nhằm giải quyết triệt để những thách thức trên thông qua việc thiết kế và triển khai một kho dữ liệu tập trung (data warehouse). Hệ thống đóng vai trò như một kho lưu trữ hợp nhất, thu thập dữ liệu từ đa dạng các nguồn nghiệp vụ như bán hàng, kế toán, nhân sự... ở mọi thời điểm giúp tối ưu hóa hiệu suất truy vấn cho các hoạt động phân tích và báo cáo.

![data-warehouse](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(new-system).png)

&nbsp;&nbsp;&nbsp;Bằng việc tự động hóa quá trình thu thập, làm sạch và chuẩn hóa các nguồn dữ liệu rời rạc, hệ thống này thiết lập một "Nguồn dữ liệu duy nhất đáng tin cậy" (Single Source of Truth). Từ đó, loại bỏ sự phụ thuộc vào các quy trình thủ công lặp lại, cung cấp một nền tảng vững chắc để thực hiện các báo cáo BI chuyên sâu, dự báo xu hướng và hỗ trợ ra quyết định chiến lược tối ưu thời gian và chi phí.

## 2. Kiến trúc dữ liệu (Data Architecture)
&nbsp;&nbsp;&nbsp;Trước khi bắt tay vào xây dựng "nhà kho", ta cần một "bản thiết kế" thật tốt tùy theo yêu cầu của từng doanh nghiệp. Trong lĩnh vực phân tích dữ liệu, người ta gọi nó là Data Architecture (kiến trúc dữ liệu). Kiến trúc dữ liệu đóng vai trò là xương sống, định hướng các quy trình thu thập, lưu trữ, xử lý, phân phối.. của dòng dữ liệu, giúp doanh nghiệp tìm đúng thông tin cần thiết để nhanh chóng đưa ra quyết dịnh phù hợp trong nhiều trường hợp.
&nbsp;&nbsp;&nbsp;Một số kiến trúc dữ liệu nổi tiếng hiện nay như: Lambda, Kappa, Data Mesh... Mỗi phương pháp đều có ưu, nhược điểm riêng. Trong project này, tôi lựa chọn phương pháp Medallion Architecture nhờ sự nhất quán và kiểm soát chất lượng dữ liệu dựa trên sự phân tầng để xử lý, phù hợp với bộ dữ liệu mà tôi lựa chọn cho Project này. 
### 2.1 Medallion Architecture
**Medallion Architecture** là phương pháp phân tầng để xử lý dữ liệu, ba tầng này là Bronze(Đồng), Silver(Bạc) và Gold (Vàng). Mỗi tầng sẽ có một nhiệm vụ khác nhau để xử lý dữ liệu đầu vào trước khi được mang đi sử dụng.
- Bronze Layer: Lưu trữ dữ liệu thô gốc từ các nguồn để đảm bảo tính an toàn và dễ dàng truy vết.
- Silver Layer: Làm sạch và chuẩn hóa dữ liệu, đảm bảo tính nhất quán dữ liệu giữa các nguồn.
- Gold Layer: tái cấu trúc dữ liệu từ các bảng thô thành Data Schema chuyên biệt cho từng đối tượng (objects), tạo ra dữ liệu sạch và đáng tin cậy.

![](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Medallion-Architecture.png)

## 3. Mô hình hóa dữ liệu (Data Modelling)
Quá trình mô hình hóa dữ liệu sẽ tái cấu trúc những dữ liệu đã được xử lý ở tầng Silver thành các đối tượng (Objects) như: customers, products, sales... Các đối tượng này sẽ được gom thành từng bảng và được chia thành 2 thuộc tính: Bảng Fact(chứa số liệu, phục vụ cho việc tính toán) và Bảng Dim (Dimension - chứa những thông tin mô tả). Sau đó các bảng/đối tượng này sẽ được kết nối với nhau dựa vào mối quan hệ giữa chúng. Hệ thống những liên kết giữa các Objects này sẽ được gọi là Schema (lược đồ) 
Có hai loại lược đồ dữ liệu phổ biến là: Star Schema (lược đồ hình sao) và Snowflake Schema (lược đồ hình bông tuyết).
- Star Schema
- Snowflake Schema

## 4. Key Features
- Cleansing như nào?
- Transform như nào
- Handle lỗi như nào?
## 5. Usage
- Cách vận hành hệ thống, thứ tự chạy những scripts nào? Lưu ý gì?
## 6. Data Dictionary
- Link tới file data_catalog, thuộc tính, mô tả giá trị của từng cột
