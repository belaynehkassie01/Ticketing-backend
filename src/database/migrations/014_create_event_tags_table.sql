-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_tags` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `slug` VARCHAR(100) UNIQUE NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_slug` (`slug`),
  INDEX `idx_is_active` (`is_active`),
  FULLTEXT `idx_search` (`name`, `name_amharic`),
  
  CONSTRAINT `chk_slug_format` CHECK (`slug` REGEXP '^[a-z0-9-]+$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;