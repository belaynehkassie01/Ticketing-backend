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