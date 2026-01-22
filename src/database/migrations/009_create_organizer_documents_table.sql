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