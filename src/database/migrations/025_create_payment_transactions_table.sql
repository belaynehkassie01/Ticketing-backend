-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_transactions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `transaction_type` ENUM('payment', 'refund', 'adjustment', 'fee') DEFAULT 'payment',
  `amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `status` ENUM('initiated', 'pending', 'completed', 'failed', 'cancelled') DEFAULT 'initiated',
  `external_transaction_id` VARCHAR(100),
  `external_status` VARCHAR(50),
  `external_response` JSON COMMENT 'Raw response from payment gateway',
  `request_data` JSON COMMENT 'Request data sent to gateway',
  `response_data` JSON COMMENT 'Response data from gateway',
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` DATETIME NULL,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_external_id` (`external_transaction_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_transaction_type` (`transaction_type`),
  INDEX `idx_completed_at` (`completed_at`),
  
  CONSTRAINT `chk_amount_non_zero` CHECK (`amount` != 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;