-- Migration: 039_create_activity_logs_table.sql
-- Purpose: Store user activity logs for analytics and Ethiopian user behavior analysis

CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- User identification
  `user_id` BIGINT UNSIGNED NOT NULL,
  `session_id` VARCHAR(100) NOT NULL,
  `device_fingerprint` VARCHAR(255) NULL COMMENT 'Browser/device fingerprint',
  
  -- Activity details
  `activity_type` VARCHAR(50) NOT NULL COMMENT 'page_view, button_click, form_submit, search, login, logout, ticket_purchase, event_view',
  `activity_subtype` VARCHAR(50) NULL COMMENT 'homepage_view, event_details_view, ticket_selection, payment_initiated',
  `activity_description` VARCHAR(500) NOT NULL,
  
  -- Page/Route information
  `page_url` VARCHAR(500) NOT NULL,
  `page_title` VARCHAR(200) NULL,
  `route_name` VARCHAR(100) NULL COMMENT 'Frontend route name',
  `referrer_url` VARCHAR(500),
  `utm_source` VARCHAR(100) NULL,
  `utm_medium` VARCHAR(100) NULL,
  `utm_campaign` VARCHAR(100) NULL,
  
  -- Device and browser info
  `device_type` VARCHAR(30) DEFAULT 'mobile' COMMENT 'mobile, tablet, desktop',
  `device_model` VARCHAR(100) NULL,
  `browser` VARCHAR(100),
  `browser_version` VARCHAR(50),
  `os` VARCHAR(100),
  `os_version` VARCHAR(50),
  `screen_resolution` VARCHAR(20) NULL COMMENT '1920x1080',
  
  -- Network information (Ethiopian context)
  `city_id` BIGINT UNSIGNED NULL,
  `region` VARCHAR(100) NULL,
  `estimated_location` VARCHAR(255),
  `network_type` VARCHAR(30) NULL COMMENT 'wifi, cellular_2g, cellular_3g, cellular_4g, unknown',
  `network_speed_kbps` INT NULL,
  `carrier` VARCHAR(100) NULL COMMENT 'Ethio Telecom, Safaricom Ethiopia',
  
  -- Performance metrics
  `page_load_time_ms` INT,
  `time_on_page_ms` INT,
  `scroll_depth_percentage` TINYINT NULL COMMENT '0-100',
  `interaction_count` INT DEFAULT 1,
  
  -- Application context
  `app_version` VARCHAR(20) NULL,
  `platform` VARCHAR(20) DEFAULT 'web' COMMENT 'web, android_app, ios_app',
  `language` ENUM('am', 'en', 'or', 'ti', 'so') DEFAULT 'am',
  
  -- Related entities
  `related_event_id` BIGINT UNSIGNED NULL,
  `related_ticket_id` BIGINT UNSIGNED NULL,
  `related_payment_id` BIGINT UNSIGNED NULL,
  `related_organizer_id` BIGINT UNSIGNED NULL,
  
  -- User journey
  `funnel_step` VARCHAR(50) NULL COMMENT 'awareness, consideration, conversion, retention',
  `conversion_goal` VARCHAR(100) NULL COMMENT 'ticket_purchase, organizer_signup, event_creation',
  `is_conversion` BOOLEAN DEFAULT FALSE,
  
  -- Error tracking
  `error_occurred` BOOLEAN DEFAULT FALSE,
  `error_message` TEXT,
  `error_stack` TEXT,
  
  -- Ethiopian market research
  `user_segment` VARCHAR(50) NULL COMMENT 'student, professional, tourist, organizer, business',
  `price_sensitivity` VARCHAR(20) NULL COMMENT 'low, medium, high',
  `event_preference` JSON NULL COMMENT 'Preferred event categories',
  
  -- Metadata
  `metadata` JSON,
  `custom_attributes` JSON,
  
  -- Timestamps
  `activity_timestamp` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_event_id`) REFERENCES `events`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes (optimized for Ethiopian user analytics)
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_activity_type` (`activity_type`),
  INDEX `idx_activity_timestamp` (`activity_timestamp`),
  INDEX `idx_page_url` (`page_url`(100)),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_network_type` (`network_type`),
  INDEX `idx_language` (`language`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_conversion_goal` (`conversion_goal`),
  INDEX `idx_is_conversion` (`is_conversion`),
  INDEX `idx_related_event_id` (`related_event_id`),
  INDEX `idx_utm_source` (`utm_source`),
  INDEX `idx_created_at` (`created_at`),
  
  -- Business constraints
  CONSTRAINT `chk_scroll_depth` CHECK (`scroll_depth_percentage` IS NULL OR `scroll_depth_percentage` BETWEEN 0 AND 100),
  CONSTRAINT `chk_page_load_time` CHECK (`page_load_time_ms` IS NULL OR `page_load_time_ms` >= 0)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='User activity logs for Ethiopian market analytics and user behavior tracking';