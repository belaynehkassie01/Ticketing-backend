-- Migration: 037_create_message_threads_table.sql (ENHANCED)
-- Purpose: Store message threads with improved foreign key constraints and status tracking

CREATE TABLE IF NOT EXISTS `message_threads` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Thread identification
  `thread_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'THREAD-ET-2024-001',
  `subject` VARCHAR(200) NOT NULL,
  `subject_amharic` VARCHAR(200),
  
  -- Participants
  `customer_id` BIGINT UNSIGNED NOT NULL COMMENT 'User who started the thread',
  `organizer_id` BIGINT UNSIGNED NULL COMMENT 'Organizer involved (if applicable)',
  `admin_id` BIGINT UNSIGNED NULL COMMENT 'Admin assigned to thread',
  
  -- Thread type and context
  `thread_type` VARCHAR(50) NOT NULL COMMENT 'customer_support, dispute, event_inquiry, payment_issue, general, partnership',
  `priority` VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  
  -- Related entities
  `related_event_id` BIGINT UNSIGNED NULL,
  `related_ticket_id` BIGINT UNSIGNED NULL,
  `related_payment_id` BIGINT UNSIGNED NULL,
  `related_dispute_id` BIGINT UNSIGNED NULL,
  
  -- Ethiopian context
  `city_id` BIGINT UNSIGNED NULL,
  `preferred_language` ENUM('am', 'en', 'or', 'ti', 'so') DEFAULT 'am',
  
  -- Status tracking
  `status` VARCHAR(30) DEFAULT 'open' COMMENT 'open, waiting_reply, resolved, closed, archived',
  `is_locked` BOOLEAN DEFAULT FALSE COMMENT 'Prevent new messages',
  `is_pinned` BOOLEAN DEFAULT FALSE COMMENT 'Pinned by admin',
  
  -- Message statistics
  `message_count` INT UNSIGNED DEFAULT 0,
  `unread_count_customer` INT UNSIGNED DEFAULT 0,
  `unread_count_organizer` INT UNSIGNED DEFAULT 0,
  `unread_count_admin` INT UNSIGNED DEFAULT 0,
  
  -- Last message info (IMPROVED: Can be from any user type)
  `last_message_at` DATETIME NULL,
  `last_message_by_user_id` BIGINT UNSIGNED NULL COMMENT 'Can be customer, organizer, or admin',
  `last_message_by_type` VARCHAR(20) NULL COMMENT 'customer, organizer, admin, system',
  `last_message_preview` VARCHAR(500) NULL,
  `last_message_preview_amharic` VARCHAR(500),
  
  -- Resolution
  `resolved_at` DATETIME NULL,
  `resolved_by` BIGINT UNSIGNED NULL,
  `resolution_notes` TEXT,
  `customer_satisfaction` TINYINT NULL COMMENT '1-5 rating',
  
  -- Closing
  `closed_at` DATETIME NULL,
  `closed_by` BIGINT UNSIGNED NULL,
  `closure_reason` VARCHAR(100) NULL COMMENT 'resolved, duplicate, spam, no_response',
  
  -- Labels and categorization
  `labels` JSON COMMENT '["urgent", "technical", "payment", "refund"]',
  `category` VARCHAR(50) NULL COMMENT 'technical, billing, event, account, other',
  
  -- SLA tracking (Ethiopian business hours)
  `sla_target_hours` INT DEFAULT 24 COMMENT 'Hours to first response',
  `first_response_at` DATETIME NULL,
  `sla_breached` BOOLEAN DEFAULT FALSE,
  `response_time_minutes` INT NULL COMMENT 'Actual response time in minutes',
  
  -- NEW: Status history tracking
  `status_history` JSON COMMENT 'Array of status changes: [{status: "open", changed_at: "...", changed_by: 1}]',
  
  -- Metadata
  `metadata` JSON,
  `audit_trail` JSON,
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `archived_at` DATETIME NULL,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_event_id`) REFERENCES `events`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`related_dispute_id`) REFERENCES `disputes`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  -- IMPROVED: Last message can be from users or organizers
  FOREIGN KEY (`last_message_by_user_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`closed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_thread_code` (`thread_code`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_admin_id` (`admin_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_thread_type` (`thread_type`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_last_message_at` (`last_message_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_preferred_language` (`preferred_language`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_related_event_id` (`related_event_id`),
  INDEX `idx_related_dispute_id` (`related_dispute_id`),
  INDEX `idx_last_message_by_user` (`last_message_by_user_id`),
  INDEX `idx_last_message_by_type` (`last_message_by_type`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Business constraints
  CONSTRAINT `chk_satisfaction_rating` CHECK (`customer_satisfaction` IS NULL OR `customer_satisfaction` BETWEEN 1 AND 5),
  CONSTRAINT `chk_message_counts` CHECK (`message_count` >= 0 AND `unread_count_customer` >= 0 AND `unread_count_organizer` >= 0 AND `unread_count_admin` >= 0),
  CONSTRAINT `chk_last_message_type` CHECK (`last_message_by_type` IS NULL OR `last_message_by_type` IN ('customer', 'organizer', 'admin', 'system'))
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Enhanced message threads for Ethiopian customer support with improved status tracking';