-- ============================================
-- TABLE: roles
-- Purpose: Store system roles and permissions (from your original users.role enum)
-- ============================================
CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `description` VARCHAR(255),
  `permissions` JSON COMMENT 'JSON array of permission strings',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_system` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_is_system` (`is_system`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;