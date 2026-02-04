-- Converted from MySQL to SQLite
-- Original file: 001_create_users_table.sql
-- Migration: 001_create_users_table.sql
-- Description: Create users table with Ethiopian phone-first authentication
-- Dependencies: Requires cities table to be created first

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins, staff)
-- Ethiopian Context: Phone-first auth, OTP verification, Amharic/English support
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  -- Primary identifier
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Authentication & Contact
  phone VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255),
  full_name VARCHAR(100),
  
  -- User Role & Localization
  role TEXT DEFAULT 'customer',
  preferred_language TEXT DEFAULT 'am',
  
  -- Ethiopian Context
  city_id INTEGEREGER NULL,
  phone_verified INTEGER DEFAULT FALSE,
  verification_code VARCHAR(6),
  verification_expiry TEXT,
  
  -- Security & Status
  is_active INTEGER DEFAULT TRUE,
  is_suspended INTEGER DEFAULT FALSE,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TEXT NULL,
  last_login TEXT NULL,
  device_id VARCHAR(255),
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL,
  
  -- Indexes
  INDEX idx_phone_verified (phone_verified), -- INDEX converted separately (role), -- INDEX converted separately (is_active), -- INDEX converted separately (city_id), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Core users table with Ethiopian phone-first authentication';

-- Insert default admin user (password will be hashed in seed)
INSERT IGNORE INTEGERO users (
  phone,
  email,
  password_hash,
  full_name,
  role,
  preferred_language,
  phone_verified,
  is_active
) VALUES (
  '+251911223344',
  'admin@ethiotickets.com',
  NULL, -- Will be set in seed with bcrypt hash
  'System Administrator',
  'admin',
  'en',
  TRUE,
  TRUE
);

SET FOREIGN_KEY_CHECKS = 1;