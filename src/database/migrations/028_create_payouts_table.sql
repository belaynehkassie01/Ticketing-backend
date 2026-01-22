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