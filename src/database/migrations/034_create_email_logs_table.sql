-- Migration: 034_create_email_logs_table.sql
-- Purpose: Store email delivery logs with Ethiopian localization support

CREATE TABLE IF NOT EXISTS `email_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Email identification
  `email_id` VARCHAR(200) UNIQUE NOT NULL COMMENT 'Internal email ID',
  `provider_message_id` VARCHAR(200) NULL COMMENT 'External provider message ID',
  
  -- Recipient info
  `recipient_email` VARCHAR(100) NOT NULL,
  `recipient_name` VARCHAR(100),
  `recipient_user_id` BIGINT UNSIGNED NULL,
  
  -- Email content
  `email_type` VARCHAR(50) NOT NULL COMMENT 'payment_confirmation, ticket_delivery, event_reminder, promotional, system, otp, welcome, password_reset',
  `template_id` VARCHAR(100) NULL,
  `template_version` VARCHAR(20) NULL,
  `subject` VARCHAR(200) NOT NULL,
  `subject_amharic` VARCHAR(200),
  `language` ENUM('am', 'en') DEFAULT 'en',
  `variables` JSON COMMENT 'Template variables replaced',
  
  -- Email provider
  `provider` VARCHAR(50) DEFAULT 'smtp' COMMENT 'smtp, sendgrid, mailgun, aws_ses, ethio_telecom_email',
  `sender_email` VARCHAR(100) NOT NULL,
  `sender_name` VARCHAR(100) NOT NULL,
  `reply_to` VARCHAR(100) NULL,
  
  -- Delivery tracking
  `status` VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, opened, clicked, bounced, failed, spam_reported',
  `delivery_report` JSON COMMENT 'Full delivery report from provider',
  `attempt_count` INT DEFAULT 1,
  `last_attempt_at` DATETIME NULL,
  `error_code` VARCHAR(50),
  `error_message` TEXT,
  
  -- Engagement tracking
  `open_count` INT DEFAULT 0,
  `click_count` INT DEFAULT 0,
  `first_opened_at` DATETIME NULL,
  `last_opened_at` DATETIME NULL,
  `first_clicked_at` DATETIME NULL,
  `last_clicked_at` DATETIME NULL,
  `unsubscribe_clicked` BOOLEAN DEFAULT FALSE,
  `spam_reported` BOOLEAN DEFAULT FALSE,
  
  -- Timing
  `scheduled_for` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `bounced_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  
  -- Related entities
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `notification_id` BIGINT UNSIGNED NULL,
  
  -- Ethiopian context
  `city_id` BIGINT UNSIGNED NULL,
  `recipient_timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  
  -- Cost tracking
  `email_cost` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'Cost in ETB',
  `is_billed` BOOLEAN DEFAULT FALSE,
  
  -- Metadata
  `metadata` JSON,
  `audit_trail` JSON,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (`recipient_user_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`notification_id`) REFERENCES `notifications`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_email_id` (`email_id`),
  INDEX `idx_recipient_email` (`recipient_email`),
  INDEX `idx_recipient_user` (`recipient_user_id`),
  INDEX `idx_email_type` (`email_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_provider` (`provider`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  INDEX `idx_template_id` (`template_id`),
  
  -- Business constraints
  CONSTRAINT `chk_email_format` CHECK (`recipient_email` REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
  CONSTRAINT `chk_cost_non_negative` CHECK (`email_cost` >= 0)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Email delivery logs with Ethiopian localization and engagement tracking';