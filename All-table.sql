001_create_users_table.sql

sql
-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins)
-- ============================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `phone` VARCHAR(20) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE,
  `password_hash` VARCHAR(255),
  `full_name` VARCHAR(100),
  `role` ENUM('customer', 'organizer', 'admin', 'staff') DEFAULT 'customer',
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `city_id` INT NULL,
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
  `organizer_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  INDEX `idx_phone` (`phone`),
  INDEX `idx_role` (`role`),
  INDEX `idx_phone_verified` (`phone_verified`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
002_create_organizers_table.sql

sql
-- ============================================
-- TABLE: organizers
-- Purpose: Store event organizer information
-- ============================================
CREATE TABLE IF NOT EXISTS `organizers` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT UNIQUE NOT NULL,
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
  `verified_by` INT NULL,
  `commission_rate` DECIMAL(5,2) DEFAULT 10.00,
  `custom_commission_rate` DECIMAL(5,2) NULL,
  `total_events` INT DEFAULT 0,
  `total_tickets_sold` INT DEFAULT 0,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `rating` DECIMAL(3,2) DEFAULT 0.00,
  `rating_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_status` (`status`),
  INDEX `idx_business_name` (`business_name`),
  INDEX `idx_verified_at` (`verified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
003_create_organizer_applications_table.sql

sql
-- ============================================
-- TABLE: organizer_applications
-- Purpose: Store organizer applications and verification
-- ============================================
CREATE TABLE IF NOT EXISTS `organizer_applications` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
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
  `reviewed_by` INT NULL,
  `review_notes` TEXT,
  `expected_monthly_events` INT,
  `primary_event_type` VARCHAR(100),
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_status` (`status`),
  INDEX `idx_submitted` (`submitted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
004_create_event_categories_table.sql

