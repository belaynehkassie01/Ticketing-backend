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