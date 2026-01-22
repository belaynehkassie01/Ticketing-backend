-- ============================================
-- TABLE: checkin_logs
-- Purpose: Store ticket check-in logs
-- ============================================
CREATE TABLE IF NOT EXISTS `checkin_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `ticket_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `checked_in_by` BIGINT UNSIGNED NOT NULL,
  `checkin_method` ENUM('qr_scan', 'manual_entry', 'offline_sync', 'batch_import') NOT NULL,
  `checkin_time` DATETIME NOT NULL,
  `device_id` VARCHAR(255),
  `device_type` ENUM('android', 'ios', 'web', 'other') DEFAULT 'android',
  `app_version` VARCHAR(20),
  `latitude` DECIMAL(10,8) NULL,
  `longitude` DECIMAL(11,8) NULL,
  `location_name` VARCHAR(255),
  `is_online` BOOLEAN DEFAULT TRUE,
  `sync_status` ENUM('pending', 'synced', 'failed') DEFAULT 'synced',
  `local_time` VARCHAR(50),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `synced_at` DATETIME NULL,
  
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_ticket` (`ticket_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_checkin_time` (`checkin_time`),
  INDEX `idx_sync_status` (`sync_status`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  INDEX `idx_device_id` (`device_id`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  UNIQUE INDEX `idx_ticket_checkin` (`ticket_id`, `checkin_time`),
  
  CONSTRAINT `chk_coordinates` CHECK (
    (`latitude` IS NULL AND `longitude` IS NULL) OR 
    (`latitude` IS NOT NULL AND `longitude` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;