-- Migration: 017_create_events_table.sql (IMPROVED VERSION)
-- Description: Store event information with enhanced features
-- Dependencies: Requires organizers, event_categories, cities, venues tables

-- ============================================
-- TABLE: events (IMPROVED)
-- Purpose: Store event information
-- Improvements: Added recurring events support, online events, age integer, removed redundant tags
-- ============================================

CREATE TABLE IF NOT EXISTS `events` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  
  -- Event Information
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `slug` VARCHAR(255) UNIQUE NOT NULL,
  `seo_slug` VARCHAR(255) UNIQUE NULL COMMENT 'Optional separate slug for SEO flexibility',
  
  -- Descriptions
  `description` TEXT,
  `description_amharic` TEXT,
  `short_description` VARCHAR(500),
  
  -- Classification
  `category_id` BIGINT UNSIGNED NOT NULL,
  `city_id` BIGINT UNSIGNED NOT NULL,
  
  -- Location & Venue
  `venue_id` BIGINT UNSIGNED NULL,
  `venue_custom` VARCHAR(200),
  `address_details` TEXT,
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `is_online` BOOLEAN DEFAULT FALSE COMMENT 'Virtual/online events',
  `online_event_url` VARCHAR(500) COMMENT 'URL for virtual events',
  
  -- Event Timing
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `start_date_ethiopian` VARCHAR(50),
  `end_date_ethiopian` VARCHAR(50),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `duration_minutes` INT,
  
  -- Recurring Events (Enhanced)
  `is_recurring` BOOLEAN DEFAULT FALSE,
  `recurrence_pattern` JSON COMMENT 'Recurrence configuration',
  `recurrence_end_date` DATETIME NULL COMMENT 'When recurring events stop',
  
  -- Status & Visibility
  `status` ENUM('draft', 'pending_review', 'published', 'cancelled', 'completed', 'suspended') DEFAULT 'draft',
  `status_reason` TEXT COMMENT 'Reason for status change',
  `visibility` ENUM('public', 'private', 'unlisted') DEFAULT 'public',
  `is_featured` BOOLEAN DEFAULT FALSE,
  `featured_until` DATETIME NULL,
  
  -- Ticketing
  `has_tickets` BOOLEAN DEFAULT TRUE,
  `external_ticket_url` VARCHAR(500) COMMENT 'For events using external ticketing',
  `total_tickets` INT DEFAULT 0,
  `tickets_sold` INT DEFAULT 0,
  `min_price` DECIMAL(10,2) NULL,
  `max_price` DECIMAL(10,2) NULL,
  
  -- Media
  `cover_image` VARCHAR(255),
  `gallery_images` JSON COMMENT 'Array of image URLs',
  `video_url` VARCHAR(500),
  
  -- Audience & Restrictions
  `min_age` INT DEFAULT 0 COMMENT 'Minimum age requirement (0 = all ages)',
  `age_restriction` ENUM('all', '18+', '21+') DEFAULT 'all' COMMENT 'Display category',
  `is_charity` BOOLEAN DEFAULT FALSE,
  `charity_org` VARCHAR(200),
  
  -- Ethiopian Tax
  `vat_included` BOOLEAN DEFAULT TRUE,
  `vat_rate` DECIMAL(5,2) DEFAULT 15.00,
  
  -- Engagement Metrics
  `views` INT DEFAULT 0,
  `shares` INT DEFAULT 0,
  `saves` INT DEFAULT 0,
  `attendee_count` INT DEFAULT 0 COMMENT 'Actual attendees (not ticket sales)',
  
  -- SEO
  `meta_title` VARCHAR(200),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `published_at` DATETIME NULL,
  `cancelled_at` DATETIME NULL,
  `cancellation_reason` TEXT,
  `cancelled_by` BIGINT UNSIGNED NULL,
  
  -- Foreign Keys
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
  
  -- Core Indexes
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_city` (`city_id`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_is_featured` (`is_featured`, `featured_until`),
  INDEX `idx_published_at` (`published_at`),
  INDEX `idx_category_id` (`category_id`),
  INDEX `idx_venue_id` (`venue_id`),
  INDEX `idx_cancelled_by` (`cancelled_by`),
  
  -- Enhanced Composite Indexes (for common queries)
  INDEX `idx_organizer_status_date` (`organizer_id`, `status`, `start_date`),
  INDEX `idx_city_status_date` (`city_id`, `status`, `start_date`),
  INDEX `idx_category_status_date` (`category_id`, `status`, `start_date`),
  INDEX `idx_featured_status_date` (`is_featured`, `status`, `start_date`),
  INDEX `idx_online_status_date` (`is_online`, `status`, `start_date`),
  
  -- Spatial and Full-Text Search
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  FULLTEXT `idx_event_search` (`title`, `title_amharic`, `description`, `description_amharic`),
  
  -- Application-enforced constraints (documented here)
  -- Note: CHECK constraints are for documentation only in older MySQL
  CONSTRAINT `chk_event_dates` CHECK (`end_date` > `start_date`),
  CONSTRAINT `chk_tickets_sold` CHECK (`tickets_sold` <= `total_tickets`),
  CONSTRAINT `chk_vat_rate` CHECK (`vat_rate` >= 0 AND `vat_rate` <= 100),
  CONSTRAINT `chk_slug_format` CHECK (`slug` REGEXP '^[a-z0-9-]+$'),
  CONSTRAINT `chk_min_age` CHECK (`min_age` >= 0 AND `min_age` <= 100),
  CONSTRAINT `chk_duration` CHECK (`duration_minutes` IS NULL OR `duration_minutes` > 0),
  CONSTRAINT `chk_venue_or_online` CHECK (
    (`venue_id` IS NOT NULL AND `is_online` = FALSE) OR
    (`venue_id` IS NULL AND `is_online` = TRUE) OR
    (`venue_id` IS NULL AND `venue_custom` IS NOT NULL AND `is_online` = FALSE)
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Core events table with enhanced features. Business rules enforced in application.';

-- ============================================
-- VIEWS FOR COMMON EVENT QUERIES
-- ============================================

-- View for public event listings
CREATE OR REPLACE VIEW `vw_public_events` AS
SELECT 
    e.id,
    e.organizer_id,
    o.business_name as organizer_name,
    e.title,
    e.title_amharic,
    e.slug,
    e.short_description,
    e.category_id,
    ec.name as category_name,
    ec.name_amharic as category_name_amharic,
    e.city_id,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    e.venue_id,
    v.name as venue_name,
    v.name_amharic as venue_name_amharic,
    e.start_date,
    e.end_date,
    e.start_date_ethiopian,
    e.end_date_ethiopian,
    e.is_online,
    e.online_event_url,
    e.cover_image,
    e.min_price,
    e.max_price,
    e.has_tickets,
    e.total_tickets,
    e.tickets_sold,
    e.min_age,
    e.age_restriction,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    -- Availability indicator
    CASE 
        WHEN e.total_tickets > 0 AND e.tickets_sold >= e.total_tickets THEN 'SOLD_OUT'
        WHEN e.total_tickets > 0 AND (e.total_tickets - e.tickets_sold) < 10 THEN 'FEW_LEFT'
        WHEN e.total_tickets > 0 THEN 'AVAILABLE'
        ELSE 'NO_TICKETS'
    END as ticket_availability,
    -- Date status
    CASE 
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.start_date <= DATE_ADD(NOW(), INTERVAL 30 DAY) THEN 'UPCOMING'
        ELSE 'FUTURE'
    END as date_status
FROM `events` e
LEFT JOIN `organizers` o ON e.organizer_id = o.id
LEFT JOIN `event_categories` ec ON e.category_id = ec.id
LEFT JOIN `cities` c ON e.city_id = c.id
LEFT JOIN `venues` v ON e.venue_id = v.id
WHERE e.status = 'published'
  AND e.visibility = 'public'
  AND (e.featured_until IS NULL OR e.featured_until > NOW())
ORDER BY 
    e.is_featured DESC,
    e.start_date ASC;

-- View for organizer dashboard
CREATE OR REPLACE VIEW `vw_organizer_events` AS
SELECT 
    e.id,
    e.title,
    e.title_amharic,
    e.status,
    e.start_date,
    e.end_date,
    e.total_tickets,
    e.tickets_sold,
    e.min_price,
    e.max_price,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    e.cancelled_at,
    -- Financial metrics
    CASE 
        WHEN e.min_price IS NOT NULL AND e.max_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' - ', FORMAT(e.max_price, 2), ' ETB')
        WHEN e.min_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' ETB')
        ELSE 'FREE'
    END as price_range,
    -- Sales percentage
    CASE 
        WHEN e.total_tickets > 0 THEN 
            CONCAT(ROUND((e.tickets_sold / e.total_tickets) * 100, 1), '%')
        ELSE '0%'
    END as sales_percentage,
    -- Time status
    CASE 
        WHEN e.cancelled_at IS NOT NULL THEN 'CANCELLED'
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.status = 'published' THEN 'ACTIVE'
        WHEN e.status = 'draft' THEN 'DRAFT'
        ELSE e.status
    END as event_status
FROM `events` e
ORDER BY 
    CASE 
        WHEN e.start_date < NOW() THEN 3
        WHEN e.status = 'published' THEN 1
        ELSE 2
    END,
    e.start_date ASC;
-- End of Migration: 017_create_events_table.sql