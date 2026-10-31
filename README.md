
# GlobalMart ELT Pipeline with Snowflake & dbt Cloud

## 1. Giới thiệu dự án

Dự án thực hành xây dựng quy trình ELT (Extract - Load - Transform) cho bộ dữ liệu GlobalMart, sử dụng Snowflake làm nền tảng lưu trữ dữ liệu và dbt Cloud để xây dựng, chuyển đổi và kiểm thử các mô hình dữ liệu.

Mục tiêu của dự án:
- Nạp dữ liệu CSV vào Snowflake.
- Xây dựng các mô hình Staging, Fact, Dimension và Data Mart.
- Chuyển đổi dữ liệu bằng SQL và dbt.
- Kiểm tra chất lượng dữ liệu.
- Phân tích doanh thu, chi phí và lợi nhuận.
- Quản lý mã nguồn bằng GitHub và Pull Request.

## 2. Công nghệ sử dụng

| Công nghệ | Vai trò |
|---|---|
| Snowflake | Cloud Data Warehouse |
| dbt Cloud | Data Transformation & Testing |
| SQL | Truy vấn và xử lý dữ liệu |
| GitHub | Quản lý mã nguồn và phiên bản |
| CSV | Dữ liệu đầu vào |

## 3. Kiến trúc hệ thống

Quy trình ELT của dự án:

```text
CSV Source Files
       |
       v
Snowflake Internal Stage
RAW.GLOBALMART.UPLOAD
       |
       v
RAW.GLOBALMART
  |-- CUSTOMERS
  |-- PRODUCTS
  |-- ORDERS
       |
       v
dbt Staging Models
  |-- stg_customers
  |-- stg_products
  |-- stg_orders
       |
       v
Transformation Models
  |-- fct_orders
  |-- dim_products
       |
       v
Analytics Data Mart
  |-- mart_globalmart
       |
       v
Data Validation & Analytics
```

Các mô hình dbt được xây dựng trong database `ANALYTICS`, schema `DBT_HUNGPTIT`.

## 4. Dữ liệu đầu vào

Dự án sử dụng ba file CSV:

| File | Bảng Snowflake | Số dòng |
|---|---|---:|
| customers.csv | RAW.GLOBALMART.CUSTOMERS | 793 |
| product.csv | RAW.GLOBALMART.PRODUCTS | 1,893 |
| orders.csv | RAW.GLOBALMART.ORDERS | 9,800 |

Dữ liệu được tải vào Snowflake Internal Stage, sau đó nạp vào các bảng trong schema RAW.GLOBALMART.

## 5. Các mô hình dbt

### 5.1. Staging Layer

**stg_customers.sql**

Chuẩn hóa và lựa chọn các trường dữ liệu khách hàng:
- CustomerID
- CustomerName
- Segment
- Country
- State

**stg_products.sql**

Chuẩn hóa dữ liệu sản phẩm:
- Category
- ProductID
- ProductName
- SubCategory

**stg_orders.sql**

Chuẩn hóa dữ liệu đơn hàng, bao gồm:
- OrderID
- OrderDate
- ShipDate
- ShipMode
- CustomerID
- ProductID
- OrderCostPrice
- OrderSellingPrice

Hai trường ngày được chuyển đổi bằng hàm `TRY_TO_DATE()`.

### 5.2. Transformation Layer

**fct_orders.sql**

Xây dựng mô hình dữ liệu giao dịch, bổ sung trường lợi nhuận:

```sql
ORDERSELLINGPRICE - ORDERCOSTPRICE AS ORDERPROFIT
```

**dim_products.sql**

Xây dựng bảng chiều sản phẩm theo ProductID.

Mô hình:
- Gom nhóm sản phẩm theo ProductID.
- Phát hiện ProductName không nhất quán.
- Kiểm tra sự thống nhất của Category và SubCategory.
- Gắn cờ NAME_CONFLICT cho các sản phẩm có tên xung đột.

### 5.3. Analytics Layer

**mart_globalmart.sql**

Kết hợp dữ liệu giao dịch, khách hàng và sản phẩm bằng LEFT JOIN.

Mô hình phân tích cuối cùng cung cấp:
- Thông tin đơn hàng.
- Thông tin khách hàng.
- Thông tin sản phẩm.
- Doanh thu.
- Chi phí.
- Lợi nhuận.
- Cờ phát hiện xung đột tên sản phẩm.

## 6. Kết quả phân tích

Kết quả truy vấn trên Snowflake:

| Chỉ tiêu | Giá trị |
|---|---:|
| Tổng số dòng giao dịch | 9,800 |
| Tổng doanh thu | 2,259,294 |
| Tổng chi phí | 1,588,857 |
| Tổng lợi nhuận theo từng dòng hợp lệ | 670,743 |
| Tỷ suất lợi nhuận tính từ tổng lợi nhuận trên doanh thu | 29.69% |

Lưu ý: Có 8 dòng thiếu giá bán. Vì vậy, tổng lợi nhuận tính từ các dòng có dữ liệu hợp lệ không hoàn toàn bằng tổng doanh thu trừ tổng chi phí của tất cả các dòng.

