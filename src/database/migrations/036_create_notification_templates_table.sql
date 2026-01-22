-- ============================================
-- TABLE: notification_templates
-- Purpose: Store notification templates
-- ============================================
CREATE TABLE IF NOT EXISTS `notification_templates` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `template_type` ENUM('sms', 'email', 'push', 'in_app') NOT NULL,
  `template_code` VARCHAR(100) UNIQUE NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `subject` VARCHAR(200),
  `body_template` TEXT NOT NULL,
  `body_template_amharic` TEXT,
  `variables` JSON COMMENT 'Array of template variable names',
  `is_active` BOOLEAN DEFAULT TRUE,
  `priority` INT DEFAULT 0,
  `default_language` ENUM('am', 'en') DEFAULT 'am',
  `requires_translation` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_template_code` (`template_code`),
  INDEX `idx_template_type` (`template_type`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_default_language` (`default_language`),
  INDEX `idx_requires_translation` (`requires_translation`),
  
  CONSTRAINT `chk_priority` CHECK (`priority` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;