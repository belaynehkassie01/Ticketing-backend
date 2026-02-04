-- Migration: 035_create_push_notifications_table.sql
-- Purpose: Store push notification logs for Ethiopian mobile apps

CREATE TABLE IF NOT EXISTS `push_notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Push identification
  `push_id` VARCHAR(100) UNIQUE NOT NULL COMMENT 'Internal push ID',
  `provider_push_id` VARCHAR(200) NULL COMMENT 'External provider ID (FCM, APNS)',
  
  -- Recipient info
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_token` VARCHAR(255) NOT NULL,
  `device_type` VARCHAR(20) NOT NULL COMMENT 'ios, android, web',
  `app_version` VARCHAR(20) NULL,
  `os_version` VARCHAR(20) NULL,
  
  -- Push content
  `push_type` VARCHAR(50) NOT NULL COMMENT 'payment, ticket, event, system, promotional, reminder',
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `body` TEXT NOT NULL,
  `body_amharic` TEXT,
  `data` JSON COMMENT 'Additional data payload',
  `badge_count` INT NULL,
  `sound` VARCHAR(50) DEFAULT 'default',
  
  -- Ethiopian context
  `language` ENUM('am', 'en') DEFAULT 'am',
  `city_id` BIGINT UNSIGNED NULL,
  
  -- Provider info
  `provider` VARCHAR(50) DEFAULT 'fcm' COMMENT 'fcm, apns, web_push, other',
  `provider_config` VARCHAR(100) NULL COMMENT 'Which config/account used',
  
  -- Delivery tracking
  `status` VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, device_not_registered',
  `delivery_report` JSON COMMENT 'Provider delivery report',
  `attempt_count` INT DEFAULT 1,
  `last_attempt_at` DATETIME NULL,
  `failure_reason` TEXT,
  `error_code` VARCHAR(50),
  
  -- Engagement tracking
  `received_at` DATETIME NULL,
  `opened_at` DATETIME NULL,
  `dismissed_at` DATETIME NULL,
  `action_taken` VARCHAR(50) NULL COMMENT 'opened, dismissed, custom_action',
  `custom_action` VARCHAR(100) NULL,
  
  -- Timing
  `scheduled_for` DATETIME NULL,
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `failed_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  
  -- Related entities
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `notification_id` BIGINT UNSIGNED NULL,
  
  -- Network info (Ethiopian context)
  `network_type` VARCHAR(20) NULL COMMENT 'wifi, cellular_2g, cellular_3g, cellular_4g, unknown',
  `battery_level` TINYINT NULL COMMENT 'Percentage 0-100',
  
  -- Metadata
  `metadata` JSON,
  `audit_trail` JSON,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`notification_id`) REFERENCES `notifications`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_push_id` (`push_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_device_token` (`device_token`(100)),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_push_type` (`push_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_provider` (`provider`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  INDEX `idx_app_version` (`app_version`),
  
  -- Business constraints
  CONSTRAINT `chk_device_type` CHECK (`device_type` IN ('ios', 'android', 'web')),
  CONSTRAINT `chk_battery_level` CHECK (`battery_level` IS NULL OR `battery_level` BETWEEN 0 AND 100)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Push notification logs for Ethiopian mobile applications';