Các giá trị tài chính sử dụng đơn vị theo dữ liệu nguồn.

## 7. Kiểm tra chất lượng dữ liệu

Các câu truy vấn SQL được sử dụng để kiểm tra tính đầy đủ, trùng lặp và tính nhất quán của dữ liệu.

### 7.1. Kết quả kiểm tra

| Hạng mục | Kết quả |
|---|---:|
| Số dòng giao dịch | 9,800 |
| Ngày đặt hàng bị NULL | 0 |
| Ngày giao hàng bị NULL | 0 |
| Giá bán bị NULL | 8 |
| Lợi nhuận bị NULL | 8 |
| Dòng thiếu thông tin khách hàng khi kết hợp dữ liệu | 5 |
| Sản phẩm có tên không nhất quán | 32 |
| Số khách hàng duy nhất | 793 |
| Số ProductID duy nhất | 1,861 |

### 7.2. Nhận xét

- Các trường ngày được chuyển đổi thành công.
- Một số giao dịch thiếu giá bán, dẫn đến lợi nhuận NULL.
- Có 5 giao dịch không liên kết được với thông tin khách hàng.
- Có 32 ProductID xuất hiện với các tên sản phẩm khác nhau.
- Số OrderID duy nhất là 9,799 trên 9,800 dòng. Một OrderID có thể tương ứng với nhiều dòng sản phẩm, vì vậy cần xác định đúng cấp độ dữ liệu trước khi kiểm tra tính duy nhất.

Các vấn đề dữ liệu được ghi nhận và phân tích thay vì tự ý xóa bản ghi nguồn.

## 8. Kiểm thử bằng dbt

Dự án khai báo các bài kiểm thử trong file:

`models/globalmart_tests.yml`

Các kiểm thử bao gồm kiểm tra dữ liệu bắt buộc và tính duy nhất ở các trường được lựa chọn.

Kết quả chạy dbt:

```text
Total tests: 7
Passed:      7
Warnings:    0
Errors:      0
```

**Kết quả: 7/7 bài kiểm thử thành công.**

Lưu ý: Kết quả kiểm thử thành công không đồng nghĩa toàn bộ dữ liệu nguồn không còn vấn đề. Các giá trị NULL và xung đột dữ liệu đã phát hiện vẫn được ghi nhận trong phần đánh giá.

## 9. Cấu trúc repository

```text
coursework-dbt-snowflake-globalmart/
|
|-- analyses/
|-- macros/
|-- models/
|   |-- example/
|   |-- stg_customers.sql
|   |-- stg_products.sql
|   |-- stg_orders.sql
|   |-- fct_orders.sql
|   |-- dim_products.sql
|   |-- mart_globalmart.sql
|   |-- globalmart_tests.yml
|
|-- seeds/
|-- snapshots/
|-- tests/
|-- dbt_project.yml
|-- README.md
```

## 10. Hướng dẫn thực thi

Yêu cầu:
- Tài khoản Snowflake.
- Dữ liệu nguồn đã được tải vào các bảng RAW.
- Dự án dbt Cloud được kết nối với Snowflake.
- Quyền truy cập warehouse và database phù hợp.

Chạy toàn bộ mô hình:

```bash
dbt run
```

Chạy các mô hình phụ thuộc của GlobalMart:

```bash
dbt run --select +mart_globalmart
```

Chạy kiểm thử:

```bash
dbt test
```

Chạy mô hình cùng các kiểm thử liên quan:

```bash
dbt build --select +mart_globalmart
```

## 11. Quản lý mã nguồn

Dự án sử dụng GitHub để quản lý thay đổi mã nguồn.

Quy trình phát triển đã thực hiện:

1. Khởi tạo repository.
2. Kết nối GitHub với dbt Cloud.
3. Tạo nhánh `feature/globalmart-models`.
4. Phát triển 6 mô hình SQL và file kiểm thử.
5. Chạy mô hình và kiểm thử trên Snowflake.
6. Commit và đồng bộ thay đổi lên GitHub.
7. Tạo Pull Request.
8. Merge mã nguồn vào nhánh `main`.

## 12. Kết luận

Dự án đã thực hiện thành công quy trình ELT từ dữ liệu CSV đến các mô hình phân tích trên Snowflake thông qua dbt Cloud.

Các kết quả chính:
- Nạp thành công 3 bộ dữ liệu nguồn.
- Xây dựng 6 mô hình dbt SQL.
- Xây dựng mô hình phân tích GlobalMart.
- Thực hiện thành công 7 bài kiểm thử dbt.
- Phát hiện và phân tích những vấn đề chất lượng dữ liệu.
- Quản lý phiên bản và tích hợp mã nguồn bằng GitHub.

Dự án minh họa quy trình xây dựng một hệ thống phân tích dữ liệu có cấu trúc, có kiểm thử và có khả năng mở rộng.

---

**Repository:** coursework-dbt-snowflake-globalmart

**GitHub:** [Hungnguyencode](https://github.com/Hungnguyencode)

**Mục đích:** Coursework - Data Engineering / ELT Practice
