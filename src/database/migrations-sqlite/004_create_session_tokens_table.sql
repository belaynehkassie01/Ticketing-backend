-- Converted from MySQL to SQLite
-- Original file: 004_create_session_tokens_table.sql
-- Migration: 004_create_session_tokens_table.sql
-- Description: Create session tokens table for JWT-based authentication
-- Dependencies: Requires users and cities tables

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS session_tokens (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  
  token VARCHAR(512) UNIQUE NOT NULL,
  refresh_token VARCHAR(255) UNIQUE NOT NULL,
  token_type TEXT DEFAULT 'access',
  
  device_id VARCHAR(255) NOT NULL,
  device_name VARCHAR(100),
  device_type TEXT DEFAULT 'mobile',
  os VARCHAR(50),
  os_version VARCHAR(20),
  browser VARCHAR(50),
  browser_version VARCHAR(20),
  app_version VARCHAR(20),
  
  ip_address VARCHAR(45),
  city_id INTEGEREGER NULL,
  country_code VARCHAR(3) DEFAULT 'ET',
  latitude REAL,
  longitude REAL,
  network_type TEXT DEFAULT 'unknown',
  
  is_active INTEGER DEFAULT TRUE,
  is_blacklisted INTEGER DEFAULT FALSE,
  blacklist_reason TEXT NULL,
  
  expires_at TEXT NOT NULL,
  refresh_expires_at TEXT NOT NULL,
  
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  login_method TEXT DEFAULT 'password',
  
  user_agent TEXT,
  meta_data JSON DEFAULT NULL,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  last_used_at TEXT NULL,
  revoked_at TEXT NULL,
  deleted_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL, -- INDEX converted separately (user_id), -- INDEX converted separately (token(100)), -- INDEX converted separately (refresh_token(100)), -- INDEX converted separately (device_id), -- INDEX converted separately (is_active), -- INDEX converted separately (expires_at), -- INDEX converted separately (refresh_expires_at), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (country_code), -- INDEX converted separately (device_type), -- INDEX converted separately (user_id, is_active), -- INDEX converted separately (is_active, expires_at), -- INDEX converted separately (user_id, device_id)
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;