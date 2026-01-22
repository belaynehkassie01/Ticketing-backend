-- ============================================
-- TABLE: email_logs
-- Purpose: Store email delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `email_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `recipient_email` VARCHAR(100) NOT NULL,
  `recipient_name` VARCHAR(100),
  `subject` VARCHAR(200) NOT NULL,
  `template_name` VARCHAR(100),
  `language` ENUM('am', 'en') DEFAULT 'en',
  `status` ENUM('pending', 'sent', 'delivered', 'opened', 'clicked', 'bounced', 'failed') DEFAULT 'pending',
  `message_id` VARCHAR(200),
  `delivery_report` JSON COMMENT 'Email service delivery report',
  `body_html` TEXT,
  `body_text` TEXT,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `opened_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_recipient` (`recipient_email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_template` (`template_name`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_email_format` CHECK (`recipient_email` REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;