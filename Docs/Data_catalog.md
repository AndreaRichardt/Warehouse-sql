# Gold Layer Data Catalog

## 1. Overview

The Gold Layer contains polished, clean, and easily accessible data that supports our business reports and analyses. It is designed to provide reliable, integrated information about customers, products, and sales, organized to make querying fast and intuitive.

This layer serves as the main source for anyone who needs accurate data insights to make informed choices, helping teams understand what is happening in the business clearly.

---

## 2. Purpose of Each Table

| Table Name          | Purpose                                                                                                  |
|---------------------|----------------------------------------------------------------------------------------------------------|
| **Gold.dim_customer** | Holds detailed customer information, including demographics and location, to support customer analysis.  |
| **Gold.dim_products** | Contains product master data like categories, cost, and product lines for product-related reporting.      |
| **Gold.dim_sales**    | Records individual sales transactions linking customers, products, and key dates for performance tracking.|

---

## 3. Table Catalogs

### 3.1 Gold.dim_customer

| Column Name      | Data Type    | Description                                                                                           |
|------------------|--------------|-----------------------------------------------------------------------------------------------------|
| customer_key     | bigint       | Surrogate key uniquely identifying each customer (e.g., 100123).                                     |
| customer_id      | int          | Original customer ID from the source system (e.g., 78945).                                           |
| customer_number  | nvarchar(50) | Customer account number, may contain letters or digits (e.g., "CUST-2023-001").                       |
| first_name       | nvarchar(50) | Customer’s first name (e.g., "John").                                                                |
| last_name        | nvarchar(50) | Customer’s last name (e.g., "Doe").                                                                  |
| country          | nvarchar(50) | Customer’s country of residence or registration (e.g., "United States").                             |
| gender           | nvarchar(50) | Customer’s gender (e.g., "Male").                                                                     |
| marital_status   | nvarchar(50) | Marital status (e.g., "Single").                                                                      |
| birthdate        | date         | Customer’s date of birth (nullable, e.g., 1985-07-12).                                               |
| create_date      | date         | Date when the customer record was created (nullable, e.g., 2023-01-15).                              |

---

### 3.2 Gold.dim_products

| Column Name      | Data Type    | Description                                                                                           |
|------------------|--------------|-----------------------------------------------------------------------------------------------------|
| product_key      | bigint       | Surrogate key uniquely identifying each product (e.g., 200345).                                      |
| product_id       | int          | Original product ID from source system (e.g., 56789).                                               |
| product_number   | nvarchar(50) | Product SKU or code (e.g., "PROD-001-XYZ").                                                         |
| product_name     | nvarchar(50) | Official product name (e.g., "Wireless Mouse").                                                     |
| category_id      | nvarchar(50) | Product category identifier (e.g., "CAT-100").                                                     |
| category         | nvarchar(50) | Product category name (e.g., "Electronics").                                                        |
| subcategory      | nvarchar(50) | More specific grouping within the category (e.g., "Computer Accessories").                          |
| product_line     | nvarchar(50) | Product line or family name (e.g., "Mouse Series X").                                              |
| maintenance      | nvarchar(50) | Maintenance or warranty plan info (nullable, e.g., "Annual Warranty").                             |
| cost             | int          | Cost to produce or acquire the product (monetary units, e.g., 25).                                 |
| start_date       | date         | Date when the product became active or available (nullable, e.g., 2020-03-01).                     |

---

### 3.3 Gold.dim_sales

| Column Name      | Data Type    | Description                                                                                           |
|------------------|--------------|-----------------------------------------------------------------------------------------------------|
| order_number     | nvarchar(50) | Unique order number (may contain letters, nullable, e.g., "ORD-20230723-001").                        |
| product_key      | bigint       | Foreign key referencing product (nullable, e.g., 200345).                                           |
| customer_key     | bigint       | Foreign key referencing customer (nullable, e.g., 100123).                                          |
| order_date       | date         | Date the order was placed (nullable, e.g., 2023-07-20).                                            |
| ship_date        | date         | Date the order was shipped (nullable if not shipped, e.g., 2023-07-22).                            |
| due_date         | date         | Delivery due date (nullable, e.g., 2023-07-25).                                                    |
| sales            | int          | Total sales amount for the order (monetary units, e.g., 150).                                      |
| quantity         | int          | Number of units sold in this order (e.g., 3).                                                      |
| price            | int          | Unit price at time of sale (monetary units, e.g., 50).                                             |

---
