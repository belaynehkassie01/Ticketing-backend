-- Migration: 013_create_event_categories_table.sql
-- Description: Create hierarchical event category system with Ethiopian context
-- Dependencies: None (standalone table)
-- Ethiopian Context: Amharic names, Ethiopian cultural categories
-- MySQL Production Safety: No session variables in views, proper FULLTEXT handling, no trigger complexity

-- ============================================
-- TABLE: event_categories
-- Purpose: Hierarchical categorization system for Ethiopian events
-- Important: All hierarchy management handled in application logic
-- ============================================

CREATE TABLE IF NOT EXISTS `event_categories` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Hierarchy Management (Application-managed)
  `parent_id` BIGINT UNSIGNED NULL COMMENT 'Parent category ID, NULL for root',
  `depth` TINYINT UNSIGNED DEFAULT 0 COMMENT 'Hierarchy depth (0 = root, managed by app)',
  `path` VARCHAR(500) COMMENT 'Materialized path (e.g., "1.5.12", managed by app)',
  `hierarchy_order` INT DEFAULT 0 COMMENT 'Order within parent for display',
  
  -- Category Names (Bilingual)
  `name` VARCHAR(100) NOT NULL COMMENT 'English category name',
  `name_amharic` VARCHAR(100) NOT NULL COMMENT 'Amharic category name',
  `slug` VARCHAR(120) UNIQUE NOT NULL COMMENT 'URL-friendly slug (lowercase, hyphens)',
  
  -- Descriptions
  `description` TEXT COMMENT 'English description',
  `description_amharic` TEXT COMMENT 'Amharic description',
  
  -- Visual Identity
  `icon` VARCHAR(50) COMMENT 'FontAwesome or custom icon class',
  `icon_amharic` VARCHAR(50) COMMENT 'Amharic-specific icon if different',
  `color` VARCHAR(7) DEFAULT '#078930' COMMENT 'Hex color for UI (#RRGGBB)',
  `image_url` VARCHAR(500) COMMENT 'Category banner/image',
  
  -- Ethiopian Cultural Context
  `cultural_significance` ENUM('high', 'medium', 'low', 'none') DEFAULT 'medium' COMMENT 'Ethiopian cultural importance',
  `typical_season` ENUM('dry', 'rainy', 'both', 'holiday', 'any') DEFAULT 'any' COMMENT 'When events typically occur',
  `common_regions` JSON DEFAULT NULL COMMENT 'Popular regions: ["Addis Ababa", "Amhara"]',
  
  -- Business Rules
  `requires_approval` BOOLEAN DEFAULT FALSE COMMENT 'Events in this category need special approval',
  `min_age_requirement` TINYINT UNSIGNED DEFAULT 0 COMMENT 'Minimum age for attendees (0-100)',
  `default_commission_rate` DECIMAL(5,2) DEFAULT 10.00 COMMENT 'Default commission (5-30%)',
  
  -- Display & Organization
  `sort_order` INT DEFAULT 0 COMMENT 'Global sorting in lists',
  `is_featured` BOOLEAN DEFAULT FALSE COMMENT 'Featured on homepage',
  `featured_until` DATETIME NULL COMMENT 'Until when featured',
  `is_active` BOOLEAN DEFAULT TRUE,
  
  -- Statistics (Denormalized for performance)
  `total_events` INT UNSIGNED DEFAULT 0,
  `upcoming_events` INT UNSIGNED DEFAULT 0,
  `total_tickets_sold` INT UNSIGNED DEFAULT 0,
  
  -- SEO & Discovery
  `meta_title` VARCHAR(200),
  `meta_description` TEXT,
  `meta_keywords` VARCHAR(500),
  `search_keywords` JSON DEFAULT NULL COMMENT 'Search terms: ["concert", "music", "ኮንሰርት"]',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Self-referential foreign key for hierarchy
  FOREIGN KEY (`parent_id`) REFERENCES `event_categories`(`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  
  -- Indexes
  INDEX `idx_parent_id` (`parent_id`),
  INDEX `idx_slug` (`slug`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sort_order` (`sort_order`),
  INDEX `idx_is_featured` (`is_featured`, `featured_until`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_depth` (`depth`),
  INDEX `idx_hierarchy_order` (`hierarchy_order`),
  
  -- Composite Indexes for Common Queries
  INDEX `idx_active_parent` (`is_active`, `parent_id`),
  INDEX `idx_featured_active` (`is_featured`, `is_active`, `featured_until`),
  INDEX `idx_parent_sort` (`parent_id`, `hierarchy_order`),
  
  -- FULLTEXT Search (English only for consistency)
  FULLTEXT INDEX `idx_category_search` (`name`, `description`),
  FULLTEXT INDEX `idx_name_search` (`name`),
  
  -- Constraints (Light, MySQL-safe)
  CONSTRAINT `chk_min_age_requirement` CHECK (`min_age_requirement` <= 100),
  CONSTRAINT `chk_default_commission_rate` CHECK (
    `default_commission_rate` >= 5 AND `default_commission_rate` <= 30
  ),
  CONSTRAINT `chk_depth_range` CHECK (`depth` <= 5)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Hierarchical event categories with Ethiopian cultural context. Hierarchy managed in application logic.';

-- ============================================
-- VIEWS FOR CATEGORY MANAGEMENT (SESSION VARIABLE FREE)
-- ============================================

-- View for category hierarchy (application will handle language)
CREATE OR REPLACE VIEW `vw_category_hierarchy` AS
WITH RECURSIVE category_tree AS (
    -- Root categories
    SELECT 
        id,
        parent_id,
        name,
        name_amharic,
        slug,
        depth,
        path,
        CONCAT(name, ' / ', name_amharic) as bilingual_name,
        CAST(id AS CHAR(200)) as hierarchy_path,
        1 as level_order,
        sort_order,
        hierarchy_order
    FROM event_categories
    WHERE parent_id IS NULL
      AND is_active = TRUE
      AND deleted_at IS NULL
    
    UNION ALL
    
    -- Child categories
    SELECT 
        c.id,
        c.parent_id,
        c.name,
        c.name_amharic,
        c.slug,
        c.depth,
        c.path,
        CONCAT(
            REPEAT('  ', ct.level_order), 
            '└─ ', 
            c.name, 
            ' / ', 
            c.name_amharic
        ) as bilingual_name,
        CONCAT(ct.hierarchy_path, '.', c.id) as hierarchy_path,
        ct.level_order + 1 as level_order,
        c.sort_order,
        c.hierarchy_order
    FROM event_categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
    WHERE c.is_active = TRUE
      AND c.deleted_at IS NULL
)
SELECT * FROM category_tree
ORDER BY hierarchy_path;

-- View for event discovery (returns both languages, app handles display)
CREATE OR REPLACE VIEW `vw_public_categories` AS
SELECT 
    c.id,
    c.parent_id,
    c.name,
    c.name_amharic,
    c.slug,
    c.description,
    c.description_amharic,
    c.icon,
    c.icon_amharic,
    c.color,
    c.image_url,
    c.cultural_significance,
    c.total_events,
    c.upcoming_events,
    c.sort_order,
    c.is_featured,
    c.featured_until,
    -- Child count for UI indicators
    (SELECT COUNT(*) FROM event_categories child 
     WHERE child.parent_id = c.id 
       AND child.is_active = TRUE 
       AND child.deleted_at IS NULL) as child_count,
    -- Hierarchy info
    c.depth,
    c.hierarchy_order
FROM event_categories c
WHERE c.is_active = TRUE
  AND c.deleted_at IS NULL
ORDER BY c.sort_order, c.hierarchy_order, c.name;

-- View for Ethiopian cultural categories (fixed for production)
CREATE OR REPLACE VIEW `vw_ethiopian_cultural_categories` AS
SELECT 
    c.id,
    c.name,
    c.name_amharic,
    c.cultural_significance,
    c.common_regions,
    c.total_events,
    -- Regional popularity (safe JSON handling)
    CASE 
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Addis Ababa') IS NOT NULL THEN 'ADDIS_ABABA'
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Amhara') IS NOT NULL THEN 'AMHARA'
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Oromia') IS NOT NULL THEN 'OROMIA'
        WHEN c.common_regions IS NOT NULL THEN 'MULTI_REGION'
        ELSE 'REGION_UNKNOWN'
    END as primary_region,
    -- Seasonality
    c.typical_season,
    -- Age appropriateness
    CASE 
        WHEN c.min_age_requirement >= 18 THEN 'ADULT_ONLY'
        WHEN c.min_age_requirement > 0 THEN 'AGE_RESTRICTED'
        ELSE 'ALL_AGES'
    END as age_category,
    -- Approval requirements
    c.requires_approval
FROM event_categories c
WHERE c.is_active = TRUE
  AND c.deleted_at IS NULL
  AND c.cultural_significance IN ('high', 'medium')
ORDER BY c.cultural_significance DESC, c.total_events DESC;

-- View for admin category management
CREATE OR REPLACE VIEW `vw_admin_categories` AS
SELECT 
    c.id,
    c.name,
    c.name_amharic,
    c.slug,
    c.parent_id,
    p.name as parent_name,
    p.name_amharic as parent_name_amharic,
    c.depth,
    c.is_active,
    c.is_featured,
    c.featured_until,
    c.total_events,
    c.upcoming_events,
    c.total_tickets_sold,
    c.requires_approval,
    c.min_age_requirement,
    c.default_commission_rate,
    c.created_at,
    c.updated_at,
    -- Status indicator
    CASE 
        WHEN c.deleted_at IS NOT NULL THEN 'DELETED'
        WHEN c.is_active = FALSE THEN 'INACTIVE'
        WHEN c.is_featured = TRUE AND (c.featured_until IS NULL OR c.featured_until > NOW()) THEN 'FEATURED'
        ELSE 'ACTIVE'
    END as status
FROM event_categories c
LEFT JOIN event_categories p ON c.parent_id = p.id
ORDER BY c.depth, c.parent_id, c.hierarchy_order;