-- Converted from MySQL to SQLite
-- Original file: 002_create_cities_table.sql
-- Migration: 002_create_cities_table.sql
-- Description: Create Ethiopian cities table with regions, Amharic names, and coordinates
-- Collation: utf8mb4_0900_ai_ci for proper Amharic FULLTEXT search
-- Dependencies: None (first table to create)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: cities
-- ============================================

CREATE TABLE IF NOT EXISTS cities (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  
  -- Ethiopian regions (ENUM for data consistency)
  region TEXT NOT NULL,
  
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  
  latitude REAL,
  longitude REAL,
  elevation INTEGER,
  
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  
  population INTEGER,
  area_sq_km REAL,
  postal_code_prefix VARCHAR(10),
  phone_area_code VARCHAR(5),
  
  major_venues JSON DEFAULT NULL,
  popular_event_types JSON DEFAULT NULL,
  
  is_active INTEGER DEFAULT TRUE,
  is_major_city INTEGER DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  
  description TEXT,
  description_amharic TEXT,
  keywords VARCHAR(500),
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Indexes
  INDEX idx_name (name), -- INDEX converted separately (region), -- INDEX converted separately (is_active), -- INDEX converted separately (is_active, is_major_city), -- INDEX converted separately (sort_order), -- INDEX converted separately (deleted_at), -- INDEX converted separately (region, is_active), -- INDEX converted separately (name_amharic(50)),
  
  -- Unique constraINTEGER
  UNIQUE KEY uq_city_region (name, region),
  
  -- Full-text search (proper collation for Amharic)
  FULLTEXT KEY idx_city_search (name, name_amharic, region, description)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;