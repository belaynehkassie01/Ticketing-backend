-- ============================================
-- TABLE: event_tag_pivot
-- Purpose: Many-to-many relationship between events and tags
-- ============================================
CREATE TABLE IF NOT EXISTS `event_tag_pivot` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `tag_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`tag_id`) REFERENCES `event_tags`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  UNIQUE INDEX `uq_event_tag` (`event_id`, `tag_id`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;