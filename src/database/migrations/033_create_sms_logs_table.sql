-- ============================================
-- TABLE: sms_logs
-- Purpose: Store SMS delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS `sms_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `recipient_phone` VARCHAR(20) NOT NULL,
  `recipient_name` VARCHAR(100),
  `message_type` ENUM('otp', 'payment_confirmation', 'ticket_delivery', 'event_reminder', 'promotional', 'system') NOT NULL,
  `message_text` TEXT NOT NULL,
  `message_text_amharic` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'expired') DEFAULT 'pending',
  `message_id` VARCHAR(100),
  `delivery_report` JSON COMMENT 'SMS gateway delivery report',
  `cost` DECIMAL(10,2) DEFAULT 0.00,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `segments` INT DEFAULT 1,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `gateway` VARCHAR(50) DEFAULT 'ethio_telecom',
  `route` VARCHAR(50),
  `scheduled_at` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_recipient` (`recipient_phone`),
  INDEX `idx_status` (`status`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_gateway` (`gateway`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_segments` CHECK (`segments` > 0),
  CONSTRAINT `chk_cost` CHECK (`cost` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;