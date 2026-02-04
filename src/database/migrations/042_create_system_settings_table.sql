-- Migration: 042_create_system_settings_table.sql
-- Purpose: Store system configuration settings

CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `category` VARCHAR(100) NOT NULL,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL,
  `setting_value` TEXT,
  `setting_type` ENUM('string', 'number', 'boolean', 'json', 'array') DEFAULT 'string',
  `label` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `is_public` BOOLEAN DEFAULT FALSE,
  `is_editable` BOOLEAN DEFAULT TRUE,
  `applies_to_country` VARCHAR(3) DEFAULT 'ET',
  `regional_variations` JSON COMMENT 'Different values for different regions',
  `validation_rules` JSON COMMENT 'Validation rules for this setting',
  `options` JSON COMMENT 'Available options for this setting',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` BIGINT UNSIGNED NULL,
  
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  INDEX `idx_category` (`category`),
  INDEX `idx_setting_key` (`setting_key`),
  INDEX `idx_is_public` (`is_public`),
  INDEX `idx_is_editable` (`is_editable`),
  INDEX `idx_applies_to_country` (`applies_to_country`),
  INDEX `idx_updated_by` (`updated_by`),
  
  CONSTRAINT `chk_setting_key_format` CHECK (`setting_key` REGEXP '^[a-z][a-z0-9_]*$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;