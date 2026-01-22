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