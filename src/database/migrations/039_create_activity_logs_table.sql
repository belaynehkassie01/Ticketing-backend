-- ============================================
-- TABLE: activity_logs
-- Purpose: Store user activity logs
-- ============================================
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `activity_type` ENUM('login', 'logout', 'page_view', 'search', 'ticket_purchase', 'event_view', 'profile_update', 'payment_attempt', 'checkin') NOT NULL,
  `activity_details` TEXT,
  `page_url` VARCHAR(500),
  `referrer_url` VARCHAR(500),
  `device_type` ENUM('mobile', 'tablet', 'desktop') DEFAULT 'mobile',
  `browser` VARCHAR(100),
  `os` VARCHAR(100),
  `city_id` BIGINT UNSIGNED NULL,
  `estimated_location` VARCHAR(255),
  `load_time_ms` INT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_activity_type` (`activity_type`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_device_type` (`device_type`),
  INDEX `idx_page_url` (`page_url`(100)),
  INDEX `idx_referrer_url` (`referrer_url`(100)),
  
  CONSTRAINT `chk_load_time` CHECK (`load_time_ms` IS NULL OR `load_time_ms` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;