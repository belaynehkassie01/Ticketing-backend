-- ============================================
-- TABLE: taxes
-- Purpose: Store tax information (VAT, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS `taxes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `tax_type` ENUM('vat', 'income_tax', 'withholding_tax', 'other') DEFAULT 'vat',
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `rate` DECIMAL(5,2) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `effective_from` DATE NOT NULL,
  `effective_to` DATE NULL,
  `applies_to_tickets` BOOLEAN DEFAULT TRUE,
  `applies_to_commission` BOOLEAN DEFAULT FALSE,
  `applies_to_fees` BOOLEAN DEFAULT FALSE,
  `tax_authority` VARCHAR(200),
  `authority_code` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_tax_type` (`tax_type`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_effective` (`effective_from`, `effective_to`),
  UNIQUE INDEX `uq_tax_type_effective` (`tax_type`, `effective_from`),
  
  CONSTRAINT `chk_tax_rate` CHECK (`rate` >= 0 AND `rate` <= 100),
  CONSTRAINT `chk_effective_dates` CHECK (`effective_to` IS NULL OR `effective_to` > `effective_from`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;