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