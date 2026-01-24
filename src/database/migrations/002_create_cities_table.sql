-- Migration: 002_create_cities_table.sql
-- Description: Create Ethiopian cities table with regions, Amharic names, and coordinates
-- Collation: utf8mb4_0900_ai_ci for proper Amharic FULLTEXT search
-- Dependencies: None (first table to create)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: cities
-- ============================================

CREATE TABLE IF NOT EXISTS `cities` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  
  -- Ethiopian regions (ENUM for data consistency)
  `region` ENUM(
    'Addis Ababa',
    'Oromia',
    'Amhara',
    'Tigray',
    'Sidama',
    'SNNPR',
    'Somali',
    'Afar',
    'Benishangul-Gumuz',
    'Gambela',
    'Harari',
    'Dire Dawa'
  ) NOT NULL,
  
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `elevation` INT,
  
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  
  `population` INT,
  `area_sq_km` DECIMAL(10, 2),
  `postal_code_prefix` VARCHAR(10),
  `phone_area_code` VARCHAR(5),
  
  `major_venues` JSON DEFAULT NULL,
  `popular_event_types` JSON DEFAULT NULL,
  
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_major_city` BOOLEAN DEFAULT FALSE,
  `sort_order` INT DEFAULT 0,
  
  `description` TEXT,
  `description_amharic` TEXT,
  `keywords` VARCHAR(500),
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Indexes
  INDEX `idx_name` (`name`),
  INDEX `idx_region` (`region`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_active_major_city` (`is_active`, `is_major_city`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_region_active` (`region`, `is_active`),
  INDEX `idx_name_amharic` (`name_amharic`(50)),
  
  -- Unique constraint
  UNIQUE KEY `uq_city_region` (`name`, `region`),
  
  -- Full-text search (proper collation for Amharic)
  FULLTEXT KEY `idx_city_search` (`name`, `name_amharic`, `region`, `description`)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;