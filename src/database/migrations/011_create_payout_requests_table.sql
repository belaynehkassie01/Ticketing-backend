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