-- Converted from MySQL to SQLite
-- Original file: All-migrations.sql
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

-- Migration: 002_create_cities_table.sql
-- Description: Create Ethiopian cities table with regions, Amharic names, and coordinates
-- Collation: utf8mb4_0900_ai_ci for proper Amharic FULLTEXT search
-- Dependencies: None (first table to create)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: cities
-- ============================================

CREATE TABLE IF NOT EXISTS cities (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  
  -- Ethiopian regions (ENUM for data consistency)
  region TEXT NOT NULL,
  
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  
  latitude REAL,
  longitude REAL,
  elevation INTEGER,
  
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  
  population INTEGER,
  area_sq_km REAL,
  postal_code_prefix VARCHAR(10),
  phone_area_code VARCHAR(5),
  
  major_venues JSON DEFAULT NULL,
  popular_event_types JSON DEFAULT NULL,
  
  is_active INTEGER DEFAULT TRUE,
  is_major_city INTEGER DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  
  description TEXT,
  description_amharic TEXT,
  keywords VARCHAR(500),
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Indexes
  INDEX idx_name (name), -- INDEX converted separately (region), -- INDEX converted separately (is_active), -- INDEX converted separately (is_active, is_major_city), -- INDEX converted separately (sort_order), -- INDEX converted separately (deleted_at), -- INDEX converted separately (region, is_active), -- INDEX converted separately (name_amharic(50)),
  
  -- Unique constraINTEGER
  UNIQUE KEY uq_city_region (name, region),
  
  -- Full-text search (proper collation for Amharic)
  FULLTEXT KEY idx_city_search (name, name_amharic, region, description)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;

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


-- Migration: 007_create_organizer_applications_table.sql
-- Description: Store organizer applications with all optimizations
-- Dependencies: Requires users and cities tables

CREATE TABLE IF NOT EXISTS organizer_applications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  
  -- Business Information
  business_name VARCHAR(200) NOT NULL,
  business_name_amharic VARCHAR(200),
  business_type TEXT NOT NULL,
  business_description TEXT,
  business_description_amharic TEXT,
  
  -- Contact Information
  contact_person VARCHAR(100),
  contact_person_amharic VARCHAR(100),
  contact_phone VARCHAR(20) NOT NULL,
  contact_email VARCHAR(100),
  
  -- Ethiopian Legal Information
  tin_number VARCHAR(50) COMMENT 'Ethiopian TIN',
  business_license_number VARCHAR(100) COMMENT 'Business license number',
  vat_registered INTEGER DEFAULT FALSE,
  vat_number VARCHAR(50),
  
  -- Ethiopian Address
  region TEXT NOT NULL,
  city_id INTEGEREGER NULL,
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  full_address TEXT,
  
  -- Ethiopian Bank Details
  bank_name TEXT NOT NULL,
  bank_account_number VARCHAR(100) NOT NULL,
  bank_account_holder VARCHAR(100) NOT NULL,
  bank_branch VARCHAR(100),
  bank_branch_city VARCHAR(100),
  
  -- Document Uploads (file paths)
  id_document_front VARCHAR(255),
  id_document_back VARCHAR(255),
  business_license_document VARCHAR(255),
  tax_certificate_document VARCHAR(255),
  bank_letter_document VARCHAR(255),
  
  -- Application Status
  status TEXT DEFAULT 'pending',
  admin_notes TEXT,
  review_notes TEXT,
  
  -- Processing Information
  submitted_at TEXT DEFAULT CURRENT_TEXT,
  reviewed_at TEXT NULL,
  reviewed_by INTEGEREGER NULL,
  
  -- Business Projections
  expected_monthly_events INTEGER,
  primary_event_type VARCHAR(100),
  previous_experience TEXT,
  
  -- Audit Tracking (Added per recommendation)
  created_by INTEGEREGER NULL COMMENT 'User who submitted (usually same as user_id)',
  updated_by INTEGEREGER NULL COMMENT 'User who last updated',
  
  -- Metadata
  meta_data JSON DEFAULT NULL,
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL,
  FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE SET NULL,
  FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL,
  
  -- Indexes (Enhanced with composite indexes)
  INDEX idx_user_id (user_id), -- INDEX converted separately (status), -- INDEX converted separately (submitted_at), -- INDEX converted separately (reviewed_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at), -- INDEX converted separately (business_name(100)), -- INDEX converted separately (tin_number), -- INDEX converted separately (region), -- INDEX converted separately (city_id), -- INDEX converted separately (created_by), -- INDEX converted separately (updated_by), -- INDEX converted separately (reviewed_by),
  
  -- Composite Indexes for Performance (Added per recommendation)
  INDEX idx_user_status_deleted (user_id, status, deleted_at), -- INDEX converted separately (status, submitted_at), -- INDEX converted separately (region, status), -- INDEX converted separately (city_id, status), -- INDEX converted separately (user_id, created_at),
  
  -- ConstraINTEGERs
  CONSTRAINTEGER chk_contact_phone CHECK (
    contact_phone REGEXP '^(09[0-9]{8}|\\+2519[0-9]{8})$'
  ),
  CONSTRAINTEGER chk_expected_events CHECK (
    expected_monthly_events IS NULL OR expected_monthly_events > 0
  ),
  CONSTRAINTEGER chk_tin_format CHECK (
    tin_number IS NULL OR 
    tin_number REGEXP '^[0-9]{10,15}$'
  ),
  CONSTRAINTEGER chk_vat_number CHECK (
    vat_number IS NULL OR 
    vat_number REGEXP '^[0-9]{10,15}$'
  )
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trigger to enforce one pending application per user (INSERT)
DELIMITER $$

CREATE TRIGGER trg_one_pending_application_per_user_insert
BEFORE INSERT ON organizer_applications
FOR EACH ROW
BEGIN
    DECLARE pending_count INTEGER;
    
    -- Count existing pending/under_review/needs_info applications for this user
    SELECT COUNT(*) INTEGERO pending_count
    FROM organizer_applications
    WHERE user_id = NEW.user_id
      AND status IN ('pending', 'under_review', 'needs_info')
      AND deleted_at IS NULL;
    
    IF pending_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already has a pending organizer application';
    END IF;
END$$

DELIMITER ;

-- Trigger to enforce one pending application per user (UPDATE)
DELIMITER $$

CREATE TRIGGER trg_one_pending_application_per_user_update
BEFORE UPDATE ON organizer_applications
FOR EACH ROW
BEGIN
    -- Only check if status is being changed to a pending state
    IF NEW.status IN ('pending', 'under_review', 'needs_info') 
       AND OLD.status NOT IN ('pending', 'under_review', 'needs_info')
       AND NEW.deleted_at IS NULL THEN
        
        DECLARE pending_count INTEGER;
        
        -- Count existing pending applications for this user (excluding current record)
        SELECT COUNT(*) INTEGERO pending_count
        FROM organizer_applications
        WHERE user_id = NEW.user_id
          AND id != NEW.id
          AND status IN ('pending', 'under_review', 'needs_info')
          AND deleted_at IS NULL;
        
        IF pending_count > 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User already has a pending organizer application';
        END IF;
    END IF;
END$$

DELIMITER ;

-- View for pending applications (Enhanced)
CREATE OR REPLACE VIEW vw_pending_organizer_applications AS
SELECT 
    oa.*,
    u.phone as user_phone,
    u.full_name as user_name,
    u.email as user_email,
    u.phone_verified as user_phone_verified,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    TEXTDIFF(HOUR, oa.submitted_at, NOW()) as hours_pending,
    TEXTDIFF(DAY, oa.submitted_at, NOW()) as days_pending,
    -- Document completion percentage
    CASE 
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL 
             AND oa.business_license_document IS NOT NULL 
             AND oa.tax_certificate_document IS NOT NULL 
             AND oa.bank_letter_document IS NOT NULL THEN 100
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL 
             AND oa.business_license_document IS NOT NULL THEN 75
        WHEN oa.id_document_front IS NOT NULL 
             AND oa.id_document_back IS NOT NULL THEN 50
        WHEN oa.id_document_front IS NOT NULL THEN 25
        ELSE 0
    END as document_completion_percentage
FROM organizer_applications oa
LEFT JOIN users u ON oa.user_id = u.id
LEFT JOIN cities c ON oa.city_id = c.id
WHERE oa.status IN ('pending', 'under_review', 'needs_info')
  AND oa.deleted_at IS NULL
ORDER BY oa.submitted_at ASC;

-- View for completed applications (for reporting)
CREATE OR REPLACE VIEW vw_completed_organizer_applications AS
SELECT 
    oa.*,
    u.phone as user_phone,
    u.full_name as user_name,
    c.name as city_name,
    ru.full_name as reviewer_name,
    CASE 
        WHEN oa.status = 'approved' THEN 'Approved'
        WHEN oa.status = 'rejected' THEN 'Rejected'
        ELSE 'Other'
    END as final_status,
    TEXTDIFF(HOUR, oa.submitted_at, oa.reviewed_at) as review_time_hours
FROM organizer_applications oa
LEFT JOIN users u ON oa.user_id = u.id
LEFT JOIN cities c ON oa.city_id = c.id
LEFT JOIN users ru ON oa.reviewed_by = ru.id
WHERE oa.status IN ('approved', 'rejected')
  AND oa.deleted_at IS NULL
ORDER BY oa.reviewed_at DESC;



-- Migration: 008_create_organizers_table.sql
-- Description: Create organizers table for approved business accounts
-- Dependencies: Requires users, cities, and organizer_applications tables

CREATE TABLE IF NOT EXISTS organizers (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,

  -- Link to user account
  user_id INTEGEREGER UNIQUE NOT NULL,

  -- Link to application (if migrated from application)
  application_id INTEGEREGER NULL,

  -- Business Information
  business_name VARCHAR(200) NOT NULL,
  business_name_amharic VARCHAR(200),
  business_type TEXT NOT NULL,
  business_description TEXT,
  business_description_amharic TEXT,

  -- Ethiopian Legal Information
  tin_number VARCHAR(50) UNIQUE NULL,
  business_license_number VARCHAR(100) UNIQUE NULL,
  vat_registered INTEGER DEFAULT FALSE,
  vat_number VARCHAR(50) DEFAULT NULL,

  -- Contact Information
  contact_person VARCHAR(100),
  contact_person_amharic VARCHAR(100),
  business_phone VARCHAR(20) NOT NULL,
  secondary_phone VARCHAR(20) DEFAULT NULL,
  business_email VARCHAR(100) DEFAULT NULL,
  website VARCHAR(255) DEFAULT NULL,

  -- Ethiopian Address
  region TEXT NOT NULL,
  city_id INTEGEREGER NULL,
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  kebele VARCHAR(100),
  house_number VARCHAR(50),
  landmark TEXT,
  full_address TEXT,

  -- Geographic Coordinates
  latitude REAL,
  longitude REAL,
  google_maps_url VARCHAR(500),

  -- Ethiopian Bank Details
  bank_name TEXT NOT NULL,
  bank_account_number VARCHAR(100) NOT NULL,
  bank_account_holder VARCHAR(100) NOT NULL,
  bank_branch VARCHAR(100),
  bank_branch_city VARCHAR(100),
  bank_verification_status TEXT DEFAULT 'pending',

  -- Verification & Status
  status TEXT DEFAULT 'approved',
  verification_level TEXT DEFAULT 'basic',
  verified_at TEXT NULL,
  verified_by INTEGEREGER NULL,
  verification_notes TEXT,

  -- Commission & Payments
  commission_rate REAL DEFAULT 10.00,
  custom_commission_rate REAL NULL,
  payout_method TEXT DEFAULT 'cbe_transfer',
  payout_threshold REAL DEFAULT 5000.00,

  -- Financial Stats
  total_events INTEGEREGER DEFAULT 0,
  total_tickets_sold INTEGEREGER DEFAULT 0,
  total_revenue REAL DEFAULT 0.00,
  available_balance REAL DEFAULT 0.00,
  pending_balance REAL DEFAULT 0.00,
  total_payouts REAL DEFAULT 0.00,

  -- Ratings & Reviews
  rating REAL DEFAULT 0.00,
  rating_count INTEGEREGER DEFAULT 0,
  review_count INTEGEREGER DEFAULT 0,

  -- Team Management
  team_size INTEGER DEFAULT 1,
  team_members JSON DEFAULT NULL,

  -- Settings & Preferences
  notification_preferences JSON DEFAULT (JSON_OBJECT(
    'sms', TRUE, 'email', TRUE, 'push', FALSE,
    'payout_notifications', TRUE, 'event_reminders', TRUE,
    'new_ticket_sales', TRUE
  )),
  communication_language TEXT DEFAULT 'both',
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',

  -- Metadata
  meta_data JSON DEFAULT NULL,

  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,

  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (application_id) REFERENCES organizer_applications(id) ON DELETE SET NULL,
  FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET NULL,
  FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,

  -- Indexes
  INDEX idx_user_id (user_id), -- INDEX converted separately (status), -- INDEX converted separately (business_name(100)), -- INDEX converted separately (tin_number), -- INDEX converted separately (business_license_number), -- INDEX converted separately (region), -- INDEX converted separately (city_id), -- INDEX converted separately (verified_at), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at)
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
SET FOREIGN_KEY_CHECKS = 1;



-- ============================================
-- TABLE: organizer_documents
-- Purpose: Store organizer verification documents
-- Dependencies: Requires organizers and users tables
-- ============================================

CREATE TABLE IF NOT EXISTS organizer_documents (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  
  document_type TEXT NOT NULL,
  
  document_name VARCHAR(200) NOT NULL,
  file_url VARCHAR(500) NOT NULL,
  mime_type VARCHAR(100),
  file_size INTEGEREGER,
  
  -- Verification
  is_verified INTEGER DEFAULT FALSE,
  verified_by INTEGEREGER NULL,
  verified_at TEXT NULL,
  verification_notes TEXT,
  
  -- Optional metadata
  document_number VARCHAR(100),
  issued_by VARCHAR(200),
  issue_date DATE NULL,
  expiry_date DATE NULL,
  
  -- Status
  is_active INTEGER DEFAULT TRUE,
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_organizer (organizer_id), -- INDEX converted separately (document_type), -- INDEX converted separately (is_verified), -- INDEX converted separately (expiry_date), -- INDEX converted separately (verified_by), -- INDEX converted separately (is_active), -- INDEX converted separately (created_at),
  
  -- ConstraINTEGERs
  CONSTRAINTEGER chk_file_size CHECK (file_size >= 0),
  CONSTRAINTEGER chk_expiry_date CHECK (expiry_date IS NULL OR expiry_date > issue_date)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Organizer verification documents with audit and status tracking';

SET FOREIGN_KEY_CHECKS = 1;


-- Migration: 010_create_admin_actions_table.sql
-- Description: Store administrative action logs for audit trail and compliance
-- Dependencies: Requires users table (admin_id FK)
-- Best Practices: Ethiopian timezone handled in app, no dangerous defaults, clear JSON structure

-- ============================================
-- TABLE: admin_actions
-- Purpose: Audit trail of all administrative actions for compliance, security, and accountability
-- Ethiopian Context: Local timezone tracking via application logic
-- ============================================

CREATE TABLE IF NOT EXISTS admin_actions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Admin Information (historical snapshot - application must provide)
  admin_id INTEGEREGER NOT NULL COMMENT 'User who performed the action',
  admin_role_at_time TEXT NOT NULL COMMENT 'Role at time of action (application must provide)',
  
  -- Action Details
  action_type TEXT NOT NULL,
  
  action_name VARCHAR(100) NOT NULL,
  action_description TEXT,
  
  -- Target Information (application rule: if target_id exists, target_type must be set)
  target_type TEXT DEFAULT NULL COMMENT 'Must be set if target_id is provided',
  
  target_id INTEGEREGER DEFAULT NULL,
  target_name VARCHAR(200),
  
  -- Change Tracking (Before/After) - Clear JSON structure
  previous_values JSON COMMENT '{"field_name": "old_value", ...} - Snapshot before change',
  new_values JSON COMMENT '{"field_name": "new_value", ...} - Snapshot after change',
  changed_fields JSON COMMENT '["field1", "field2", ...] - Array of modified field names',
  
  -- Action Metadata
  requires_approval INTEGER DEFAULT FALSE COMMENT 'Sensitive actions requiring supervisor approval',
  approved_by INTEGEREGER NULL COMMENT 'Supervisor who approved the action',
  approved_at TEXT NULL,
  approval_notes TEXT,
  
  requires_review INTEGER DEFAULT FALSE COMMENT 'Actions that need periodic review',
  reviewed_by INTEGEREGER NULL,
  reviewed_at TEXT NULL,
  review_notes TEXT,
  
  -- Ethiopian Context (Application sets local time)
  performed_at_local TEXT NULL COMMENT 'Local time in Africa/Addis_Ababa (set by application)',
  performed_in_city_id INTEGEREGER NULL COMMENT 'City where action was performed',
  performed_from_ip VARCHAR(45),
  
  -- Device & Session Information
  device_id VARCHAR(255),
  device_type TEXT DEFAULT 'desktop',
  session_id VARCHAR(100),
  user_agent TEXT,
  browser_fingerprINTEGER TEXT,
  
  -- Status & Impact
  status TEXT DEFAULT 'completed',
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  
  impact_level TEXT DEFAULT 'medium',
  affected_users_count INTEGER DEFAULT 1,
  financial_impact_etb REAL DEFAULT 0.00,
  
  -- Related Entities
  related_actions JSON COMMENT 'Array of related action IDs: [123, 456, ...]',
  batch_id VARCHAR(100) COMMENT 'For bulk operations',
  
  -- Compliance & Auditing
  compliance_reference VARCHAR(100),
  audit_trail_id VARCHAR(100),
  gdpr_impact INTEGER DEFAULT FALSE,
  requires_notification INTEGER DEFAULT FALSE,
  
  -- Metadata
  meta_data JSON DEFAULT NULL,
  tags JSON DEFAULT NULL COMMENT 'Tags for categorization and search: ["financial", "urgent", ...]',
  
  -- TEXTs (Server UTC)
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  archived_at TEXT NULL COMMENT 'For GDPR compliance archiving',
  
  -- Foreign Keys (Application will enforce consistency rules)
  FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (performed_in_city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Core Indexes (Optimized for common queries)
  INDEX idx_admin_id (admin_id), -- INDEX converted separately (action_type), -- INDEX converted separately (target_type, target_id), -- INDEX converted separately (created_at), -- INDEX converted separately (requires_approval), -- INDEX converted separately (approved_by), -- INDEX converted separately (status), -- INDEX converted separately (batch_id), -- INDEX converted separately (performed_at_local), -- INDEX converted separately (deleted_at), -- INDEX converted separately (impact_level),
  
  -- Composite Indexes for Performance (Carefully selected)
  INDEX idx_admin_action_time (admin_id, action_type, created_at), -- INDEX converted separately (target_type, target_id, created_at), -- INDEX converted separately (requires_approval, approved_at, status), -- INDEX converted separately (admin_id, created_at), -- INDEX converted separately (action_type, status, created_at)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit trail of administrative actions. Ethiopian timezone handled in app. Target consistency: if target_id exists, target_type must be set.';

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View for admin dashboard (optimized)
CREATE OR REPLACE VIEW vw_admin_action_summary AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.target_name,
    aa.status,
    aa.impact_level,
    aa.financial_impact_etb,
    aa.requires_approval,
    aa.approved_by,
    aa.performed_at_local,
    aa.created_at,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    -- Calculate action duration if available
    TEXTDIFF(SECOND, aa.created_at, aa.updated_at) as duration_seconds,
    -- Count affected users
    aa.affected_users_count,
    -- Format for display
    DATE_FORMAT(aa.created_at, '%Y-%m-%d %H:%i:%s') as formatted_time,
    DATE_FORMAT(aa.performed_at_local, '%Y-%m-%d %H:%i:%s') as formatted_local_time
FROM admin_actions aa
LEFT JOIN users u ON aa.admin_id = u.id
LEFT JOIN cities c ON aa.performed_in_city_id = c.id
WHERE aa.deleted_at IS NULL
ORDER BY aa.created_at DESC;

-- View for compliance reporting
CREATE OR REPLACE VIEW vw_compliance_audit_log AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    u.phone as admin_phone,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.previous_values,
    aa.new_values,
    aa.changed_fields,
    aa.requires_approval,
    aa.approved_by,
    ab.full_name as approved_by_name,
    aa.approved_at,
    aa.approval_notes,
    aa.performed_at_local,
    aa.performed_from_ip,
    aa.device_type,
    aa.session_id,
    aa.gdpr_impact,
    aa.compliance_reference,
    aa.created_at,
    -- Data privacy flags (application-level logic)
    CASE 
        WHEN aa.gdpr_impact = TRUE THEN 'GDPR_RELEVANT'
        WHEN aa.target_type IN ('user', 'organizer') THEN 'PERSONAL_DATA'
        ELSE 'GENERAL_ACTION'
    END as data_privacy_level
FROM admin_actions aa
LEFT JOIN users u ON aa.admin_id = u.id
LEFT JOIN users ab ON aa.approved_by = ab.id
WHERE aa.deleted_at IS NULL
  AND (aa.gdpr_impact = TRUE OR aa.target_type IN ('user', 'organizer', 'payment'))
ORDER BY aa.created_at DESC;


-- Migration: 011_create_payout_requests_table.sql
-- Description: Store organizer payout requests (Ethiopian banking & Telebirr)
-- Dependencies: organizers, users
-- MySQL-safe: No CHECK constraINTEGERs, app-enforced validation

CREATE TABLE IF NOT EXISTS payout_requests (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,

  -- Organizer
  organizer_id INTEGEREGER NOT NULL,

  -- Financial Snapshot
  requested_amount REAL NOT NULL COMMENT 'Requested payout amount (ETB)',
  available_balance REAL NOT NULL COMMENT 'Balance at request time',
  currency CHAR(3) DEFAULT 'ETB',

  -- Ethiopian Bank Details
  bank_name TEXT NOT NULL,

  bank_account_number VARCHAR(100) NOT NULL,
  account_holder_name VARCHAR(100) NOT NULL,
  bank_branch VARCHAR(100),
  bank_branch_city VARCHAR(100),

  -- Workflow Status
  status TEXT DEFAULT 'pending',

  -- Workflow TEXTs
  requested_at TEXT DEFAULT CURRENT_TEXT,
  reviewed_at TEXT NULL,
  processed_at TEXT NULL,
  completed_at TEXT NULL,
  cancelled_at TEXT NULL,

  -- Admin Review
  reviewed_by INTEGEREGER NULL,
  review_notes TEXT,
  rejection_reason TEXT,

  -- Processing Details
  processing_method TEXT DEFAULT 'cbe_online',

  processing_reference VARCHAR(100),
  processing_fee REAL DEFAULT 0.00,
  processing_notes TEXT,

  -- Tax & Compliance
  tax_deducted INTEGER DEFAULT FALSE,
  tax_amount REAL DEFAULT 0.00,
  tax_reference VARCHAR(100),

  -- Security & Audit
  ip_address VARCHAR(45),
  device_id VARCHAR(255),
  user_agent TEXT,

  -- Metadata
  meta_data JSON DEFAULT NULL,

  -- Soft delete & TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,

  -- Foreign Keys
  CONSTRAINTEGER fk_payout_requests_organizer
    FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  CONSTRAINTEGER fk_payout_requests_reviewed_by
    FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,

  -- Indexes
  INDEX idx_organizer_id (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (requested_at), -- INDEX converted separately (reviewed_by), -- INDEX converted separately (bank_name), -- INDEX converted separately (deleted_at),

  -- Composite indexes (important)
  INDEX idx_organizer_status (organizer_id, status), -- INDEX converted separately (status, requested_at), -- INDEX converted separately (bank_name, status)

) 
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Organizer payout requests with Ethiopian banking & Telebirr support';


-- Migration: 012_create_commissions_table.sql
-- Description: Store commission calculations for Ethiopian platform revenue sharing
-- Dependencies: Requires payments, organizers, events tables
-- Ethiopian Context: 15% VAT calculations, Ethiopian tax compliance
-- MySQL Compatibility: Fixed string concatenation, proper DECIMAL precision, explicit FK handling

-- ============================================
-- TABLE: commissions
-- Purpose: Track platform commission calculations with Ethiopian VAT compliance
-- Important: All financial consistency rules enforced at application level
-- ============================================

CREATE TABLE IF NOT EXISTS commissions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Core References
  payment_id INTEGEREGER NOT NULL COMMENT 'Reference to the original payment',
  organizer_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  
  -- Ethiopian Financial Calculations (ETH larger for platform scale)
  ticket_amount REAL NOT NULL COMMENT 'Gross ticket amount in ETB',
  commission_rate REAL NOT NULL COMMENT 'Platform commission percentage (5-15%)',
  commission_amount REAL NOT NULL COMMENT 'commission_rate * ticket_amount',
  
  -- Ethiopian VAT (15%) Calculations
  vat_rate REAL DEFAULT 15.00 COMMENT 'Ethiopian VAT rate (15%)',
  vat_amount REAL NOT NULL COMMENT 'VAT on ticket_amount (payable to ERA)',
  vat_included INTEGER DEFAULT TRUE COMMENT 'Whether VAT is included in ticket price',
  vat_liability TEXT DEFAULT 'organizer' COMMENT 'Who is liable for VAT payment',
  
  -- Net Amounts (VAT-adjusted)
  net_ticket_amount REAL NOT NULL COMMENT 'ticket_amount - vat_amount (if vat_included)',
  organizer_amount REAL NOT NULL COMMENT 'Net amount to organizer after commission and VAT',
  platform_amount REAL NOT NULL COMMENT 'Platform earnings (commission only, VAT separate)',
  
  -- Commission Status & Release
  status TEXT DEFAULT 'pending',
  held_until TEXT NULL COMMENT 'Date when commission can be released',
  released_at TEXT NULL COMMENT 'When commission was made available for payout',
  paid_at TEXT NULL COMMENT 'When commission was actually paid to platform',
  
  -- Payout Linkage (Soft references - may not exist yet)
  payout_id INTEGEREGER NULL COMMENT 'Link to platform payout record (soft reference)',
  organizer_payout_id INTEGEREGER NULL COMMENT 'Link to organizer payout record (soft reference)',
  
  -- Ethiopian Tax Compliance
  tax_withheld INTEGER DEFAULT FALSE COMMENT 'Whether tax was withheld at source',
  tax_withheld_amount REAL DEFAULT 0.00,
  tax_reference VARCHAR(100),
  tax_authority TEXT DEFAULT 'era' COMMENT 'Ethiopian tax authority',
  
  -- Audit & Verification
  calculated_by_system INTEGER DEFAULT TRUE,
  calculation_notes TEXT,
  verified_by INTEGEREGER NULL COMMENT 'Admin who verified calculation',
  verified_at TEXT NULL,
  
  -- Reversal Tracking (for refunds/cancellations)
  is_reversed INTEGER DEFAULT FALSE,
  reversed_at TEXT NULL,
  reversal_reason TEXT NULL,
  reversal_reference_id INTEGEREGER NULL COMMENT 'Link to reversal commission record',
  
  -- Metadata
  meta_data JSON DEFAULT NULL COMMENT 'Calculation details, audit trail',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys (Core references only, payout references are soft)
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Note: payout_id and organizer_payout_id are soft references
  -- They will reference payouts table (to be created later)
  -- Application logic handles consistency
  
  -- Indexes
  INDEX idx_payment (payment_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (event_id), -- INDEX converted separately (status), -- INDEX converted separately (created_at), -- INDEX converted separately (held_until), -- INDEX converted separately (released_at), -- INDEX converted separately (deleted_at),
  
  -- Composite Indexes for Performance
  INDEX idx_organizer_status (organizer_id, status), -- INDEX converted separately (event_id, status), -- INDEX converted separately (payment_id, organizer_id), -- INDEX converted separately (status, created_at), -- INDEX converted separately (organizer_id, created_at),
  
  -- Unique constraINTEGER to prevent duplicate commissions per payment
  UNIQUE KEY uq_payment_commission (payment_id)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian commission calculations with 15% VAT compliance. Amounts in ETB. Payout references are soft. All financial consistency enforced in application.';

-- ============================================
-- VIEWS FOR FINANCIAL REPORTING (FIXED STRING CONCATENATION)
-- ============================================

-- View for organizer commission dashboard
CREATE OR REPLACE VIEW vw_organizer_commissions AS
SELECT 
    c.id,
    c.organizer_id,
    o.business_name,
    c.event_id,
    e.title as event_title,
    c.ticket_amount,
    c.commission_rate,
    c.commission_amount,
    c.vat_amount,
    c.organizer_amount,
    c.status,
    c.created_at,
    c.released_at,
    c.paid_at,
    -- Financial summary
    CASE 
        WHEN c.status = 'paid' THEN c.organizer_amount
        WHEN c.status = 'released' THEN c.organizer_amount
        ELSE 0.00
    END as available_amount,
    -- Status display (FIXED: Using CONCAT instead of ||)
    CASE c.status
        WHEN 'pending' THEN 'Pending Release'
        WHEN 'held' THEN CONCAT('Held Until ', DATE_FORMAT(c.held_until, '%Y-%m-%d'))
        WHEN 'released' THEN 'Available for Payout'
        WHEN 'paid' THEN 'Paid to Organizer'
        WHEN 'refunded' THEN 'Refunded'
        ELSE c.status
    END as status_display,
    -- Ethiopian VAT information
    CONCAT(c.vat_rate, '%') as vat_rate_display,
    CASE c.vat_included
        WHEN TRUE THEN 'VAT Included'
        ELSE 'VAT Excluded'
    END as vat_status,
    -- VAT liability clarity
    CASE c.vat_liability
        WHEN 'organizer' THEN 'Organizer liable for VAT'
        WHEN 'platform' THEN 'Platform liable for VAT'
        WHEN 'shared' THEN 'VAT liability shared'
        ELSE 'VAT status pending'
    END as vat_liability_display
FROM commissions c
LEFT JOIN organizers o ON c.organizer_id = o.id
LEFT JOIN events e ON c.event_id = e.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
ORDER BY c.created_at DESC;

-- View for platform revenue dashboard (Admin) - Clarified VAT ownership
CREATE OR REPLACE VIEW vw_platform_revenue AS
SELECT 
    DATE(c.created_at) as revenue_date,
    COUNT(c.id) as transaction_count,
    SUM(c.ticket_amount) as gross_revenue,
    SUM(c.commission_amount) as total_commission,
    SUM(c.vat_amount) as total_vat_collected,
    SUM(c.platform_amount) as net_platform_revenue,
    -- VAT liability summary
    SUM(CASE WHEN c.vat_liability = 'platform' THEN c.vat_amount ELSE 0 END) as vat_payable_by_platform,
    SUM(CASE WHEN c.vat_liability = 'organizer' THEN c.vat_amount ELSE 0 END) as vat_payable_by_organizer,
    -- Average metrics
    AVG(c.commission_rate) as avg_commission_rate,
    AVG(c.ticket_amount) as avg_ticket_price,
    -- Status breakdown
    SUM(CASE WHEN c.status = 'paid' THEN 1 ELSE 0 END) as paid_count,
    SUM(CASE WHEN c.status = 'released' THEN c.platform_amount ELSE 0 END) as released_amount,
    SUM(CASE WHEN c.status = 'paid' THEN c.platform_amount ELSE 0 END) as paid_amount,
    -- Ethiopian tax summary
    SUM(CASE WHEN c.tax_withheld = TRUE THEN c.tax_withheld_amount ELSE 0 END) as total_tax_withheld
FROM commissions c
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
GROUP BY DATE(c.created_at)
ORDER BY revenue_date DESC;

-- View for Ethiopian tax compliance reporting
CREATE OR REPLACE VIEW vw_vat_compliance_report AS
SELECT 
    c.id,
    c.payment_id,
    c.organizer_id,
    o.business_name,
    o.tin_number,
    o.vat_number,
    c.event_id,
    e.title as event_title,
    c.ticket_amount,
    c.vat_rate,
    c.vat_amount,
    c.vat_included,
    c.vat_liability,
    c.created_at,
    -- Ethiopian VAT compliance status
    CASE 
        WHEN o.vat_registered = TRUE AND o.vat_number IS NOT NULL THEN 'REGISTERED_VAT'
        WHEN o.vat_registered = FALSE AND c.ticket_amount >= 1000000 THEN 'THRESHOLD_VAT'
        ELSE 'STANDARD_VAT'
    END as vat_compliance_status,
    -- VAT invoice requirements
    CASE 
        WHEN o.vat_registered = TRUE AND c.ticket_amount >= 2000 THEN 'VAT_INVOICE_REQUIRED'
        ELSE 'STANDARD_RECEIPT'
    END as invoice_requirement,
    -- VAT payment responsibility
    CASE c.vat_liability
        WHEN 'platform' THEN 'Platform to pay ERA'
        WHEN 'organizer' THEN 'Organizer to pay ERA'
        ELSE 'Shared responsibility'
    END as vat_payment_responsibility
FROM commissions c
JOIN organizers o ON c.organizer_id = o.id
LEFT JOIN events e ON c.event_id = e.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
  AND c.status IN ('pending', 'released', 'paid')
ORDER BY c.created_at DESC;

-- ============================================
-- HELPER VIEW FOR FINANCIAL RECONCILIATION
-- ============================================

CREATE OR REPLACE VIEW vw_commission_reconciliation AS
SELECT 
    -- Date range
    MIN(DATE(c.created_at)) as period_start,
    MAX(DATE(c.created_at)) as period_end,
    -- Organizer summary
    c.organizer_id,
    o.business_name,
    COUNT(c.id) as total_transactions,
    SUM(c.ticket_amount) as total_gross_sales,
    SUM(c.organizer_amount) as total_organizer_share,
    SUM(c.platform_amount) as total_platform_share,
    SUM(c.vat_amount) as total_vat_collected,
    -- VAT liability breakdown
    SUM(CASE WHEN c.vat_liability = 'platform' THEN c.vat_amount ELSE 0 END) as platform_vat_liability,
    SUM(CASE WHEN c.vat_liability = 'organizer' THEN c.vat_amount ELSE 0 END) as organizer_vat_liability,
    -- Payment status summary
    SUM(CASE WHEN c.status = 'paid' THEN 1 ELSE 0 END) as paid_count,
    SUM(CASE WHEN c.status = 'released' THEN c.organizer_amount ELSE 0 END) as released_amount,
    SUM(CASE WHEN c.status = 'paid' THEN c.organizer_amount ELSE 0 END) as paid_amount,
    -- Commission rate analysis
    AVG(c.commission_rate) as avg_commission_rate,
    MIN(c.commission_rate) as min_commission_rate,
    MAX(c.commission_rate) as max_commission_rate
FROM commissions c
JOIN organizers o ON c.organizer_id = o.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
  AND c.created_at >= DATE_SUB(CURDATE(), INTEGERERVAL 30 DAY) -- Last 30 days
GROUP BY c.organizer_id, o.business_name
ORDER BY total_gross_sales DESC;


-- Migration: 013_create_event_categories_table.sql
-- Description: Create hierarchical event category system with Ethiopian context
-- Dependencies: None (standalone table)
-- Ethiopian Context: Amharic names, Ethiopian cultural categories
-- MySQL Production Safety: No session variables in views, proper FULLTEXT handling, no trigger complexity

-- ============================================
-- TABLE: event_categories
-- Purpose: Hierarchical categorization system for Ethiopian events
-- Important: All hierarchy management handled in application logic
-- ============================================

CREATE TABLE IF NOT EXISTS event_categories (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Hierarchy Management (Application-managed)
  parent_id INTEGEREGER NULL COMMENT 'Parent category ID, NULL for root',
  depth INTEGEREGEREGER DEFAULT 0 COMMENT 'Hierarchy depth (0 = root, managed by app)',
  path VARCHAR(500) COMMENT 'Materialized path (e.g., "1.5.12", managed by app)',
  hierarchy_order INTEGER DEFAULT 0 COMMENT 'Order within parent for display',
  
  -- Category Names (Bilingual)
  name VARCHAR(100) NOT NULL COMMENT 'English category name',
  name_amharic VARCHAR(100) NOT NULL COMMENT 'Amharic category name',
  slug VARCHAR(120) UNIQUE NOT NULL COMMENT 'URL-friendly slug (lowercase, hyphens)',
  
  -- Descriptions
  description TEXT COMMENT 'English description',
  description_amharic TEXT COMMENT 'Amharic description',
  
  -- Visual Identity
  icon VARCHAR(50) COMMENT 'FontAwesome or custom icon class',
  icon_amharic VARCHAR(50) COMMENT 'Amharic-specific icon if different',
  color VARCHAR(7) DEFAULT '#078930' COMMENT 'Hex color for UI (#RRGGBB)',
  image_url VARCHAR(500) COMMENT 'Category banner/image',
  
  -- Ethiopian Cultural Context
  cultural_significance TEXT DEFAULT 'medium' COMMENT 'Ethiopian cultural importance',
  typical_season TEXT DEFAULT 'any' COMMENT 'When events typically occur',
  common_regions JSON DEFAULT NULL COMMENT 'Popular regions: ["Addis Ababa", "Amhara"]',
  
  -- Business Rules
  requires_approval INTEGER DEFAULT FALSE COMMENT 'Events in this category need special approval',
  min_age_requirement INTEGEREGEREGER DEFAULT 0 COMMENT 'Minimum age for attendees (0-100)',
  default_commission_rate REAL DEFAULT 10.00 COMMENT 'Default commission (5-30%)',
  
  -- Display & Organization
  sort_order INTEGER DEFAULT 0 COMMENT 'Global sorting in lists',
  is_featured INTEGER DEFAULT FALSE COMMENT 'Featured on homepage',
  featured_until TEXT NULL COMMENT 'Until when featured',
  is_active INTEGER DEFAULT TRUE,
  
  -- Statistics (Denormalized for performance)
  total_events INTEGEREGER DEFAULT 0,
  upcoming_events INTEGEREGER DEFAULT 0,
  total_tickets_sold INTEGEREGER DEFAULT 0,
  
  -- SEO & Discovery
  meta_title VARCHAR(200),
  meta_description TEXT,
  meta_keywords VARCHAR(500),
  search_keywords JSON DEFAULT NULL COMMENT 'Search terms: ["concert", "music", "ኮንሰርት"]',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Self-referential foreign key for hierarchy
  FOREIGN KEY (parent_id) REFERENCES event_categories(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  
  -- Indexes
  INDEX idx_parent_id (parent_id), -- INDEX converted separately (slug), -- INDEX converted separately (is_active), -- INDEX converted separately (sort_order), -- INDEX converted separately (is_featured, featured_until), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (depth), -- INDEX converted separately (hierarchy_order),
  
  -- Composite Indexes for Common Queries
  INDEX idx_active_parent (is_active, parent_id), -- INDEX converted separately (is_featured, is_active, featured_until), -- INDEX converted separately (parent_id, hierarchy_order),
  
  -- FULLTEXT Search (English only for consistency)
  FULLTEXT INDEX idx_category_search (name, description),
  FULLTEXT INDEX idx_name_search (name),
  
  -- ConstraINTEGERs (Light, MySQL-safe)
  CONSTRAINTEGER chk_min_age_requirement CHECK (min_age_requirement <= 100),
  CONSTRAINTEGER chk_default_commission_rate CHECK (
    default_commission_rate >= 5 AND default_commission_rate <= 30
  ),
  CONSTRAINTEGER chk_depth_range CHECK (depth <= 5)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Hierarchical event categories with Ethiopian cultural context. Hierarchy managed in application logic.';

-- ============================================
-- VIEWS FOR CATEGORY MANAGEMENT (SESSION VARIABLE FREE)
-- ============================================

-- View for category hierarchy (application will handle language)
CREATE OR REPLACE VIEW vw_category_hierarchy AS
WITH RECURSIVE category_tree AS (
    -- Root categories
    SELECT 
        id,
        parent_id,
        name,
        name_amharic,
        slug,
        depth,
        path,
        CONCAT(name, ' / ', name_amharic) as bilingual_name,
        CAST(id AS CHAR(200)) as hierarchy_path,
        1 as level_order,
        sort_order,
        hierarchy_order
    FROM event_categories
    WHERE parent_id IS NULL
      AND is_active = TRUE
      AND deleted_at IS NULL
    
    UNION ALL
    
    -- Child categories
    SELECT 
        c.id,
        c.parent_id,
        c.name,
        c.name_amharic,
        c.slug,
        c.depth,
        c.path,
        CONCAT(
            REPEAT('  ', ct.level_order), 
            '└─ ', 
            c.name, 
            ' / ', 
            c.name_amharic
        ) as bilingual_name,
        CONCAT(ct.hierarchy_path, '.', c.id) as hierarchy_path,
        ct.level_order + 1 as level_order,
        c.sort_order,
        c.hierarchy_order
    FROM event_categories c
    INNER JOIN category_tree ct ON c.parent_id = ct.id
    WHERE c.is_active = TRUE
      AND c.deleted_at IS NULL
)
SELECT * FROM category_tree
ORDER BY hierarchy_path;

-- View for event discovery (returns both languages, app handles display)
CREATE OR REPLACE VIEW vw_public_categories AS
SELECT 
    c.id,
    c.parent_id,
    c.name,
    c.name_amharic,
    c.slug,
    c.description,
    c.description_amharic,
    c.icon,
    c.icon_amharic,
    c.color,
    c.image_url,
    c.cultural_significance,
    c.total_events,
    c.upcoming_events,
    c.sort_order,
    c.is_featured,
    c.featured_until,
    -- Child count for UI indicators
    (SELECT COUNT(*) FROM event_categories child 
     WHERE child.parent_id = c.id 
       AND child.is_active = TRUE 
       AND child.deleted_at IS NULL) as child_count,
    -- Hierarchy info
    c.depth,
    c.hierarchy_order
FROM event_categories c
WHERE c.is_active = TRUE
  AND c.deleted_at IS NULL
ORDER BY c.sort_order, c.hierarchy_order, c.name;

-- View for Ethiopian cultural categories (fixed for production)
CREATE OR REPLACE VIEW vw_ethiopian_cultural_categories AS
SELECT 
    c.id,
    c.name,
    c.name_amharic,
    c.cultural_significance,
    c.common_regions,
    c.total_events,
    -- Regional popularity (safe JSON handling)
    CASE 
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Addis Ababa') IS NOT NULL THEN 'ADDIS_ABABA'
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Amhara') IS NOT NULL THEN 'AMHARA'
        WHEN c.common_regions IS NOT NULL AND 
             JSON_SEARCH(c.common_regions, 'one', 'Oromia') IS NOT NULL THEN 'OROMIA'
        WHEN c.common_regions IS NOT NULL THEN 'MULTI_REGION'
        ELSE 'REGION_UNKNOWN'
    END as primary_region,
    -- Seasonality
    c.typical_season,
    -- Age appropriateness
    CASE 
        WHEN c.min_age_requirement >= 18 THEN 'ADULT_ONLY'
        WHEN c.min_age_requirement > 0 THEN 'AGE_RESTRICTED'
        ELSE 'ALL_AGES'
    END as age_category,
    -- Approval requirements
    c.requires_approval
FROM event_categories c
WHERE c.is_active = TRUE
  AND c.deleted_at IS NULL
  AND c.cultural_significance IN ('high', 'medium')
ORDER BY c.cultural_significance DESC, c.total_events DESC;

-- View for admin category management
CREATE OR REPLACE VIEW vw_admin_categories AS
SELECT 
    c.id,
    c.name,
    c.name_amharic,
    c.slug,
    c.parent_id,
    p.name as parent_name,
    p.name_amharic as parent_name_amharic,
    c.depth,
    c.is_active,
    c.is_featured,
    c.featured_until,
    c.total_events,
    c.upcoming_events,
    c.total_tickets_sold,
    c.requires_approval,
    c.min_age_requirement,
    c.default_commission_rate,
    c.created_at,
    c.updated_at,
    -- Status indicator
    CASE 
        WHEN c.deleted_at IS NOT NULL THEN 'DELETED'
        WHEN c.is_active = FALSE THEN 'INACTIVE'
        WHEN c.is_featured = TRUE AND (c.featured_until IS NULL OR c.featured_until > NOW()) THEN 'FEATURED'
        ELSE 'ACTIVE'
    END as status
FROM event_categories c
LEFT JOIN event_categories p ON c.parent_id = p.id
ORDER BY c.depth, c.parent_id, c.hierarchy_order;


-- Migration: 014_create_event_tags_table.sql
-- Description: Store tags for event classification (Improved Production Version)
-- Dependencies: None (standalone table)
-- Best Practices: Soft delete, duplicate prevention, consistent with other tables

-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- Note: Slug validation enforced in application, not MySQL CHECK constraINTEGERs
-- ============================================

CREATE TABLE IF NOT EXISTS event_tags (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Tag Names (Bilingual)
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  slug VARCHAR(100) UNIQUE NOT NULL COMMENT 'URL-friendly lowercase slug (validated in app)',
  
  -- Descriptions (Optional but useful for admin/SEO)
  description TEXT COMMENT 'English description',
  description_amharic TEXT COMMENT 'Amharic description',
  
  -- Metadata
  usage_count INTEGEREGER DEFAULT 0 COMMENT 'How many times this tag is used',
  is_featured INTEGER DEFAULT FALSE COMMENT 'Featured tags for discovery',
  is_active INTEGER DEFAULT TRUE,
  
  -- Ethiopian Context
  cultural_relevance TEXT DEFAULT 'medium' COMMENT 'Ethiopian cultural relevance',
  common_in_regions JSON DEFAULT NULL COMMENT 'Regions where this tag is popular: ["Addis Ababa", "Amhara"]',
  
  -- SEO & Discovery
  meta_title VARCHAR(200),
  meta_description TEXT,
  meta_keywords VARCHAR(500),
  
  -- TEXTs (Consistent with other tables)
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL COMMENT 'Soft delete TEXT',
  
  -- Indexes
  INDEX idx_slug (slug), -- INDEX converted separately (name(50)), -- INDEX converted separately (is_active), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at), -- INDEX converted separately (usage_count), -- INDEX converted separately (cultural_relevance),
  
  -- Composite Indexes for Common Queries
  INDEX idx_active_featured (is_active, is_featured), -- INDEX converted separately (is_active, usage_count), -- INDEX converted separately (name, is_active),
  
  -- FULLTEXT Search (Supports Amharic with utf8mb4)
  FULLTEXT idx_search (name, name_amharic, description, description_amharic),
  
  -- ConstraINTEGERs (Application-enforced, documented here)
  -- Note: Slug format validation happens in application code
  
  -- Prevent duplicate names (case-insensitive)
  UNIQUE KEY uq_name_unique (name)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event tags for classification. Soft delete supported. Name uniqueness enforced.';

-- ============================================
-- VIEWS FOR TAG MANAGEMENT
-- ============================================

-- View for active tags (public facing)
CREATE OR REPLACE VIEW vw_active_tags AS
SELECT 
    id,
    name,
    name_amharic,
    slug,
    description,
    description_amharic,
    usage_count,
    is_featured,
    cultural_relevance,
    created_at,
    -- Language-specific display name (app will choose)
    name as display_name_en,
    name_amharic as display_name_am,
    -- Popularity indicator
    CASE 
        WHEN usage_count > 100 THEN 'VERY_POPULAR'
        WHEN usage_count > 50 THEN 'POPULAR'
        WHEN usage_count > 10 THEN 'COMMON'
        ELSE 'NEW'
    END as popularity_level
FROM event_tags
WHERE is_active = TRUE
  AND deleted_at IS NULL
ORDER BY usage_count DESC, name;


HAVING recent_usage > 0
ORDER BY recent_usage DESC;
*/

-- View for admin tag management
CREATE OR REPLACE VIEW vw_admin_tags AS
SELECT 
    id,
    name,
    name_amharic,
    slug,
    usage_count,
    is_active,
    is_featured,
    cultural_relevance,
    created_at,
    updated_at,
    deleted_at,
    -- Status indicator
    CASE 
        WHEN deleted_at IS NOT NULL THEN 'DELETED'
        WHEN is_active = FALSE THEN 'INACTIVE'
        WHEN is_featured = TRUE THEN 'FEATURED'
        ELSE 'ACTIVE'
    END as status
FROM event_tags
ORDER BY 
    CASE 
        WHEN deleted_at IS NOT NULL THEN 3
        WHEN is_active = FALSE THEN 2
        ELSE 1
    END,
    usage_count DESC;



-- Migration: 015_create_event_tag_pivot_table.sql
-- Description: Many-to-many relationship between events and tags
-- Dependencies: Requires events and event_tags tables

CREATE TABLE IF NOT EXISTS event_tag_pivot (
  event_id INTEGEREGER NOT NULL,
  tag_id INTEGEREGER NOT NULL,

  -- Metadata
  source TEXT DEFAULT 'manual',
  created_at TEXT DEFAULT CURRENT_TEXT,
  deleted_at TEXT NULL,

  -- Composite Primary Key
  PRIMARY KEY (event_id, tag_id),

  -- Foreign Keys
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  FOREIGN KEY (tag_id) REFERENCES event_tags(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  -- Indexes
  INDEX idx_event_id (event_id), -- INDEX converted separately (tag_id), -- INDEX converted separately (deleted_at)

) 
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pivot table linking events and tags (many-to-many)';



-- Migration: 016_create_venues_table.sql
-- Description: Store venue information for events
-- Dependencies: Requires cities table for foreign key
CREATE TABLE IF NOT EXISTS venues (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(200) NOT NULL,
  name_amharic VARCHAR(200),

  city_id INTEGEREGER NOT NULL,
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  kebele VARCHAR(100),
  house_number VARCHAR(50),
  landmark TEXT,
  full_address TEXT,

  -- Geographic data
  latitude REAL,
  longitude REAL,
  location POINTEGER GENERATED ALWAYS AS (
    ST_SRID(POINTEGER(longitude, latitude), 4326)
  ) STORED,

  google_maps_url VARCHAR(500),

  capacity INTEGER,
  venue_type TEXT DEFAULT 'indoor',

  amenities JSON,
  contact_phone VARCHAR(20),
  contact_email VARCHAR(100),
  website VARCHAR(255),

  is_verified INTEGER DEFAULT FALSE,
  is_active INTEGER DEFAULT TRUE,

  description TEXT,
  images JSON,

  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,

  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT, -- INDEX converted separately (city_id), -- INDEX converted separately (name), -- INDEX converted separately (is_active), -- INDEX converted separately (is_verified), -- INDEX converted separately (deleted_at),

  FULLTEXT INDEX idx_search
    (name, name_amharic, landmark, full_address),

  SPATIAL INDEX idx_location (location),

  CONSTRAINTEGER chk_capacity
    CHECK (capacity IS NULL OR capacity > 0),

  CONSTRAINTEGER chk_coordinates
    CHECK (
      (latitude IS NULL AND longitude IS NULL)
      OR
      (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
) 
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;



-- Migration: 017_create_events_table.sql (IMPROVED VERSION)
-- Description: Store event information with enhanced features
-- Dependencies: Requires organizers, event_categories, cities, venues tables

-- ============================================
-- TABLE: events (IMPROVED)
-- Purpose: Store event information
-- Improvements: Added recurring events support, online events, age INTEGEReger, removed redundant tags
-- ============================================

CREATE TABLE IF NOT EXISTS events (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  
  -- Event Information
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  slug VARCHAR(255) UNIQUE NOT NULL,
  seo_slug VARCHAR(255) UNIQUE NULL COMMENT 'Optional separate slug for SEO flexibility',
  
  -- Descriptions
  description TEXT,
  description_amharic TEXT,
  short_description VARCHAR(500),
  
  -- Classification
  category_id INTEGEREGER NOT NULL,
  city_id INTEGEREGER NOT NULL,
  
  -- Location & Venue
  venue_id INTEGEREGER NULL,
  venue_custom VARCHAR(200),
  address_details TEXT,
  latitude REAL,
  longitude REAL,
  is_online INTEGER DEFAULT FALSE COMMENT 'Virtual/online events',
  online_event_url VARCHAR(500) COMMENT 'URL for virtual events',
  
  -- Event Timing
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  start_date_ethiopian VARCHAR(50),
  end_date_ethiopian VARCHAR(50),
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  duration_minutes INTEGER,
  
  -- Recurring Events (Enhanced)
  is_recurring INTEGER DEFAULT FALSE,
  recurrence_pattern JSON COMMENT 'Recurrence configuration',
  recurrence_end_date TEXT NULL COMMENT 'When recurring events stop',
  
  -- Status & Visibility
  status TEXT DEFAULT 'draft',
  status_reason TEXT COMMENT 'Reason for status change',
  visibility TEXT DEFAULT 'public',
  is_featured INTEGER DEFAULT FALSE,
  featured_until TEXT NULL,
  
  -- Ticketing
  has_tickets INTEGER DEFAULT TRUE,
  external_ticket_url VARCHAR(500) COMMENT 'For events using external ticketing',
  total_tickets INTEGER DEFAULT 0,
  tickets_sold INTEGER DEFAULT 0,
  min_price REAL NULL,
  max_price REAL NULL,
  
  -- Media
  cover_image VARCHAR(255),
  gallery_images JSON COMMENT 'Array of image URLs',
  video_url VARCHAR(500),
  
  -- Audience & Restrictions
  min_age INTEGER DEFAULT 0 COMMENT 'Minimum age requirement (0 = all ages)',
  age_restriction TEXT DEFAULT 'all' COMMENT 'Display category',
  is_charity INTEGER DEFAULT FALSE,
  charity_org VARCHAR(200),
  
  -- Ethiopian Tax
  vat_included INTEGER DEFAULT TRUE,
  vat_rate REAL DEFAULT 15.00,
  
  -- Engagement Metrics
  views INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  attendee_count INTEGER DEFAULT 0 COMMENT 'Actual attendees (not ticket sales)',
  
  -- SEO
  meta_title VARCHAR(200),
  meta_description TEXT,
  meta_keywords VARCHAR(500),
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  published_at TEXT NULL,
  cancelled_at TEXT NULL,
  cancellation_reason TEXT,
  cancelled_by INTEGEREGER NULL,
  
  -- Foreign Keys
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (venue_id) REFERENCES venues(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (cancelled_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Core Indexes
  INDEX idx_organizer (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (city_id), -- INDEX converted separately (start_date), -- INDEX converted separately (is_featured, featured_until), -- INDEX converted separately (published_at), -- INDEX converted separately (category_id), -- INDEX converted separately (venue_id), -- INDEX converted separately (cancelled_by),
  
  -- Enhanced Composite Indexes (for common queries)
  INDEX idx_organizer_status_date (organizer_id, status, start_date), -- INDEX converted separately (city_id, status, start_date), -- INDEX converted separately (category_id, status, start_date), -- INDEX converted separately (is_featured, status, start_date), -- INDEX converted separately (is_online, status, start_date),
  
  -- Spatial and Full-Text Search
  SPATIAL INDEX idx_location (latitude, longitude),
  FULLTEXT idx_event_search (title, title_amharic, description, description_amharic),
  
  -- Application-enforced constraINTEGERs (documented here)
  -- Note: CHECK constraINTEGERs are for documentation only in older MySQL
  CONSTRAINTEGER chk_event_dates CHECK (end_date > start_date),
  CONSTRAINTEGER chk_tickets_sold CHECK (tickets_sold <= total_tickets),
  CONSTRAINTEGER chk_vat_rate CHECK (vat_rate >= 0 AND vat_rate <= 100),
  CONSTRAINTEGER chk_slug_format -- CHECK (REGEXP not supported in SQLite '^[a-z0-9-]+$'),
  CONSTRAINTEGER chk_min_age CHECK (min_age >= 0 AND min_age <= 100),
  CONSTRAINTEGER chk_duration CHECK (duration_minutes IS NULL OR duration_minutes > 0),
  CONSTRAINTEGER chk_venue_or_online CHECK (
    (venue_id IS NOT NULL AND is_online = FALSE) OR
    (venue_id IS NULL AND is_online = TRUE) OR
    (venue_id IS NULL AND venue_custom IS NOT NULL AND is_online = FALSE)
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Core events table with enhanced features. Business rules enforced in application.';

-- ============================================
-- VIEWS FOR COMMON EVENT QUERIES
-- ============================================

-- View for public event listings
CREATE OR REPLACE VIEW vw_public_events AS
SELECT 
    e.id,
    e.organizer_id,
    o.business_name as organizer_name,
    e.title,
    e.title_amharic,
    e.slug,
    e.short_description,
    e.category_id,
    ec.name as category_name,
    ec.name_amharic as category_name_amharic,
    e.city_id,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    e.venue_id,
    v.name as venue_name,
    v.name_amharic as venue_name_amharic,
    e.start_date,
    e.end_date,
    e.start_date_ethiopian,
    e.end_date_ethiopian,
    e.is_online,
    e.online_event_url,
    e.cover_image,
    e.min_price,
    e.max_price,
    e.has_tickets,
    e.total_tickets,
    e.tickets_sold,
    e.min_age,
    e.age_restriction,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    -- Availability indicator
    CASE 
        WHEN e.total_tickets > 0 AND e.tickets_sold >= e.total_tickets THEN 'SOLD_OUT'
        WHEN e.total_tickets > 0 AND (e.total_tickets - e.tickets_sold) < 10 THEN 'FEW_LEFT'
        WHEN e.total_tickets > 0 THEN 'AVAILABLE'
        ELSE 'NO_TICKETS'
    END as ticket_availability,
    -- Date status
    CASE 
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 30 DAY) THEN 'UPCOMING'
        ELSE 'FUTURE'
    END as date_status
FROM events e
LEFT JOIN organizers o ON e.organizer_id = o.id
LEFT JOIN event_categories ec ON e.category_id = ec.id
LEFT JOIN cities c ON e.city_id = c.id
LEFT JOIN venues v ON e.venue_id = v.id
WHERE e.status = 'published'
  AND e.visibility = 'public'
  AND (e.featured_until IS NULL OR e.featured_until > NOW())
ORDER BY 
    e.is_featured DESC,
    e.start_date ASC;

-- View for organizer dashboard
CREATE OR REPLACE VIEW vw_organizer_events AS
SELECT 
    e.id,
    e.title,
    e.title_amharic,
    e.status,
    e.start_date,
    e.end_date,
    e.total_tickets,
    e.tickets_sold,
    e.min_price,
    e.max_price,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    e.cancelled_at,
    -- Financial metrics
    CASE 
        WHEN e.min_price IS NOT NULL AND e.max_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' - ', FORMAT(e.max_price, 2), ' ETB')
        WHEN e.min_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' ETB')
        ELSE 'FREE'
    END as price_range,
    -- Sales percentage
    CASE 
        WHEN e.total_tickets > 0 THEN 
            CONCAT(ROUND((e.tickets_sold / e.total_tickets) * 100, 1), '%')
        ELSE '0%'
    END as sales_percentage,
    -- Time status
    CASE 
        WHEN e.cancelled_at IS NOT NULL THEN 'CANCELLED'
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.status = 'published' THEN 'ACTIVE'
        WHEN e.status = 'draft' THEN 'DRAFT'
        ELSE e.status
    END as event_status
FROM events e
ORDER BY 
    CASE 
        WHEN e.start_date < NOW() THEN 3
        WHEN e.status = 'published' THEN 1
        ELSE 2
    END,
    e.start_date ASC;
-- End of Migration: 017_create_events_table.sql



-- Migration: 018_create_event_media_table.sql (IMPROVED VERSION)
-- Description: Store media files for events with enhanced tracking
-- Dependencies: Requires events and users tables

-- ============================================
-- TABLE: event_media (IMPROVED)
-- Purpose: Store media files for events with upload tracking and soft delete
-- ============================================

CREATE TABLE IF NOT EXISTS event_media (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGEREGER NOT NULL,
  
  -- Media Information
  media_type TEXT DEFAULT 'image',
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  filename VARCHAR(255),
  mime_type VARCHAR(100),
  file_size INTEGEREGER COMMENT 'Size in bytes',
  width INTEGEREGER COMMENT 'Width in pixels (for images/videos)',
  height INTEGEREGER COMMENT 'Height in pixels (for images/videos)',
  duration INTEGEREGER NULL COMMENT 'Duration in seconds (for videos/audio)',
  
  -- Captions & Descriptions (Bilingual)
  title VARCHAR(200),
  title_amharic VARCHAR(200),
  caption VARCHAR(500),
  caption_amharic VARCHAR(500),
  description TEXT,
  description_amharic TEXT,
  alt_text VARCHAR(500) COMMENT 'Accessibility alt text',
  
  -- Organization & Display
  sort_order INTEGER DEFAULT 0,
  is_primary INTEGER DEFAULT FALSE COMMENT 'Primary/featured media for event',
  is_cover_image INTEGER DEFAULT FALSE COMMENT 'If this is the event cover image',
  
  -- Status & Approval
  is_approved INTEGER DEFAULT TRUE,
  approved_by INTEGEREGER NULL COMMENT 'User who approved the media',
  approved_at TEXT NULL,
  rejection_reason TEXT COMMENT 'If media was rejected',
  
  -- Upload Tracking
  uploaded_by INTEGEREGER NULL COMMENT 'User who uploaded the media',
  upload_source TEXT DEFAULT 'organizer',
  original_filename VARCHAR(255) COMMENT 'Original filename before processing',
  
  -- Metadata
  meta_data JSON COMMENT 'Additional metadata: {"camera": "iPhone 12", "format": "JPEG", "compression": "high"}',
  tags JSON COMMENT 'Tags for media organization',
  
  -- Soft Delete & TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  archived_at TEXT NULL COMMENT 'For long-term archiving',
  
  -- Foreign Keys
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (uploaded_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_event (event_id), -- INDEX converted separately (media_type), -- INDEX converted separately (sort_order), -- INDEX converted separately (is_primary), -- INDEX converted separately (is_approved), -- INDEX converted separately (is_cover_image), -- INDEX converted separately (uploaded_by), -- INDEX converted separately (approved_by), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at),
  
  -- Composite Indexes
  INDEX idx_event_primary (event_id, is_primary), -- INDEX converted separately (event_id, is_approved), -- INDEX converted separately (event_id, media_type), -- INDEX converted separately (event_id, sort_order),
  
  -- Application-enforced constraINTEGERs
  CONSTRAINTEGER chk_file_size CHECK (file_size >= 0),
  CONSTRAINTEGER chk_dimensions CHECK (width >= 0 AND height >= 0),
  CONSTRAINTEGER chk_duration CHECK (duration IS NULL OR duration > 0)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event media storage with upload tracking, approval workflow, and soft delete support.';

-- ============================================
-- VIEWS FOR MEDIA MANAGEMENT
-- ============================================

-- View for event media gallery (public)
CREATE OR REPLACE VIEW vw_event_media_gallery AS
SELECT 
    em.id,
    em.event_id,
    em.media_type,
    em.url,
    em.thumbnail_url,
    em.title,
    em.title_amharic,
    em.caption,
    em.caption_amharic,
    em.width,
    em.height,
    em.duration,
    em.sort_order,
    em.is_primary,
    em.is_cover_image,
    em.mime_type,
    em.file_size,
    -- Display information
    CASE 
        WHEN em.media_type = 'image' THEN 'PHOTO'
        WHEN em.media_type = 'video' THEN 'VIDEO'
        WHEN em.media_type = 'document' THEN 'DOCUMENT'
        WHEN em.media_type = 'audio' THEN 'AUDIO'
        ELSE 'MEDIA'
    END as media_type_display,
    -- File size in readable format
    CASE 
        WHEN em.file_size < 1024 THEN CONCAT(em.file_size, ' B')
        WHEN em.file_size < 1048576 THEN CONCAT(ROUND(em.file_size / 1024, 1), ' KB')
        ELSE CONCAT(ROUND(em.file_size / 1048576, 1), ' MB')
    END as file_size_display
FROM event_media em
WHERE em.is_approved = TRUE
  AND em.deleted_at IS NULL
  AND em.event_id IN (SELECT id FROM events WHERE status = 'published')
ORDER BY em.event_id, em.sort_order, em.created_at;

-- View for organizer media management
CREATE OR REPLACE VIEW vw_organizer_event_media AS
SELECT 
    em.id,
    em.event_id,
    e.title as event_title,
    e.title_amharic as event_title_amharic,
    em.media_type,
    em.url,
    em.filename,
    em.file_size,
    em.width,
    em.height,
    em.is_approved,
    em.is_primary,
    em.is_cover_image,
    em.created_at,
    em.updated_at,
    u.full_name as uploaded_by_name,
    -- Approval status
    CASE 
        WHEN em.is_approved = TRUE THEN 'APPROVED'
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NOT NULL THEN 'REJECTED'
        WHEN em.is_approved = FALSE THEN 'PENDING_APPROVAL'
        ELSE 'UNKNOWN'
    END as approval_status,
    -- Media type icon
    CASE em.media_type
        WHEN 'image' THEN '📷'
        WHEN 'video' THEN '🎬'
        WHEN 'document' THEN '📄'
        WHEN 'audio' THEN '🎵'
        ELSE '📁'
    END as media_icon
FROM event_media em
JOIN events e ON em.event_id = e.id
LEFT JOIN users u ON em.uploaded_by = u.id
WHERE em.deleted_at IS NULL
ORDER BY em.event_id, em.sort_order;

-- View for admin media moderation
CREATE OR REPLACE VIEW vw_admin_media_moderation AS
SELECT 
    em.id,
    em.event_id,
    e.title as event_title,
    o.business_name as organizer_name,
    em.media_type,
    em.url,
    em.filename,
    em.mime_type,
    em.file_size,
    em.is_approved,
    em.uploaded_by,
    u.full_name as uploaded_by_name,
    u.phone as uploaded_by_phone,
    em.created_at,
    em.approved_by,
    em.approved_at,
    em.rejection_reason,
    -- Moderation flags
    CASE 
        WHEN em.mime_type LIKE 'video/%' AND em.file_size > 104857600 THEN 'LARGE_VIDEO'
        WHEN em.media_type = 'image' AND (em.width > 5000 OR em.height > 5000) THEN 'HIGH_RES_IMAGE'
        WHEN em.media_type = 'document' AND em.file_size > 10485760 THEN 'LARGE_DOCUMENT'
        ELSE 'STANDARD'
    END as moderation_flag,
    -- Action required
    CASE 
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NULL THEN 'NEEDS_REVIEW'
        WHEN em.is_approved = FALSE AND em.rejection_reason IS NOT NULL THEN 'REJECTED_NEEDS_FOLLOWUP'
        ELSE 'NO_ACTION'
    END as action_required
FROM event_media em
JOIN events e ON em.event_id = e.id
JOIN organizers o ON e.organizer_id = o.id
LEFT JOIN users u ON em.uploaded_by = u.id
WHERE em.deleted_at IS NULL
  AND (em.is_approved = FALSE OR em.rejection_reason IS NOT NULL)
ORDER BY em.created_at DESC;

-- Migration: 019_create_ticket_types_table.sql (CORRECTED VERSION)
-- Description: Store different ticket types for events with proper VAT calculations
-- Dependencies: Requires events table
-- Important: Ethiopian VAT fixed at 15%, calculations rounded to 2 decimals

-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- VAT Note: Ethiopian VAT is fixed at 15%, calculations use ROUND() for precision
-- ============================================

CREATE TABLE IF NOT EXISTS ticket_types (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGEREGER NOT NULL,
  
  -- Ticket Information (Bilingual)
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  description TEXT,
  description_amharic TEXT,
  
  -- Pricing (ETH - Ethiopian Birr)
  price REAL NOT NULL COMMENT 'Display price in ETB',
  vat_included INTEGER DEFAULT TRUE COMMENT 'Whether 15% VAT is included in price',
  
  -- Generated VAT Columns (Ethiopian 15% VAT with rounding)
  vat_amount REAL GENERATED ALWAYS AS (
    CASE WHEN vat_included THEN ROUND(price * 0.15, 2) ELSE 0.00 END
  ) STORED COMMENT '15% VAT amount (rounded to 2 decimals)',
  
  net_price REAL GENERATED ALWAYS AS (
    CASE WHEN vat_included THEN ROUND(price / 1.15, 2) ELSE price END
  ) STORED COMMENT 'Price without VAT (rounded to 2 decimals)',
  
  -- Inventory Management
  quantity INTEGER NOT NULL COMMENT 'Total tickets available',
  sold_count INTEGER DEFAULT 0 COMMENT 'Tickets sold (confirmed payments)',
  reserved_count INTEGER DEFAULT 0 COMMENT 'Tickets reserved (pending payment)',
  
  available_count INTEGER GENERATED ALWAYS AS (
    quantity - sold_count - reserved_count
  ) STORED COMMENT 'Available tickets (calculated)',
  
  -- Purchase Limits
  max_per_user INTEGER DEFAULT 5 COMMENT 'Maximum tickets per user',
  min_per_user INTEGER DEFAULT 1 COMMENT 'Minimum tickets per user',
  
  -- Sales Window
  sales_start TEXT COMMENT 'When ticket sales begin',
  sales_end TEXT COMMENT 'When ticket sales end',
  
  -- Special Ticket Types
  is_early_bird INTEGER DEFAULT FALSE,
  early_bird_end TEXT NULL COMMENT 'End of early bird pricing',
  
  access_level TEXT DEFAULT 'general',
  seating_info TEXT COMMENT 'Seat numbers, sections, etc.',
  
  benefits JSON COMMENT 'Array of benefits: ["early_entry", "free_drink", "meet_greet"]',
  
  -- Status Flags
  is_active INTEGER DEFAULT TRUE,
  is_hidden INTEGER DEFAULT FALSE COMMENT 'Hidden from public view',
  
  -- Special Ticket Categories
  is_student_ticket INTEGER DEFAULT FALSE,
  requires_student_id INTEGER DEFAULT FALSE,
  is_group_ticket INTEGER DEFAULT FALSE,
  group_size INTEGER NULL COMMENT 'Required group size for group tickets',
  
  -- Cached Revenue (Application must keep in sync)
  revenue REAL DEFAULT 0.00 COMMENT 'Cached revenue (sold_count * price) - app must update',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Key
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_event (event_id), -- INDEX converted separately (is_active), -- INDEX converted separately (sales_start, sales_end), -- INDEX converted separately (price), -- INDEX converted separately (access_level), -- INDEX converted separately (deleted_at), -- INDEX converted separately (event_id, is_active), -- INDEX converted separately (event_id, sales_start, sales_end),
  
  -- Unique constraINTEGER: Prevent duplicate ticket names per event
  UNIQUE KEY uq_event_ticket_name (event_id, name),
  
  -- ConstraINTEGERs (Application-enforced, documented here)
  CONSTRAINTEGER chk_quantity CHECK (quantity >= 0),
  CONSTRAINTEGER chk_sold_count CHECK (sold_count >= 0),
  CONSTRAINTEGER chk_reserved_count CHECK (reserved_count >= 0),
  CONSTRAINTEGER chk_price CHECK (price >= 0),
  CONSTRAINTEGER chk_sales_dates CHECK (
    sales_end IS NULL OR 
    sales_start IS NULL OR 
    sales_end > sales_start
  ),
  CONSTRAINTEGER chk_max_min_per_user CHECK (
    max_per_user >= min_per_user AND 
    min_per_user > 0
  ),
  CONSTRAINTEGER chk_group_size CHECK (
    group_size IS NULL OR 
    group_size > 1
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event ticket types with Ethiopian 15% VAT calculations. Revenue field is cached - app must maINTEGERain.';

-- ============================================
-- VIEWS FOR TICKET MANAGEMENT
-- ============================================

-- View for public ticket display
CREATE OR REPLACE VIEW vw_public_tickets AS
SELECT 
    tt.id,
    tt.event_id,
    e.title as event_title,
    e.title_amharic as event_title_amharic,
    tt.name,
    tt.name_amharic,
    tt.description,
    tt.description_amharic,
    tt.price,
    tt.vat_included,
    tt.vat_amount,
    tt.net_price,
    tt.quantity,
    tt.sold_count,
    tt.reserved_count,
    tt.available_count,
    tt.max_per_user,
    tt.min_per_user,
    tt.sales_start,
    tt.sales_end,
    tt.is_early_bird,
    tt.early_bird_end,
    tt.access_level,
    tt.seating_info,
    tt.benefits,
    tt.is_student_ticket,
    tt.requires_student_id,
    tt.is_group_ticket,
    tt.group_size,
    tt.created_at,
    -- Availability status
    CASE 
        WHEN tt.available_count <= 0 THEN 'SOLD_OUT'
        WHEN tt.available_count < 10 THEN 'FEW_LEFT'
        WHEN tt.sales_end IS NOT NULL AND tt.sales_end < NOW() THEN 'SALES_ENDED'
        WHEN tt.sales_start IS NOT NULL AND tt.sales_start > NOW() THEN 'SALES_NOT_STARTED'
        ELSE 'AVAILABLE'
    END as availability_status,
    -- Price display
    CASE 
        WHEN tt.vat_included = TRUE THEN CONCAT(FORMAT(tt.price, 2), ' ETB (VAT included)')
        ELSE CONCAT(FORMAT(tt.price, 2), ' ETB + VAT')
    END as price_display,
    -- Early bird status
    CASE 
        WHEN tt.is_early_bird = TRUE AND tt.early_bird_end > NOW() THEN 'EARLY_BIRD_ACTIVE'
        WHEN tt.is_early_bird = TRUE AND tt.early_bird_end <= NOW() THEN 'EARLY_BIRD_EXPIRED'
        ELSE 'REGULAR_PRICE'
    END as pricing_status
FROM ticket_types tt
JOIN events e ON tt.event_id = e.id
WHERE tt.is_active = TRUE
  AND tt.is_hidden = FALSE
  AND tt.deleted_at IS NULL
  AND e.status = 'published'
ORDER BY 
    tt.price ASC,
    tt.access_level,
    tt.created_at;

-- View for organizer ticket management
CREATE OR REPLACE VIEW vw_organizer_ticket_types AS
SELECT 
    tt.id,
    tt.event_id,
    e.title as event_title,
    tt.name,
    tt.price,
    tt.quantity,
    tt.sold_count,
    tt.reserved_count,
    tt.available_count,
    tt.revenue,
    tt.is_active,
    tt.sales_start,
    tt.sales_end,
    tt.created_at,
    tt.updated_at,
    -- Sales percentage
    CASE 
        WHEN tt.quantity > 0 THEN ROUND((tt.sold_count / tt.quantity) * 100, 1)
        ELSE 0
    END as sold_percentage,
    -- Revenue per ticket
    CASE 
        WHEN tt.sold_count > 0 THEN ROUND(tt.revenue / tt.sold_count, 2)
        ELSE 0
    END as avg_revenue_per_ticket,
    -- Status indicator
    CASE 
        WHEN tt.available_count <= 0 THEN 'SOLD_OUT'
        WHEN tt.sales_end IS NOT NULL AND tt.sales_end < NOW() THEN 'SALES_ENDED'
        WHEN tt.sales_start IS NOT NULL AND tt.sales_start > NOW() THEN 'UPCOMING_SALES'
        WHEN tt.is_active = FALSE THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END as ticket_status
FROM ticket_types tt
JOIN events e ON tt.event_id = e.id
WHERE tt.deleted_at IS NULL
ORDER BY tt.event_id, tt.price;


-- Migration: 020_create_reservations_table.sql (IMPROVED VERSION)
-- Description: Store temporary ticket reservations before payment
-- Dependencies: Requires users, events, ticket_types tables
-- Ethiopian Context: Telebirr and CBE payment methods, ETB currency

-- ============================================
-- TABLE: reservations (IMPROVED)
-- Purpose: Store temporary ticket reservations before payment
-- Important: Reservation rules enforced in application logic
-- ============================================

CREATE TABLE IF NOT EXISTS reservations (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Reservation Identification
  reservation_code VARCHAR(32) UNIQUE NOT NULL COMMENT 'Format: RSV-ETH-YYYYMMDD-XXXXXX',
  user_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  ticket_type_id INTEGEREGER NOT NULL,
  
  -- Reservation Details
  quantity INTEGER NOT NULL,
  total_amount REAL NOT NULL COMMENT 'Total in ETB (supports group bookings)',
  currency VARCHAR(3) DEFAULT 'ETB',
  
  -- Status & Lifecycle
  status TEXT DEFAULT 'active',
  payment_method TEXT NULL,
  
  -- Timing & Expiry
  expires_at TEXT NOT NULL,
  completed_at TEXT NULL,
  cancelled_at TEXT NULL,
  expired_at TEXT NULL COMMENT 'When system marked as expired',
  
  -- User Session & Device Information
  session_id VARCHAR(100),
  device_id VARCHAR(255),
  device_type TEXT DEFAULT 'mobile',
  ip_address VARCHAR(45),
  user_agent TEXT,
  
  -- Ethiopian Payment Context
  telebirr_qr_data TEXT COMMENT 'Telebirr QR code data if payment method is Telebirr',
  cbe_reference_number VARCHAR(50) COMMENT 'CBE reference number for bank transfer',
  payment_instructions TEXT COMMENT 'Payment instructions in Amharic/English',
  
  -- Audit & Metadata
  cancellation_reason TEXT NULL,
  metadata JSON DEFAULT NULL COMMENT 'Reservation metadata',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_reservation_code (reservation_code), -- INDEX converted separately (user_id), -- INDEX converted separately (status, expires_at), -- INDEX converted separately (event_id), -- INDEX converted separately (ticket_type_id), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (payment_method),
  
  -- Composite Indexes for Performance
  INDEX idx_user_event_status (user_id, event_id, status), -- INDEX converted separately (ticket_type_id, status, expires_at), -- INDEX converted separately (event_id, ticket_type_id, status), -- INDEX converted separately (status, expires_at, created_at), -- INDEX converted separately (user_id, created_at, status),
  
  -- Application-enforced constraINTEGERs (documented)
  CONSTRAINTEGER chk_quantity CHECK (quantity > 0 AND quantity <= 100),
  CONSTRAINTEGER chk_total_amount CHECK (total_amount > 0),
  CONSTRAINTEGER chk_expires_at CHECK (expires_at > created_at),
  CONSTRAINTEGER chk_status_dates CHECK (
    (status = 'completed' AND completed_at IS NOT NULL) OR
    (status = 'cancelled' AND cancelled_at IS NOT NULL) OR
    (status = 'expired' AND expired_at IS NOT NULL) OR
    (status IN ('active', 'payment_pending'))
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ticket reservations with Ethiopian payment support. Reservation rules enforced in application.';

-- ============================================
-- VIEWS FOR RESERVATION MANAGEMENT
-- ============================================

-- View for active reservations (for cleanup jobs)
CREATE OR REPLACE VIEW vw_active_reservations AS
SELECT 
    r.id,
    r.reservation_code,
    r.user_id,
    u.full_name as user_name,
    u.phone as user_phone,
    r.event_id,
    e.title as event_title,
    r.ticket_type_id,
    tt.name as ticket_type_name,
    r.quantity,
    r.total_amount,
    r.status,
    r.expires_at,
    r.created_at,
    -- Time until expiry
    TEXTDIFF(MINUTE, NOW(), r.expires_at) as minutes_until_expiry,
    -- Reservation age
    TEXTDIFF(MINUTE, r.created_at, NOW()) as age_minutes,
    -- Payment status
    CASE 
        WHEN r.payment_method IS NOT NULL THEN 'PAYMENT_INITIATED'
        ELSE 'NO_PAYMENT'
    END as payment_status
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN events e ON r.event_id = e.id
JOIN ticket_types tt ON r.ticket_type_id = tt.id
WHERE r.status IN ('active', 'payment_pending')
  AND r.deleted_at IS NULL
  AND r.expires_at > NOW()
ORDER BY r.expires_at ASC;

-- View for reservation analytics
CREATE OR REPLACE VIEW vw_reservation_analytics AS
SELECT 
    DATE(r.created_at) as reservation_date,
    COUNT(*) as total_reservations,
    SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) as completed_count,
    SUM(CASE WHEN r.status = 'expired' THEN 1 ELSE 0 END) as expired_count,
    SUM(CASE WHEN r.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count,
    SUM(r.quantity) as total_tickets_reserved,
    SUM(r.total_amount) as total_value_etb,
    -- Conversion rates
    ROUND(
        (SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
    ) as conversion_rate_percent,
    -- Average reservation value
    ROUND(AVG(r.total_amount), 2) as avg_reservation_value,
    -- Popular payment methods
    MAX(CASE WHEN r.payment_method = 'telebirr' THEN 'Telebirr' END) as top_payment_method
FROM reservations r
WHERE r.deleted_at IS NULL
  AND r.created_at >= DATE_SUB(NOW(), INTEGERERVAL 30 DAY)
GROUP BY DATE(r.created_at)
ORDER BY reservation_date DESC;

-- View for user reservation history
CREATE OR REPLACE VIEW vw_user_reservations AS
SELECT 
    r.id,
    r.reservation_code,
    r.user_id,
    r.event_id,
    e.title as event_title,
    e.start_date as event_date,
    r.ticket_type_id,
    tt.name as ticket_type_name,
    r.quantity,
    r.total_amount,
    r.status,
    r.payment_method,
    r.created_at,
    r.completed_at,
    r.cancelled_at,
    r.expired_at,
    -- Status description
    CASE r.status
        WHEN 'active' THEN 'Reservation Active'
        WHEN 'completed' THEN 'Completed Purchase'
        WHEN 'expired' THEN 'Expired'
        WHEN 'cancelled' THEN 'Cancelled'
        WHEN 'payment_pending' THEN 'Awaiting Payment'
        ELSE r.status
    END as status_description,
    -- Event status
    CASE 
        WHEN e.start_date < NOW() THEN 'EVENT_PASSED'
        WHEN e.cancelled_at IS NOT NULL THEN 'EVENT_CANCELLED'
        ELSE 'EVENT_UPCOMING'
    END as event_status
FROM reservations r
JOIN events e ON r.event_id = e.id
JOIN ticket_types tt ON r.ticket_type_id = tt.id
WHERE r.deleted_at IS NULL
ORDER BY r.created_at DESC;