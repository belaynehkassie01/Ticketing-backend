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

-- Migration: 003_create_roles_table.sql
-- Description: Create roles table for RBAC (Role-Based Access Control)
-- Dependencies: None (can be created after cities)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `name_amharic` VARCHAR(50),
  `description` TEXT,
  `description_amharic` TEXT,
  
  `is_system_role` BOOLEAN DEFAULT FALSE,
  `is_default` BOOLEAN DEFAULT FALSE,
  
  `permissions` JSON DEFAULT NULL,
  
  `scope` ENUM('platform', 'organizer', 'event') DEFAULT 'platform',
  
  `parent_role_id` BIGINT UNSIGNED NULL,
  `level` INT DEFAULT 0,
  
  `is_active` BOOLEAN DEFAULT TRUE,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`parent_role_id`) REFERENCES `roles`(`id`)
    ON DELETE SET NULL,
  
  INDEX `idx_name` (`name`),
  INDEX `idx_is_system_role` (`is_system_role`),
  INDEX `idx_is_default` (`is_default`),
  INDEX `idx_scope` (`scope`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_level` (`level`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_scope_active` (`scope`, `is_active`),
  
  CONSTRAINT `chk_role_level` CHECK (`level` >= 0),
  
  UNIQUE KEY `uq_role_hierarchy` (`name`, `parent_role_id`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;


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


-- Migration: 006_create_qr_codes_table.sql
-- Description: Create QR codes table for tickets, payments, and Ethiopian TeleBirr
-- Dependencies: Requires users table (optional foreign keys)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  `qr_data` TEXT NOT NULL,
  `qr_hash` VARCHAR(64) UNIQUE NOT NULL,
  `qr_image_url` VARCHAR(500),
  `qr_image_path` VARCHAR(500),
  
  `entity_type` ENUM('ticket', 'event', 'organizer', 'user', 'payment', 'telebirr', 'promo') NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  
  `qr_format` ENUM('telebirr', 'ticket', 'promo', 'generic') DEFAULT 'ticket',
  `qr_version` VARCHAR(20) DEFAULT '1.0',
  `generated_in_country` VARCHAR(3) DEFAULT 'ET',
  `generated_by_user` BIGINT UNSIGNED NULL,
  
  `scan_count` INT UNSIGNED DEFAULT 0,
  `max_scans` INT UNSIGNED NULL,
  `last_scanned_at` DATETIME NULL,
  `last_scanned_by` BIGINT UNSIGNED NULL,
  `last_scanned_device_id` VARCHAR(255),
  `last_scanned_ip` VARCHAR(45),
  
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_valid` BOOLEAN DEFAULT TRUE,
  `expires_at` DATETIME NULL,
  `invalidated_at` DATETIME NULL,
  `invalidation_reason` ENUM('used', 'expired', 'compromised', 'replaced', 'cancelled') NULL,
  `invalidated_by` BIGINT UNSIGNED NULL,
  
  `ticket_data` JSON NULL,
  `payment_data` JSON NULL,
  `telebirr_data` JSON NULL,
  `promo_data` JSON NULL,
  
  `meta_data` JSON DEFAULT NULL,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_last_scanned_at` (`last_scanned_at`),
  INDEX `idx_qr_format` (`qr_format`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_generated_by_user` (`generated_by_user`),
  
  INDEX `idx_active_expires` (`is_active`, `expires_at`),
  INDEX `idx_entity_active` (`entity_type`, `entity_id`, `is_active`),
  INDEX `idx_format_active` (`qr_format`, `is_active`),
  INDEX `idx_entity_format` (`entity_type`, `qr_format`),
  
  -- Optional foreign keys (remove if users table not ready)
  FOREIGN KEY (`generated_by_user`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`last_scanned_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`invalidated_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  
  CONSTRAINT `chk_entity_id` CHECK (`entity_id` > 0),
  CONSTRAINT `chk_scan_count` CHECK (`scan_count` >= 0),
  CONSTRAINT `chk_max_scans` CHECK (`max_scans` IS NULL OR `max_scans` > 0),
  CONSTRAINT `chk_expiry` CHECK (`expires_at` IS NULL OR `expires_at` > `created_at`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;


-- Migration: 007_create_organizer_applications_table.sql
-- Description: Store organizer applications with all optimizations
-- Dependencies: Requires users and cities tables

CREATE TABLE IF NOT EXISTS `organizer_applications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  
  -- Business Information
  `business_name` VARCHAR(200) NOT NULL,
  `business_name_amharic` VARCHAR(200),
  `business_type` ENUM('individual', 'company', 'ngo', 'government', 'association') NOT NULL,
  `business_description` TEXT,
  `business_description_amharic` TEXT,
  
  -- Contact Information
  `contact_person` VARCHAR(100),
  `contact_person_amharic` VARCHAR(100),
  `contact_phone` VARCHAR(20) NOT NULL,
  `contact_email` VARCHAR(100),
  
  -- Ethiopian Legal Information
  `tin_number` VARCHAR(50) COMMENT 'Ethiopian TIN',
  `business_license_number` VARCHAR(100) COMMENT 'Business license number',
  `vat_registered` BOOLEAN DEFAULT FALSE,
  `vat_number` VARCHAR(50),
  
  -- Ethiopian Address
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
  `city_id` BIGINT UNSIGNED NULL,
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  `full_address` TEXT,
  
  -- Ethiopian Bank Details
  `bank_name` ENUM('cbe', 'awash', 'dashen', 'abyssinia', 'nib', 'cbe_birr', 'telebirr', 'other') NOT NULL,
  `bank_account_number` VARCHAR(100) NOT NULL,
  `bank_account_holder` VARCHAR(100) NOT NULL,
  `bank_branch` VARCHAR(100),
  `bank_branch_city` VARCHAR(100),
  
  -- Document Uploads (file paths)
  `id_document_front` VARCHAR(255),
  `id_document_back` VARCHAR(255),
  `business_license_document` VARCHAR(255),
  `tax_certificate_document` VARCHAR(255),
  `bank_letter_document` VARCHAR(255),
  
  -- Application Status
  `status` ENUM('pending', 'under_review', 'approved', 'rejected', 'needs_info') DEFAULT 'pending',
  `admin_notes` TEXT,
  `review_notes` TEXT,
  
  -- Processing Information
  `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewed_by` BIGINT UNSIGNED NULL,
  
  -- Business Projections
  `expected_monthly_events` INT,
  `primary_event_type` VARCHAR(100),
  `previous_experience` TEXT,
  
  -- Audit Tracking (Added per recommendation)
  `created_by` BIGINT UNSIGNED NULL COMMENT 'User who submitted (usually same as user_id)',
  `updated_by` BIGINT UNSIGNED NULL COMMENT 'User who last updated',
  
  -- Metadata
  `meta_data` JSON DEFAULT NULL,
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL,
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL,
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL,
  
  -- Indexes (Enhanced with composite indexes)
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_submitted_at` (`submitted_at`),
  INDEX `idx_reviewed_at` (`reviewed_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_business_name` (`business_name`(100)),
  INDEX `idx_tin_number` (`tin_number`),
  INDEX `idx_region` (`region`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_created_by` (`created_by`),
  INDEX `idx_updated_by` (`updated_by`),
  INDEX `idx_reviewed_by` (`reviewed_by`),
  
  -- Composite Indexes for Performance (Added per recommendation)
  INDEX `idx_user_status_deleted` (`user_id`, `status`, `deleted_at`),
  INDEX `idx_status_submitted` (`status`, `submitted_at`),
  INDEX `idx_region_status` (`region`, `status`),
  INDEX `idx_city_status` (`city_id`, `status`),
  INDEX `idx_user_created` (`user_id`, `created_at`),
  
  -- Constraints
  CONSTRAINT `chk_contact_phone` CHECK (
    `contact_phone` REGEXP '^(09[0-9]{8}|\\+2519[0-9]{8})$'
  ),
  CONSTRAINT `chk_expected_events` CHECK (
    `expected_monthly_events` IS NULL OR `expected_monthly_events` > 0
  ),
  CONSTRAINT `chk_tin_format` CHECK (
    `tin_number` IS NULL OR 
    `tin_number` REGEXP '^[0-9]{10,15}$'
  ),
  CONSTRAINT `chk_vat_number` CHECK (
    `vat_number` IS NULL OR 
    `vat_number` REGEXP '^[0-9]{10,15}$'
  )
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trigger to enforce one pending application per user (INSERT)
DELIMITER $$

CREATE TRIGGER `trg_one_pending_application_per_user_insert`
BEFORE INSERT ON `organizer_applications`
FOR EACH ROW
BEGIN
    DECLARE pending_count INT;
    
    -- Count existing pending/under_review/needs_info applications for this user
    SELECT COUNT(*) INTO pending_count
    FROM `organizer_applications`
    WHERE `user_id` = NEW.`user_id`
      AND `status` IN ('pending', 'under_review', 'needs_info')
      AND `deleted_at` IS NULL;
    
    IF pending_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already has a pending organizer application';
    END IF;
END$$

DELIMITER ;

-- Trigger to enforce one pending application per user (UPDATE)
DELIMITER $$

CREATE TRIGGER `trg_one_pending_application_per_user_update`
BEFORE UPDATE ON `organizer_applications`
FOR EACH ROW
BEGIN
    -- Only check if status is being changed to a pending state
    IF NEW.`status` IN ('pending', 'under_review', 'needs_info') 
       AND OLD.`status` NOT IN ('pending', 'under_review', 'needs_info')
       AND NEW.`deleted_at` IS NULL THEN
        
        DECLARE pending_count INT;
        
        -- Count existing pending applications for this user (excluding current record)
        SELECT COUNT(*) INTO pending_count
        FROM `organizer_applications`
        WHERE `user_id` = NEW.`user_id`
          AND `id` != NEW.`id`
          AND `status` IN ('pending', 'under_review', 'needs_info')
          AND `deleted_at` IS NULL;
        
        IF pending_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a pending organizer application';
        END IF;
    END IF;
END$$

DELIMITER ;

-- View for pending applications (Enhanced)
CREATE OR REPLACE VIEW `vw_pending_organizer_applications` AS
SELECT 
    oa.*,
    u.phone as user_phone,
    u.full_name as user_name,
    u.email as user_email,
    u.phone_verified as user_phone_verified,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    TIMESTAMPDIFF(HOUR, oa.submitted_at, NOW()) as hours_pending,
    TIMESTAMPDIFF(DAY, oa.submitted_at, NOW()) as days_pending,
    -- Document completion percentage
    CASE 
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL 
             AND oa.business_license_document IS NOT NULL 
             AND oa.tax_certificate_document IS NOT NULL 
             AND oa.bank_letter_document IS NOT NULL THEN 100
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL 
             AND oa.business_license_document IS NOT NULL THEN 75
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL THEN 50
        WHEN oa.id_document_front IS NOT NULL THEN 25
        ELSE 0
    END as document_completion_percentage
FROM `organizer_applications` oa
LEFT JOIN `users` u ON oa.user_id = u.id
LEFT JOIN `cities` c ON oa.city_id = c.id
WHERE oa.status IN ('pending', 'under_review', 'needs_info')
  AND oa.deleted_at IS NULL
ORDER BY oa.submitted_at ASC;

-- View for completed applications (for reporting)
CREATE OR REPLACE VIEW `vw_completed_organizer_applications` AS
SELECT 
    oa.*,
    u.phone as user_phone,
    u.full_name as user_name,
    c.name as city_name,
    ru.full_name as reviewer_name,
    CASE 
        WHEN oa.status = 'approved' THEN 'Approved'
        WHEN oa.status = 'rejected' THEN 'Rejected'
        ELSE 'Other'
    END as final_status,
    TIMESTAMPDIFF(HOUR, oa.submitted_at, oa.reviewed_at) as review_time_hours
FROM `organizer_applications` oa
LEFT JOIN `users` u ON oa.user_id = u.id
LEFT JOIN `cities` c ON oa.city_id = c.id
LEFT JOIN `users` ru ON oa.reviewed_by = ru.id
WHERE oa.status IN ('approved', 'rejected')
  AND oa.deleted_at IS NULL
ORDER BY oa.reviewed_at DESC;



-- Migration: 008_create_organizers_table.sql
-- Description: Create organizers table for approved business accounts
-- Dependencies: Requires users, cities, and organizer_applications tables

CREATE TABLE IF NOT EXISTS `organizers` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

  -- Link to user account
  `user_id` BIGINT UNSIGNED UNIQUE NOT NULL,

  -- Link to application (if migrated from application)
  `application_id` BIGINT UNSIGNED NULL,

  -- Business Information
  `business_name` VARCHAR(200) NOT NULL,
  `business_name_amharic` VARCHAR(200),
  `business_type` ENUM('individual', 'company', 'ngo', 'government', 'association', 'other') NOT NULL,
  `business_description` TEXT,
  `business_description_amharic` TEXT,

  -- Ethiopian Legal Information
  `tin_number` VARCHAR(50) UNIQUE NULL,
  `business_license_number` VARCHAR(100) UNIQUE NULL,
  `vat_registered` BOOLEAN DEFAULT FALSE,
  `vat_number` VARCHAR(50) DEFAULT NULL,

  -- Contact Information
  `contact_person` VARCHAR(100),
  `contact_person_amharic` VARCHAR(100),
  `business_phone` VARCHAR(20) NOT NULL,
  `secondary_phone` VARCHAR(20) DEFAULT NULL,
  `business_email` VARCHAR(100) DEFAULT NULL,
  `website` VARCHAR(255) DEFAULT NULL,

  -- Ethiopian Address
  `region` ENUM(
    'Addis Ababa', 'Oromia', 'Amhara', 'Tigray', 'Sidama',
    'SNNPR', 'Somali', 'Afar', 'Benishangul-Gumuz', 'Gambela',
    'Harari', 'Dire Dawa'
  ) NOT NULL,
  `city_id` BIGINT UNSIGNED NULL,
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  `kebele` VARCHAR(100),
  `house_number` VARCHAR(50),
  `landmark` TEXT,
  `full_address` TEXT,

  -- Geographic Coordinates
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `google_maps_url` VARCHAR(500),

  -- Ethiopian Bank Details
  `bank_name` ENUM('cbe','awash','dashen','abyssinia','nib','cbe_birr','telebirr','other') NOT NULL,
  `bank_account_number` VARCHAR(100) NOT NULL,
  `bank_account_holder` VARCHAR(100) NOT NULL,
  `bank_branch` VARCHAR(100),
  `bank_branch_city` VARCHAR(100),
  `bank_verification_status` ENUM('pending','verified','failed') DEFAULT 'pending',

  -- Verification & Status
  `status` ENUM('pending','under_review','approved','suspended','rejected') DEFAULT 'approved',
  `verification_level` ENUM('basic','verified','premium') DEFAULT 'basic',
  `verified_at` DATETIME NULL,
  `verified_by` BIGINT UNSIGNED NULL,
  `verification_notes` TEXT,

  -- Commission & Payments
  `commission_rate` DECIMAL(5,2) DEFAULT 10.00,
  `custom_commission_rate` DECIMAL(5,2) NULL,
  `payout_method` ENUM('cbe_transfer','telebirr','bank_transfer') DEFAULT 'cbe_transfer',
  `payout_threshold` DECIMAL(10,2) DEFAULT 5000.00,

  -- Financial Stats
  `total_events` INT UNSIGNED DEFAULT 0,
  `total_tickets_sold` INT UNSIGNED DEFAULT 0,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `available_balance` DECIMAL(15,2) DEFAULT 0.00,
  `pending_balance` DECIMAL(15,2) DEFAULT 0.00,
  `total_payouts` DECIMAL(15,2) DEFAULT 0.00,

  -- Ratings & Reviews
  `rating` DECIMAL(3,2) DEFAULT 0.00,
  `rating_count` INT UNSIGNED DEFAULT 0,
  `review_count` INT UNSIGNED DEFAULT 0,

  -- Team Management
  `team_size` INT DEFAULT 1,
  `team_members` JSON DEFAULT NULL,

  -- Settings & Preferences
  `notification_preferences` JSON DEFAULT (JSON_OBJECT(
    'sms', TRUE, 'email', TRUE, 'push', FALSE,
    'payout_notifications', TRUE, 'event_reminders', TRUE,
    'new_ticket_sales', TRUE
  )),
  `communication_language` ENUM('am','en','both') DEFAULT 'both',
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',

  -- Metadata
  `meta_data` JSON DEFAULT NULL,

  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,

  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`application_id`) REFERENCES `organizer_applications`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,

  -- Indexes
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_business_name` (`business_name`(100)),
  INDEX `idx_tin_number` (`tin_number`),
  INDEX `idx_business_license` (`business_license_number`),
  INDEX `idx_region` (`region`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_verified_at` (`verified_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_deleted_at` (`deleted_at`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
SET FOREIGN_KEY_CHECKS = 1;



-- ============================================
-- TABLE: organizer_documents
-- Purpose: Store organizer verification documents
-- Dependencies: Requires organizers and users tables
-- ============================================

CREATE TABLE IF NOT EXISTS `organizer_documents` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  
  `document_type` ENUM(
    'business_license', 
    'tin_certificate', 
    'id_card_front', 
    'id_card_back', 
    'tax_clearance', 
    'bank_letter', 
    'other'
  ) NOT NULL,
  
  `document_name` VARCHAR(200) NOT NULL,
  `file_url` VARCHAR(500) NOT NULL,
  `mime_type` VARCHAR(100),
  `file_size` INT UNSIGNED,
  
  -- Verification
  `is_verified` BOOLEAN DEFAULT FALSE,
  `verified_by` BIGINT UNSIGNED NULL,
  `verified_at` DATETIME NULL,
  `verification_notes` TEXT,
  
  -- Optional metadata
  `document_number` VARCHAR(100),
  `issued_by` VARCHAR(200),
  `issue_date` DATE NULL,
  `expiry_date` DATE NULL,
  
  -- Status
  `is_active` BOOLEAN DEFAULT TRUE,
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_document_type` (`document_type`),
  INDEX `idx_is_verified` (`is_verified`),
  INDEX `idx_expiry_date` (`expiry_date`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_created_at` (`created_at`),
  
  -- Constraints
  CONSTRAINT `chk_file_size` CHECK (`file_size` >= 0),
  CONSTRAINT `chk_expiry_date` CHECK (`expiry_date` IS NULL OR `expiry_date` > `issue_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Organizer verification documents with audit and status tracking';

SET FOREIGN_KEY_CHECKS = 1;