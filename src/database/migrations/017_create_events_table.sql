-- ============================================
-- TABLE: events
-- Purpose: Store event information
-- ============================================
CREATE TABLE IF NOT EXISTS `events` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `description` TEXT,
  `description_amharic` TEXT,
  `short_description` VARCHAR(500),
  `category_id` BIGINT UNSIGNED NOT NULL,
  `tags` JSON COMMENT 'Array of tag IDs',
  `city_id` BIGINT UNSIGNED NOT NULL,
  `venue_id` BIGINT UNSIGNED NULL,
  `venue_custom` VARCHAR(200),
  `address_details` TEXT,
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `start_date_ethiopian` VARCHAR(50),
  `end_date_ethiopian` VARCHAR(50),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `duration_minutes` INT,
  `is_recurring` BOOLEAN DEFAULT FALSE,
  `recurrence_pattern` JSON COMMENT 'Recurrence configuration',
  `status` ENUM('draft', 'pending_review', 'published', 'cancelled', 'completed', 'suspended') DEFAULT 'draft',
  `visibility` ENUM('public', 'private', 'unlisted') DEFAULT 'public',
  `is_featured` BOOLEAN DEFAULT FALSE,
  `featured_until` DATETIME NULL,
  `has_tickets` BOOLEAN DEFAULT TRUE,
  `total_tickets` INT DEFAULT 0,
  `tickets_sold` INT DEFAULT 0,
  `min_price` DECIMAL(10,2) NULL,
  `max_price` DECIMAL(10,2) NULL,
  `cover_image` VARCHAR(255),
  `gallery_images` JSON COMMENT 'Array of image URLs',
  `video_url` VARCHAR(500),
  `age_restriction` ENUM('all', '18+', '21+') DEFAULT 'all',
  `is_charity` BOOLEAN DEFAULT FALSE,
  `charity_org` VARCHAR(200),
  `vat_included` BOOLEAN DEFAULT TRUE,
  `vat_rate` DECIMAL(5,2) DEFAULT 15.00,
  `views` INT DEFAULT 0,
  `shares` INT DEFAULT 0,
  `saves` INT DEFAULT 0,
  `meta_title` VARCHAR(200),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `published_at` DATETIME NULL,
  `cancelled_at` DATETIME NULL,
  `cancellation_reason` TEXT,
  `cancelled_by` BIGINT UNSIGNED NULL,
  
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`category_id`) REFERENCES `event_categories`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (`venue_id`) REFERENCES `venues`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_is_featured` (`is_featured`, `featured_until`),
  INDEX `idx_published_at` (`published_at`),
  INDEX `idx_category_id` (`category_id`),
  INDEX `idx_venue_id` (`venue_id`),
  INDEX `idx_cancelled_by` (`cancelled_by`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  FULLTEXT `idx_event_search` (`title`, `title_amharic`, `description`, `description_amharic`),
  
  CONSTRAINT `chk_event_dates` CHECK (`end_date` > `start_date`),
  CONSTRAINT `chk_tickets_sold` CHECK (`tickets_sold` <= `total_tickets`),
  CONSTRAINT `chk_vat_rate` CHECK (`vat_rate` >= 0 AND `vat_rate` <= 100),
  CONSTRAINT `chk_slug_format` CHECK (`slug` REGEXP '^[a-z0-9-]+$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;