sql
-- ============================================
-- TABLE: event_categories
-- Purpose: Store categories for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_categories` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
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
  INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
005_create_event_tags_table.sql

sql
-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_tags` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `slug` VARCHAR(100) UNIQUE NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_slug` (`slug`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
006_create_cities_table.sql

sql
-- ============================================
-- TABLE: cities
-- Purpose: Store Ethiopian cities and regions
-- ============================================
CREATE TABLE IF NOT EXISTS `cities` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `region` VARCHAR(100),
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `population` INT NULL,
  `major_venues` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_region` (`region`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
007_create_venues_table.sql

sql
-- ============================================
-- TABLE: venues
-- Purpose: Store event venue information
-- ============================================
CREATE TABLE IF NOT EXISTS `venues` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `name_amharic` VARCHAR(200),
  `city_id` INT NOT NULL,
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
  `amenities` JSON,
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(100),
  `website` VARCHAR(255),
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `description` TEXT,
  `images` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`),
  
  INDEX `idx_city` (`city_id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  FULLTEXT `idx_search` (`name`, `name_amharic`, `landmark`, `full_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
008_create_events_table.sql

sql
-- ============================================
-- TABLE: events
-- Purpose: Store event information
-- ============================================
CREATE TABLE IF NOT EXISTS `events` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` INT NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `description` TEXT,
  `description_amharic` TEXT,
  `short_description` VARCHAR(500),
  `category_id` INT NOT NULL,
  `tags` JSON,
  `city_id` INT NOT NULL,
  `venue_id` INT NULL,
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
  `recurrence_pattern` JSON,
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
  `gallery_images` JSON,
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
  `cancelled_by` INT NULL,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `event_categories`(`id`),
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`),
  FOREIGN KEY (`venue_id`) REFERENCES `venues`(`id`),
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_is_featured` (`is_featured`, `featured_until`),
  INDEX `idx_published` (`published_at`),
  FULLTEXT `idx_event_search` (`title`, `title_amharic`, `description`, `description_amharic`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
009_create_event_media_table.sql

sql
-- ============================================
-- TABLE: event_media
-- Purpose: Store media files for events
-- ============================================
CREATE TABLE IF NOT EXISTS `event_media` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `event_id` INT NOT NULL,
  `media_type` ENUM('image', 'video', 'document') DEFAULT 'image',
  `url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT,
  `width` INT,
  `height` INT,
  `duration` INT NULL,
  `caption` VARCHAR(500),
  `caption_amharic` VARCHAR(500),
  `sort_order` INT DEFAULT 0,
  `is_primary` BOOLEAN DEFAULT FALSE,
  `is_approved` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_primary` (`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
010_create_ticket_types_table.sql

sql
-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- ============================================
CREATE TABLE IF NOT EXISTS `ticket_types` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `event_id` INT NOT NULL,
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
  `benefits` JSON,
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
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sales_dates` (`sales_start`, `sales_end`),
  INDEX `idx_price` (`price`),
  CONSTRAINT `chk_quantity` CHECK (`quantity` >= `sold_count` + `reserved_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
011_create_individual_tickets_table.sql

sql
-- ============================================
-- TABLE: individual_tickets
-- Purpose: Store individual ticket instances
-- ============================================
CREATE TABLE IF NOT EXISTS `individual_tickets` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_number` VARCHAR(50) UNIQUE NOT NULL,
  `ticket_type_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `purchase_price` DECIMAL(10,2) NOT NULL,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `platform_commission` DECIMAL(10,2) NOT NULL,
  `organizer_earning` DECIMAL(10,2) NOT NULL,
  `qr_data` TEXT NOT NULL,
  `qr_image_url` VARCHAR(500),
  `qr_secret_key` VARCHAR(100),
  `status` ENUM('reserved', 'paid', 'checked_in', 'cancelled', 'refunded', 'transferred') DEFAULT 'reserved',
  `checked_in_at` DATETIME NULL,
  `checked_in_by` INT NULL,
  `checkin_device_id` VARCHAR(100),
  `checkin_location` VARCHAR(255),
  `checkin_method` ENUM('qr_scan', 'manual', 'offline_sync') NULL,
  `transferred_at` DATETIME NULL,
  `transferred_to_user` INT NULL,
  `transfer_token` VARCHAR(100),
  `cancelled_at` DATETIME NULL,
  `cancelled_by` INT NULL,
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
  
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`),
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`),
  FOREIGN KEY (`transferred_to_user`) REFERENCES `users`(`id`),
  
  INDEX `idx_ticket_number` (`ticket_number`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_purchased` (`purchased_at`),
  INDEX `idx_checkin` (`checked_in_at`),
  INDEX `idx_qr_secret` (`qr_secret_key`),
  UNIQUE INDEX `idx_qr_data` (`qr_data`(100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
012_create_reservations_table.sql

sql
-- ============================================
-- TABLE: reservations
-- Purpose: Store temporary ticket reservations before payment
-- ============================================
CREATE TABLE IF NOT EXISTS `reservations` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `reservation_code` VARCHAR(20) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `ticket_type_id` INT NOT NULL,
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
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`),
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`),
  
  INDEX `idx_reservation_code` (`reservation_code`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status_expires` (`status`, `expires_at`),
  INDEX `idx_event` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
013_create_payment_methods_table.sql

sql
-- ============================================
-- TABLE: payment_methods
-- Purpose: Store available payment methods (Telebirr, CBE, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_methods` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
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
  `api_config` JSON,
  `webhook_url` VARCHAR(500) NULL,
  `icon` VARCHAR(255),
  `instructions` TEXT,
  `instructions_amharic` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_code` (`code`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
014_create_payments_table.sql

sql
-- ============================================
-- TABLE: payments
-- Purpose: Store payment transactions
-- ============================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `payment_reference` VARCHAR(100) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `reservation_id` INT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `platform_commission` DECIMAL(10,2) NOT NULL,
  `organizer_earning` DECIMAL(10,2) NOT NULL,
  `commission_rate` DECIMAL(5,2) NOT NULL,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `payment_method_id` INT NOT NULL,
  `payment_method_code` VARCHAR(50) NOT NULL,
  `transaction_id` VARCHAR(100),
  `external_reference` VARCHAR(100),
  `status` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
  `payment_status` ENUM('initiated', 'authorized', 'captured', 'declined', 'error') DEFAULT 'initiated',
  `requires_verification` BOOLEAN DEFAULT FALSE,
  `verified_by` INT NULL,
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
  `fraud_flags` JSON,
  `is_suspicious` BOOLEAN DEFAULT FALSE,
  `is_telebirr` BOOLEAN GENERATED ALWAYS AS (`payment_method_code` = 'telebirr') STORED,
  `is_cbe` BOOLEAN GENERATED ALWAYS AS (`payment_method_code` LIKE 'cbe%') STORED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`),
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`),
  FOREIGN KEY (`reservation_id`) REFERENCES `reservations`(`id`),
  FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods`(`id`),
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_payment_reference` (`payment_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment_method` (`payment_method_code`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_transaction` (`transaction_id`),
  INDEX `idx_requires_verification` (`requires_verification`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
015_create_payment_transactions_table.sql

sql
-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_transactions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `payment_id` INT NOT NULL,
  `transaction_type` ENUM('payment', 'refund', 'adjustment', 'fee') DEFAULT 'payment',
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `status` ENUM('initiated', 'pending', 'completed', 'failed', 'cancelled') DEFAULT 'initiated',
  `external_transaction_id` VARCHAR(100),
  `external_status` VARCHAR(50),
  `external_response` JSON,
  `request_data` JSON,
  `response_data` JSON,
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_external_id` (`external_transaction_id`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
016_create_payouts_table.sql

sql
-- ============================================
-- TABLE: payouts
-- Purpose: Store organizer payout records
-- ============================================
CREATE TABLE IF NOT EXISTS `payouts` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `payout_reference` VARCHAR(100) UNIQUE NOT NULL,
  `organizer_id` INT NOT NULL,
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
  `processed_by` INT NULL,
  `processing_notes` TEXT,
  `transfer_method` ENUM('cbe_online', 'cbe_branch', 'other_bank', 'telebirr') DEFAULT 'cbe_online',
  `transfer_reference` VARCHAR(100),
  `transfer_date` DATE NULL,
  `payment_ids` JSON,
  `tax_deducted` BOOLEAN DEFAULT FALSE,
  `tax_amount` DECIMAL(10,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`processed_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_payout_reference` (`payout_reference`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested` (`requested_at`),
  INDEX `idx_processed` (`processed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
017_create_payout_requests_table.sql

sql
-- ============================================
-- TABLE: payout_requests
-- Purpose: Store payout requests from organizers
-- ============================================
CREATE TABLE IF NOT EXISTS `payout_requests` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` INT NOT NULL,
  `requested_amount` DECIMAL(10,2) NOT NULL,
  `available_balance` DECIMAL(10,2) NOT NULL,
  `bank_name` VARCHAR(100),
  `bank_account` VARCHAR(100),
  `account_holder_name` VARCHAR(100),
  `status` ENUM('pending', 'approved', 'rejected', 'processing') DEFAULT 'pending',
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `reviewed_by` INT NULL,
  `review_notes` TEXT,
  `rejection_reason` TEXT,
  `payout_id` INT NULL,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`),
  FOREIGN KEY (`payout_id`) REFERENCES `payouts`(`id`),
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested` (`requested_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
018_create_commissions_table.sql

sql
-- ============================================
-- TABLE: commissions
-- Purpose: Store commission calculations for payments
-- ============================================
CREATE TABLE IF NOT EXISTS `commissions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `payment_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `ticket_amount` DECIMAL(10,2) NOT NULL,
  `commission_rate` DECIMAL(5,2) NOT NULL,
  `commission_amount` DECIMAL(10,2) NOT NULL,
  `organizer_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pending', 'held', 'released', 'paid') DEFAULT 'pending',
  `held_until` DATETIME NULL,
  `released_at` DATETIME NULL,
  `paid_at` DATETIME NULL,
  `payout_id` INT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`payout_id`) REFERENCES `payouts`(`id`),
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_event` (`event_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
019_create_refunds_table.sql

sql
-- ============================================
-- TABLE: refunds
-- Purpose: Store refund records
-- ============================================
CREATE TABLE IF NOT EXISTS `refunds` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `refund_reference` VARCHAR(100) UNIQUE NOT NULL,
  `ticket_id` INT NOT NULL,
  `payment_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `refund_amount` DECIMAL(10,2) NOT NULL,
  `refund_reason` ENUM('event_cancelled', 'customer_request', 'duplicate_payment', 'fraud', 'technical_issue', 'other') NOT NULL,
  `refund_reason_details` TEXT,
  `status` ENUM('requested', 'approved', 'rejected', 'processing', 'completed', 'failed') DEFAULT 'requested',
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `requested_by` INT NOT NULL,
  `approved_at` DATETIME NULL,
  `approved_by` INT NULL,
  `processed_at` DATETIME NULL,
  `processed_by` INT NULL,
  `refund_method` ENUM('original_method', 'telebirr', 'cbe_transfer', 'wallet_credit', 'other') DEFAULT 'original_method',
  `refund_transaction_id` VARCHAR(100),
  `commission_refunded` BOOLEAN DEFAULT FALSE,
  `commission_refund_amount` DECIMAL(10,2) DEFAULT 0.00,
  `requires_approval` BOOLEAN DEFAULT TRUE,
  `approval_level` ENUM('organizer', 'admin') DEFAULT 'organizer',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`requested_by`) REFERENCES `users`(`id`),
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`),
  FOREIGN KEY (`processed_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_refund_reference` (`refund_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested` (`requested_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
020_create_taxes_table.sql

sql
-- ============================================
-- TABLE: taxes
-- Purpose: Store tax information (VAT, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `taxes` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
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
  INDEX `idx_effective` (`effective_from`, `effective_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
021_create_financial_reports_table.sql

sql
-- ============================================
-- TABLE: financial_reports
-- Purpose: Store financial reports and analytics
-- ============================================
CREATE TABLE IF NOT EXISTS `financial_reports` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `report_type` ENUM('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom') NOT NULL,
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `total_tickets_sold` INT DEFAULT 0,
  `total_events` INT DEFAULT 0,
  `total_organizers` INT DEFAULT 0,
  `revenue_by_city` JSON,
  `revenue_by_category` JSON,
  `revenue_by_payment_method` JSON,
  `platform_commission` DECIMAL(15,2) DEFAULT 0.00,
  `platform_fees` DECIMAL(15,2) DEFAULT 0.00,
  `total_vat_collected` DECIMAL(15,2) DEFAULT 0.00,
  `total_payouts` DECIMAL(15,2) DEFAULT 0.00,
  `payouts_by_organizer` JSON,
  `report_currency` VARCHAR(3) DEFAULT 'ETB',
  `exchange_rate` DECIMAL(10,4) DEFAULT 1.0000,
  `status` ENUM('generating', 'completed', 'failed') DEFAULT 'generating',
  `generated_at` DATETIME NULL,
  `generated_by` INT NULL,
  `report_file_url` VARCHAR(500),
  `report_data` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`generated_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_report_type` (`report_type`),
  INDEX `idx_period` (`period_start`, `period_end`),
  INDEX `idx_generated` (`generated_at`),
  UNIQUE INDEX `idx_period_type` (`report_type`, `period_start`, `period_end`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
022_create_notifications_table.sql

sql
-- ============================================
-- TABLE: notifications
-- Purpose: Store user notifications
-- ============================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
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
  `related_id` INT,
  `related_type` VARCHAR(50),
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `read_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

023_create_sms_logs_table.sql

sql
-- ============================================
-- TABLE: sms_logs
-- Purpose: Store SMS delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `sms_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `recipient_phone` VARCHAR(20) NOT NULL,
  `recipient_name` VARCHAR(100),
  `message_type` ENUM('otp', 'payment_confirmation', 'ticket_delivery', 'event_reminder', 'promotional', 'system') NOT NULL,
  `message_text` TEXT NOT NULL,
  `message_text_amharic` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'expired') DEFAULT 'pending',
  `message_id` VARCHAR(100),
  `delivery_report` JSON,
  `cost` DECIMAL(10,2) DEFAULT 0.00,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `segments` INT DEFAULT 1,
  `related_id` INT,
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
  INDEX `idx_sent` (`sent_at`),
  INDEX `idx_gateway` (`gateway`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
024_create_email_logs_table.sql

sql
-- ============================================
-- TABLE: email_logs
-- Purpose: Store email delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `email_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `recipient_email` VARCHAR(100) NOT NULL,
  `recipient_name` VARCHAR(100),
  `subject` VARCHAR(200) NOT NULL,
  `template_name` VARCHAR(100),
  `language` ENUM('am', 'en') DEFAULT 'en',
  `status` ENUM('pending', 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'failed') DEFAULT 'pending',
  `message_id` VARCHAR(200),
  `delivery_report` JSON,
  `body_html` TEXT,
  `body_text` TEXT,
  `related_id` INT,
  `related_type` VARCHAR(50),
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `opened_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_recipient` (`recipient_email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent` (`sent_at`),
  INDEX `idx_template` (`template_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
025_create_push_notifications_table.sql

sql
-- ============================================
-- TABLE: push_notifications
-- Purpose: Store push notification logs
-- ============================================
CREATE TABLE IF NOT EXISTS `push_notifications` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `device_token` VARCHAR(255) NOT NULL,
  `device_type` ENUM('ios', 'android', 'web') NOT NULL,
  `app_version` VARCHAR(20),
  `title` VARCHAR(200) NOT NULL,
  `body` TEXT NOT NULL,
  `data` JSON,
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'device_not_registered') DEFAULT 'pending',
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `failure_reason` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_device_token` (`device_token`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
026_create_notification_templates_table.sql

sql
-- ============================================
-- TABLE: notification_templates
-- Purpose: Store notification templates
-- ============================================
CREATE TABLE IF NOT EXISTS `notification_templates` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `template_type` ENUM('sms', 'email', 'push', 'in_app') NOT NULL,
  `template_code` VARCHAR(100) UNIQUE NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `subject` VARCHAR(200),
  `body_template` TEXT NOT NULL,
  `body_template_amharic` TEXT,
  `variables` JSON,
  `is_active` BOOLEAN DEFAULT TRUE,
  `priority` INT DEFAULT 0,
  `default_language` ENUM('am', 'en') DEFAULT 'am',
  `requires_translation` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_template_code` (`template_code`),
  INDEX `idx_template_type` (`template_type`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
027_create_message_threads_table.sql

sql
-- ============================================
-- TABLE: message_threads
-- Purpose: Store message threads between users, organizers, and admins
-- ============================================
CREATE TABLE IF NOT EXISTS `message_threads` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `organizer_id` INT NULL,
  `admin_id` INT NULL,
  `subject` VARCHAR(200) NOT NULL,
  `related_event_id` INT NULL,
  `related_ticket_id` INT NULL,
  `status` ENUM('open', 'waiting_reply', 'resolved', 'closed') DEFAULT 'open',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `last_message_at` DATETIME NULL,
  `last_message_by` INT NULL,
  `message_count` INT DEFAULT 0,
  `unread_count_user` INT DEFAULT 0,
  `unread_count_admin` INT DEFAULT 0,
  `unread_count_organizer` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` DATETIME NULL,
  `closed_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`related_event_id`) REFERENCES `events`(`id`),
  FOREIGN KEY (`related_ticket_id`) REFERENCES `individual_tickets`(`id`),
  FOREIGN KEY (`last_message_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_last_message` (`last_message_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
028_create_disputes_table.sql

sql
-- ============================================
-- TABLE: disputes
-- Purpose: Store dispute records between users and organizers
-- ============================================
CREATE TABLE IF NOT EXISTS `disputes` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `dispute_reference` VARCHAR(100) UNIQUE NOT NULL,
  `user_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `ticket_id` INT NULL,
  `payment_id` INT NULL,
  `type` ENUM('refund_request', 'event_cancelled', 'ticket_not_valid', 'organizer_no_show', 'event_different', 'fraud', 'technical_issue', 'other') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `desired_outcome` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'apology', 'other') NOT NULL,
  `status` ENUM('open', 'under_review', 'awaiting_response', 'resolved', 'closed', 'escalated') DEFAULT 'open',
  `resolution` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'organizer_penalty', 'rejected', 'other') NULL,
  `resolution_amount` DECIMAL(10,2) NULL,
  `resolution_details` TEXT,
  `assigned_to` INT NULL,
  `assigned_at` DATETIME NULL,
  `resolved_at` DATETIME NULL,
  `resolved_by` INT NULL,
  `closed_at` DATETIME NULL,
  `requires_mediation` BOOLEAN DEFAULT FALSE,
  `mediation_notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`),
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`),
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`),
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_dispute_reference` (`dispute_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_assigned` (`assigned_to`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
029_create_dispute_messages_table.sql

sql
-- ============================================
-- TABLE: dispute_messages
-- Purpose: Store messages within disputes
-- ============================================
CREATE TABLE IF NOT EXISTS `dispute_messages` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `dispute_id` INT NOT NULL,
  `sender_id` INT NOT NULL,
  `sender_type` ENUM('user', 'organizer', 'admin') NOT NULL,
  `message` TEXT NOT NULL,
  `attachments` JSON,
  `is_internal` BOOLEAN DEFAULT FALSE,
  `is_read` BOOLEAN DEFAULT FALSE,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `read_at` DATETIME NULL,
  
  FOREIGN KEY (`dispute_id`) REFERENCES `disputes`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`sender_id`) REFERENCES `users`(`id`),
  
  INDEX `idx_dispute` (`dispute_id`),
  INDEX `idx_sender` (`sender_id`, `sender_type`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
030_create_audit_logs_table.sql

sql
-- ============================================
-- TABLE: audit_logs
-- Purpose: Store audit trail for important actions
-- ============================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NULL,
  `user_type` ENUM('customer', 'organizer', 'admin', 'system') NULL,
  `action` VARCHAR(100) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` INT NOT NULL,
  `old_values` JSON,
  `new_values` JSON,
  `changed_fields` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `device_id` VARCHAR(255),
  `session_id` VARCHAR(100),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
031_create_activity_logs_table.sql

sql
-- ============================================
-- TABLE: activity_logs
-- Purpose: Store user activity logs
-- ============================================
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `activity_type` ENUM('login', 'logout', 'page_view', 'search', 'ticket_purchase', 'event_view', 'profile_update', 'payment_attempt', 'checkin') NOT NULL,
  `activity_details` TEXT,
  `page_url` VARCHAR(500),
  `referrer_url` VARCHAR(500),
  `device_type` ENUM('mobile', 'tablet', 'desktop') DEFAULT 'mobile',
  `browser` VARCHAR(100),
  `os` VARCHAR(100),
  `city_id` INT NULL,
  `estimated_location` VARCHAR(255),
  `load_time_ms` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`),
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_activity_type` (`activity_type`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_city` (`city_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
032_create_checkin_logs_table.sql

sql
-- ============================================
-- TABLE: checkin_logs
-- Purpose: Store ticket check-in logs
-- ============================================
CREATE TABLE IF NOT EXISTS `checkin_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` INT NOT NULL,
  `event_id` INT NOT NULL,
  `organizer_id` INT NOT NULL,
  `checked_in_by` INT NOT NULL,
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
  
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_ticket` (`ticket_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_checkin_time` (`checkin_time`),
  INDEX `idx_sync_status` (`sync_status`),
  UNIQUE INDEX `idx_ticket_checkin` (`ticket_id`, `checkin_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
033_create_offline_sync_logs_table.sql

sql
-- ============================================
-- TABLE: offline_sync_logs
-- Purpose: Store offline sync logs
-- ============================================
CREATE TABLE IF NOT EXISTS `offline_sync_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `device_id` VARCHAR(255) NOT NULL,
  `user_id` INT NOT NULL,
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
  `city_id` INT NULL,
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`),
  
  INDEX `idx_device` (`device_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_started` (`started_at`),
  INDEX `idx_sync_type` (`sync_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
034_create_admin_actions_table.sql

sql
-- ============================================
-- TABLE: admin_actions
-- Purpose: Store admin action logs
-- ============================================
CREATE TABLE IF NOT EXISTS `admin_actions` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `admin_id` INT NOT NULL,
  `action_type` ENUM('payment_verification', 'payout_processing', 'organizer_approval', 'event_moderation', 'user_management', 'dispute_resolution', 'system_config', 'data_export', 'other') NOT NULL,
  `action_details` TEXT NOT NULL,
  `target_type` VARCHAR(50),
  `target_id` INT,
  `changes_made` JSON,
  `requires_approval` BOOLEAN DEFAULT FALSE,
  `approved_by` INT NULL,
  `approved_at` DATETIME NULL,
  `approval_notes` TEXT,
  `performed_at_local` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_admin` (`admin_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_target` (`target_type`, `target_id`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_approval` (`requires_approval`, `approved_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
035_create_system_settings_table.sql

sql
-- ============================================
-- TABLE: system_settings
-- Purpose: Store system configuration settings
-- ============================================
CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `category` VARCHAR(100) NOT NULL,
  `setting_key` VARCHAR(100) UNIQUE NOT NULL,
  `setting_value` TEXT,
  `setting_type` ENUM('string', 'number', 'boolean', 'json', 'array') DEFAULT 'string',
  `label` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `is_public` BOOLEAN DEFAULT FALSE,
  `is_editable` BOOLEAN DEFAULT TRUE,
  `applies_to_country` VARCHAR(3) DEFAULT 'ET',
  `regional_variations` JSON,
  `validation_rules` JSON,
  `options` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` INT NULL,
  
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_category` (`category`),
  INDEX `idx_setting_key` (`setting_key`),
  INDEX `idx_is_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
036_create_event_media_files_table.sql

sql
-- ============================================
-- TABLE: event_media_files
-- Purpose: Store event media files
-- ============================================
CREATE TABLE IF NOT EXISTS `event_media_files` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `event_id` INT NOT NULL,
  `media_type` ENUM('image', 'video', 'document', 'banner', 'thumbnail') DEFAULT 'image',
  `file_url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT,
  `width` INT,
  `height` INT,
  `duration` INT NULL,
  `title` VARCHAR(200),
  `description` TEXT,
  `alt_text` VARCHAR(500),
  `credits` VARCHAR(200),
  `is_approved` BOOLEAN DEFAULT TRUE,
  `is_primary` BOOLEAN DEFAULT FALSE,
  `sort_order` INT DEFAULT 0,
  `language` ENUM('am', 'en', 'both') DEFAULT 'both',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_is_primary` (`is_primary`),
  INDEX `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
037_create_organizer_documents_table.sql

sql
-- ============================================
-- TABLE: organizer_documents
-- Purpose: Store organizer documents
-- ============================================
CREATE TABLE IF NOT EXISTS `organizer_documents` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` INT NOT NULL,
  `document_type` ENUM('business_license', 'tin_certificate', 'id_card_front', 'id_card_back', 'tax_clearance', 'bank_letter', 'other') NOT NULL,
  `document_name` VARCHAR(200) NOT NULL,
  `file_url` VARCHAR(500) NOT NULL,
  `mime_type` VARCHAR(100),
  `file_size` INT,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `verified_by` INT NULL,
  `verified_at` DATETIME NULL,
  `verification_notes` TEXT,
  `document_number` VARCHAR(100),
  `issued_by` VARCHAR(200),
  `issue_date` DATE NULL,
  `expiry_date` DATE NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_document_type` (`document_type`),
  INDEX `idx_is_verified` (`is_verified`),
  INDEX `idx_expiry` (`expiry_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
038_create_payment_receipts_table.sql

sql
-- ============================================
-- TABLE: payment_receipts
-- Purpose: Store payment receipt uploads
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_receipts` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `payment_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `receipt_type` ENUM('cbe_screenshot', 'bank_slip', 'telebirr_screenshot', 'other') DEFAULT 'cbe_screenshot',
  `image_url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `bank_name` VARCHAR(100),
  `account_number` VARCHAR(100),
  `transaction_id` VARCHAR(100),
  `amount` DECIMAL(10,2),
  `transaction_date` DATE,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `verified_by` INT NULL,
  `verified_at` DATETIME NULL,
  `verification_status` ENUM('pending', 'approved', 'rejected', 'needs_clarification') DEFAULT 'pending',
  `verification_notes` TEXT,
  `bank_branch` VARCHAR(100),
  `teller_number` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`),
  
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_verification_status` (`verification_status`),
  INDEX `idx_receipt_type` (`receipt_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
039_create_user_uploads_table.sql

sql
-- ============================================
-- TABLE: user_uploads
-- Purpose: Store user uploads
-- ============================================
CREATE TABLE IF NOT EXISTS `user_uploads` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `upload_type` ENUM('profile_picture', 'id_document', 'payment_receipt', 'event_image', 'support_attachment', 'other') NOT NULL,
  `file_url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `original_filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT,
  `title` VARCHAR(200),
  `description` TEXT,
  `is_public` BOOLEAN DEFAULT FALSE,
  `access_token` VARCHAR(100),
  `requires_verification` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_upload_type` (`upload_type`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
040_create_webhook_logs_table.sql

sql
-- ============================================
-- TABLE: webhook_logs
-- Purpose: Store webhook logs
-- ============================================
CREATE TABLE IF NOT EXISTS `webhook_logs` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `webhook_type` ENUM('telebirr_payment', 'sms_delivery', 'email_delivery', 'third_party', 'custom') NOT NULL,
  `endpoint_url` VARCHAR(500) NOT NULL,
  `request_headers` JSON,
  `request_body` TEXT,
  `request_method` VARCHAR(10) DEFAULT 'POST',
  `response_status` INT,
  `response_headers` JSON,
  `response_body` TEXT,
  `response_time_ms` INT,
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'retrying') DEFAULT 'pending',
  `retry_count` INT DEFAULT 0,
  `error_message` TEXT,
  `next_retry_at` DATETIME NULL,
  `related_id` INT,
  `related_type` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  
  INDEX `idx_webhook_type` (`webhook_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created` (`created_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_next_retry` (`next_retry_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
041_create_api_keys_table.sql

sql
-- ============================================
-- TABLE: api_keys
-- Purpose: Store API keys
-- ============================================
CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `api_key` VARCHAR(100) UNIQUE NOT NULL,
  `api_secret` VARCHAR(255) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `user_id` INT NULL,
  `organizer_id` INT NULL,
  `permissions` JSON,
  `is_active` BOOLEAN DEFAULT TRUE,
  `rate_limit_per_minute` INT DEFAULT 60,
  `last_used_at` DATETIME NULL,
  `usage_count` INT DEFAULT 0,
  `ip_whitelist` JSON,
  `expires_at` DATETIME NULL,
  `allowed_for_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`),
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`),
  
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
042_create_qr_codes_table.sql

sql
-- ============================================
-- TABLE: qr_codes
-- Purpose: Store QR code data
-- ============================================
CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `qr_data` TEXT NOT NULL,
  `qr_hash` VARCHAR(64) UNIQUE NOT NULL,
  `qr_image_url` VARCHAR(500),
  `entity_type` ENUM('ticket', 'event', 'organizer', 'user', 'payment') NOT NULL,
  `entity_id` INT NOT NULL,
  `scan_count` INT DEFAULT 0,
  `last_scanned_at` DATETIME NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `expires_at` DATETIME NULL,
  `generated_in_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
043_create_session_tokens_table.sql

sql
-- ============================================
-- TABLE: session_tokens
-- Purpose: Store user session tokens
-- ============================================
CREATE TABLE IF NOT EXISTS `session_tokens` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `token` VARCHAR(512) UNIQUE NOT NULL,
  `refresh_token` VARCHAR(255) UNIQUE NOT NULL,
  `token_type` ENUM('access', 'refresh', 'device') DEFAULT 'access',
  `device_id` VARCHAR(255) NOT NULL,
  `device_name` VARCHAR(100),
  `device_type` ENUM('mobile', 'tablet', 'desktop', 'unknown') DEFAULT 'mobile',
  `os` VARCHAR(50),
  `browser` VARCHAR(50),
  `ip_address` VARCHAR(45),
  `city_id` INT NULL,
  `country_code` VARCHAR(3) DEFAULT 'ET',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_blacklisted` BOOLEAN DEFAULT FALSE,
  `expires_at` DATETIME NOT NULL,
  `refresh_expires_at` DATETIME NOT NULL,
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_used_at` DATETIME NULL,
  `revoked_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`),
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_token` (`token`),
  INDEX `idx_refresh_token` (`refresh_token`),
  INDEX `idx_device` (`device_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
044_create_ethiopian_holidays_table.sql

sql
-- ============================================
-- TABLE: ethiopian_holidays
-- Purpose: Store Ethiopian holiday calendar
-- ============================================
CREATE TABLE IF NOT EXISTS `ethiopian_holidays` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
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
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;