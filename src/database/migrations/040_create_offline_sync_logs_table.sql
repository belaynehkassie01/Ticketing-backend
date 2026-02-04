-- Migration: 040_create_offline_sync_logs_table.sql
-- Purpose: Store offline sync logs

CREATE TABLE IF NOT EXISTS `offline_sync_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `device_id` VARCHAR(255) NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `device_type` ENUM('android', 'ios', 'web') NOT NULL,
  `app_version` VARCHAR(20),
  `sync_type` ENUM('checkin', 'ticket_download', 'event_data', 'profile', 'all') NOT NULL,
  `records_count` INT DEFAULT 0,
  `data_size_kb` INT,
  `status` ENUM('pending', 'in_progress', 'completed', 'failed', 'partial') DEFAULT 'pending',
  `started_at` DATETIME NOT NULL,
  `completed_at` DATETIME NULL,
  `duration_ms` INT,
  `connection_type` ENUM('wifi', 'cellular_2g', 'cellular_3g', 'cellular_4g', 'cellular_5g', 'unknown') DEFAULT 'unknown',
  `network_speed_kbps` INT,
  `city_id` BIGINT UNSIGNED NULL,
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  INDEX `idx_device` (`device_id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_started_at` (`started_at`),
  INDEX `idx_sync_type` (`sync_type`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_connection_type` (`connection_type`),
  INDEX `idx_completed_at` (`completed_at`),
  
  CONSTRAINT `chk_records_count` CHECK (`records_count` >= 0),
  CONSTRAINT `chk_data_size` CHECK (`data_size_kb` IS NULL OR `data_size_kb` >= 0),
  CONSTRAINT `chk_duration` CHECK (`duration_ms` IS NULL OR `duration_ms` >= 0),
  CONSTRAINT `chk_network_speed` CHECK (`network_speed_kbps` IS NULL OR `network_speed_kbps` >= 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;