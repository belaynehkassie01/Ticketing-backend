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
