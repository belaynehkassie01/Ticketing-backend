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