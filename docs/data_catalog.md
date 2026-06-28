# DATA DICTIONARY FOR GOLD LAYER

1. gold.dim_customers
- Purpose: 
- Columns:

| Column name | Data Type | Description |
|:---|:---|:---|
| customer_key | INT | Surrogate key uniquely identifying each customer record in the table |
|customer_id| INT | Unique numerical identifier assigned to each customer |
|customer_number| CHAR(10) | Alphanumeric identifier representing the customer, used for tracking and referencing |
|first_name| NVARCHAR(50) | The customer first name |
|last_name| NVARCHAR(50) | The customer last name |
|country| NVARCHAR(50) | The country where the customer come from |
|marital_status| VARCHAR(6) | Current status of the customer ('Single', 'Married') |
|gender| VARCHAR(6) | The gender of the customer ('Male', 'Female', 'n/a')|
|birthdate| DATE | The date of birth of the customer, formatted as yyyy-mm-dd (1982-03-25)|
|create_date| DATE | The date of customer record was created in the system, formatted as yyyy-mm-dd (2026-05-20)|

2. gold.dim_products
- Purpose:
- Columns:

| Column name | Data Type | Description |
|:---|:---|:---|
|product_key| INT| Surrogate key uniquely identifying each product record in the table |
|product_id| INT | Unique numerical identifier assigned to each product |
|product_number| Alphanumeric identifier representing the product, used for tracking and referencing ||
|product_name| NVARCHAR(50) |The product's name|
|category_id| CHAR(5) | Unique numerical identifier assigned to each category |
|category| NVARCHAR(50) | The name of the category|
|sub_category| NVARCHAR(50) | The name of the subcategory |
|maintenance| VARCHAR(3) ||
|cost| FLOAT ||
|product_line| VARCHAR(20) ||
|start_date| DATE ||
