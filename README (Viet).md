# BUILDING DATA WAREHOUSE PROJECT

## MỤC LỤC
&nbsp;&nbsp;&nbsp;[1. Giới thiệu chung](#1-giới-thiệu-chung)

&nbsp;&nbsp;&nbsp;[2. Kiến trúc dữ liệu (Data Architecture)](#2-kiến-trúc-dữ-liệu-data-architecture)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[2.1 Medallion Architecture](#21-medallion-architecture)

&nbsp;&nbsp;&nbsp;[3. Mô hình hóa dữ liệu (Data Modelling)](#3-mô-hình-hóa-dữ-liệu-data-modelling)

&nbsp;&nbsp;&nbsp;[4. Triển khai dự án (Project Implementation)](#4-triển-khai-dự-án-project-implementation)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.1 Chuẩn bị Data](#41-chuẩn-bị-data)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2 Thiết lập cấu trúc bảng](#42-thiết-lập-cấu-trúc-bảng)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.1 Tầng Bronze](#421-tầng-bronze)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.2 Tầng Silver](#422-tầng-silver)

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[4.2.3 Tầng Gold](#423-tầng-gold)

&nbsp;&nbsp;&nbsp;[5. Data Dictionary](#5-data-dictionary)

## 1. Giới thiệu chung
&nbsp;&nbsp;&nbsp;Trong kỷ nguyên số, khả năng chuyển đổi dữ liệu thô thành những thông tin có giá trị chính là lợi thế cạnh tranh cốt lõi của mọi doanh nghiệp. Tuy nhiên, tình trạng dữ liệu phân mảnh giữa các phòng ban khiến việc tổng hợp dữ liệu trở nên thủ công, tốn kém thời gian và làm chậm trễ các quyết định chiến lược.

![data-flow (old systems)](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(old%20systems).png)

&nbsp;&nbsp;&nbsp;Dự án này được xây dựng nhằm giải quyết triệt để những thách thức trên thông qua việc thiết kế và triển khai một kho dữ liệu tập trung (data warehouse). Hệ thống này đóng vai trò như một kho lưu trữ hợp nhất, thu thập dữ liệu từ đa dạng các nguồn nghiệp vụ như bán hàng, kế toán, nhân sự... ở mọi thời điểm giúp tối ưu hóa hiệu suất truy vấn cho các hoạt động phân tích và báo cáo.

![data-warehouse](https://github.com/trungbui011/data-warehouse-project/blob/main/images/data-flow(new-system).png)

&nbsp;&nbsp;&nbsp;Bằng việc tự động hóa quá trình thu thập, làm sạch và chuẩn hóa các nguồn dữ liệu rời rạc, hệ thống này thiết lập một "Nguồn dữ liệu duy nhất đáng tin cậy" (Single Source of Truth). Từ đó, loại bỏ sự phụ thuộc vào các quy trình thủ công lặp lại, cung cấp một nền tảng vững chắc để thực hiện các báo cáo BI chuyên sâu, dự báo xu hướng và hỗ trợ ra quyết định chiến lược tối ưu thời gian và chi phí.

## 2. Kiến trúc dữ liệu (Data Architecture)
&nbsp;&nbsp;&nbsp;Trước khi bắt tay vào xây dựng "nhà kho", ta cần một "bản thiết kế" thật tốt tùy theo yêu cầu của từng doanh nghiệp. Trong lĩnh vực phân tích dữ liệu, người ta gọi nó là Data Architecture (kiến trúc dữ liệu). Kiến trúc dữ liệu đóng vai trò là xương sống, định hướng các quy trình thu thập, lưu trữ, xử lý, phân phối.. của dòng dữ liệu, giúp doanh nghiệp tìm đúng thông tin cần thiết để nhanh chóng đưa ra quyết dịnh phù hợp trong nhiều trường hợp.

&nbsp;&nbsp;&nbsp;Một số kiến trúc dữ liệu nổi tiếng hiện nay như: Lambda, Kappa, Data Mesh... Mỗi phương pháp đều có ưu, nhược điểm riêng. Trong project này, tôi lựa chọn phương pháp Medallion Architecture nhờ sự nhất quán và kiểm soát chất lượng dữ liệu dựa trên sự phân tầng để xử lý, phù hợp với bộ dữ liệu mà tôi lựa chọn cho Project này. 
### 2.1 Medallion Architecture
&nbsp;&nbsp;&nbsp;**Medallion Architecture** là phương pháp phân tầng để xử lý dữ liệu, ba tầng này là **Bronze(đồng)**, **Silver(bạc)** và **Gold (vàng)**. Mỗi tầng sẽ có một nhiệm vụ khác nhau để xử lý dữ liệu đầu vào trước khi được mang đi sử dụng.
- Bronze Layer: Lưu trữ dữ liệu thô gốc từ các nguồn để đảm bảo tính an toàn và dễ dàng truy vết.
- Silver Layer: Làm sạch và chuẩn hóa dữ liệu, đảm bảo tính nhất quán dữ liệu giữa các nguồn.
- Gold Layer: tái cấu trúc dữ liệu từ các bảng thô thành Data Schema chuyên biệt cho từng đối tượng (objects), tạo ra dữ liệu sạch sẵn sàng sử dụng.

![Architecture](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Medallion-Architecture.png)

## 3. Mô hình hóa dữ liệu (Data Modelling)
&nbsp;&nbsp;&nbsp;Quá trình mô hình hóa dữ liệu được thực hiện ở tầng Gold, sau khi ta đã xác định được những đối tượng chính (tái cấu trúc dữ liệu đã được xử lý ở tầng Silver thành các bảng mang thông tin, thuộc tính của từng đối tượng) như: customers, products, sales... Các đối tượng này được phân loại thành 2 dạng là: **Bảng Fact** (chứa số liệu, phục vụ cho việc tính toán) và **Bảng Dim** (Dimension - chứa những thông tin mô tả). Các đối tượng sẽ được kết nối với nhau để tạo thành mô hình hóa dữ liệu dựa vào mối quan hệ giữa chúng. Lược đồ biểu diễn mối quan hệ giữa các đối tượng được gọi là Schema (lược đồ).

&nbsp;&nbsp;&nbsp;Có hai loại lược đồ dữ liệu phổ biến là: Star Schema (lược đồ hình sao) và Snowflake Schema (lược đồ hình bông tuyết).
- Star Schema: là một mô hình thiết kế cơ sở dữ liệu phổ biến trong Data Warehouse, bao gồm một bảng Fact ở trung tâm và được bao quanh bởi các bảng Dimension vệ tinh chứa thông tin mô tả chi tiết.
- Snowflake Schema: là mô hình nâng cấp của Star Schema, lúc này các bảng Dimension được chuẩn hóa thành nhiều cấp độ để giảm thiểu dư thừa dữ liệu. Mô hình này phù hợp khi cần đảm bảo tính toàn vẹn dữ liệu cao và cấu trúc logic phức tạp.

![Schema](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Schemas.png)

## 4. Triển khai dự án (Project Implementation)
&nbsp;&nbsp;&nbsp;Bước đầu tiên là bước cực kỳ quan trọng, đó là [khởi tạo Database](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/init_database.sql)
### 4.1 Chuẩn bị Data
&nbsp;&nbsp;&nbsp;Dữ liệu thô ban đầu thuộc 2 nguồn giả định CRM và ERP được lưu trong folder [datasets](https://github.com/trungbui011/data-warehouse-project/tree/main/datasets) dưới dạng các file csv.
### 4.2 Thiết lập cấu trúc bảng
&nbsp;&nbsp;&nbsp;Trước khi thiết lập cấu trúc bảng của từng layer, ta cần tạo database trên RDBMS (SQL Server hoặc Oracle). Việc này giúp chuẩn hóa hạ tầng, đảm bảo tính nhất quán và hiệu năng tối ưu cho các tầng dữ liệu phía sau.
  #### 4.2.1 Tầng Bronze
&nbsp;&nbsp;&nbsp;Bước 1: Khởi tạo DDL (Data Definition Language): Xây dựng cấu trúc bảng và định nghĩa kiểu dữ liệu phù hợp với dữ liệu thô từ nguồn. [ddl_bronze.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/1.%20bronze_layer/ddl_bronze.sql)

&nbsp;&nbsp;&nbsp;Bước 2: Tự động hóa với Stored Procedures: Thiết lập câu lệnh lưu trữ script vào database (Stored Procedures) để tối ưu hóa hiệu suất nạp dữ liệu và chuẩn hóa quy trình xử lý. [proc_load_bronze.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/1.%20bronze_layer/proc_load_bronze.sql)

&nbsp;&nbsp;&nbsp;Dữ liệu thô đưa vào tầng Bronze được giữ nguyên toàn bộ cấu trúc và định dạng. Mục đích là để dễ truy vết và xác định lỗi nếu ta gặp lỗi ở tầng Silver hay Gold. Dữ liệu được nạp vào tự động định kỳ có hệ thống kiểm tra để tránh lỗi lặp dữ liệu (duplicate data), tối ưu không gian lưu trữ và xử lý data.

![](https://github.com/trungbui011/data-warehouse-project/blob/main/images/bronze_tables.png)

  #### 4.2.2 Tầng Silver
&nbsp;&nbsp;&nbsp;Bước 1: Thiết kế cấu trúc bảng (DDL): Định nghĩa lại các bảng với kiểu dữ liệu chuẩn, cũng tương tự như tầng Bronze nhưng lần này cần siết chặt điều kiện hơn nữa [ddl_silver.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/2.%20silver_layer/ddl_silver.sql)

&nbsp;&nbsp;&nbsp;Bước 2: Xử lý và chuẩn hóa dữ liệu (ETL): Ở tầng Silver này cần xử lý những trường hợp dữ liệu sau:
- Data Cleansing: loại bỏ giá trị trùng lặp, xử lý các giá trị rỗng (NULL)
- Thống nhất định dạng: (ngày tháng) và biến thể của dữ liệu (vd: 'US', 'USA' và 'United States' -> 'United States')
- Đồng bộ hóa các khóa: khắc phục vấn đề khi dữ liệu bị phân mảnh, ví dụ cùng 1 **id** khách hàng **'11000'**:
  - Ở bảng **BRONZE.erp_cust_az12** giá trị trong cột **cid** là **'NASAW00011000'**,
  - Ở bảng **BRONZE.crm_cust_info** giá trị trong cột **cst_key** là **'AW00011000'**,
  - Ở bảng **BRONZE.erp_loc_a101** giá trị trong cột **cid** là **'AW-00011000'**.

&nbsp;&nbsp;&nbsp;Do đó cần phải thống nhất một định dạng để đảm bảo tính toàn vẹn và chính xác trước khi thực hiện JOIN các bảng ở tầng Gold. Để dễ dàng đối soát và kiểm tra dữ liệu, mỗi bảng được bổ sung cột **dwh_create_date** nhằm theo dõi thời điểm dữ liệu được nạp vào hệ thống (chi tiết đến từng mili giây).

&nbsp;&nbsp;&nbsp;Tham khảo script Stored Procedures của tầng Silver tại đây: [proc_load_silver.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/2.%20silver_layer/proc_load_silver.sql). 
  #### 4.2.3 Tầng Gold
&nbsp;&nbsp;&nbsp;Đây là tầng cuối cùng, dữ liệu bây giờ sẽ được tổ chức lại theo mô hình Star Schema để phù hợp với quy mô của bộ dữ liệu, nhằm tối ưu hiệu suất truy vấn và hỗ trợ trực quan hóa dữ liệu (BI).

&nbsp;&nbsp;&nbsp;Mối liên hệ giữa các bảng được kết nối với nhau thông qua các khóa chính PK (Primary key):

![objects relationship](https://github.com/trungbui011/data-warehouse-project/blob/main/images/Objects%20relationship.png)

&nbsp;&nbsp;&nbsp;Data flow của project này được trình bày chi tiết như hình dưới:

![](https://github.com/trungbui011/data-warehouse-project/blob/main/images/project-data-flow.png)

&nbsp;&nbsp;&nbsp;Dưới đây là scripts SQL tạo 3 objects cho tầng Gold dựa theo data flow: [ddl_gold.sql](https://github.com/trungbui011/data-warehouse-project/blob/main/scripts/3.%20gold_layer/ddl_gold.sql)

&nbsp;&nbsp;&nbsp;Sử dụng Star schema để mô hình hóa 3 objects này:

![scm](https://github.com/trungbui011/data-warehouse-project/blob/main/images/star%20schema.png)

## 5. Data Dictionary
&nbsp;&nbsp;&nbsp;Từ điển data này sẽ mô tả chi tiết tên từng cột, kiểu dữ liệu và ý nghĩa của nó đối với object đó, hãy tham khảo data dictionary bằng  [Tiếng Anh](https://github.com/trungbui011/data-warehouse-project/blob/main/docs/data_catalog%20(English%20Version).md) hoặc [Tiếng Việt](https://github.com/trungbui011/data-warehouse-project/blob/main/docs/data_catalog%20(Vietnamese%20Version).md)
