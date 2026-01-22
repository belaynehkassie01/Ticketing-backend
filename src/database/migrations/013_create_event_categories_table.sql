-- ============================================
-- TABLE: event_categories
-- Purpose: Store categories for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS `event_categories` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `description` TEXT,
  `icon` VARCHAR(50),
  `color` VARCHAR(7),
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sort_order` (`sort_order`),
  UNIQUE INDEX `uq_name` (`name`),
  
  CONSTRAINT `chk_color_format` CHECK (`color` IS NULL OR `color` REGEXP '^#[0-9A-Fa-f]{6}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;