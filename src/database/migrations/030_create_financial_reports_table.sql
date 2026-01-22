-- ============================================
-- TABLE: financial_reports
-- Purpose: Store financial reports and analytics
-- ============================================
CREATE TABLE IF NOT EXISTS `financial_reports` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `report_type` ENUM('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom') NOT NULL,
  `period_start` DATE NOT NULL,
  `period_end` DATE NOT NULL,
  `total_revenue` DECIMAL(15,2) DEFAULT 0.00,
  `total_tickets_sold` INT DEFAULT 0,
  `total_events` INT DEFAULT 0,
  `total_organizers` INT DEFAULT 0,
  `revenue_by_city` JSON COMMENT 'City-wise revenue breakdown',
  `revenue_by_category` JSON COMMENT 'Category-wise revenue breakdown',
  `revenue_by_payment_method` JSON COMMENT 'Payment method-wise revenue breakdown',
  `platform_commission` DECIMAL(15,2) DEFAULT 0.00,
  `platform_fees` DECIMAL(15,2) DEFAULT 0.00,
  `total_vat_collected` DECIMAL(15,2) DEFAULT 0.00,
  `total_payouts` DECIMAL(15,2) DEFAULT 0.00,
  `payouts_by_organizer` JSON COMMENT 'Organizer-wise payout breakdown',
  `report_currency` VARCHAR(3) DEFAULT 'ETB',
  `exchange_rate` DECIMAL(10,4) DEFAULT 1.0000,
  `status` ENUM('generating', 'completed', 'failed') DEFAULT 'generating',
  `generated_at` DATETIME NULL,
  `generated_by` BIGINT UNSIGNED NULL,
  `report_file_url` VARCHAR(500),
  `report_data` JSON COMMENT 'Complete report data in JSON format',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`generated_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_report_type` (`report_type`),
  INDEX `idx_period` (`period_start`, `period_end`),
  INDEX `idx_generated_at` (`generated_at`),
  INDEX `idx_generated_by` (`generated_by`),
  INDEX `idx_status` (`status`),
  UNIQUE INDEX `idx_period_type` (`report_type`, `period_start`, `period_end`),
  
  CONSTRAINT `chk_period` CHECK (`period_end` >= `period_start`),
  CONSTRAINT `chk_exchange_rate` CHECK (`exchange_rate` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;