-- Migration: 032_create_notifications_table.sql
-- Purpose: Store user notifications with Ethiopian SMS/Email/Push support

CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Notification identification
  `notification_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'NOTIF-ET-2024-001',
  `user_id` BIGINT UNSIGNED NOT NULL,
  
  -- Notification metadata
  `notification_type` VARCHAR(50) NOT NULL COMMENT 'payment, ticket, event, system, promotional, admin, otp, reminder, security, dispute',
  `category` VARCHAR(50) NULL COMMENT 'transactional, marketing, security, reminder, alert',
  `channel` VARCHAR(20) NOT NULL COMMENT 'in_app, sms, email, push, all',
  
  -- Content (Ethiopian bilingual support)
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `message` TEXT NOT NULL,
  `message_amharic` TEXT,
  `short_message` VARCHAR(500) NULL COMMENT 'For SMS/push preview',
  `short_message_amharic` VARCHAR(500),
  
  -- Action and navigation
  `action_url` VARCHAR(500),
  `action_label` VARCHAR(100),
  `action_label_amharic` VARCHAR(100),
  `action_data` JSON,
  `deep_link` VARCHAR(500) NULL COMMENT 'app://ticket/123',
  
  -- Template reference
  `template_id` VARCHAR(100) NULL,
  `template_version` VARCHAR(20) NULL,
  `variables` JSON COMMENT 'Template variables replaced',
  
  -- Ethiopian context
  `preferred_language` ENUM('am', 'en', 'or', 'ti', 'so') DEFAULT 'am',
  `city_id` BIGINT UNSIGNED NULL,
  
  -- Delivery status per channel
  `in_app_status` VARCHAR(30) DEFAULT 'pending' COMMENT 'pending, sent, delivered, read, failed',
  `sms_status` VARCHAR(30) DEFAULT 'pending',
  `email_status` VARCHAR(30) DEFAULT 'pending',
  `push_status` VARCHAR(30) DEFAULT 'pending',
  
  -- Ethiopian SMS specific
  `sms_provider` VARCHAR(50) DEFAULT 'ethio_telecom' COMMENT 'ethio_telecom, awash_sms, cbe_sms',
  `sms_message_id` VARCHAR(100) NULL,
  `sms_unicode` BOOLEAN DEFAULT FALSE,
  `sms_retry_count` INT DEFAULT 0,
  
  -- Email specific
  `email_subject` VARCHAR(200) NULL,
  `email_message_id` VARCHAR(200) NULL,
  `email_retry_count` INT DEFAULT 0,
  
  -- Push specific
  `device_token` VARCHAR(255) NULL,
  `device_type` VARCHAR(20) NULL COMMENT 'ios, android, web',
  `push_retry_count` INT DEFAULT 0,
  
  -- Status tracking
  `is_read` BOOLEAN DEFAULT FALSE,
  `is_delivered` BOOLEAN DEFAULT FALSE,
  `is_archived` BOOLEAN DEFAULT FALSE,
  `delivery_status` VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, bounced, opened, clicked',
  `failure_reason` TEXT,
  `retry_count` INT DEFAULT 0,
  `max_retries` INT DEFAULT 3,
  
  -- Priority and scheduling
  `priority` VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  `scheduled_for` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `read_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `opened_at` DATETIME NULL,
  `clicked_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  
  -- Related entities
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `metadata` JSON,
  
  -- Performance tracking
  `open_count` INT DEFAULT 0,
  `click_count` INT DEFAULT 0,
  `last_opened_at` DATETIME NULL,
  `last_clicked_at` DATETIME NULL,
  
  -- Cost tracking (Ethiopian SMS/Email costs)
  `sms_cost` DECIMAL(10,2) DEFAULT 0.10 COMMENT 'Cost in ETB per SMS',
  `email_cost` DECIMAL(10,2) DEFAULT 0.00,
  `total_cost` DECIMAL(10,2) DEFAULT 0.00,
  
  -- Audit
  `audit_trail` JSON,
  `created_by` BIGINT UNSIGNED NULL COMMENT 'System or admin who triggered',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_notification_code` (`notification_code`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_notification_type` (`notification_type`),
  INDEX `idx_channel` (`channel`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_delivery_status` (`delivery_status`),
  INDEX `idx_scheduled_for` (`scheduled_for`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_template_id` (`template_id`),
  INDEX `idx_preferred_language` (`preferred_language`),
  INDEX `idx_sms_provider` (`sms_provider`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Business constraints
  CONSTRAINT `chk_channel_values` CHECK (`channel` IN ('in_app', 'sms', 'email', 'push', 'all')),
  CONSTRAINT `chk_priority_values` CHECK (`priority` IN ('low', 'medium', 'high', 'urgent'))
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian notifications system with SMS, Email, and Push support';