-- Converted from MySQL to SQLite
-- Original file: 042_create_system_settings_table.sql
-- Migration: 042_create_system_settings_table.sql
-- Purpose: Store system configuration settings

CREATE TABLE IF NOT EXISTS system_settings (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  category VARCHAR(100) NOT NULL,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  setting_type TEXT DEFAULT 'string',
  label VARCHAR(200) NOT NULL,
  description TEXT,
  is_public INTEGER DEFAULT FALSE,
  is_editable INTEGER DEFAULT TRUE,
  applies_to_country VARCHAR(3) DEFAULT 'ET',
  regional_variations JSON COMMENT 'Different values for different regions',
  validation_rules JSON COMMENT 'Validation rules for this setting',
  options JSON COMMENT 'Available options for this setting',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  updated_by INTEGEREGER NULL,
  
  FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT, -- INDEX converted separately (category), -- INDEX converted separately (setting_key), -- INDEX converted separately (is_public), -- INDEX converted separately (is_editable), -- INDEX converted separately (applies_to_country), -- INDEX converted separately (updated_by),
  
  CONSTRAINTEGER chk_setting_key_format -- CHECK (REGEXP not supported in SQLite '^[a-z][a-z0-9_]*$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;