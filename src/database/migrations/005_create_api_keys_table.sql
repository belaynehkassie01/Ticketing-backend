-- Migration: 005_create_api_keys_table.sql
-- Description: Create API keys table with ALL improvements applied
-- Dependencies: Requires users AND organizers tables (organizer_id FK)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  `api_key` VARCHAR(64) UNIQUE NOT NULL,
  `api_secret_hash` VARCHAR(255) NOT NULL,
  `api_secret_salt` VARCHAR(64),
  
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `description_amharic` TEXT,
  
  `user_id` BIGINT UNSIGNED NULL,
  `organizer_id` BIGINT UNSIGNED NULL,
  `admin_id` BIGINT UNSIGNED NULL,
  
  `permissions` JSON NOT NULL DEFAULT (JSON_OBJECT()),
  `scope` ENUM('read', 'write', 'admin', 'custom') DEFAULT 'read',
  `allowed_endpoints` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  `denied_endpoints` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  
  `rate_limit_per_minute` INT DEFAULT 60,
  `rate_limit_per_hour` INT DEFAULT 1000,
  `rate_limit_per_day` INT DEFAULT 10000,
  `rate_limit_window` ENUM('minute', 'hour', 'day', 'none') DEFAULT 'minute',
  
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_revoked` BOOLEAN DEFAULT FALSE,
  `revoked_at` DATETIME NULL,
  `revoked_reason` ENUM('compromised', 'expired', 'manual', 'suspicious', 'inactive') NULL,
  `last_used_at` DATETIME NULL,
  `last_used_ip` VARCHAR(45),
  `last_used_endpoint` VARCHAR(255),
  
  `usage_count` BIGINT UNSIGNED DEFAULT 0,
  `failed_attempts` INT DEFAULT 0,
  `locked_until` DATETIME NULL,
  
  `ip_whitelist` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  `ip_blacklist` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  `allowed_countries` JSON NOT NULL DEFAULT (JSON_ARRAY('ET')),
  `blocked_countries` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  
  `expires_at` DATETIME NULL,
  `rotated_at` DATETIME NULL,
  `previous_api_key` VARCHAR(64) NULL,
  
  `allowed_for_country` VARCHAR(3) DEFAULT 'ET',
  `allowed_ips_ethiopia_only` BOOLEAN DEFAULT TRUE,
  `allowed_telecom_operators` JSON NOT NULL DEFAULT (JSON_ARRAY('ethio_telecom')),
  
  `webhook_url` VARCHAR(500) NULL,
  `webhook_secret` VARCHAR(255) NULL,
  `webhook_enabled` BOOLEAN DEFAULT FALSE,
  
  `created_by` BIGINT UNSIGNED NULL,
  `updated_by` BIGINT UNSIGNED NULL,
  
  `meta_data` JSON DEFAULT NULL,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_scope` (`scope`),
  INDEX `idx_last_used_at` (`last_used_at`),
  INDEX `idx_revoked_at` (`revoked_at`),
  INDEX `idx_created_by` (`created_by`),
  INDEX `idx_updated_by` (`updated_by`),
  
  INDEX `idx_active_expires` (`is_active`, `expires_at`),
  INDEX `idx_user_active` (`user_id`, `is_active`),
  INDEX `idx_organizer_active` (`organizer_id`, `is_active`),
  INDEX `idx_api_key_active` (`api_key`, `is_active`),
  INDEX `idx_active_revoked` (`is_active`, `revoked_at`),
  INDEX `idx_scope_active` (`scope`, `is_active`),
  INDEX `idx_owner_active` (`user_id`, `organizer_id`, `admin_id`, `is_active`),
  
  UNIQUE KEY `uq_user_api_key` (`user_id`, `api_key`),
  UNIQUE KEY `uq_organizer_api_key` (`organizer_id`, `api_key`),
  UNIQUE KEY `uq_admin_api_key` (`admin_id`, `api_key`),
  
  CONSTRAINT `chk_rate_limit_minute` CHECK (`rate_limit_per_minute` >= 0),
  CONSTRAINT `chk_rate_limit_hour` CHECK (`rate_limit_per_hour` >= 0),
  CONSTRAINT `chk_rate_limit_day` CHECK (`rate_limit_per_day` >= 0),
  CONSTRAINT `chk_usage_count` CHECK (`usage_count` >= 0),
  CONSTRAINT `chk_failed_attempts` CHECK (`failed_attempts` >= 0),
  CONSTRAINT `chk_api_key_length` CHECK (CHAR_LENGTH(`api_key`) BETWEEN 32 AND 64),
  CONSTRAINT `chk_at_least_one_owner` CHECK (
    (`user_id` IS NOT NULL) OR
    (`organizer_id` IS NOT NULL) OR
    (`admin_id` IS NOT NULL)
  ),
  CONSTRAINT `chk_webhook_config` CHECK (
    (`webhook_url` IS NULL AND `webhook_secret` IS NULL AND `webhook_enabled` = FALSE) OR
    (`webhook_url` IS NOT NULL AND `webhook_secret` IS NOT NULL AND `webhook_enabled` = TRUE)
  )
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;