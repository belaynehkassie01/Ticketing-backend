-- Migration: 003_create_roles_table.sql
-- Description: Create roles table for RBAC (Role-Based Access Control)
-- Dependencies: None (can be created after cities)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(50) UNIQUE NOT NULL,
  `name_amharic` VARCHAR(50),
  `description` TEXT,
  `description_amharic` TEXT,
  
  `is_system_role` BOOLEAN DEFAULT FALSE,
  `is_default` BOOLEAN DEFAULT FALSE,
  
  `permissions` JSON DEFAULT NULL,
  
  `scope` ENUM('platform', 'organizer', 'event') DEFAULT 'platform',
  
  `parent_role_id` BIGINT UNSIGNED NULL,
  `level` INT DEFAULT 0,
  
  `is_active` BOOLEAN DEFAULT TRUE,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`parent_role_id`) REFERENCES `roles`(`id`)
    ON DELETE SET NULL,
  
  INDEX `idx_name` (`name`),
  INDEX `idx_is_system_role` (`is_system_role`),
  INDEX `idx_is_default` (`is_default`),
  INDEX `idx_scope` (`scope`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_level` (`level`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_scope_active` (`scope`, `is_active`),
  
  CONSTRAINT `chk_role_level` CHECK (`level` >= 0),
  
  UNIQUE KEY `uq_role_hierarchy` (`name`, `parent_role_id`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;