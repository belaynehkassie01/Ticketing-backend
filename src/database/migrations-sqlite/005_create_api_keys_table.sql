-- Converted from MySQL to SQLite
-- Original file: 005_create_api_keys_table.sql
-- Migration: 005_create_api_keys_table.sql
-- Description: Create API keys table with ALL improvements applied
-- Dependencies: Requires users AND organizers tables (organizer_id FK)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS api_keys (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  api_key VARCHAR(64) UNIQUE NOT NULL,
  api_secret_hash VARCHAR(255) NOT NULL,
  api_secret_salt VARCHAR(64),
  
  name VARCHAR(200) NOT NULL,
  description TEXT,
  description_amharic TEXT,
  
  user_id INTEGEREGER NULL,
  organizer_id INTEGEREGER NULL,
  admin_id INTEGEREGER NULL,
  
  permissions JSON NOT NULL DEFAULT (JSON_OBJECT()),
  scope TEXT DEFAULT 'read',
  allowed_endpoINTEGERs JSON NOT NULL DEFAULT (JSON_ARRAY()),
  denied_endpoINTEGERs JSON NOT NULL DEFAULT (JSON_ARRAY()),
  
  rate_limit_per_minute INTEGER DEFAULT 60,
  rate_limit_per_hour INTEGER DEFAULT 1000,
  rate_limit_per_day INTEGER DEFAULT 10000,
  rate_limit_window TEXT DEFAULT 'minute',
  
  is_active INTEGER DEFAULT TRUE,
  is_revoked INTEGER DEFAULT FALSE,
  revoked_at TEXT NULL,
  revoked_reason TEXT NULL,
  last_used_at TEXT NULL,
  last_used_ip VARCHAR(45),
  last_used_endpoINTEGER VARCHAR(255),
  
  usage_count INTEGEREGER DEFAULT 0,
  failed_attempts INTEGER DEFAULT 0,
  locked_until TEXT NULL,
  
  ip_whitelist JSON NOT NULL DEFAULT (JSON_ARRAY()),
  ip_blacklist JSON NOT NULL DEFAULT (JSON_ARRAY()),
  allowed_countries JSON NOT NULL DEFAULT (JSON_ARRAY('ET')),
  blocked_countries JSON NOT NULL DEFAULT (JSON_ARRAY()),
  
  expires_at TEXT NULL,
  rotated_at TEXT NULL,
  previous_api_key VARCHAR(64) NULL,
  
  allowed_for_country VARCHAR(3) DEFAULT 'ET',
  allowed_ips_ethiopia_only INTEGER DEFAULT TRUE,
  allowed_telecom_operators JSON NOT NULL DEFAULT (JSON_ARRAY('ethio_telecom')),
  
  webhook_url VARCHAR(500) NULL,
  webhook_secret VARCHAR(255) NULL,
  webhook_enabled INTEGER DEFAULT FALSE,
  
  created_by INTEGEREGER NULL,
  updated_by INTEGEREGER NULL,
  
  meta_data JSON DEFAULT NULL,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id) ON DELETE CASCADE,
  FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL, -- INDEX converted separately (api_key), -- INDEX converted separately (is_active), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (expires_at), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (scope), -- INDEX converted separately (last_used_at), -- INDEX converted separately (revoked_at), -- INDEX converted separately (created_by), -- INDEX converted separately (updated_by), -- INDEX converted separately (is_active, expires_at), -- INDEX converted separately (user_id, is_active), -- INDEX converted separately (organizer_id, is_active), -- INDEX converted separately (api_key, is_active), -- INDEX converted separately (is_active, revoked_at), -- INDEX converted separately (scope, is_active), -- INDEX converted separately (user_id, organizer_id, admin_id, is_active),
  
  UNIQUE KEY uq_user_api_key (user_id, api_key),
  UNIQUE KEY uq_organizer_api_key (organizer_id, api_key),
  UNIQUE KEY uq_admin_api_key (admin_id, api_key),
  
  CONSTRAINTEGER chk_rate_limit_minute CHECK (rate_limit_per_minute >= 0),
  CONSTRAINTEGER chk_rate_limit_hour CHECK (rate_limit_per_hour >= 0),
  CONSTRAINTEGER chk_rate_limit_day CHECK (rate_limit_per_day >= 0),
  CONSTRAINTEGER chk_usage_count CHECK (usage_count >= 0),
  CONSTRAINTEGER chk_failed_attempts CHECK (failed_attempts >= 0),
  CONSTRAINTEGER chk_api_key_length CHECK (CHAR_LENGTH(api_key) BETWEEN 32 AND 64),
  CONSTRAINTEGER chk_at_least_one_owner CHECK (
    (user_id IS NOT NULL) OR
    (organizer_id IS NOT NULL) OR
    (admin_id IS NOT NULL)
  ),
  CONSTRAINTEGER chk_webhook_config CHECK (
    (webhook_url IS NULL AND webhook_secret IS NULL AND webhook_enabled = FALSE) OR
    (webhook_url IS NOT NULL AND webhook_secret IS NOT NULL AND webhook_enabled = TRUE)
  )
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;