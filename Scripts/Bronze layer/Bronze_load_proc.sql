/*
===============================================================================
    DDL Script:  Bronze_data_load.sql
    Purpose:     DDL and data loading script for Bronze layer
                  - Truncates and loads raw source data from CSV files
                  - Uses BULK INSERT from local file paths
===============================================================================
*/

-- Load CRM customer info
TRUNCATE TABLE bronze.crm_cust_info;
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\Usuario\Documents\datasets\source_crm\cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load CRM product info
TRUNCATE TABLE bronze.crm_prd_info;
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\Usuario\Documents\datasets\source_crm\prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load CRM sales details
TRUNCATE TABLE bronze.crm_sales_details;
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\Usuario\Documents\datasets\source_crm\sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load ERP location data
TRUNCATE TABLE bronze.erp_loc_a101;
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\Usuario\Documents\datasets\source_erp\loc_a101.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load ERP customer info
TRUNCATE TABLE bronze.erp_cust_az12;
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\Usuario\Documents\datasets\source_erp\cust_az12.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);

-- Load ERP pricing category
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\Usuario\Documents\datasets\source_erp\px_cat_g1v2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    TABLOCK
);
