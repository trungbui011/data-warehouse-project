# DATA DICTIONARY FOR GOLD LAYER

Star Schema của tầng Gold:

![](https://github.com/trungbui011/data-warehouse-project/raw/main/images/star%20schema.png)

## 1. gold.dim_customers
- Purpose: Stores customer details enriched with demographic and geographic data

| Column name | Data Type | Description |
|:---:|:---:|:---|
| customer_key | INT | Surrogate key uniquely identifying each customer record in the table |
|customer_id| INT | Unique numerical identifier assigned to each customer |
|customer_number| VARCHAR(20) | Alphanumeric identifier representing the customer, used for tracking and referencing |
|first_name| NVARCHAR(50) | The customer first name |
|last_name| NVARCHAR(50) | The customer last name |
|country| NVARCHAR(50) | The country where the customer come from |
|marital_status| VARCHAR(10) | Current status of the customer ('Single', 'Married') |
|gender| VARCHAR(10) | The gender of the customer ('Male', 'Female', 'n/a')|
|birthdate| DATE | The date of birth of the customer, formatted as yyyy-mm-dd (1982-03-25)|
|create_date| DATE | The date of customer record was created in the system, formatted as yyyy-mm-dd (2026-05-20)|

## 2. gold.dim_products
- Purpose: Provides information about the products and their attributes

| Column name | Data Type | Description |
|:---:|:---:|:---|
|product_key| INT| Surrogate key uniquely identifying each product record in the table |
|product_id| INT | Unique numerical identifier assigned to each product |
|product_number| VARCHAR(20) | Alphanumeric identifier representing the product, used for tracking and referencing |
|product_name| NVARCHAR(50) |The product's name|
|category_id| VARCHAR(10) | Unique numerical identifier assigned to each category |
|category| NVARCHAR(50) | The name of the category|
|sub_category| NVARCHAR(50) | The name of the subcategory |
|maintenance| VARCHAR(3) | Whether the product requires maintenance or not ('Yes', 'No', 'n/a')|
|cost| DECIMAL(18, 2) | The cost or base price of the product|
|product_line| VARCHAR(20) | The specific product line ('Mountain', 'Road', 'Touring', 'other Sales', 'n/a')|
|start_date| DATE |The date when products are available for sales|

## 3. gold.fact_sales
- Purpose: Stores transactional sales data for analytical purposes

| Column name | Data Type | Description |
|:---:|:---:|:---|
|order_number| VARCHAR(10) | A unique alphanumeric identifier for each sales order |
|product_key| INT | Surrogate key link the order to the product dimension table |
|customer_key| INT | Surrogate key link the order to the customer dimension table |
|order_date| DATE | The date when the order was placed|
|ship_date| DATE |The date when the order was shipped to the customer|
|due_date| DATE | The date when the order payment was due|
|sales_amount| DECIMAL(18, 2) | The total monetary value of the sale fỏ the line item|
|quantity| INT | The number of units of the product ordered for the line item|
|price| DECIMAL(18, 2) | The price per unit of the product|
