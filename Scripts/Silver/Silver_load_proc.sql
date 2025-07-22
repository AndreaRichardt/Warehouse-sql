-- ========================================================================================================
-- Procedure Name: silver.load_silver
-- Script Purpose: Load cleaned and standardized data from Bronze layer into Silver layer
	-- Description:
	-- - This procedure truncates all target Silver tables and reloads them with data from the Bronze layer.
	-- - It applies data cleaning steps such as trimming whitespace, normalizing categorical values,
	--   handling duplicates by keeping the latest records, correcting invalid or inconsistent data,
	--   and setting valid date ranges.
	-- - Tables loaded include customers, products, sales details, customer demographic data, location info,
	--   and product categories.
	-- - Designed to ensure consistent, high-quality data in the Silver layer for downstream analytics and reporting.
-- ========================================================================================================

	CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Starting Silver Layer Load';
        PRINT '================================================';

        -- ================================================
        -- CRM Customer Info
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';
        -- ========================================================================================================
        -- Script Purpose: Clean and insert the latest customer record into the Silver layer from Bronze
        -- Cleans nulls, trims whitespace, standardizes values, and handles duplicates by keeping latest record
        -- ========================================================================================================
        INSERT INTO Silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gender,
            cst_create_date)
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,                     -- Remove leading/trailing whitespace
            TRIM(cst_lastname) AS cst_lastname,                       -- Remove leading/trailing whitespace
            CASE
                WHEN UPPER(cst_marital_status) = 'M' THEN 'Married'   -- Normalize values
                WHEN UPPER(cst_marital_status) = 'S' THEN 'Single'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(cst_gender) = 'M' THEN 'Male'              -- Normalize values
                WHEN UPPER(cst_gender) = 'F' THEN 'Female'
                ELSE 'n/a'
            END AS cst_gender,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS Rank                                             -- Handle duplicate IDs: keep latest record
            FROM Bronze.crm_cust_info
            WHERE cst_id IS NOT NULL                                  -- Exclude records with null customer ID
        ) s
        WHERE rank = 1;                                               -- Keep only most recent record per customer
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- ================================================
        -- CRM Product Info
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';
        -- ========================================================================================================
        -- Script Purpose: Clean and insert product records into the Silver layer from Bronze
        -- Cleans nulls, trims values, standardizes labels, and sets end date based on next product period
        -- ========================================================================================================
        INSERT INTO Silver.crm_prd_info (
            prd_id,
            prd_cat_id,
            prd_key,
            prd_name,
            prd_cost,
            prd_line,
            prd_start_date,
            prd_end_date)
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS prd_cat_id,        -- Extract category and replace '-' with '_'
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,                   -- Extract unique product key
            TRIM(prd_name) AS prd_name,                                       -- Remove leading/trailing whitespace
            ISNULL(prd_cost, 0) AS prd_cost,                                  -- Replace nulls with 0
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'                  -- Normalize product line
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other sales'
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            prd_start_date,
            DATEADD(DAY, -1, LEAD(prd_start_date) OVER (
                PARTITION BY prd_key
                ORDER BY prd_start_date
            )) AS prd_end_date                                                -- Set end date as day before next start date
        FROM Bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- ================================================
        -- CRM Sales Details
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        -- ========================================================================================================
        -- Script Purpose: Clean and insert sales details into the Silver layer from Bronze
        -- Cleans invalid or null dates, corrects inconsistent sales values, and ensures positive price values
        -- ========================================================================================================
        INSERT INTO Silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_date,
            sls_ship_date,
            sls_due_date,
            sls_sales, 
            sls_quantity,
            sls_price)
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            -- Clean and convert sls_order_date: set NULL if not in YYYYMMDD format or invalid
            CASE 
                WHEN sls_order_date IS NULL 
                     OR sls_order_date = 0 
                     OR LEN(CAST(sls_order_date AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_date AS VARCHAR) AS DATE)
            END AS sls_order_date,

            -- Clean and convert sls_ship_date: set NULL if not in YYYYMMDD format or invalid
            CASE 
                WHEN sls_ship_date IS NULL 
                     OR sls_ship_date = 0 
                     OR LEN(CAST(sls_ship_date AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
            END AS sls_ship_date,

            -- Clean and convert sls_due_date: set NULL if not in YYYYMMDD format or invalid
            CASE 
                WHEN sls_due_date IS NULL 
                     OR sls_due_date = 0 
                     OR LEN(CAST(sls_due_date AS VARCHAR)) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_date AS VARCHAR) AS DATE)
            END AS sls_due_date,

            -- Recalculate sls_sales if value is inconsistent, negative or null
            CASE 
                WHEN sls_sales != sls_quantity * ABS(sls_price) 
                     OR sls_sales <= 0 
                     OR sls_sales IS NULL THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales, 

            sls_quantity,

            -- Set price as sales/quantity if missing or invalid (<= 0), ensure positive price using ABS
            CASE
                WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / sls_quantity
                ELSE sls_price
            END AS sls_price

        FROM Bronze.crm_sales_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- ================================================
        -- ERP Customer AZ12
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        -- ========================================================================================================
        -- Script Purpose: Clean and insert customer records into the Silver layer from Bronze
        -- Cleans invalid ID length, removes future birthdates, and standardizes gender labels
        -- ========================================================================================================
        INSERT INTO Silver.erp_cust_az12 (
            id,
            birthdate,
            gender)
        SELECT
            -- Fix ID: if it has 10 characters, keep it. If it has more, take the last 10. Otherwise, leave it as is.
            CASE    
                WHEN LEN(id) = 10 THEN id    
                WHEN LEN(id) > 10 THEN SUBSTRING(id, LEN(id) - 9, 10)
                ELSE id
            END AS id,

            -- Remove future dates
            CASE    
                WHEN birthdate > GETDATE() THEN NULL
                ELSE birthdate
            END AS birthdate,

            -- Normalize gender
            CASE    
                WHEN UPPER(TRIM(gender)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(gender)) = 'F' THEN 'Female'
                WHEN gender IS NULL OR TRIM(gender) = '' THEN 'n/a'
                ELSE gender        
            END AS gender

        FROM Bronze.erp_cust_az12;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- ================================================
        -- ERP Location A101
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        -- ========================================================================================================
        -- Script Purpose: Clean and insert location data into the Silver layer from Bronze
        -- Removes dashes from ID and standardizes country values
        -- ========================================================================================================
        INSERT INTO Silver.erp_loc_a101 (
            id,
            country)
        SELECT
            -- Remove dashes from ID
            REPLACE(id, '-', '') AS id,

            -- Standardize country values
            CASE 
                WHEN TRIM(country) = 'DE' THEN 'Germany'
                WHEN TRIM(country) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(country) = '' OR country IS NULL THEN 'n/a'
                ELSE country
            END AS country
        FROM Bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- ================================================
        -- ERP Product Category G1V2
        -- ================================================
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        -- ========================================================================================================
        -- Script Purpose: Insert high-quality product category data into the Silver layer from Bronze
        -- Source data is already high quality; basic checks like TRIM and DISTINCT were performed
        -- ========================================================================================================
        INSERT INTO Silver.erp_px_cat_g1v2(
            id,
            category,
            subcategory,
            maintenance)
        SELECT 
            id,
            category,
            subcategory,
            maintenance
        FROM Bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Silver Load Completed Successfully';
        PRINT 'Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '>> An error occurred during the Silver Layer load.';
        PRINT ERROR_MESSAGE();
    END CATCH
END
