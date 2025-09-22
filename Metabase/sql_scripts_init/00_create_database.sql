-- =====================================================
-- 01_create_tables.sql
-- Create simplified tables for Lucca ETL
-- =====================================================

-- Switch to simplified database (make sure it exists)
CREATE DATABASE IF NOT EXISTS lucca_simplified
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE lucca_simplified;
