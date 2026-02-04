-- Migration: 043_create_ethiopian_holidays_table.sql
-- Purpose: Store Ethiopian holiday calendar

CREATE TABLE IF NOT EXISTS `ethiopian_holidays` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `name_amharic` VARCHAR(200),
  `description` TEXT,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `holiday_type` ENUM('religious', 'national', 'regional', 'international') DEFAULT 'national',
  `is_active` BOOLEAN DEFAULT TRUE,
  `year` YEAR,
  `recurring` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_dates` (`start_date`, `end_date`),
  INDEX `idx_year` (`year`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_holiday_type` (`holiday_type`),
  INDEX `idx_recurring` (`recurring`),
  UNIQUE INDEX `uq_holiday_year` (`name`, `year`),
  
  CONSTRAINT `chk_holiday_dates` CHECK (`end_date` >= `start_date`),
  CONSTRAINT `chk_year_range` CHECK (`year` BETWEEN 1900 AND 2100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;