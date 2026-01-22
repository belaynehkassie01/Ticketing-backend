-- ============================================
-- TABLE: api_keys
-- Purpose: Store API keys for system access
-- ============================================
CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `api_key` VARCHAR(255) UNIQUE NOT NULL,
  `api_secret` VARCHAR(255) NOT NULL,
  `name` VARCHAR(200) NOT NULL,
  `description` TEXT,
  `user_id` BIGINT UNSIGNED NULL,
  `organizer_id` BIGINT UNSIGNED NULL,
  `permissions` JSON COMMENT 'JSON object with endpoint permissions',
  `is_active` BOOLEAN DEFAULT TRUE,
  `rate_limit_per_minute` INT DEFAULT 60,
  `last_used_at` DATETIME NULL,
  `usage_count` BIGINT UNSIGNED DEFAULT 0,
  `ip_whitelist` JSON COMMENT 'Array of allowed IP addresses',
  `expires_at` DATETIME NULL,
  `allowed_for_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_api_key` (`api_key`(100)),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_rate_limit` CHECK (`rate_limit_per_minute` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;