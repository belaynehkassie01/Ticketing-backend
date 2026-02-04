-- Converted from MySQL to SQLite
-- Original file: 006_create_qr_codes_table.sql
-- Migration: 006_create_qr_codes_table.sql
-- Description: Create QR codes table for tickets, payments, and Ethiopian TeleBirr
-- Dependencies: Requires users table (optional foreign keys)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS qr_codes (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  qr_data TEXT NOT NULL,
  qr_hash VARCHAR(64) UNIQUE NOT NULL,
  qr_image_url VARCHAR(500),
  qr_image_path VARCHAR(500),
  
  entity_type TEXT NOT NULL,
  entity_id INTEGEREGER NOT NULL,
  
  qr_format TEXT DEFAULT 'ticket',
  qr_version VARCHAR(20) DEFAULT '1.0',
  generated_in_country VARCHAR(3) DEFAULT 'ET',
  generated_by_user INTEGEREGER NULL,
  
  scan_count INTEGEREGER DEFAULT 0,
  max_scans INTEGEREGER NULL,
  last_scanned_at TEXT NULL,
  last_scanned_by INTEGEREGER NULL,
  last_scanned_device_id VARCHAR(255),
  last_scanned_ip VARCHAR(45),
  
  is_active INTEGER DEFAULT TRUE,
  is_valid INTEGER DEFAULT TRUE,
  expires_at TEXT NULL,
  invalidated_at TEXT NULL,
  invalidation_reason TEXT NULL,
  invalidated_by INTEGEREGER NULL,
  
  ticket_data JSON NULL,
  payment_data JSON NULL,
  telebirr_data JSON NULL,
  promo_data JSON NULL,
  
  meta_data JSON DEFAULT NULL,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL, -- INDEX converted separately (qr_hash), -- INDEX converted separately (entity_type, entity_id), -- INDEX converted separately (is_active), -- INDEX converted separately (expires_at), -- INDEX converted separately (last_scanned_at), -- INDEX converted separately (qr_format), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at), -- INDEX converted separately (generated_by_user), -- INDEX converted separately (is_active, expires_at), -- INDEX converted separately (entity_type, entity_id, is_active), -- INDEX converted separately (qr_format, is_active), -- INDEX converted separately (entity_type, qr_format),
  
  -- Optional foreign keys (remove if users table not ready)
  FOREIGN KEY (generated_by_user) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (last_scanned_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (invalidated_by) REFERENCES users(id) ON DELETE SET NULL,
  
  CONSTRAINTEGER chk_entity_id CHECK (entity_id > 0),
  CONSTRAINTEGER chk_scan_count CHECK (scan_count >= 0),
  CONSTRAINTEGER chk_max_scans CHECK (max_scans IS NULL OR max_scans > 0),
  CONSTRAINTEGER chk_expiry CHECK (expires_at IS NULL OR expires_at > created_at)
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;