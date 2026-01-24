-- Migration: 004_create_session_tokens_table.sql
-- Description: Create session tokens table for JWT-based authentication
-- Dependencies: Requires users and cities tables

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `session_tokens` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  
  `token` VARCHAR(512) UNIQUE NOT NULL,
  `refresh_token` VARCHAR(255) UNIQUE NOT NULL,
  `token_type` ENUM('access', 'refresh', 'device') DEFAULT 'access',
  
  `device_id` VARCHAR(255) NOT NULL,
  `device_name` VARCHAR(100),
  `device_type` ENUM('mobile', 'tablet', 'desktop', 'unknown') DEFAULT 'mobile',
  `os` VARCHAR(50),
  `os_version` VARCHAR(20),
  `browser` VARCHAR(50),
  `browser_version` VARCHAR(20),
  `app_version` VARCHAR(20),
  
  `ip_address` VARCHAR(45),
  `city_id` BIGINT UNSIGNED NULL,
  `country_code` VARCHAR(3) DEFAULT 'ET',
  `latitude` DECIMAL(10, 8),
  `longitude` DECIMAL(11, 8),
  `network_type` ENUM('wifi', 'cellular_2g', 'cellular_3g', 'cellular_4g', 'cellular_5g', 'unknown') DEFAULT 'unknown',
  
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_blacklisted` BOOLEAN DEFAULT FALSE,
  `blacklist_reason` ENUM('logout', 'password_change', 'suspicious_activity', 'admin_revoke', 'device_change') NULL,
  
  `expires_at` DATETIME NOT NULL,
  `refresh_expires_at` DATETIME NOT NULL,
  
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `login_method` ENUM('password', 'otp', 'biometric', 'social') DEFAULT 'password',
  
  `user_agent` TEXT,
  `meta_data` JSON DEFAULT NULL,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` DATETIME NULL,
  `revoked_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL,
  
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_token` (`token`(100)),
  INDEX `idx_refresh_token` (`refresh_token`(100)),
  INDEX `idx_device_id` (`device_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_refresh_expires_at` (`refresh_expires_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_country_code` (`country_code`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_user_active` (`user_id`, `is_active`),
  INDEX `idx_active_expires` (`is_active`, `expires_at`),
  INDEX `idx_user_device` (`user_id`, `device_id`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;