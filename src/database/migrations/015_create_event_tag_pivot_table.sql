-- Migration: 015_create_event_tag_pivot_table.sql
-- Description: Many-to-many relationship between events and tags
-- Dependencies: Requires events and event_tags tables

CREATE TABLE IF NOT EXISTS `event_tag_pivot` (
  `event_id` BIGINT UNSIGNED NOT NULL,
  `tag_id` BIGINT UNSIGNED NOT NULL,

  -- Metadata
  `source` ENUM('manual', 'auto', 'ai') DEFAULT 'manual',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,

  -- Composite Primary Key
  PRIMARY KEY (`event_id`, `tag_id`),

  -- Foreign Keys
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  FOREIGN KEY (`tag_id`) REFERENCES `event_tags`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  -- Indexes
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_tag_id` (`tag_id`),
  INDEX `idx_deleted_at` (`deleted_at`)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pivot table linking events and tags (many-to-many)';
