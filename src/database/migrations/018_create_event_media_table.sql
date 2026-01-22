-- ============================================
-- TABLE: event_media
-- Purpose: Store media files for events
-- ============================================
CREATE TABLE IF NOT EXISTS `event_media` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `media_type` ENUM('image', 'video', 'document') DEFAULT 'image',
  `url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500),
  `filename` VARCHAR(255),
  `mime_type` VARCHAR(100),
  `file_size` INT UNSIGNED,
  `width` INT UNSIGNED,
  `height` INT UNSIGNED,
  `duration` INT UNSIGNED NULL,
  `caption` VARCHAR(500),
  `caption_amharic` VARCHAR(500),
  `sort_order` INT DEFAULT 0,
  `is_primary` BOOLEAN DEFAULT FALSE,
  `is_approved` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_media_type` (`media_type`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_primary` (`is_primary`),
  INDEX `idx_is_approved` (`is_approved`),
  
  CONSTRAINT `chk_file_size` CHECK (`file_size` >= 0),
  CONSTRAINT `chk_dimensions` CHECK (`width` >= 0 AND `height` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;