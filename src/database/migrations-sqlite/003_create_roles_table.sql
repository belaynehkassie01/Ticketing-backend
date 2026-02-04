-- Converted from MySQL to SQLite
-- Original file: 003_create_roles_table.sql
-- Migration: 003_create_roles_table.sql
-- Description: Create roles table for RBAC (Role-Based Access Control)
-- Dependencies: None (can be created after cities)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS roles (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  name_amharic VARCHAR(50),
  description TEXT,
  description_amharic TEXT,
  
  is_system_role INTEGER DEFAULT FALSE,
  is_default INTEGER DEFAULT FALSE,
  
  permissions JSON DEFAULT NULL,
  
  scope TEXT DEFAULT 'platform',
  
  parent_role_id INTEGEREGER NULL,
  level INTEGER DEFAULT 0,
  
  is_active INTEGER DEFAULT TRUE,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  FOREIGN KEY (parent_role_id) REFERENCES roles(id)
    ON DELETE SET NULL, -- INDEX converted separately (name), -- INDEX converted separately (is_system_role), -- INDEX converted separately (is_default), -- INDEX converted separately (scope), -- INDEX converted separately (is_active), -- INDEX converted separately (level), -- INDEX converted separately (deleted_at), -- INDEX converted separately (scope, is_active),
  
  CONSTRAINTEGER chk_role_level CHECK (level >= 0),
  
  UNIQUE KEY uq_role_hierarchy (name, parent_role_id)
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;