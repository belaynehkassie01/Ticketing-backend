001_create_users_table.sql
sql
-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins)
-- ============================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `phone` VARCHAR(20) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE,
  `password_hash` VARCHAR(255),
  `full_name` VARCHAR(100),
  `role` ENUM('customer', 'organizer', 'admin', 'staff') DEFAULT 'customer',
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `city_id` BIGINT UNSIGNED NULL,
  `phone_verified` BOOLEAN DEFAULT FALSE,
  `verification_code` VARCHAR(6),
  `verification_expiry` DATETIME,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_suspended` BOOLEAN DEFAULT FALSE,
  `failed_login_attempts` INT DEFAULT 0,
  `locked_until` DATETIME NULL,
  `last_login` DATETIME NULL,
  `device_id` VARCHAR(255),
  `organizer_status` ENUM('none', 'pending', 'approved', 'rejected') DEFAULT 'none',
  `organizer_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_phone` (`phone`),
  INDEX `idx_role` (`role`),
  INDEX `idx_phone_verified` (`phone_verified`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_organizer_status` (`organizer_status`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_failed_attempts` CHECK (`failed_login_attempts` >= 0),
  CONSTRAINT `chk_phone_format` CHECK (`phone` REGEXP '^[0-9+][0-9]{5,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
002_create_cities_table.sql
sql
-- ============================================
-- TABLE: cities
-- Purpose: Store Ethiopian cities and regions
-- ============================================
CREATE TABLE IF NOT EXISTS `cities` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name_en` VARCHAR(100) NOT NULL,
  `name_am` VARCHAR(100) NOT NULL,
  `region` ENUM(
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Dire Dawa',
    'Gambela',
    'Harari',
    'Oromia',
    'Sidama',
    'Somali',
    'South West Ethiopia Peoples',
    'Southern Nations, Nationalities, and Peoples',
    'Tigray'
  ) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_region` (`region`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_name_en` (`name_en`),
  INDEX `idx_name_am` (`name_am`),
  UNIQUE INDEX `uq_city_region` (`name_en`, `region`),
  
  CONSTRAINT `chk_city_names` CHECK (`name_en` != '' AND `name_am` != '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
003_create_roles_table.sql
sql
-- ============================================
-- TABLE: roles
-- Purpose: Store system roles and permissions (from your original users.role enum)
-- ============================================
CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `description` VARCHAR(255),
  `permissions` JSON COMMENT 'JSON array of permission strings',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_system` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_is_system` (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
004_create_session_tokens_table.sql
sql
-- ============================================
-- TABLE: session_tokens
-- Purpose: Store user session tokens
-- ============================================
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
  `browser` VARCHAR(50),
  `ip_address` VARCHAR(45),
  `city_id` BIGINT UNSIGNED NULL,
  `country_code` VARCHAR(3) DEFAULT 'ET',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_blacklisted` BOOLEAN DEFAULT FALSE,
  `expires_at` DATETIME NOT NULL,
  `refresh_expires_at` DATETIME NOT NULL,
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` DATETIME NULL,
  `revoked_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_token` (`token`(100)),
  INDEX `idx_refresh_token` (`refresh_token`),
  INDEX `idx_device` (`device_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_refresh_expires_at` (`refresh_expires_at`),
  INDEX `idx_city_id` (`city_id`),
  
  CONSTRAINT `chk_expiry_dates` CHECK (`refresh_expires_at` > `expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
005_create_api_keys_table.sql
sql
-- ============================================
-- TABLE: api_keys
-- Purpose: Store API keys for system access
-- ============================================
CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `api_key` VARCHAR(255) UNIQUE NOT NULL,
  `api_secret` VARCHAR(255) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `user_id` BIGINT UNSIGNED NULL,
  `organizer_id` BIGINT UNSIGNED NULL,
  `permissions` JSON COMMENT 'JSON object with endpoint permissions',
  `is_active` BOOLEAN DEFAULT TRUE,
  `rate_limit_per_minute` INT DEFAULT 60,
  `last_used_at` DATETIME NULL,
  `usage_count` BIGINT UNSIGNED DEFAULT 0,
  `ip_whitelist` JSON COMMENT 'Array of allowed IP addresses',
  `expires_at` DATETIME NULL,
  `allowed_for_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_api_key` (`api_key`(100)),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_rate_limit` CHECK (`rate_limit_per_minute` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
006_create_qr_codes_table.sql
sql
-- ============================================
-- TABLE: qr_codes
-- Purpose: Store QR code data for tickets and payments
-- ============================================
CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `qr_data` TEXT NOT NULL,
  `qr_hash` VARCHAR(64) UNIQUE NOT NULL,
  `qr_image_url` VARCHAR(500),
  `entity_type` ENUM('ticket', 'event', 'organizer', 'user', 'payment') NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `scan_count` INT UNSIGNED DEFAULT 0,
  `last_scanned_at` DATETIME NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `expires_at` DATETIME NULL,
  `generated_in_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_last_scanned_at` (`last_scanned_at`),
  
  CONSTRAINT `chk_entity_id` CHECK (`entity_id` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
007_create_organizer_applications_table.sql
sql
-- ============================================
-- TABLE: organizer_applications
-- Purpose: Store organizer applications and verification
-- ============================================
CREATE TABLE IF NOT EXISTS `organizer_applications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `business_name` VARCHAR(200) NOT NULL,
  `business_type` ENUM('individual', 'company', 'ngo', 'government', 'association') NOT NULL,
  `business_description` TEXT,
  `contact_person` VARCHAR(100),
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(100),
  `id_document_front` VARCHAR(255),
  `id_document_back` VARCHAR(255),
  `business_license_doc` VARCHAR(255),
  `tax_certificate` VARCHAR(255),
  `bank_name` VARCHAR(100),
  `bank_account` VARCHAR(100),
  `account_holder_name` VARCHAR(100),
  `status` ENUM('pending', 'under_review', 'approved', 'rejected', 'needs_info') DEFAULT 'pending',
  `admin_notes` TEXT,
  `submitted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewed_by` BIGINT UNSIGNED NULL,
  `review_notes` TEXT,
  `expected_monthly_events` INT,
  `primary_event_type` VARCHAR(100),
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_status` (`status`),
  INDEX `idx_submitted_at` (`submitted_at`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_reviewed_by` (`reviewed_by`),
  INDEX `idx_reviewed_at` (`reviewed_at`),
  
  CONSTRAINT `chk_expected_events` CHECK (`expected_monthly_events` IS NULL OR `expected_monthly_events` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
008_create_organizers_table.sql
sql
-- ============================================
-- TABLE: organizers
-- Purpose: Store event organizer information
-- ============================================
CREATE TABLE IF NOT EXISTS `organizers` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED UNIQUE NOT NULL,
  `business_name` VARCHAR(200) NOT NULL,
  `business_name_amharic` VARCHAR(200),
  `business_type` ENUM('individual', 'company', 'ngo', 'government', 'association') NOT NULL,
  `tax_id` VARCHAR(50),
  `business_license` VARCHAR(100),
  `vat_registered` BOOLEAN DEFAULT FALSE,
  `vat_number` VARCHAR(50),
  `business_phone` VARCHAR(20),
  `business_email` VARCHAR(100),
  `website` VARCHAR(255),
  `region` VARCHAR(100),
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  `house_number` VARCHAR(50),
  `bank_name` ENUM('cbe', 'awash', 'dashen', 'abyssinia', 'nib', 'other'),
  `bank_account` VARCHAR(100),
  `account_holder_name` VARCHAR(100),
  `bank_branch` VARCHAR(100),
  `status` ENUM('pending', 'approved', 'suspended', 'rejected', 'under_review') DEFAULT 'pending',
  `verification_level` ENUM('basic', 'verified', 'premium') DEFAULT 'basic',
  `verified_at` DATETIME NULL,
  `verified_by` BIGINT UNSIGNED NULL,
  `commission_rate` DECIMAL(5,2) DEFAULT 10.00,
  `custom_commission_rate` DECIMAL(5,2) NULL,
  `total_events` INT UNSIGNED DEFAULT 0,
  `total_tickets_sold` INT UNSIGNED DEFAULT 0,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `rating` DECIMAL(3,2) DEFAULT 0.00,
  `rating_count` INT UNSIGNED DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_status` (`status`),
  INDEX `idx_business_name` (`business_name`),
  INDEX `idx_verified_at` (`verified_at`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_commission_rate` CHECK (`commission_rate` BETWEEN 0 AND 100),
  CONSTRAINT `chk_custom_commission` CHECK (`custom_commission_rate` IS NULL OR `custom_commission_rate` BETWEEN 0 AND 100),
  CONSTRAINT `chk_rating` CHECK (`rating` BETWEEN 0 AND 5),
  CONSTRAINT `chk_revenue` CHECK (`total_revenue` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
009_create_organizer_documents_table.sql
sql
-- ============================================
-- TABLE: organizer_documents
-- Purpose: Store organizer verification documents
-- ============================================
CREATE TABLE IF NOT EXISTS `organizer_documents` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `document_type` ENUM('business_license', 'tin_certificate', 'id_card_front', 'id_card_back', 'tax_clearance', 'bank_letter', 'other') NOT NULL,
  `document_name` VARCHAR(200) NOT NULL,
  `file_url` VARCHAR(500) NOT NULL,
  `mime_type` VARCHAR(100),
  `file_size` INT UNSIGNED,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `verified_by` BIGINT UNSIGNED NULL,
  `verified_at` DATETIME NULL,
  `verification_notes` TEXT,
  `document_number` VARCHAR(100),
  `issued_by` VARCHAR(200),
  `issue_date` DATE NULL,
  `expiry_date` DATE NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_document_type` (`document_type`),
  INDEX `idx_is_verified` (`is_verified`),
  INDEX `idx_expiry_date` (`expiry_date`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_is_active` (`is_active`),
  
  CONSTRAINT `chk_file_size` CHECK (`file_size` >= 0),
  CONSTRAINT `chk_expiry_date` CHECK (`expiry_date` IS NULL OR `expiry_date` > `issue_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
010_create_admin_actions_table.sql
sql
-- ============================================
-- TABLE: admin_actions
-- Purpose: Store administrative action logs
-- ============================================
CREATE TABLE IF NOT EXISTS `admin_actions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `admin_id` BIGINT UNSIGNED NOT NULL,
  `action_type` ENUM('payment_verification', 'payout_processing', 'organizer_approval', 'event_moderation', 'user_management', 'dispute_resolution', 'system_config', 'data_export', 'other') NOT NULL,
  `action_details` TEXT NOT NULL,
  `target_type` VARCHAR(50),
  `target_id` BIGINT UNSIGNED,
  `changes_made` JSON COMMENT 'JSON object of old vs new values',
  `requires_approval` BOOLEAN DEFAULT FALSE,
  `approved_by` BIGINT UNSIGNED NULL,
  `approved_at` DATETIME NULL,
  `approval_notes` TEXT,
  `performed_at_local` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_admin` (`admin_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_target` (`target_type`, `target_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_requires_approval` (`requires_approval`, `approved_at`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_performed_at` (`performed_at_local`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
011_create_payout_requests_table.sql
sql
-- ============================================
-- TABLE: payout_requests
-- Purpose: Store organizer payout requests
-- ============================================
CREATE TABLE IF NOT EXISTS `payout_requests` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `requested_amount` DECIMAL(10,2) NOT NULL,
  `available_balance` DECIMAL(10,2) NOT NULL,
  `bank_name` VARCHAR(100),
  `bank_account` VARCHAR(100),
  `account_holder_name` VARCHAR(100),
  `status` ENUM('pending', 'approved', 'rejected', 'processing') DEFAULT 'pending',
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewed_by` BIGINT UNSIGNED NULL,
  `review_notes` TEXT,
  `rejection_reason` TEXT,
  `payout_id` BIGINT UNSIGNED NULL,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payout_id`) REFERENCES `payouts`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested_at` (`requested_at`),
  INDEX `idx_reviewed_by` (`reviewed_by`),
  INDEX `idx_payout_id` (`payout_id`),
  
  CONSTRAINT `chk_requested_amount` CHECK (`requested_amount` > 0 AND `requested_amount` <= `available_balance`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
012_create_commissions_table.sql
sql
-- ============================================
-- TABLE: commissions
-- Purpose: Store commission calculations for payments
-- ============================================
CREATE TABLE IF NOT EXISTS `commissions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_amount` DECIMAL(10,2) NOT NULL,
  `commission_rate` DECIMAL(5,2) NOT NULL,
  `commission_amount` DECIMAL(10,2) NOT NULL,
  `organizer_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pending', 'held', 'released', 'paid') DEFAULT 'pending',
  `held_until` DATETIME NULL,
  `released_at` DATETIME NULL,
  `paid_at` DATETIME NULL,
  `payout_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payout_id`) REFERENCES `payouts`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_payout_id` (`payout_id`),
  INDEX `idx_held_until` (`held_until`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_commission_rate` CHECK (`commission_rate` BETWEEN 0 AND 100),
  CONSTRAINT `chk_amounts` CHECK (`ticket_amount` = `commission_amount` + `organizer_amount` AND `ticket_amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
013_create_event_categories_table.sql
sql
-- ============================================
-- TABLE: event_categories
-- Purpose: Store categories for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_categories` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `description` TEXT,
  `icon` VARCHAR(50),
  `color` VARCHAR(7),
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sort_order` (`sort_order`),
  UNIQUE INDEX `uq_name` (`name`),
  
  CONSTRAINT `chk_color_format` CHECK (`color` IS NULL OR `color` REGEXP '^#[0-9A-Fa-f]{6}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
014_create_event_tags_table.sql
sql
-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_tags` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `slug` VARCHAR(100) UNIQUE NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_slug` (`slug`),
  INDEX `idx_is_active` (`is_active`),
  FULLTEXT `idx_search` (`name`, `name_amharic`),
  
  CONSTRAINT `chk_slug_format` CHECK (`slug` REGEXP '^[a-z0-9-]+$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
015_create_event_tag_pivot_table.sql
sql
-- ============================================
-- TABLE: event_tag_pivot
-- Purpose: Many-to-many relationship between events and tags
-- ============================================
CREATE TABLE IF NOT EXISTS `event_tag_pivot` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `tag_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`tag_id`) REFERENCES `event_tags`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  UNIQUE INDEX `uq_event_tag` (`event_id`, `tag_id`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
016_create_venues_table.sql
sql
-- ============================================
-- TABLE: venues
-- Purpose: Store event venue information
-- ============================================
CREATE TABLE IF NOT EXISTS `venues` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `name_amharic` VARCHAR(200),
  `city_id` BIGINT UNSIGNED NOT NULL,
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  `kebele` VARCHAR(100),
  `house_number` VARCHAR(50),
  `landmark` TEXT,
  `full_address` TEXT,
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `google_maps_url` VARCHAR(500),
  `capacity` INT,
  `venue_type` ENUM('indoor', 'outdoor', 'both') DEFAULT 'indoor',
  `amenities` JSON COMMENT 'Array of amenities: ["parking", "wifi", "restrooms", "food", "bar", "ac", "stage"]',
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(100),
  `website` VARCHAR(255),
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `description` TEXT,
  `images` JSON COMMENT 'Array of image URLs with metadata',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_city` (`city_id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_is_verified` (`is_verified`),
  FULLTEXT `idx_search` (`name`, `name_amharic`, `landmark`, `full_address`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  
  CONSTRAINT `chk_capacity` CHECK (`capacity` IS NULL OR `capacity` > 0),
  CONSTRAINT `chk_coordinates` CHECK (
    (`latitude` IS NULL AND `longitude` IS NULL) OR 
    (`latitude` IS NOT NULL AND `longitude` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
017_create_events_table.sql
sql
-- ============================================
-- TABLE: events
-- Purpose: Store event information
-- ============================================
CREATE TABLE IF NOT EXISTS `events` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `description` TEXT,
  `description_amharic` TEXT,
  `short_description` VARCHAR(500),
  `category_id` BIGINT UNSIGNED NOT NULL,
  `tags` JSON COMMENT 'Array of tag IDs',
  `city_id` BIGINT UNSIGNED NOT NULL,
  `venue_id` BIGINT UNSIGNED NULL,
  `venue_custom` VARCHAR(200),
  `address_details` TEXT,
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `start_date_ethiopian` VARCHAR(50),
  `end_date_ethiopian` VARCHAR(50),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `duration_minutes` INT,
  `is_recurring` BOOLEAN DEFAULT FALSE,
  `recurrence_pattern` JSON COMMENT 'Recurrence configuration',
  `status` ENUM('draft', 'pending_review', 'published', 'cancelled', 'completed', 'suspended') DEFAULT 'draft',
  `visibility` ENUM('public', 'private', 'unlisted') DEFAULT 'public',
  `is_featured` BOOLEAN DEFAULT FALSE,
  `featured_until` DATETIME NULL,
  `has_tickets` BOOLEAN DEFAULT TRUE,
  `total_tickets` INT DEFAULT 0,
  `tickets_sold` INT DEFAULT 0,
  `min_price` DECIMAL(10,2) NULL,
  `max_price` DECIMAL(10,2) NULL,
  `cover_image` VARCHAR(255),
  `gallery_images` JSON COMMENT 'Array of image URLs',
  `video_url` VARCHAR(500),
  `age_restriction` ENUM('all', '18+', '21+') DEFAULT 'all',
  `is_charity` BOOLEAN DEFAULT FALSE,
  `charity_org` VARCHAR(200),
  `vat_included` BOOLEAN DEFAULT TRUE,
  `vat_rate` DECIMAL(5,2) DEFAULT 15.00,
  `views` INT DEFAULT 0,
  `shares` INT DEFAULT 0,
  `saves` INT DEFAULT 0,
  `meta_title` VARCHAR(200),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `published_at` DATETIME NULL,
  `cancelled_at` DATETIME NULL,
  `cancellation_reason` TEXT,
  `cancelled_by` BIGINT UNSIGNED NULL,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`category_id`) REFERENCES `event_categories`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`venue_id`) REFERENCES `venues`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_is_featured` (`is_featured`, `featured_until`),
  INDEX `idx_published_at` (`published_at`),
  INDEX `idx_category_id` (`category_id`),
  INDEX `idx_venue_id` (`venue_id`),
  INDEX `idx_cancelled_by` (`cancelled_by`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  FULLTEXT `idx_event_search` (`title`, `title_amharic`, `description`, `description_amharic`),
  
  CONSTRAINT `chk_event_dates` CHECK (`end_date` > `start_date`),
  CONSTRAINT `chk_tickets_sold` CHECK (`tickets_sold` <= `total_tickets`),
  CONSTRAINT `chk_vat_rate` CHECK (`vat_rate` >= 0 AND `vat_rate` <= 100),
  CONSTRAINT `chk_slug_format` CHECK (`slug` REGEXP '^[a-z0-9-]+$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
018_create_event_media_table.sql
sql
-- ============================================
-- TABLE: event_media
-- Purpose: Store media files for events
-- ============================================
CREATE TABLE IF NOT EXISTS `event_media` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `media_type` ENUM('image', 'video', 'document') DEFAULT 'image',
  `url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT UNSIGNED,
  `width` INT UNSIGNED,
  `height` INT UNSIGNED,
  `duration` INT UNSIGNED NULL,
  `caption` VARCHAR(500),
  `caption_amharic` VARCHAR(500),
  `sort_order` INT DEFAULT 0,
  `is_primary` BOOLEAN DEFAULT FALSE,
  `is_approved` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_primary` (`is_primary`),
  INDEX `idx_is_approved` (`is_approved`),
  
  CONSTRAINT `chk_file_size` CHECK (`file_size` >= 0),
  CONSTRAINT `chk_dimensions` CHECK (`width` >= 0 AND `height` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
019_create_ticket_types_table.sql
sql
-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- ============================================
CREATE TABLE IF NOT EXISTS `ticket_types` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `description` TEXT,
  `description_amharic` TEXT,
  `price` DECIMAL(10,2) NOT NULL,
  `vat_included` BOOLEAN DEFAULT TRUE,
  `vat_amount` DECIMAL(10,2) GENERATED ALWAYS AS (CASE WHEN `vat_included` THEN `price` * 0.15 ELSE 0 END) STORED,
  `net_price` DECIMAL(10,2) GENERATED ALWAYS AS (CASE WHEN `vat_included` THEN `price` / 1.15 ELSE `price` END) STORED,
  `quantity` INT NOT NULL,
  `sold_count` INT DEFAULT 0,
  `reserved_count` INT DEFAULT 0,
  `available_count` INT GENERATED ALWAYS AS (`quantity` - `sold_count` - `reserved_count`) STORED,
  `max_per_user` INT DEFAULT 5,
  `min_per_user` INT DEFAULT 1,
  `sales_start` DATETIME,
  `sales_end` DATETIME,
  `is_early_bird` BOOLEAN DEFAULT FALSE,
  `early_bird_end` DATETIME NULL,
  `access_level` ENUM('general', 'vip', 'backstage', 'premium') DEFAULT 'general',
  `seating_info` TEXT,
  `benefits` JSON COMMENT 'Array of benefits for this ticket type',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_hidden` BOOLEAN DEFAULT FALSE,
  `is_student_ticket` BOOLEAN DEFAULT FALSE,
  `requires_student_id` BOOLEAN DEFAULT FALSE,
  `is_group_ticket` BOOLEAN DEFAULT FALSE,
  `group_size` INT NULL,
  `revenue` DECIMAL(15,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sales_dates` (`sales_start`, `sales_end`),
  INDEX `idx_price` (`price`),
  INDEX `idx_access_level` (`access_level`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  CONSTRAINT `chk_quantity` CHECK (`quantity` >= 0),
  CONSTRAINT `chk_sold_count` CHECK (`sold_count` >= 0),
  CONSTRAINT `chk_reserved_count` CHECK (`reserved_count` >= 0),
  CONSTRAINT `chk_price` CHECK (`price` >= 0),
  CONSTRAINT `chk_sales_dates` CHECK (`sales_end` IS NULL OR `sales_start` IS NULL OR `sales_end` > `sales_start`),
  CONSTRAINT `chk_max_min_per_user` CHECK (`max_per_user` >= `min_per_user` AND `min_per_user` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
020_create_reservations_table.sql
sql
-- ============================================
-- TABLE: reservations
-- Purpose: Store temporary ticket reservations before payment
-- ============================================
CREATE TABLE IF NOT EXISTS `reservations` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `reservation_code` VARCHAR(20) UNIQUE NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_type_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `status` ENUM('active', 'completed', 'expired', 'cancelled') DEFAULT 'active',
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash') NULL,
  `expires_at` DATETIME NOT NULL,
  `completed_at` DATETIME NULL,
  `session_id` VARCHAR(100),
  `device_id` VARCHAR(255),
  `ip_address` VARCHAR(45),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_reservation_code` (`reservation_code`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status_expires` (`status`, `expires_at`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_quantity` CHECK (`quantity` > 0),
  CONSTRAINT `chk_total_amount` CHECK (`total_amount` > 0),
  CONSTRAINT `chk_expires_at` CHECK (`expires_at` > `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

021_create_individual_tickets_table.sql
sql
-- ============================================
-- TABLE: individual_tickets
-- Purpose: Store individual ticket instances
-- ============================================
CREATE TABLE IF NOT EXISTS `individual_tickets` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `ticket_number` VARCHAR(50) UNIQUE NOT NULL,
  `ticket_type_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `purchase_price` DECIMAL(10,2) NOT NULL,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `platform_commission` DECIMAL(10,2) NOT NULL,
  `organizer_earning` DECIMAL(10,2) NOT NULL,
  `qr_data` TEXT NOT NULL,
  `qr_image_url` VARCHAR(500),
  `qr_secret_key` VARCHAR(100),
  `status` ENUM('reserved', 'paid', 'checked_in', 'cancelled', 'refunded', 'transferred') DEFAULT 'reserved',
  `checked_in_at` DATETIME NULL,
  `checked_in_by` BIGINT UNSIGNED NULL,
  `checkin_device_id` VARCHAR(100),
  `checkin_location` VARCHAR(255),
  `checkin_method` ENUM('qr_scan', 'manual', 'offline_sync') NULL,
  `transferred_at` DATETIME NULL,
  `transferred_to_user` BIGINT UNSIGNED NULL,
  `transfer_token` VARCHAR(100),
  `cancelled_at` DATETIME NULL,
  `cancelled_by` BIGINT UNSIGNED NULL,
  `cancellation_reason` ENUM('user_request', 'event_cancelled', 'duplicate', 'fraud', 'other') NULL,
  `refund_amount` DECIMAL(10,2) NULL,
  `refunded_at` DATETIME NULL,
  `refund_transaction_id` VARCHAR(100),
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash', 'other') NULL,
  `payment_reference` VARCHAR(100),
  `device_id` VARCHAR(255),
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `reserved_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `purchased_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`transferred_to_user`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_ticket_number` (`ticket_number`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_purchased_at` (`purchased_at`),
  INDEX `idx_checked_in_at` (`checked_in_at`),
  INDEX `idx_qr_secret` (`qr_secret_key`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  UNIQUE INDEX `idx_qr_data` (`qr_data`(100)),
  
  CONSTRAINT `chk_purchase_price` CHECK (`purchase_price` >= 0),
  CONSTRAINT `chk_vat_amount` CHECK (`vat_amount` >= 0),
  CONSTRAINT `chk_platform_commission` CHECK (`platform_commission` >= 0),
  CONSTRAINT `chk_organizer_earning` CHECK (`organizer_earning` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
022_create_checkin_logs_table.sql
sql
-- ============================================
-- TABLE: checkin_logs
-- Purpose: Store ticket check-in logs
-- ============================================
CREATE TABLE IF NOT EXISTS `checkin_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `checked_in_by` BIGINT UNSIGNED NOT NULL,
  `checkin_method` ENUM('qr_scan', 'manual_entry', 'offline_sync', 'batch_import') NOT NULL,
  `checkin_time` DATETIME NOT NULL,
  `device_id` VARCHAR(255),
  `device_type` ENUM('android', 'ios', 'web', 'other') DEFAULT 'android',
  `app_version` VARCHAR(20),
  `latitude` DECIMAL(10,8) NULL,
  `longitude` DECIMAL(11,8) NULL,
  `location_name` VARCHAR(255),
  `is_online` BOOLEAN DEFAULT TRUE,
  `sync_status` ENUM('pending', 'synced', 'failed') DEFAULT 'synced',
  `local_time` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `synced_at` DATETIME NULL,
  
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_ticket` (`ticket_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_checkin_time` (`checkin_time`),
  INDEX `idx_sync_status` (`sync_status`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  INDEX `idx_device_id` (`device_id`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  UNIQUE INDEX `idx_ticket_checkin` (`ticket_id`, `checkin_time`),
  
  CONSTRAINT `chk_coordinates` CHECK (
    (`latitude` IS NULL AND `longitude` IS NULL) OR 
    (`latitude` IS NOT NULL AND `longitude` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
023_create_payment_methods_table.sql
sql
-- ============================================
-- TABLE: payment_methods
-- Purpose: Store available payment methods (Telebirr, CBE, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_methods` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `code` VARCHAR(50) UNIQUE NOT NULL,
  `type` ENUM('mobile_money', 'bank_transfer', 'card', 'cash') NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_default` BOOLEAN DEFAULT FALSE,
  `sort_order` INT DEFAULT 0,
  `min_amount` DECIMAL(10,2) DEFAULT 0.00,
  `max_amount` DECIMAL(10,2) DEFAULT 100000.00,
  `bank_name` VARCHAR(100) NULL,
  `account_number` VARCHAR(100) NULL,
  `account_name` VARCHAR(200) NULL,
  `qr_supported` BOOLEAN DEFAULT FALSE,
  `has_fee` BOOLEAN DEFAULT FALSE,
  `fee_type` ENUM('percentage', 'fixed', 'both') DEFAULT 'percentage',
  `fee_percentage` DECIMAL(5,2) DEFAULT 0.00,
  `fee_fixed` DECIMAL(10,2) DEFAULT 0.00,
  `api_config` JSON COMMENT 'Payment gateway configuration',
  `webhook_url` VARCHAR(500) NULL,
  `icon` VARCHAR(255),
  `instructions` TEXT,
  `instructions_amharic` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_code` (`code`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_type` (`type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_default` (`is_default`),
  
  CONSTRAINT `chk_min_max_amount` CHECK (`max_amount` >= `min_amount`),
  CONSTRAINT `chk_fee_percentage` CHECK (`fee_percentage` >= 0 AND `fee_percentage` <= 100),
  CONSTRAINT `chk_fee_fixed` CHECK (`fee_fixed` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
024_create_payments_table.sql
sql
-- ============================================
-- TABLE: payments
-- Purpose: Store payment transactions
-- ============================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_reference` VARCHAR(100) UNIQUE NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `reservation_id` BIGINT UNSIGNED NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `platform_commission` DECIMAL(10,2) NOT NULL,
  `organizer_earning` DECIMAL(10,2) NOT NULL,
  `commission_rate` DECIMAL(5,2) NOT NULL,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `payment_method_id` BIGINT UNSIGNED NOT NULL,
  `payment_method_code` VARCHAR(50) NOT NULL,
  `transaction_id` VARCHAR(100),
  `external_reference` VARCHAR(100),
  `status` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
  `payment_status` ENUM('initiated', 'authorized', 'captured', 'declined', 'error') DEFAULT 'initiated',
  `requires_verification` BOOLEAN DEFAULT FALSE,
  `verified_by` BIGINT UNSIGNED NULL,
  `verified_at` DATETIME NULL,
  `verification_notes` TEXT,
  `bank_statement_image` VARCHAR(255),
  `customer_phone` VARCHAR(20),
  `customer_email` VARCHAR(100),
  `customer_name` VARCHAR(100),
  `sms_sent` BOOLEAN DEFAULT FALSE,
  `sms_delivered` BOOLEAN DEFAULT FALSE,
  `email_sent` BOOLEAN DEFAULT FALSE,
  `receipt_sent` BOOLEAN DEFAULT FALSE,
  `fraud_score` DECIMAL(5,2) DEFAULT 0.00,
  `fraud_flags` JSON COMMENT 'Array of fraud detection flags',
  `is_suspicious` BOOLEAN DEFAULT FALSE,
  `is_telebirr` BOOLEAN GENERATED ALWAYS AS (`payment_method_code` = 'telebirr') STORED,
  `is_cbe` BOOLEAN GENERATED ALWAYS AS (`payment_method_code` LIKE 'cbe%') STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_payment_reference` (`payment_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment_method` (`payment_method_code`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_transaction` (`transaction_id`),
  INDEX `idx_requires_verification` (`requires_verification`, `status`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_reservation_id` (`reservation_id`),
  INDEX `idx_payment_method_id` (`payment_method_id`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_completed_at` (`completed_at`),
  
  CONSTRAINT `chk_amount` CHECK (`amount` > 0),
  CONSTRAINT `chk_commission_rate` CHECK (`commission_rate` BETWEEN 0 AND 100),
  CONSTRAINT `chk_platform_commission` CHECK (`platform_commission` >= 0),
  CONSTRAINT `chk_organizer_earning` CHECK (`organizer_earning` >= 0),
  CONSTRAINT `chk_vat_amount` CHECK (`vat_amount` >= 0),
  CONSTRAINT `chk_fraud_score` CHECK (`fraud_score` BETWEEN 0 AND 100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
025_create_payment_transactions_table.sql
sql
-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_transactions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `transaction_type` ENUM('payment', 'refund', 'adjustment', 'fee') DEFAULT 'payment',
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `status` ENUM('initiated', 'pending', 'completed', 'failed', 'cancelled') DEFAULT 'initiated',
  `external_transaction_id` VARCHAR(100),
  `external_status` VARCHAR(50),
  `external_response` JSON COMMENT 'Raw response from payment gateway',
  `request_data` JSON COMMENT 'Request data sent to gateway',
  `response_data` JSON COMMENT 'Response data from gateway',
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_external_id` (`external_transaction_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_transaction_type` (`transaction_type`),
  INDEX `idx_completed_at` (`completed_at`),
  
  CONSTRAINT `chk_amount_non_zero` CHECK (`amount` != 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
026_create_payment_receipts_table.sql
sql
-- ============================================
-- TABLE: payment_receipts
-- Purpose: Store payment receipt uploads
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_receipts` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `receipt_type` ENUM('cbe_screenshot', 'bank_slip', 'telebirr_screenshot', 'other') DEFAULT 'cbe_screenshot',
  `image_url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `bank_name` VARCHAR(100),
  `account_number` VARCHAR(100),
  `transaction_id` VARCHAR(100),
  `amount` DECIMAL(10,2),
  `transaction_date` DATE,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `verified_by` BIGINT UNSIGNED NULL,
  `verified_at` DATETIME NULL,
  `verification_status` ENUM('pending', 'approved', 'rejected', 'needs_clarification') DEFAULT 'pending',
  `verification_notes` TEXT,
  `bank_branch` VARCHAR(100),
  `teller_number` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_verification_status` (`verification_status`),
  INDEX `idx_receipt_type` (`receipt_type`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_is_verified` (`is_verified`),
  INDEX `idx_transaction_date` (`transaction_date`),
  
  CONSTRAINT `chk_amount_match` CHECK (`amount` IS NULL OR `amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
027_create_refunds_table.sql
sql
-- ============================================
-- TABLE: refunds
-- Purpose: Store refund records
-- ============================================
CREATE TABLE IF NOT EXISTS `refunds` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `refund_reference` VARCHAR(100) UNIQUE NOT NULL,
  `ticket_id` BIGINT UNSIGNED NOT NULL,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `refund_amount` DECIMAL(10,2) NOT NULL,
  `refund_reason` ENUM('event_cancelled', 'customer_request', 'duplicate_payment', 'fraud', 'technical_issue', 'other') NOT NULL,
  `refund_reason_details` TEXT,
  `status` ENUM('requested', 'approved', 'rejected', 'processing', 'completed', 'failed') DEFAULT 'requested',
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `requested_by` BIGINT UNSIGNED NOT NULL,
  `approved_at` DATETIME NULL,
  `approved_by` BIGINT UNSIGNED NULL,
  `processed_at` DATETIME NULL,
  `processed_by` BIGINT UNSIGNED NULL,
  `refund_method` ENUM('original_method', 'telebirr', 'cbe_transfer', 'wallet_credit', 'other') DEFAULT 'original_method',
  `refund_transaction_id` VARCHAR(100),
  `commission_refunded` BOOLEAN DEFAULT FALSE,
  `commission_refund_amount` DECIMAL(10,2) DEFAULT 0.00,
  `requires_approval` BOOLEAN DEFAULT TRUE,
  `approval_level` ENUM('organizer', 'admin') DEFAULT 'organizer',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`requested_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`processed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_refund_reference` (`refund_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested_at` (`requested_at`),
  INDEX `idx_ticket_id` (`ticket_id`),
  INDEX `idx_payment_id` (`payment_id`),
  INDEX `idx_requested_by` (`requested_by`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_processed_by` (`processed_by`),
  
  CONSTRAINT `chk_refund_amount` CHECK (`refund_amount` > 0),
  CONSTRAINT `chk_commission_refund_amount` CHECK (`commission_refund_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
028_create_payouts_table.sql
sql
-- ============================================
-- TABLE: payouts
-- Purpose: Store organizer payout records
-- ============================================
CREATE TABLE IF NOT EXISTS `payouts` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payout_reference` VARCHAR(100) UNIQUE NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `fee_amount` DECIMAL(10,2) DEFAULT 0.00,
  `net_amount` DECIMAL(10,2) GENERATED ALWAYS AS (`amount` - `fee_amount`) STORED,
  `bank_name` VARCHAR(100),
  `bank_account` VARCHAR(100),
  `account_holder_name` VARCHAR(100),
  `bank_branch` VARCHAR(100),
  `status` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled') DEFAULT 'pending',
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `processed_at` DATETIME NULL,
  `processed_by` BIGINT UNSIGNED NULL,
  `processing_notes` TEXT,
  `transfer_method` ENUM('cbe_online', 'cbe_branch', 'other_bank', 'telebirr') DEFAULT 'cbe_online',
  `transfer_reference` VARCHAR(100),
  `transfer_date` DATE NULL,
  `payment_ids` JSON COMMENT 'Array of payment IDs included in this payout',
  `tax_deducted` BOOLEAN DEFAULT FALSE,
  `tax_amount` DECIMAL(10,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`processed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_payout_reference` (`payout_reference`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested_at` (`requested_at`),
  INDEX `idx_processed_at` (`processed_at`),
  INDEX `idx_processed_by` (`processed_by`),
  INDEX `idx_transfer_date` (`transfer_date`),
  
  CONSTRAINT `chk_payout_amount` CHECK (`amount` > 0),
  CONSTRAINT `chk_fee_amount` CHECK (`fee_amount` >= 0),
  CONSTRAINT `chk_tax_amount` CHECK (`tax_amount` >= 0),
  CONSTRAINT `chk_net_amount` CHECK (`net_amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
029_create_taxes_table.sql
sql
-- ============================================
-- TABLE: taxes
-- Purpose: Store tax information (VAT, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `taxes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `tax_type` ENUM('vat', 'income_tax', 'withholding_tax', 'other') DEFAULT 'vat',
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `rate` DECIMAL(5,2) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `effective_from` DATE NOT NULL,
  `effective_to` DATE NULL,
  `applies_to_tickets` BOOLEAN DEFAULT TRUE,
  `applies_to_commission` BOOLEAN DEFAULT FALSE,
  `applies_to_fees` BOOLEAN DEFAULT FALSE,
  `tax_authority` VARCHAR(200),
  `authority_code` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_tax_type` (`tax_type`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_effective` (`effective_from`, `effective_to`),
  UNIQUE INDEX `uq_tax_type_effective` (`tax_type`, `effective_from`),
  
  CONSTRAINT `chk_tax_rate` CHECK (`rate` >= 0 AND `rate` <= 100),
  CONSTRAINT `chk_effective_dates` CHECK (`effective_to` IS NULL OR `effective_to` > `effective_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
030_create_financial_reports_table.sql
sql
-- ============================================
-- TABLE: financial_reports
-- Purpose: Store financial reports and analytics
-- ============================================
CREATE TABLE IF NOT EXISTS `financial_reports` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `report_type` ENUM('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom') NOT NULL,
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `total_tickets_sold` INT DEFAULT 0,
  `total_events` INT DEFAULT 0,
  `total_organizers` INT DEFAULT 0,
  `revenue_by_city` JSON COMMENT 'City-wise revenue breakdown',
  `revenue_by_category` JSON COMMENT 'Category-wise revenue breakdown',
  `revenue_by_payment_method` JSON COMMENT 'Payment method-wise revenue breakdown',
  `platform_commission` DECIMAL(15,2) DEFAULT 0.00,
  `platform_fees` DECIMAL(15,2) DEFAULT 0.00,
  `total_vat_collected` DECIMAL(15,2) DEFAULT 0.00,
  `total_payouts` DECIMAL(15,2) DEFAULT 0.00,
  `payouts_by_organizer` JSON COMMENT 'Organizer-wise payout breakdown',
  `report_currency` VARCHAR(3) DEFAULT 'ETB',
  `exchange_rate` DECIMAL(10,4) DEFAULT 1.0000,
  `status` ENUM('generating', 'completed', 'failed') DEFAULT 'generating',
  `generated_at` DATETIME NULL,
  `generated_by` BIGINT UNSIGNED NULL,
  `report_file_url` VARCHAR(500),
  `report_data` JSON COMMENT 'Complete report data in JSON format',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`generated_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_report_type` (`report_type`),
  INDEX `idx_period` (`period_start`, `period_end`),
  INDEX `idx_generated_at` (`generated_at`),
  INDEX `idx_generated_by` (`generated_by`),
  INDEX `idx_status` (`status`),
  UNIQUE INDEX `idx_period_type` (`report_type`, `period_start`, `period_end`),
  
  CONSTRAINT `chk_period` CHECK (`period_end` >= `period_start`),
  CONSTRAINT `chk_exchange_rate` CHECK (`exchange_rate` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
031_create_disputes_table.sql
sql
-- ============================================
-- TABLE: disputes
-- Purpose: Store dispute records between users and organizers
-- ============================================
CREATE TABLE IF NOT EXISTS `disputes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `dispute_reference` VARCHAR(100) UNIQUE NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_id` BIGINT UNSIGNED NULL,
  `payment_id` BIGINT UNSIGNED NULL,
  `type` ENUM('refund_request', 'event_cancelled', 'ticket_not_valid', 'organizer_no_show', 'event_different', 'fraud', 'technical_issue', 'other') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `desired_outcome` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'apology', 'other') NOT NULL,
  `status` ENUM('open', 'under_review', 'awaiting_response', 'resolved', 'closed', 'escalated') DEFAULT 'open',
  `resolution` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'organizer_penalty', 'rejected', 'other') NULL,
  `resolution_amount` DECIMAL(10,2) NULL,
  `resolution_details` TEXT,
  `assigned_to` BIGINT UNSIGNED NULL,
  `assigned_at` DATETIME NULL,
  `resolved_at` DATETIME NULL,
  `resolved_by` BIGINT UNSIGNED NULL,
  `closed_at` DATETIME NULL,
  `requires_mediation` BOOLEAN DEFAULT FALSE,
  `mediation_notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_dispute_reference` (`dispute_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_assigned_to` (`assigned_to`, `status`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_resolved_at` (`resolved_at`),
  
  CONSTRAINT `chk_resolution_amount` CHECK (`resolution_amount` IS NULL OR `resolution_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
032_create_notifications_table.sql
sql
-- ============================================
-- TABLE: notifications
-- Purpose: Store user notifications
-- ============================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `type` ENUM('payment', 'ticket', 'event', 'system', 'promotional', 'admin') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `message` TEXT NOT NULL,
  `message_amharic` TEXT,
  `action_url` VARCHAR(500),
  `action_label` VARCHAR(100),
  `action_label_amharic` VARCHAR(100),
  `is_read` BOOLEAN DEFAULT FALSE,
  `is_sent` BOOLEAN DEFAULT FALSE,
  `delivery_method` ENUM('in_app', 'sms', 'email', 'push', 'all') DEFAULT 'in_app',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `expires_at` DATETIME NULL,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `read_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_delivery_method` (`delivery_method`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_is_sent` (`is_sent`),
  
  CONSTRAINT `chk_expires_at` CHECK (`expires_at` IS NULL OR `expires_at` > `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
033_create_sms_logs_table.sql
sql
-- ============================================
-- TABLE: sms_logs
-- Purpose: Store SMS delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `sms_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `recipient_phone` VARCHAR(20) NOT NULL,
  `recipient_name` VARCHAR(100),
  `message_type` ENUM('otp', 'payment_confirmation', 'ticket_delivery', 'event_reminder', 'promotional', 'system') NOT NULL,
  `message_text` TEXT NOT NULL,
  `message_text_amharic` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'expired') DEFAULT 'pending',
  `message_id` VARCHAR(100),
  `delivery_report` JSON COMMENT 'SMS gateway delivery report',
  `cost` DECIMAL(10,2) DEFAULT 0.00,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `segments` INT DEFAULT 1,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `gateway` VARCHAR(50) DEFAULT 'ethio_telecom',
  `route` VARCHAR(50),
  `scheduled_at` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_recipient` (`recipient_phone`),
  INDEX `idx_status` (`status`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_gateway` (`gateway`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_segments` CHECK (`segments` > 0),
  CONSTRAINT `chk_cost` CHECK (`cost` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
034_create_email_logs_table.sql
sql
-- ============================================
-- TABLE: email_logs
-- Purpose: Store email delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `email_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `recipient_email` VARCHAR(100) NOT NULL,
  `recipient_name` VARCHAR(100),
  `subject` VARCHAR(200) NOT NULL,
  `template_name` VARCHAR(100),
  `language` ENUM('am', 'en') DEFAULT 'en',
  `status` ENUM('pending', 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'failed') DEFAULT 'pending',
  `message_id` VARCHAR(200),
  `delivery_report` JSON COMMENT 'Email service delivery report',
  `body_html` TEXT,
  `body_text` TEXT,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `opened_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_recipient` (`recipient_email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_template` (`template_name`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_email_format` CHECK (`recipient_email` REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
035_create_push_notifications_table.sql
sql
-- ============================================
-- TABLE: push_notifications
-- Purpose: Store push notification logs
-- ============================================
CREATE TABLE IF NOT EXISTS `push_notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_token` VARCHAR(255) NOT NULL,
  `device_type` ENUM('ios', 'android', 'web') NOT NULL,
  `app_version` VARCHAR(20),
  `title` VARCHAR(200) NOT NULL,
  `body` TEXT NOT NULL,
  `data` JSON COMMENT 'Additional data payload',
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'device_not_registered') DEFAULT 'pending',
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `failure_reason` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_device_token` (`device_token`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_device_token_length` CHECK (CHAR_LENGTH(`device_token`) >= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
036_create_notification_templates_table.sql
sql
-- ============================================
-- TABLE: notification_templates
-- Purpose: Store notification templates
-- ============================================
CREATE TABLE IF NOT EXISTS `notification_templates` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `template_type` ENUM('sms', 'email', 'push', 'in_app') NOT NULL,
  `template_code` VARCHAR(100) UNIQUE NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `subject` VARCHAR(200),
  `body_template` TEXT NOT NULL,
  `body_template_amharic` TEXT,
  `variables` JSON COMMENT 'Array of template variable names',
  `is_active` BOOLEAN DEFAULT TRUE,
  `priority` INT DEFAULT 0,
  `default_language` ENUM('am', 'en') DEFAULT 'am',
  `requires_translation` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_template_code` (`template_code`),
  INDEX `idx_template_type` (`template_type`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_default_language` (`default_language`),
  INDEX `idx_requires_translation` (`requires_translation`),
  
  CONSTRAINT `chk_priority` CHECK (`priority` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
037_create_message_threads_table.sql
sql
-- ============================================
-- TABLE: message_threads
-- Purpose: Store message threads between users, organizers, and admins
-- ============================================
CREATE TABLE IF NOT EXISTS `message_threads` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NULL,
  `admin_id` BIGINT UNSIGNED NULL,
  `subject` VARCHAR(200) NOT NULL,
  `related_event_id` BIGINT UNSIGNED NULL,
  `related_ticket_id` BIGINT UNSIGNED NULL,
  `status` ENUM('open', 'waiting_reply', 'resolved', 'closed') DEFAULT 'open',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `last_message_at` DATETIME NULL,
  `last_message_by` BIGINT UNSIGNED NULL,
  `message_count` INT UNSIGNED DEFAULT 0,
  `unread_count_user` INT UNSIGNED DEFAULT 0,
  `unread_count_admin` INT UNSIGNED DEFAULT 0,
  `unread_count_organizer` INT UNSIGNED DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` DATETIME NULL,
  `closed_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`related_event_id`) REFERENCES `events`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`related_ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`last_message_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_last_message_at` (`last_message_at`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_admin_id` (`admin_id`),
  INDEX `idx_related_event_id` (`related_event_id`),
  INDEX `idx_related_ticket_id` (`related_ticket_id`),
  INDEX `idx_last_message_by` (`last_message_by`),
  
  CONSTRAINT `chk_message_counts` CHECK (`message_count` >= 0 AND `unread_count_user` >= 0 AND `unread_count_admin` >= 0 AND `unread_count_organizer` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
038_create_audit_logs_table.sql
sql
-- ============================================
-- TABLE: audit_logs
-- Purpose: Store audit trail for important actions
-- ============================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NULL,
  `user_type` ENUM('customer', 'organizer', 'admin', 'system') NULL,
  `action` VARCHAR(100) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `old_values` JSON COMMENT 'Previous values before change',
  `new_values` JSON COMMENT 'New values after change',
  `changed_fields` JSON COMMENT 'Array of field names that changed',
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `device_id` VARCHAR(255),
  `session_id` VARCHAR(100),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_user_type` (`user_type`),
  INDEX `idx_ip_address` (`ip_address`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_entity_id` (`entity_id`),
  
  CONSTRAINT `chk_entity_id_positive` CHECK (`entity_id` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
039_create_activity_logs_table.sql
sql
-- ============================================
-- TABLE: activity_logs
-- Purpose: Store user activity logs
-- ============================================
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `activity_type` ENUM('login', 'logout', 'page_view', 'search', 'ticket_purchase', 'event_view', 'profile_update', 'payment_attempt', 'checkin') NOT NULL,
  `activity_details` TEXT,
  `page_url` VARCHAR(500),
  `referrer_url` VARCHAR(500),
  `device_type` ENUM('mobile', 'tablet', 'desktop') DEFAULT 'mobile',
  `browser` VARCHAR(100),
  `os` VARCHAR(100),
  `city_id` BIGINT UNSIGNED NULL,
  `estimated_location` VARCHAR(255),
  `load_time_ms` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_activity_type` (`activity_type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_page_url` (`page_url`(100)),
  INDEX `idx_referrer_url` (`referrer_url`(100)),
  
  CONSTRAINT `chk_load_time` CHECK (`load_time_ms` IS NULL OR `load_time_ms` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
040_create_offline_sync_logs_table.sql
sql
-- ============================================
-- TABLE: offline_sync_logs
-- Purpose: Store offline sync logs
-- ============================================
CREATE TABLE IF NOT EXISTS `offline_sync_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `device_id` VARCHAR(255) NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_type` ENUM('android', 'ios', 'web') NOT NULL,
  `app_version` VARCHAR(20),
  `sync_type` ENUM('checkin', 'ticket_download', 'event_data', 'profile', 'all') NOT NULL,
  `records_count` INT DEFAULT 0,
  `data_size_kb` INT,
  `status` ENUM('pending', 'in_progress', 'completed', 'failed', 'partial') DEFAULT 'pending',
  `started_at` DATETIME NOT NULL,
  `completed_at` DATETIME NULL,
  `duration_ms` INT,
  `connection_type` ENUM('wifi', 'cellular_2g', 'cellular_3g', 'cellular_4g', 'cellular_5g', 'unknown') DEFAULT 'unknown',
  `network_speed_kbps` INT,
  `city_id` BIGINT UNSIGNED NULL,
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_device` (`device_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_started_at` (`started_at`),
  INDEX `idx_sync_type` (`sync_type`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_connection_type` (`connection_type`),
  INDEX `idx_completed_at` (`completed_at`),
  
  CONSTRAINT `chk_records_count` CHECK (`records_count` >= 0),
  CONSTRAINT `chk_data_size` CHECK (`data_size_kb` IS NULL OR `data_size_kb` >= 0),
  CONSTRAINT `chk_duration` CHECK (`duration_ms` IS NULL OR `duration_ms` >= 0),
  CONSTRAINT `chk_network_speed` CHECK (`network_speed_kbps` IS NULL OR `network_speed_kbps` >= 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
041_create_webhook_logs_table.sql
sql
-- ============================================
-- TABLE: webhook_logs
-- Purpose: Store webhook logs
-- ============================================
CREATE TABLE IF NOT EXISTS `webhook_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `webhook_type` ENUM('telebirr_payment', 'sms_delivery', 'email_delivery', 'third_party', 'custom') NOT NULL,
  `endpoint_url` VARCHAR(500) NOT NULL,
  `request_headers` JSON COMMENT 'HTTP headers sent',
  `request_body` TEXT,
  `request_method` VARCHAR(10) DEFAULT 'POST',
  `response_status` INT,
  `response_headers` JSON COMMENT 'HTTP headers received',
  `response_body` TEXT,
  `response_time_ms` INT,
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'retrying') DEFAULT 'pending',
  `retry_count` INT DEFAULT 0,
  `error_message` TEXT,
  `next_retry_at` DATETIME NULL,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  
  INDEX `idx_webhook_type` (`webhook_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_next_retry_at` (`next_retry_at`),
  INDEX `idx_endpoint_url` (`endpoint_url`(100)),
  INDEX `idx_response_status` (`response_status`),
  INDEX `idx_sent_at` (`sent_at`),
  
  CONSTRAINT `chk_response_time` CHECK (`response_time_ms` IS NULL OR `response_time_ms` >= 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0),
  CONSTRAINT `chk_response_status` CHECK (`response_status` IS NULL OR `response_status` BETWEEN 100 AND 599)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
042_create_system_settings_table.sql
sql
-- ============================================
-- TABLE: system_settings
-- Purpose: Store system configuration settings
-- ============================================
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
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_category` (`category`),
  INDEX `idx_setting_key` (`setting_key`),
  INDEX `idx_is_public` (`is_public`),
  INDEX `idx_is_editable` (`is_editable`),
  INDEX `idx_applies_to_country` (`applies_to_country`),
  INDEX `idx_updated_by` (`updated_by`),
  
  CONSTRAINT `chk_setting_key_format` CHECK (`setting_key` REGEXP '^[a-z][a-z0-9_]*$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
043_create_ethiopian_holidays_table.sql
sql
-- ============================================
-- TABLE: ethiopian_holidays
-- Purpose: Store Ethiopian holiday calendar
-- ============================================
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