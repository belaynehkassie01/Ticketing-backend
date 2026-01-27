-- Migration: 014_create_event_tags_table.sql
-- Description: Store tags for event classification (Improved Production Version)
-- Dependencies: None (standalone table)
-- Best Practices: Soft delete, duplicate prevention, consistent with other tables

-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- Note: Slug validation enforced in application, not MySQL CHECK constraints
-- ============================================

CREATE TABLE IF NOT EXISTS `event_tags` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Tag Names (Bilingual)
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `slug` VARCHAR(100) UNIQUE NOT NULL COMMENT 'URL-friendly lowercase slug (validated in app)',
  
  -- Descriptions (Optional but useful for admin/SEO)
  `description` TEXT COMMENT 'English description',
  `description_amharic` TEXT COMMENT 'Amharic description',
  
  -- Metadata
  `usage_count` INT UNSIGNED DEFAULT 0 COMMENT 'How many times this tag is used',
  `is_featured` BOOLEAN DEFAULT FALSE COMMENT 'Featured tags for discovery',
  `is_active` BOOLEAN DEFAULT TRUE,
  
  -- Ethiopian Context
  `cultural_relevance` ENUM('high', 'medium', 'low', 'none') DEFAULT 'medium' COMMENT 'Ethiopian cultural relevance',
  `common_in_regions` JSON DEFAULT NULL COMMENT 'Regions where this tag is popular: ["Addis Ababa", "Amhara"]',
  
  -- SEO & Discovery
  `meta_title` VARCHAR(200),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  
  -- Timestamps (Consistent with other tables)
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL COMMENT 'Soft delete timestamp',
  
  -- Indexes
  INDEX `idx_slug` (`slug`),
  INDEX `idx_name` (`name`(50)),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_usage_count` (`usage_count`),
  INDEX `idx_cultural_relevance` (`cultural_relevance`),
  
  -- Composite Indexes for Common Queries
  INDEX `idx_active_featured` (`is_active`, `is_featured`),
  INDEX `idx_active_usage` (`is_active`, `usage_count`),
  INDEX `idx_name_active` (`name`, `is_active`),
  
  -- FULLTEXT Search (Supports Amharic with utf8mb4)
  FULLTEXT `idx_search` (`name`, `name_amharic`, `description`, `description_amharic`),
  
  -- Constraints (Application-enforced, documented here)
  -- Note: Slug format validation happens in application code
  
  -- Prevent duplicate names (case-insensitive)
  UNIQUE KEY `uq_name_unique` (`name`)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event tags for classification. Soft delete supported. Name uniqueness enforced.';

-- ============================================
-- VIEWS FOR TAG MANAGEMENT
-- ============================================

-- View for active tags (public facing)
CREATE OR REPLACE VIEW `vw_active_tags` AS
SELECT 
    id,
    name,
    name_amharic,
    slug,
    description,
    description_amharic,
    usage_count,
    is_featured,
    cultural_relevance,
    created_at,
    -- Language-specific display name (app will choose)
    name as display_name_en,
    name_amharic as display_name_am,
    -- Popularity indicator
    CASE 
        WHEN usage_count > 100 THEN 'VERY_POPULAR'
        WHEN usage_count > 50 THEN 'POPULAR'
        WHEN usage_count > 10 THEN 'COMMON'
        ELSE 'NEW'
    END as popularity_level
FROM `event_tags`
WHERE is_active = TRUE
  AND deleted_at IS NULL
ORDER BY usage_count DESC, name;


HAVING recent_usage > 0
ORDER BY recent_usage DESC;
*/

-- View for admin tag management
CREATE OR REPLACE VIEW `vw_admin_tags` AS
SELECT 
    id,
    name,
    name_amharic,
    slug,
    usage_count,
    is_active,
    is_featured,
    cultural_relevance,
    created_at,
    updated_at,
    deleted_at,
    -- Status indicator
    CASE 
        WHEN deleted_at IS NOT NULL THEN 'DELETED'
        WHEN is_active = FALSE THEN 'INACTIVE'
        WHEN is_featured = TRUE THEN 'FEATURED'
        ELSE 'ACTIVE'
    END as status
FROM `event_tags`
ORDER BY 
    CASE 
        WHEN deleted_at IS NOT NULL THEN 3
        WHEN is_active = FALSE THEN 2
        ELSE 1
    END,
    usage_count DESC;
