/***********************************************************************************************
Script Name   : gold_layer_views.sql  
Purpose       : Create core views for the Gold Layer in a dimensional data model.
                These views serve as clean, business-ready tables for analytics and reporting.

------------------------------------------------------------------------------------------------
This script includes:
1. View: gold.dim_customer   – Cleans and enriches customer data  
2. View: gold.dim_products   – Combines product info and product category  
3. View: gold.dim_sales      – Sales fact view combining customer and product dimensions  
***********************************************************************************************/



-- 1. Customer Dimension View
------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS gold.dim_customer;
GO

CREATE VIEW gold.dim_customer AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_create_date) AS customer_key,     -- surrogate key
    ci.cst_id AS customer_id,                                            -- business id
    ci.cst_key AS customer_number,                                       -- alternate key
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.country AS country,
    -- Gender cleaning: fallback to ERP data if CRM data is missing
    CASE 
        WHEN ci.cst_gender = 'n/a' OR ci.cst_gender IS NULL 
            THEN COALESCE(ca.gender, 'n/a')
        ELSE ci.cst_gender
    END AS gender,
    ci.cst_marital_status AS marital_status,
    ca.birthdate AS birthdate,
    ci.cst_create_date AS create_date
FROM   Silver.crm_cust_info AS ci
LEFT JOIN Silver.erp_cust_az12 AS ca ON ci.cst_key = ca.id
LEFT JOIN Silver.erp_loc_a101 AS la ON ci.cst_key = la.id;



-- 2. Product Dimension View
------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pi.prd_start_date) AS product_key,       -- surrogate key
    pi.prd_id AS product_id,                                             -- business id
    pi.prd_key AS product_number,                                        -- alternate key
    pi.prd_name AS product_name,
    pi.prd_cat_id AS category_id,
    pc.category AS category,
    pc.subcategory AS subcategory,
    pi.prd_line AS product_line,
    pc.maintenance AS maintenance,
    pi.prd_cost AS cost,
    CAST(pi.prd_start_date AS DATE) AS start_date
FROM   Silver.crm_prd_info AS pi
LEFT JOIN Silver.erp_px_cat_g1v2 AS pc ON pi.prd_cat_id = pc.id
WHERE  pi.prd_end_date IS NULL; -- Only active products



-- 3. Sales Fact View
------------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS gold.dim_sales;
GO

CREATE VIEW gold.dim_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    gp.product_key AS product_key,
    gc.customer_key AS customer_key,
    sd.sls_order_date AS order_date,
    sd.sls_ship_date AS ship_date,
    sd.sls_due_date AS due_date,
    sd.sls_sales AS sales,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM   Silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS gp ON sd.sls_prd_key = gp.product_number
LEFT JOIN gold.dim_customer AS gc ON sd.sls_cust_id = gc.customer_id;