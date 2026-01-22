-- ============================================
-- TABLE: payment_methods
-- Purpose: Store available payment methods (Telebirr, CBE, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `payment_methods` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `code` VARCHAR(50) UNIQUE NOT NULL,
  `type` ENUM('mobile_money', 'bank_transfer', 'card', 'cash') NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_default` BOOLEAN DEFAULT FALSE,
  `sort_order` INT DEFAULT 0,
  `min_amount` DECIMAL(10,2) DEFAULT 0.00,
  `max_amount` DECIMAL(10,2) DEFAULT 100000.00,
  `bank_name` VARCHAR(100) NULL,
  `account_number` VARCHAR(100) NULL,
  `account_name` VARCHAR(200) NULL,
  `qr_supported` BOOLEAN DEFAULT FALSE,
  `has_fee` BOOLEAN DEFAULT FALSE,
  `fee_type` ENUM('percentage', 'fixed', 'both') DEFAULT 'percentage',
  `fee_percentage` DECIMAL(5,2) DEFAULT 0.00,
  `fee_fixed` DECIMAL(10,2) DEFAULT 0.00,
  `api_config` JSON COMMENT 'Payment gateway configuration',
  `webhook_url` VARCHAR(500) NULL,
  `icon` VARCHAR(255),
  `instructions` TEXT,
  `instructions_amharic` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_code` (`code`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_type` (`type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_default` (`is_default`),
  
  CONSTRAINT `chk_min_max_amount` CHECK (`max_amount` >= `min_amount`),
  CONSTRAINT `chk_fee_percentage` CHECK (`fee_percentage` >= 0 AND `fee_percentage` <= 100),
  CONSTRAINT `chk_fee_fixed` CHECK (`fee_fixed` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;