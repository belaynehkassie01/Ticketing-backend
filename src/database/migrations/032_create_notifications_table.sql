-- ============================================
-- TABLE: notifications
-- Purpose: Store user notifications
-- ============================================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `type` ENUM('payment', 'ticket', 'event', 'system', 'promotional', 'admin') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `message` TEXT NOT NULL,
  `message_amharic` TEXT,
  `action_url` VARCHAR(500),
  `action_label` VARCHAR(100),
  `action_label_amharic` VARCHAR(100),
  `is_read` BOOLEAN DEFAULT FALSE,
  `is_sent` BOOLEAN DEFAULT FALSE,
  `delivery_method` ENUM('in_app', 'sms', 'email', 'push', 'all') DEFAULT 'in_app',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `expires_at` DATETIME NULL,
  `related_id` BIGINT UNSIGNED,
  `related_type` VARCHAR(50),
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `sent_at` DATETIME NULL,
  `read_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_delivery_method` (`delivery_method`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_related` (`related_type`, `related_id`),
  INDEX `idx_is_sent` (`is_sent`),
  
  CONSTRAINT `chk_expires_at` CHECK (`expires_at` IS NULL OR `expires_at` > `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;