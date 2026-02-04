-- Migration: 029_1_create_tax_transactions_table.sql
-- Purpose: Track all tax transactions for Ethiopian compliance

CREATE TABLE IF NOT EXISTS `tax_transactions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Transaction identification
  `transaction_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'TAX-ET-2024-001',
  `tax_id` BIGINT UNSIGNED NOT NULL COMMENT 'Reference to taxes table',
  
  -- Transaction details
  `transaction_type` VARCHAR(30) NOT NULL COMMENT 'vat_collection, vat_payment, withholding_collection, withholding_payment, penalty, adjustment',
  `entity_type` VARCHAR(50) NOT NULL COMMENT 'ticket_sale, commission_fee, payout, expense, adjustment',
  `entity_id` BIGINT UNSIGNED NOT NULL,
  
  -- Financial details (ETB)
  `base_amount` DECIMAL(15,2) NOT NULL COMMENT 'Amount before tax',
  `tax_rate` DECIMAL(5,2) NOT NULL,
  `tax_amount` DECIMAL(15,2) NOT NULL,
  `total_amount` DECIMAL(15,2) NOT NULL COMMENT 'base_amount + tax_amount',
  `currency` VARCHAR(3) DEFAULT 'ETB',
  
  -- Ethiopian compliance
  `tax_authority` VARCHAR(30) DEFAULT 'erca' COMMENT 'erca, regional_revenue, city_administration',
  `tax_period` VARCHAR(20) COMMENT 'YYYY-MM for reporting',
  `is_deductible` BOOLEAN DEFAULT TRUE COMMENT 'For input VAT',
  
  -- Status
  `status` VARCHAR(30) DEFAULT 'pending' COMMENT 'pending, calculated, due, paid, overdue, waived',
  `payment_status` VARCHAR(30) DEFAULT 'unpaid' COMMENT 'unpaid, partially_paid, paid, refunded',
  
  -- Dates
  `transaction_date` DATE NOT NULL,
  `due_date` DATE NULL,
  `paid_date` DATE NULL,
  `reported_date` DATE NULL,
  
  -- Payment reference
  `payment_reference` VARCHAR(100) NULL,
  `bank_transaction_id` VARCHAR(100) NULL,
  
  -- Related entities
  `related_payment_id` BIGINT UNSIGNED NULL,
  `related_payout_id` BIGINT UNSIGNED NULL,
  `related_refund_id` BIGINT UNSIGNED NULL,
  
  -- Audit
  `created_by` BIGINT UNSIGNED NOT NULL,
  `updated_by` BIGINT UNSIGNED NULL,
  `audit_trail` JSON,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`tax_id`) REFERENCES `taxes`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_payout_id`) REFERENCES `payouts`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_refund_id`) REFERENCES `refunds`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`updated_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_transaction_code` (`transaction_code`),
  INDEX `idx_tax_id` (`tax_id`),
  INDEX `idx_transaction_type` (`transaction_type`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment_status` (`payment_status`),
  INDEX `idx_transaction_date` (`transaction_date`),
  INDEX `idx_due_date` (`due_date`),
  INDEX `idx_tax_period` (`tax_period`),
  INDEX `idx_tax_authority` (`tax_authority`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Business key
  UNIQUE KEY `uq_tax_entity` (`entity_type`, `entity_id`, `transaction_type`, `deleted_at`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;