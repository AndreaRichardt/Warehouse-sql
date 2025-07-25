-- ==========================================
-- Script: create_database_and_schemas.sql
-- Purpose: Initializes the DataWarehouse database and sets up Bronze, Silver, and Gold schemas
-- ==========================================

-- Switch to master to create a new database
USE master;
GO
-- Create the database
CREATE DATABASE DataWarehouse;

-- Switch to the new database
USE DataWarehouse;
GO
-- Create schemas
CREATE SCHEMA Bronze;    -- Raw layer
GO
CREATE SCHEMA Silver;    -- Cleaned data
GO
CREATE SCHEMA Gold;      -- Business-ready data
GO