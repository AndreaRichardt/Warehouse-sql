/* 
===============================================================================
    DDL Script: Bronze Layer Table Creation 
    Purpose:    This script creates the raw ingestion layer (Bronze) 
                to store source CRM and ERP data in structured SQL tables.
===============================================================================
*/

-- Drop and Create CRM Customer Info Table
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gender           NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and Create CRM Product Info Table
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id           INT,
    prd_cat_id       NVARCHAR(50),
    prd_key          NVARCHAR(50),
    prd_name         NVARCHAR(50),
    prd_cost         INT,
    prd_line         NVARCHAR(50),
    prd_start_date   DATETIME,
    prd_end_date     DATETIME,
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and Create CRM Sales Details Table
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num      NVARCHAR(50),
    sls_prd_key      NVARCHAR(50),
    sls_cust_id      INT,
    sls_order_date   DATE,
    sls_ship_date    DATE,
    sls_due_date     DATE,
    sls_sales        INT,
    sls_quantity     INT,
    sls_price        INT,
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and Create ERP Location A101 Table
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    id               NVARCHAR(50),
    country          NVARCHAR(50),
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and Create ERP Customer AZ12 Table
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    id              NVARCHAR(50),
    birthdate       DATE,
    gender           NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Drop and Create ERP Product Category G1V2 Table
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id               NVARCHAR(50),
    category         NVARCHAR(50),
    subcategory      NVARCHAR(50),
    maintenance      NVARCHAR(50),
    dwh_create_date  DATETIME2 DEFAULT GETDATE()
);
GO
