-- Migration: 033_create_sms_logs_table.sql
-- Purpose: Store Ethiopian SMS delivery logs (Ethio Telecom integration)

CREATE TABLE IF NOT EXISTS `sms_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- SMS identification
  `sms_id` VARCHAR(100) UNIQUE NOT NULL COMMENT 'Internal message ID',
  `provider_message_id` VARCHAR(200) NULL COMMENT 'External provider ID',
  
  -- Recipient info (Ethiopian format)
  `recipient_phone` VARCHAR(20) NOT NULL COMMENT '0912345678 or +251912345678',
  `recipient_name` VARCHAR(100),
  `recipient_user_id` BIGINT UNSIGNED NULL,
  
  -- SMS content
  `message_type` VARCHAR(50) NOT NULL COMMENT 'otp, payment_confirmation, ticket_delivery, event_reminder, promotional, system, dispute_update',
  `template_id` VARCHAR(100) NULL,
  `message_text` TEXT NOT NULL,
  `message_text_amharic` TEXT,
  `language` ENUM('am', 'en', 'or', 'ti', 'so') DEFAULT 'am',
  `unicode` BOOLEAN DEFAULT FALSE COMMENT 'For Amharic/Unicode characters',
  `character_count` INT,
  `segments` INT DEFAULT 1,
  
  -- Ethiopian SMS provider
  `gateway` VARCHAR(50) DEFAULT 'ethio_telecom' COMMENT 'ethio_telecom, awash_sms, cbe_sms, other',
  `route` VARCHAR(50) DEFAULT 'transactional' COMMENT 'transactional, promotional',
  `sender_id` VARCHAR(20) DEFAULT 'ET-TICKETS',
  `gateway_account` VARCHAR(100) NULL COMMENT 'Which account/API key used',
  
  -- Delivery tracking
  `status` VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, expired, rejected',
  `delivery_status` VARCHAR(100) NULL COMMENT 'Provider delivery status',
  `delivery_report` JSON COMMENT 'Full delivery report from gateway',
  `attempt_count` INT DEFAULT 1,
  `last_attempt_at` DATETIME NULL,
  `error_code` VARCHAR(50),
  `error_message` TEXT,
  
  -- Costs and billing (Ethiopian pricing)
  `cost_per_sms` DECIMAL(10,2) DEFAULT 0.10 COMMENT 'Cost in ETB per SMS',
  `total_cost` DECIMAL(10,2) DEFAULT 0.10,
  `billing_month` VARCHAR(7) NULL COMMENT 'YYYY-MM for billing reconciliation',
  `is_billed` BOOLEAN DEFAULT FALSE,
  
  -- Ethiopian network information
  `city_id` BIGINT UNSIGNED NULL,
  `region` VARCHAR(100) NULL,
  `network_operator` VARCHAR(50) NULL COMMENT 'Ethio Telecom, Safaricom Ethiopia, etc.',
  `network_type` VARCHAR(20) NULL COMMENT '2g, 3g, 4g, 5g',
  
  -- Timing
  `scheduled_for` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `read_at` DATETIME NULL COMMENT 'If SMS was marked as read (if supported)',
  
  -- Related entities
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `notification_id` BIGINT UNSIGNED NULL,
  `otp_id` BIGINT UNSIGNED NULL COMMENT 'If this SMS contains OTP',
  
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
    
  FOREIGN KEY (`otp_id`) REFERENCES `session_tokens`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_sms_id` (`sms_id`),
  INDEX `idx_recipient_phone` (`recipient_phone`),
  INDEX `idx_recipient_user` (`recipient_user_id`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_gateway` (`gateway`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_network_operator` (`network_operator`),
  INDEX `idx_language` (`language`),
  INDEX `idx_template_id` (`template_id`),
  INDEX `idx_billing_month` (`billing_month`),
  
  -- Business constraints
  CONSTRAINT `chk_phone_format` CHECK (`recipient_phone` REGEXP '^(09[0-9]{8}|\\+251[0-9]{9})$'),
  CONSTRAINT `chk_cost_non_negative` CHECK (`total_cost` >= 0)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian SMS delivery logs with network and cost tracking';