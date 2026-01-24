-- Migration: 001_create_users_table.sql
-- Description: Create users table with Ethiopian phone-first authentication
-- Dependencies: Requires cities table to be created first

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins, staff)
-- Ethiopian Context: Phone-first auth, OTP verification, Amharic/English support
-- ============================================

CREATE TABLE IF NOT EXISTS `users` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Authentication & Contact
  `phone` VARCHAR(20) NOT NULL UNIQUE,
  `email` VARCHAR(100) UNIQUE,
  `password_hash` VARCHAR(255),
  `full_name` VARCHAR(100),
  
  -- User Role & Localization
  `role` ENUM('customer', 'organizer', 'admin', 'staff') DEFAULT 'customer',
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  
  -- Ethiopian Context
  `city_id` BIGINT UNSIGNED NULL,
  `phone_verified` BOOLEAN DEFAULT FALSE,
  `verification_code` VARCHAR(6),
  `verification_expiry` DATETIME,
  
  -- Security & Status
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_suspended` BOOLEAN DEFAULT FALSE,
  `failed_login_attempts` INT DEFAULT 0,
  `locked_until` DATETIME NULL,
  `last_login` DATETIME NULL,
  `device_id` VARCHAR(255),
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL,
  
  -- Indexes
  INDEX `idx_phone_verified` (`phone_verified`),
  INDEX `idx_role` (`role`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Core users table with Ethiopian phone-first authentication';

-- Insert default admin user (password will be hashed in seed)
INSERT IGNORE INTO `users` (
  `phone`,
  `email`,
  `password_hash`,
  `full_name`,
  `role`,
  `preferred_language`,
  `phone_verified`,
  `is_active`
) VALUES (
  '+251911223344',
  'admin@ethiotickets.com',
  NULL, -- Will be set in seed with bcrypt hash
  'System Administrator',
  'admin',
  'en',
  TRUE,
  TRUE
);

SET FOREIGN_KEY_CHECKS = 1;