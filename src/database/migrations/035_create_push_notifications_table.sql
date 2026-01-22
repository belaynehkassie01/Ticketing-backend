-- ============================================
-- TABLE: push_notifications
-- Purpose: Store push notification logs
-- ============================================
CREATE TABLE IF NOT EXISTS `push_notifications` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_token` VARCHAR(255) NOT NULL,
  `device_type` ENUM('ios', 'android', 'web') NOT NULL,
  `app_version` VARCHAR(20),
  `title` VARCHAR(200) NOT NULL,
  `body` TEXT NOT NULL,
  `data` JSON COMMENT 'Additional data payload',
  `status` ENUM('pending', 'sent', 'delivered', 'failed', 'device_not_registered') DEFAULT 'pending',
  `sent_at` DATETIME NULL,
  `delivered_at` DATETIME NULL,
  `failure_reason` TEXT,
  `language` ENUM('am', 'en') DEFAULT 'am',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_device_token` (`device_token`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sent_at` (`sent_at`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_language` (`language`),
  
  CONSTRAINT `chk_device_token_length` CHECK (CHAR_LENGTH(`device_token`) >= 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;