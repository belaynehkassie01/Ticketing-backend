-- Converted from MySQL to SQLite
-- Original file: All-table.sql
001_create_users_table.sql
sql
-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  phone VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE,
  password_hash VARCHAR(255),
  full_name VARCHAR(100),
  role TEXT DEFAULT 'customer',
  preferred_language TEXT DEFAULT 'am',
  city_id INTEGEREGER NULL,
  phone_verified INTEGER DEFAULT FALSE,
  verification_code VARCHAR(6),
  verification_expiry TEXT,
  is_active INTEGER DEFAULT TRUE,
  is_suspended INTEGER DEFAULT FALSE,
  failed_login_attempts INTEGER DEFAULT 0,
  locked_until TEXT NULL,
  last_login TEXT NULL,
  device_id VARCHAR(255),
  organizer_status TEXT DEFAULT 'none',
  organizer_id INTEGEREGER NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (phone), -- INDEX converted separately (role), -- INDEX converted separately (phone_verified), -- INDEX converted separately (is_active), -- INDEX converted separately (city_id), -- INDEX converted separately (organizer_status), -- INDEX converted separately (deleted_at), -- INDEX converted separately (created_at),
  
  CONSTRAINTEGER chk_failed_attempts CHECK (failed_login_attempts >= 0),
  CONSTRAINTEGER chk_phone_format -- CHECK (REGEXP not supported in SQLite '^[0-9+][0-9]{5,}$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
002_create_cities_table.sql
sql
-- ============================================
-- TABLE: cities
-- Purpose: Store Ethiopian cities and regions
-- ============================================
CREATE TABLE IF NOT EXISTS cities (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name_en VARCHAR(100) NOT NULL,
  name_am VARCHAR(100) NOT NULL,
  region TEXT NOT NULL,
  is_active INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (region), -- INDEX converted separately (is_active), -- INDEX converted separately (name_en), -- INDEX converted separately (name_am), -- UNIQUE INDEX converted separately (name_en, region),
  
  CONSTRAINTEGER chk_city_names CHECK (name_en != '' AND name_am != '')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
003_create_roles_table.sql
sql
-- ============================================
-- TABLE: roles
-- Purpose: Store system roles and permissions (from your original users.role enum)
-- ============================================
CREATE TABLE IF NOT EXISTS roles (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(50) UNIQUE NOT NULL,
  description VARCHAR(255),
  permissions JSON COMMENT 'JSON array of permission strings',
  is_active INTEGER DEFAULT TRUE,
  is_system INTEGER DEFAULT FALSE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (name), -- INDEX converted separately (is_active), -- INDEX converted separately (is_system)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
004_create_session_tokens_table.sql
sql
-- ============================================
-- TABLE: session_tokens
-- Purpose: Store user session tokens
-- ============================================
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
  browser VARCHAR(50),
  ip_address VARCHAR(45),
  city_id INTEGEREGER NULL,
  country_code VARCHAR(3) DEFAULT 'ET',
  is_active INTEGER DEFAULT TRUE,
  is_blacklisted INTEGER DEFAULT FALSE,
  expires_at TEXT NOT NULL,
  refresh_expires_at TEXT NOT NULL,
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  created_at TEXT DEFAULT CURRENT_TEXT,
  last_used_at TEXT NULL,
  revoked_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (user_id), -- INDEX converted separately (token(100)), -- INDEX converted separately (refresh_token), -- INDEX converted separately (device_id), -- INDEX converted separately (is_active), -- INDEX converted separately (expires_at), -- INDEX converted separately (refresh_expires_at), -- INDEX converted separately (city_id),
  
  CONSTRAINTEGER chk_expiry_dates CHECK (refresh_expires_at > expires_at)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
005_create_api_keys_table.sql
sql
-- ============================================
-- TABLE: api_keys
-- Purpose: Store API keys for system access
-- ============================================
CREATE TABLE IF NOT EXISTS api_keys (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  api_key VARCHAR(255) UNIQUE NOT NULL,
  api_secret VARCHAR(255) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  user_id INTEGEREGER NULL,
  organizer_id INTEGEREGER NULL,
  permissions JSON COMMENT 'JSON object with endpoINTEGER permissions',
  is_active INTEGER DEFAULT TRUE,
  rate_limit_per_minute INTEGER DEFAULT 60,
  last_used_at TEXT NULL,
  usage_count INTEGEREGER DEFAULT 0,
  ip_whitelist JSON COMMENT 'Array of allowed IP addresses',
  expires_at TEXT NULL,
  allowed_for_country VARCHAR(3) DEFAULT 'ET',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (api_key(100)), -- INDEX converted separately (is_active), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (expires_at), -- INDEX converted separately (created_at),
  
  CONSTRAINTEGER chk_rate_limit CHECK (rate_limit_per_minute > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
006_create_qr_codes_table.sql
sql
-- ============================================
-- TABLE: qr_codes
-- Purpose: Store QR code data for tickets and payments
-- ============================================
CREATE TABLE IF NOT EXISTS qr_codes (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  qr_data TEXT NOT NULL,
  qr_hash VARCHAR(64) UNIQUE NOT NULL,
  qr_image_url VARCHAR(500),
  entity_type TEXT NOT NULL,
  entity_id INTEGEREGER NOT NULL,
  scan_count INTEGEREGER DEFAULT 0,
  last_scanned_at TEXT NULL,
  is_active INTEGER DEFAULT TRUE,
  expires_at TEXT NULL,
  generated_in_country VARCHAR(3) DEFAULT 'ET',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (qr_hash), -- INDEX converted separately (entity_type, entity_id), -- INDEX converted separately (is_active), -- INDEX converted separately (expires_at), -- INDEX converted separately (last_scanned_at),
  
  CONSTRAINTEGER chk_entity_id CHECK (entity_id > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
007_create_organizer_applications_table.sql
sql
-- ============================================
-- TABLE: organizer_applications
-- Purpose: Store organizer applications and verification
-- ============================================
CREATE TABLE IF NOT EXISTS organizer_applications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  business_name VARCHAR(200) NOT NULL,
  business_type TEXT NOT NULL,
  business_description TEXT,
  contact_person VARCHAR(100),
  contact_phone VARCHAR(20),
  contact_email VARCHAR(100),
  id_document_front VARCHAR(255),
  id_document_back VARCHAR(255),
  business_license_doc VARCHAR(255),
  tax_certificate VARCHAR(255),
  bank_name VARCHAR(100),
  bank_account VARCHAR(100),
  account_holder_name VARCHAR(100),
  status TEXT DEFAULT 'pending',
  admin_notes TEXT,
  submitted_at TEXT DEFAULT CURRENT_TEXT,
  reviewed_at TEXT NULL,
  reviewed_by INTEGEREGER NULL,
  review_notes TEXT,
  expected_monthly_events INTEGER,
  primary_event_type VARCHAR(100),
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (status), -- INDEX converted separately (submitted_at), -- INDEX converted separately (user_id), -- INDEX converted separately (reviewed_by), -- INDEX converted separately (reviewed_at),
  
  CONSTRAINTEGER chk_expected_events CHECK (expected_monthly_events IS NULL OR expected_monthly_events >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
008_create_organizers_table.sql
sql
-- ============================================
-- TABLE: organizers
-- Purpose: Store event organizer information
-- ============================================
CREATE TABLE IF NOT EXISTS organizers (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER UNIQUE NOT NULL,
  business_name VARCHAR(200) NOT NULL,
  business_name_amharic VARCHAR(200),
  business_type TEXT NOT NULL,
  tax_id VARCHAR(50),
  business_license VARCHAR(100),
  vat_registered INTEGER DEFAULT FALSE,
  vat_number VARCHAR(50),
  business_phone VARCHAR(20),
  business_email VARCHAR(100),
  website VARCHAR(255),
  region VARCHAR(100),
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  house_number VARCHAR(50),
  bank_name TEXT,
  bank_account VARCHAR(100),
  account_holder_name VARCHAR(100),
  bank_branch VARCHAR(100),
  status TEXT DEFAULT 'pending',
  verification_level TEXT DEFAULT 'basic',
  verified_at TEXT NULL,
  verified_by INTEGEREGER NULL,
  commission_rate REAL DEFAULT 10.00,
  custom_commission_rate REAL NULL,
  total_events INTEGEREGER DEFAULT 0,
  total_tickets_sold INTEGEREGER DEFAULT 0,
  total_revenue REAL DEFAULT 0.00,
  rating REAL DEFAULT 0.00,
  rating_count INTEGEREGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (status), -- INDEX converted separately (business_name), -- INDEX converted separately (verified_at), -- INDEX converted separately (user_id), -- INDEX converted separately (verified_by), -- INDEX converted separately (created_at),
  
  CONSTRAINTEGER chk_commission_rate CHECK (commission_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_custom_commission CHECK (custom_commission_rate IS NULL OR custom_commission_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_rating CHECK (rating BETWEEN 0 AND 5),
  CONSTRAINTEGER chk_revenue CHECK (total_revenue >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
009_create_organizer_documents_table.sql
sql
-- ============================================
-- TABLE: organizer_documents
-- Purpose: Store organizer verification documents
-- ============================================
CREATE TABLE IF NOT EXISTS organizer_documents (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  document_type TEXT NOT NULL,
  document_name VARCHAR(200) NOT NULL,
  file_url VARCHAR(500) NOT NULL,
  mime_type VARCHAR(100),
  file_size INTEGEREGER,
  is_verified INTEGER DEFAULT FALSE,
  verified_by INTEGEREGER NULL,
  verified_at TEXT NULL,
  verification_notes TEXT,
  document_number VARCHAR(100),
  issued_by VARCHAR(200),
  issue_date DATE NULL,
  expiry_date DATE NULL,
  is_active INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (organizer_id), -- INDEX converted separately (document_type), -- INDEX converted separately (is_verified), -- INDEX converted separately (expiry_date), -- INDEX converted separately (verified_by), -- INDEX converted separately (is_active),
  
  CONSTRAINTEGER chk_file_size CHECK (file_size >= 0),
  CONSTRAINTEGER chk_expiry_date CHECK (expiry_date IS NULL OR expiry_date > issue_date)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
010_create_admin_actions_table.sql
sql
-- ============================================
-- TABLE: admin_actions
-- Purpose: Store administrative action logs
-- ============================================
CREATE TABLE IF NOT EXISTS admin_actions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  admin_id INTEGEREGER NOT NULL,
  action_type TEXT NOT NULL,
  action_details TEXT NOT NULL,
  target_type VARCHAR(50),
  target_id INTEGEREGER,
  changes_made JSON COMMENT 'JSON object of old vs new values',
  requires_approval INTEGER DEFAULT FALSE,
  approved_by INTEGEREGER NULL,
  approved_at TEXT NULL,
  approval_notes TEXT,
  performed_at_local TEXT,
  created_at TEXT DEFAULT CURRENT_TEXT,
  
  FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (admin_id), -- INDEX converted separately (action_type), -- INDEX converted separately (target_type, target_id), -- INDEX converted separately (created_at), -- INDEX converted separately (requires_approval, approved_at), -- INDEX converted separately (approved_by), -- INDEX converted separately (performed_at_local)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
011_create_payout_requests_table.sql
sql
-- ============================================
-- TABLE: payout_requests
-- Purpose: Store organizer payout requests
-- ============================================
CREATE TABLE IF NOT EXISTS payout_requests (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  requested_amount REAL NOT NULL,
  available_balance REAL NOT NULL,
  bank_name VARCHAR(100),
  bank_account VARCHAR(100),
  account_holder_name VARCHAR(100),
  status TEXT DEFAULT 'pending',
  requested_at TEXT DEFAULT CURRENT_TEXT,
  reviewed_at TEXT NULL,
  reviewed_by INTEGEREGER NULL,
  review_notes TEXT,
  rejection_reason TEXT,
  payout_id INTEGEREGER NULL,
  
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (payout_id) REFERENCES payouts(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (requested_at), -- INDEX converted separately (reviewed_by), -- INDEX converted separately (payout_id),
  
  CONSTRAINTEGER chk_requested_amount CHECK (requested_amount > 0 AND requested_amount <= available_balance)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
012_create_commissions_table.sql
sql
-- ============================================
-- TABLE: commissions
-- Purpose: Store commission calculations for payments
-- ============================================
CREATE TABLE IF NOT EXISTS commissions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  payment_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  ticket_amount REAL NOT NULL,
  commission_rate REAL NOT NULL,
  commission_amount REAL NOT NULL,
  organizer_amount REAL NOT NULL,
  status TEXT DEFAULT 'pending',
  held_until TEXT NULL,
  released_at TEXT NULL,
  paid_at TEXT NULL,
  payout_id INTEGEREGER NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (payout_id) REFERENCES payouts(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (payment_id), -- INDEX converted separately (event_id), -- INDEX converted separately (payout_id), -- INDEX converted separately (held_until), -- INDEX converted separately (created_at),
  
  CONSTRAINTEGER chk_commission_rate CHECK (commission_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_amounts CHECK (ticket_amount = commission_amount + organizer_amount AND ticket_amount > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
013_create_event_categories_table.sql
sql
-- ============================================
-- TABLE: event_categories
-- Purpose: Store categories for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS event_categories (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  description TEXT,
  icon VARCHAR(50),
  color VARCHAR(7),
  is_active INTEGER DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (is_active), -- INDEX converted separately (sort_order), -- UNIQUE INDEX converted separately (name),
  
  CONSTRAINTEGER chk_color_format CHECK (color IS NULL OR color REGEXP '^#[0-9A-Fa-f]{6}$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
014_create_event_tags_table.sql
sql
-- ============================================
-- TABLE: event_tags
-- Purpose: Store tags for event classification
-- ============================================
CREATE TABLE IF NOT EXISTS event_tags (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  slug VARCHAR(100) UNIQUE NOT NULL,
  is_active INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (slug), -- INDEX converted separately (is_active),
  FULLTEXT idx_search (name, name_amharic),
  
  CONSTRAINTEGER chk_slug_format -- CHECK (REGEXP not supported in SQLite '^[a-z0-9-]+$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
015_create_event_tag_pivot_table.sql
sql
-- ============================================
-- TABLE: event_tag_pivot
-- Purpose: Many-to-many relationship between events and tags
-- ============================================
CREATE TABLE IF NOT EXISTS event_tag_pivot (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGEREGER NOT NULL,
  tag_id INTEGEREGER NOT NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (tag_id) REFERENCES event_tags(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- UNIQUE INDEX converted separately (event_id, tag_id), -- INDEX converted separately (event_id), -- INDEX converted separately (tag_id)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
016_create_venues_table.sql
sql
-- ============================================
-- TABLE: venues
-- Purpose: Store event venue information
-- ============================================
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
  latitude REAL,
  longitude REAL,
  google_maps_url VARCHAR(500),
  capacity INTEGER,
  venue_type TEXT DEFAULT 'indoor',
  amenities JSON COMMENT 'Array of amenities: ["parking", "wifi", "restrooms", "food", "bar", "ac", "stage"]',
  contact_phone VARCHAR(20),
  contact_email VARCHAR(100),
  website VARCHAR(255),
  is_verified INTEGER DEFAULT FALSE,
  is_active INTEGER DEFAULT TRUE,
  description TEXT,
  images JSON COMMENT 'Array of image URLs with metadata',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT, -- INDEX converted separately (city_id), -- INDEX converted separately (name), -- INDEX converted separately (is_active), -- INDEX converted separately (is_verified),
  FULLTEXT idx_search (name, name_amharic, landmark, full_address),
  SPATIAL INDEX idx_location (latitude, longitude),
  
  CONSTRAINTEGER chk_capacity CHECK (capacity IS NULL OR capacity > 0),
  CONSTRAINTEGER chk_coordinates CHECK (
    (latitude IS NULL AND longitude IS NULL) OR 
    (latitude IS NOT NULL AND longitude IS NOT NULL)
  )
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
017_create_events_table.sql
sql
-- ============================================
-- TABLE: events
-- Purpose: Store event information
-- ============================================
CREATE TABLE IF NOT EXISTS events (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  description_amharic TEXT,
  short_description VARCHAR(500),
  category_id INTEGEREGER NOT NULL,
  tags JSON COMMENT 'Array of tag IDs',
  city_id INTEGEREGER NOT NULL,
  venue_id INTEGEREGER NULL,
  venue_custom VARCHAR(200),
  address_details TEXT,
  latitude REAL,
  longitude REAL,
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  start_date_ethiopian VARCHAR(50),
  end_date_ethiopian VARCHAR(50),
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  duration_minutes INTEGER,
  is_recurring INTEGER DEFAULT FALSE,
  recurrence_pattern JSON COMMENT 'Recurrence configuration',
  status TEXT DEFAULT 'draft',
  visibility TEXT DEFAULT 'public',
  is_featured INTEGER DEFAULT FALSE,
  featured_until TEXT NULL,
  has_tickets INTEGER DEFAULT TRUE,
  total_tickets INTEGER DEFAULT 0,
  tickets_sold INTEGER DEFAULT 0,
  min_price REAL NULL,
  max_price REAL NULL,
  cover_image VARCHAR(255),
  gallery_images JSON COMMENT 'Array of image URLs',
  video_url VARCHAR(500),
  age_restriction TEXT DEFAULT 'all',
  is_charity INTEGER DEFAULT FALSE,
  charity_org VARCHAR(200),
  vat_included INTEGER DEFAULT TRUE,
  vat_rate REAL DEFAULT 15.00,
  views INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  meta_title VARCHAR(200),
  meta_description TEXT,
  meta_keywords VARCHAR(500),
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  published_at TEXT NULL,
  cancelled_at TEXT NULL,
  cancellation_reason TEXT,
  cancelled_by INTEGEREGER NULL,
  
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
    ON UPDATE RESTRICT, -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (city_id), -- INDEX converted separately (start_date), -- INDEX converted separately (is_featured, featured_until), -- INDEX converted separately (published_at), -- INDEX converted separately (category_id), -- INDEX converted separately (venue_id), -- INDEX converted separately (cancelled_by),
  SPATIAL INDEX idx_location (latitude, longitude),
  FULLTEXT idx_event_search (title, title_amharic, description, description_amharic),
  
  CONSTRAINTEGER chk_event_dates CHECK (end_date > start_date),
  CONSTRAINTEGER chk_tickets_sold CHECK (tickets_sold <= total_tickets),
  CONSTRAINTEGER chk_vat_rate CHECK (vat_rate >= 0 AND vat_rate <= 100),
  CONSTRAINTEGER chk_slug_format -- CHECK (REGEXP not supported in SQLite '^[a-z0-9-]+$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
018_create_event_media_table.sql
sql
-- ============================================
-- TABLE: event_media
-- Purpose: Store media files for events
-- ============================================
CREATE TABLE IF NOT EXISTS event_media (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGEREGER NOT NULL,
  media_type TEXT DEFAULT 'image',
  url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  filename VARCHAR(255),
  mime_type VARCHAR(100),
  file_size INTEGEREGER,
  width INTEGEREGER,
  height INTEGEREGER,
  duration INTEGEREGER NULL,
  caption VARCHAR(500),
  caption_amharic VARCHAR(500),
  sort_order INTEGER DEFAULT 0,
  is_primary INTEGER DEFAULT FALSE,
  is_approved INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (event_id), -- INDEX converted separately (media_type), -- INDEX converted separately (sort_order), -- INDEX converted separately (is_primary), -- INDEX converted separately (is_approved),
  
  CONSTRAINTEGER chk_file_size CHECK (file_size >= 0),
  CONSTRAINTEGER chk_dimensions CHECK (width >= 0 AND height >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
019_create_ticket_types_table.sql
sql
-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- ============================================
CREATE TABLE IF NOT EXISTS ticket_types (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGEREGER NOT NULL,
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  description TEXT,
  description_amharic TEXT,
  price REAL NOT NULL,
  vat_included INTEGER DEFAULT TRUE,
  vat_amount REAL GENERATED ALWAYS AS (CASE WHEN vat_included THEN price * 0.15 ELSE 0 END) STORED,
  net_price REAL GENERATED ALWAYS AS (CASE WHEN vat_included THEN price / 1.15 ELSE price END) STORED,
  quantity INTEGER NOT NULL,
  sold_count INTEGER DEFAULT 0,
  reserved_count INTEGER DEFAULT 0,
  available_count INTEGER GENERATED ALWAYS AS (quantity - sold_count - reserved_count) STORED,
  max_per_user INTEGER DEFAULT 5,
  min_per_user INTEGER DEFAULT 1,
  sales_start TEXT,
  sales_end TEXT,
  is_early_bird INTEGER DEFAULT FALSE,
  early_bird_end TEXT NULL,
  access_level TEXT DEFAULT 'general',
  seating_info TEXT,
  benefits JSON COMMENT 'Array of benefits for this ticket type',
  is_active INTEGER DEFAULT TRUE,
  is_hidden INTEGER DEFAULT FALSE,
  is_student_ticket INTEGER DEFAULT FALSE,
  requires_student_id INTEGER DEFAULT FALSE,
  is_group_ticket INTEGER DEFAULT FALSE,
  group_size INTEGER NULL,
  revenue REAL DEFAULT 0.00,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (event_id), -- INDEX converted separately (is_active), -- INDEX converted separately (sales_start, sales_end), -- INDEX converted separately (price), -- INDEX converted separately (access_level), -- INDEX converted separately (deleted_at),
  
  CONSTRAINTEGER chk_quantity CHECK (quantity >= 0),
  CONSTRAINTEGER chk_sold_count CHECK (sold_count >= 0),
  CONSTRAINTEGER chk_reserved_count CHECK (reserved_count >= 0),
  CONSTRAINTEGER chk_price CHECK (price >= 0),
  CONSTRAINTEGER chk_sales_dates CHECK (sales_end IS NULL OR sales_start IS NULL OR sales_end > sales_start),
  CONSTRAINTEGER chk_max_min_per_user CHECK (max_per_user >= min_per_user AND min_per_user > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
020_create_reservations_table.sql
sql
-- ============================================
-- TABLE: reservations
-- Purpose: Store temporary ticket reservations before payment
-- ============================================
CREATE TABLE IF NOT EXISTS reservations (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  reservation_code VARCHAR(20) UNIQUE NOT NULL,
  user_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  ticket_type_id INTEGEREGER NOT NULL,
  quantity INTEGER NOT NULL,
  total_amount REAL NOT NULL,
  currency VARCHAR(3) DEFAULT 'ETB',
  status TEXT DEFAULT 'active',
  payment_method TEXT NULL,
  expires_at TEXT NOT NULL,
  completed_at TEXT NULL,
  session_id VARCHAR(100),
  device_id VARCHAR(255),
  ip_address VARCHAR(45),
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT, -- INDEX converted separately (reservation_code), -- INDEX converted separately (user_id), -- INDEX converted separately (status, expires_at), -- INDEX converted separately (event_id), -- INDEX converted separately (ticket_type_id), -- INDEX converted separately (created_at),
  
  CONSTRAINTEGER chk_quantity CHECK (quantity > 0),
  CONSTRAINTEGER chk_total_amount CHECK (total_amount > 0),
  CONSTRAINTEGER chk_expires_at CHECK (expires_at > created_at)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

021_create_individual_tickets_table.sql
sql
-- ============================================
-- TABLE: individual_tickets
-- Purpose: Store individual ticket instances
-- ============================================
CREATE TABLE IF NOT EXISTS individual_tickets (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  ticket_number VARCHAR(50) UNIQUE NOT NULL,
  ticket_type_id INTEGEREGER NOT NULL,
  user_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  purchase_price REAL NOT NULL,
  vat_amount REAL NOT NULL,
  platform_commission REAL NOT NULL,
  organizer_earning REAL NOT NULL,
  qr_data TEXT NOT NULL,
  qr_image_url VARCHAR(500),
  qr_secret_key VARCHAR(100),
  status TEXT DEFAULT 'reserved',
  checked_in_at TEXT NULL,
  checked_in_by INTEGEREGER NULL,
  checkin_device_id VARCHAR(100),
  checkin_location VARCHAR(255),
  checkin_method TEXT NULL,
  transferred_at TEXT NULL,
  transferred_to_user INTEGEREGER NULL,
  transfer_token VARCHAR(100),
  cancelled_at TEXT NULL,
  cancelled_by INTEGEREGER NULL,
  cancellation_reason TEXT NULL,
  refund_amount REAL NULL,
  refunded_at TEXT NULL,
  refund_transaction_id VARCHAR(100),
  payment_method TEXT NULL,
  payment_reference VARCHAR(100),
  device_id VARCHAR(255),
  ip_address VARCHAR(45),
  user_agent TEXT,
  reserved_at TEXT NULL,
  expires_at TEXT NULL,
  purchased_at TEXT NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (checked_in_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (cancelled_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (transferred_to_user) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (ticket_number), -- INDEX converted separately (user_id), -- INDEX converted separately (event_id), -- INDEX converted separately (status), -- INDEX converted separately (organizer_id), -- INDEX converted separately (purchased_at), -- INDEX converted separately (checked_in_at), -- INDEX converted separately (qr_secret_key), -- INDEX converted separately (ticket_type_id), -- INDEX converted separately (checked_in_by), -- UNIQUE INDEX converted separately (qr_data(100)),
  
  CONSTRAINTEGER chk_purchase_price CHECK (purchase_price >= 0),
  CONSTRAINTEGER chk_vat_amount CHECK (vat_amount >= 0),
  CONSTRAINTEGER chk_platform_commission CHECK (platform_commission >= 0),
  CONSTRAINTEGER chk_organizer_earning CHECK (organizer_earning >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
022_create_checkin_logs_table.sql
sql
-- ============================================
-- TABLE: checkin_logs
-- Purpose: Store ticket check-in logs
-- ============================================
CREATE TABLE IF NOT EXISTS checkin_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  ticket_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  checked_in_by INTEGEREGER NOT NULL,
  checkin_method TEXT NOT NULL,
  checkin_time TEXT NOT NULL,
  device_id VARCHAR(255),
  device_type TEXT DEFAULT 'android',
  app_version VARCHAR(20),
  latitude REAL NULL,
  longitude REAL NULL,
  location_name VARCHAR(255),
  is_online INTEGER DEFAULT TRUE,
  sync_status TEXT DEFAULT 'synced',
  local_time VARCHAR(50),
  created_at TEXT DEFAULT CURRENT_TEXT,
  synced_at TEXT NULL,
  
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (checked_in_by) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT, -- INDEX converted separately (ticket_id), -- INDEX converted separately (event_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (checkin_time), -- INDEX converted separately (sync_status), -- INDEX converted separately (checked_in_by), -- INDEX converted separately (device_id),
  SPATIAL INDEX idx_location (latitude, longitude), -- UNIQUE INDEX converted separately (ticket_id, checkin_time),
  
  CONSTRAINTEGER chk_coordinates CHECK (
    (latitude IS NULL AND longitude IS NULL) OR 
    (latitude IS NOT NULL AND longitude IS NOT NULL)
  )
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
023_create_payment_methods_table.sql
sql
-- ============================================
-- TABLE: payment_methods
-- Purpose: Store available payment methods (Telebirr, CBE, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS payment_methods (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  code VARCHAR(50) UNIQUE NOT NULL,
  type TEXT NOT NULL,
  is_active INTEGER DEFAULT TRUE,
  is_default INTEGER DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  min_amount REAL DEFAULT 0.00,
  max_amount REAL DEFAULT 100000.00,
  bank_name VARCHAR(100) NULL,
  account_number VARCHAR(100) NULL,
  account_name VARCHAR(200) NULL,
  qr_supported INTEGER DEFAULT FALSE,
  has_fee INTEGER DEFAULT FALSE,
  fee_type TEXT DEFAULT 'percentage',
  fee_percentage REAL DEFAULT 0.00,
  fee_fixed REAL DEFAULT 0.00,
  api_config JSON COMMENT 'Payment gateway configuration',
  webhook_url VARCHAR(500) NULL,
  icon VARCHAR(255),
  instructions TEXT,
  instructions_amharic TEXT,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (code), -- INDEX converted separately (is_active), -- INDEX converted separately (type), -- INDEX converted separately (sort_order), -- INDEX converted separately (is_default),
  
  CONSTRAINTEGER chk_min_max_amount CHECK (max_amount >= min_amount),
  CONSTRAINTEGER chk_fee_percentage CHECK (fee_percentage >= 0 AND fee_percentage <= 100),
  CONSTRAINTEGER chk_fee_fixed CHECK (fee_fixed >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
024_create_payments_table.sql
sql
-- ============================================
-- TABLE: payments
-- Purpose: Store payment transactions
-- ============================================
CREATE TABLE IF NOT EXISTS payments (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  payment_reference VARCHAR(100) UNIQUE NOT NULL,
  user_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  reservation_id INTEGEREGER NULL,
  amount REAL NOT NULL,
  platform_commission REAL NOT NULL,
  organizer_earning REAL NOT NULL,
  commission_rate REAL NOT NULL,
  vat_amount REAL NOT NULL,
  payment_method_id INTEGEREGER NOT NULL,
  payment_method_code VARCHAR(50) NOT NULL,
  transaction_id VARCHAR(100),
  external_reference VARCHAR(100),
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'initiated',
  requires_verification INTEGER DEFAULT FALSE,
  verified_by INTEGEREGER NULL,
  verified_at TEXT NULL,
  verification_notes TEXT,
  bank_statement_image VARCHAR(255),
  customer_phone VARCHAR(20),
  customer_email VARCHAR(100),
  customer_name VARCHAR(100),
  sms_sent INTEGER DEFAULT FALSE,
  sms_delivered INTEGER DEFAULT FALSE,
  email_sent INTEGER DEFAULT FALSE,
  receipt_sent INTEGER DEFAULT FALSE,
  fraud_score REAL DEFAULT 0.00,
  fraud_flags JSON COMMENT 'Array of fraud detection flags',
  is_suspicious INTEGER DEFAULT FALSE,
  is_telebirr INTEGER GENERATED ALWAYS AS (payment_method_code = 'telebirr') STORED,
  is_cbe INTEGER GENERATED ALWAYS AS (payment_method_code LIKE 'cbe%') STORED,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  completed_at TEXT NULL,
  failed_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (reservation_id) REFERENCES reservations(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (payment_reference), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (payment_method_code), -- INDEX converted separately (created_at), -- INDEX converted separately (transaction_id), -- INDEX converted separately (requires_verification, status), -- INDEX converted separately (event_id), -- INDEX converted separately (reservation_id), -- INDEX converted separately (payment_method_id), -- INDEX converted separately (verified_by), -- INDEX converted separately (completed_at),
  
  CONSTRAINTEGER chk_amount CHECK (amount > 0),
  CONSTRAINTEGER chk_commission_rate CHECK (commission_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_platform_commission CHECK (platform_commission >= 0),
  CONSTRAINTEGER chk_organizer_earning CHECK (organizer_earning >= 0),
  CONSTRAINTEGER chk_vat_amount CHECK (vat_amount >= 0),
  CONSTRAINTEGER chk_fraud_score CHECK (fraud_score BETWEEN 0 AND 100)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
025_create_payment_transactions_table.sql
sql
-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs
-- ============================================
CREATE TABLE IF NOT EXISTS payment_transactions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  payment_id INTEGEREGER NOT NULL,
  transaction_type TEXT DEFAULT 'payment',
  amount REAL NOT NULL,
  currency VARCHAR(3) DEFAULT 'ETB',
  status TEXT DEFAULT 'initiated',
  external_transaction_id VARCHAR(100),
  external_status VARCHAR(50),
  external_response JSON COMMENT 'Raw response from payment gateway',
  request_data JSON COMMENT 'Request data sent to gateway',
  response_data JSON COMMENT 'Response data from gateway',
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  completed_at TEXT NULL,
  
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (payment_id), -- INDEX converted separately (status), -- INDEX converted separately (external_transaction_id), -- INDEX converted separately (created_at), -- INDEX converted separately (transaction_type), -- INDEX converted separately (completed_at),
  
  CONSTRAINTEGER chk_amount_non_zero CHECK (amount != 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
026_create_payment_receipts_table.sql
sql
-- ============================================
-- TABLE: payment_receipts
-- Purpose: Store payment receipt uploads
-- ============================================
CREATE TABLE IF NOT EXISTS payment_receipts (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  payment_id INTEGEREGER NOT NULL,
  user_id INTEGEREGER NOT NULL,
  receipt_type TEXT DEFAULT 'cbe_screenshot',
  image_url VARCHAR(500) NOT NULL,
  thumbnail_url VARCHAR(500),
  bank_name VARCHAR(100),
  account_number VARCHAR(100),
  transaction_id VARCHAR(100),
  amount REAL,
  transaction_date DATE,
  is_verified INTEGER DEFAULT FALSE,
  verified_by INTEGEREGER NULL,
  verified_at TEXT NULL,
  verification_status TEXT DEFAULT 'pending',
  verification_notes TEXT,
  bank_branch VARCHAR(100),
  teller_number VARCHAR(50),
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (verified_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (payment_id), -- INDEX converted separately (user_id), -- INDEX converted separately (verification_status), -- INDEX converted separately (receipt_type), -- INDEX converted separately (verified_by), -- INDEX converted separately (is_verified), -- INDEX converted separately (transaction_date),
  
  CONSTRAINTEGER chk_amount_match CHECK (amount IS NULL OR amount > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
027_create_refunds_table.sql
sql
-- ============================================
-- TABLE: refunds
-- Purpose: Store refund records
-- ============================================
CREATE TABLE IF NOT EXISTS refunds (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  refund_reference VARCHAR(100) UNIQUE NOT NULL,
  ticket_id INTEGEREGER NOT NULL,
  payment_id INTEGEREGER NOT NULL,
  user_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  refund_amount REAL NOT NULL,
  refund_reason TEXT NOT NULL,
  refund_reason_details TEXT,
  status TEXT DEFAULT 'requested',
  requested_at TEXT DEFAULT CURRENT_TEXT,
  requested_by INTEGEREGER NOT NULL,
  approved_at TEXT NULL,
  approved_by INTEGEREGER NULL,
  processed_at TEXT NULL,
  processed_by INTEGEREGER NULL,
  refund_method TEXT DEFAULT 'original_method',
  refund_transaction_id VARCHAR(100),
  commission_refunded INTEGER DEFAULT FALSE,
  commission_refund_amount REAL DEFAULT 0.00,
  requires_approval INTEGER DEFAULT TRUE,
  approval_level TEXT DEFAULT 'organizer',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (requested_by) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (processed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (refund_reference), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (requested_at), -- INDEX converted separately (ticket_id), -- INDEX converted separately (payment_id), -- INDEX converted separately (requested_by), -- INDEX converted separately (approved_by), -- INDEX converted separately (processed_by),
  
  CONSTRAINTEGER chk_refund_amount CHECK (refund_amount > 0),
  CONSTRAINTEGER chk_commission_refund_amount CHECK (commission_refund_amount >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
028_create_payouts_table.sql
sql
-- ============================================
-- TABLE: payouts
-- Purpose: Store organizer payout records
-- ============================================
CREATE TABLE IF NOT EXISTS payouts (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  payout_reference VARCHAR(100) UNIQUE NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  amount REAL NOT NULL,
  currency VARCHAR(3) DEFAULT 'ETB',
  fee_amount REAL DEFAULT 0.00,
  net_amount REAL GENERATED ALWAYS AS (amount - fee_amount) STORED,
  bank_name VARCHAR(100),
  bank_account VARCHAR(100),
  account_holder_name VARCHAR(100),
  bank_branch VARCHAR(100),
  status TEXT DEFAULT 'pending',
  requested_at TEXT DEFAULT CURRENT_TEXT,
  processed_at TEXT NULL,
  processed_by INTEGEREGER NULL,
  processing_notes TEXT,
  transfer_method TEXT DEFAULT 'cbe_online',
  transfer_reference VARCHAR(100),
  transfer_date DATE NULL,
  payment_ids JSON COMMENT 'Array of payment IDs included in this payout',
  tax_deducted INTEGER DEFAULT FALSE,
  tax_amount REAL DEFAULT 0.00,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (processed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (payout_reference), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (requested_at), -- INDEX converted separately (processed_at), -- INDEX converted separately (processed_by), -- INDEX converted separately (transfer_date),
  
  CONSTRAINTEGER chk_payout_amount CHECK (amount > 0),
  CONSTRAINTEGER chk_fee_amount CHECK (fee_amount >= 0),
  CONSTRAINTEGER chk_tax_amount CHECK (tax_amount >= 0),
  CONSTRAINTEGER chk_net_amount CHECK (net_amount > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
029_create_taxes_table.sql
sql
-- ============================================
-- TABLE: taxes
-- Purpose: Store tax information (VAT, etc.)
-- ============================================
CREATE TABLE IF NOT EXISTS taxes (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  tax_type TEXT DEFAULT 'vat',
  name VARCHAR(100) NOT NULL,
  name_amharic VARCHAR(100),
  rate REAL NOT NULL,
  is_active INTEGER DEFAULT TRUE,
  effective_from DATE NOT NULL,
  effective_to DATE NULL,
  applies_to_tickets INTEGER DEFAULT TRUE,
  applies_to_commission INTEGER DEFAULT FALSE,
  applies_to_fees INTEGER DEFAULT FALSE,
  tax_authority VARCHAR(200),
  authority_code VARCHAR(50),
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (tax_type), -- INDEX converted separately (is_active), -- INDEX converted separately (effective_from, effective_to), -- UNIQUE INDEX converted separately (tax_type, effective_from),
  
  CONSTRAINTEGER chk_tax_rate CHECK (rate >= 0 AND rate <= 100),
  CONSTRAINTEGER chk_effective_dates CHECK (effective_to IS NULL OR effective_to > effective_from)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
030_create_financial_reports_table.sql
sql
-- ============================================
-- TABLE: financial_reports
-- Purpose: Store financial reports and analytics
-- ============================================
CREATE TABLE IF NOT EXISTS financial_reports (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  report_type TEXT NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  total_revenue REAL DEFAULT 0.00,
  total_tickets_sold INTEGER DEFAULT 0,
  total_events INTEGER DEFAULT 0,
  total_organizers INTEGER DEFAULT 0,
  revenue_by_city JSON COMMENT 'City-wise revenue breakdown',
  revenue_by_category JSON COMMENT 'Category-wise revenue breakdown',
  revenue_by_payment_method JSON COMMENT 'Payment method-wise revenue breakdown',
  platform_commission REAL DEFAULT 0.00,
  platform_fees REAL DEFAULT 0.00,
  total_vat_collected REAL DEFAULT 0.00,
  total_payouts REAL DEFAULT 0.00,
  payouts_by_organizer JSON COMMENT 'Organizer-wise payout breakdown',
  report_currency VARCHAR(3) DEFAULT 'ETB',
  exchange_rate REAL DEFAULT 1.0000,
  status TEXT DEFAULT 'generating',
  generated_at TEXT NULL,
  generated_by INTEGEREGER NULL,
  report_file_url VARCHAR(500),
  report_data JSON COMMENT 'Complete report data in JSON format',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (generated_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (report_type), -- INDEX converted separately (period_start, period_end), -- INDEX converted separately (generated_at), -- INDEX converted separately (generated_by), -- INDEX converted separately (status), -- UNIQUE INDEX converted separately (report_type, period_start, period_end),
  
  CONSTRAINTEGER chk_period CHECK (period_end >= period_start),
  CONSTRAINTEGER chk_exchange_rate CHECK (exchange_rate > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
031_create_disputes_table.sql
sql
-- ============================================
-- TABLE: disputes
-- Purpose: Store dispute records between users and organizers
-- ============================================
CREATE TABLE IF NOT EXISTS disputes (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  dispute_reference VARCHAR(100) UNIQUE NOT NULL,
  user_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  ticket_id INTEGEREGER NULL,
  payment_id INTEGEREGER NULL,
  type TEXT NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  desired_outcome TEXT NOT NULL,
  status TEXT DEFAULT 'open',
  resolution TEXT NULL,
  resolution_amount REAL NULL,
  resolution_details TEXT,
  assigned_to INTEGEREGER NULL,
  assigned_at TEXT NULL,
  resolved_at TEXT NULL,
  resolved_by INTEGEREGER NULL,
  closed_at TEXT NULL,
  requires_mediation INTEGER DEFAULT FALSE,
  mediation_notes TEXT,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (assigned_to) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (resolved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (dispute_reference), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (created_at), -- INDEX converted separately (assigned_to, status), -- INDEX converted separately (event_id), -- INDEX converted separately (type), -- INDEX converted separately (resolved_at),
  
  CONSTRAINTEGER chk_resolution_amount CHECK (resolution_amount IS NULL OR resolution_amount >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
032_create_notifications_table.sql
sql
-- ============================================
-- TABLE: notifications
-- Purpose: Store user notifications
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  type TEXT NOT NULL,
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  message TEXT NOT NULL,
  message_amharic TEXT,
  action_url VARCHAR(500),
  action_label VARCHAR(100),
  action_label_amharic VARCHAR(100),
  is_read INTEGER DEFAULT FALSE,
  is_sent INTEGER DEFAULT FALSE,
  delivery_method TEXT DEFAULT 'in_app',
  priority TEXT DEFAULT 'medium',
  expires_at TEXT NULL,
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  preferred_language TEXT DEFAULT 'am',
  created_at TEXT DEFAULT CURRENT_TEXT,
  sent_at TEXT NULL,
  read_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (user_id), -- INDEX converted separately (type), -- INDEX converted separately (is_read), -- INDEX converted separately (created_at), -- INDEX converted separately (priority), -- INDEX converted separately (delivery_method), -- INDEX converted separately (expires_at), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (is_sent),
  
  CONSTRAINTEGER chk_expires_at CHECK (expires_at IS NULL OR expires_at > created_at)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
033_create_sms_logs_table.sql
sql
-- ============================================
-- TABLE: sms_logs
-- Purpose: Store SMS delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS sms_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  recipient_phone VARCHAR(20) NOT NULL,
  recipient_name VARCHAR(100),
  message_type TEXT NOT NULL,
  message_text TEXT NOT NULL,
  message_text_amharic TEXT,
  language TEXT DEFAULT 'am',
  status TEXT DEFAULT 'pending',
  message_id VARCHAR(100),
  delivery_report JSON COMMENT 'SMS gateway delivery report',
  cost REAL DEFAULT 0.00,
  currency VARCHAR(3) DEFAULT 'ETB',
  segments INTEGER DEFAULT 1,
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  gateway VARCHAR(50) DEFAULT 'ethio_telecom',
  route VARCHAR(50),
  scheduled_at TEXT NULL,
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  expires_at TEXT NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (recipient_phone), -- INDEX converted separately (status), -- INDEX converted separately (message_type), -- INDEX converted separately (sent_at), -- INDEX converted separately (gateway), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (created_at), -- INDEX converted separately (language),
  
  CONSTRAINTEGER chk_segments CHECK (segments > 0),
  CONSTRAINTEGER chk_cost CHECK (cost >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
034_create_email_logs_table.sql
sql
-- ============================================
-- TABLE: email_logs
-- Purpose: Store email delivery logs
-- ============================================
CREATE TABLE IF NOT EXISTS email_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  recipient_email VARCHAR(100) NOT NULL,
  recipient_name VARCHAR(100),
  subject VARCHAR(200) NOT NULL,
  template_name VARCHAR(100),
  language TEXT DEFAULT 'en',
  status TEXT DEFAULT 'pending',
  message_id VARCHAR(200),
  delivery_report JSON COMMENT 'Email service delivery report',
  body_html TEXT,
  body_text TEXT,
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  opened_at TEXT NULL,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (recipient_email), -- INDEX converted separately (status), -- INDEX converted separately (sent_at), -- INDEX converted separately (template_name), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (created_at), -- INDEX converted separately (language),
  
  CONSTRAINTEGER chk_email_format -- CHECK (REGEXP not supported in SQLite '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
035_create_push_notifications_table.sql
sql
-- ============================================
-- TABLE: push_notifications
-- Purpose: Store push notification logs
-- ============================================
CREATE TABLE IF NOT EXISTS push_notifications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  device_token VARCHAR(255) NOT NULL,
  device_type TEXT NOT NULL,
  app_version VARCHAR(20),
  title VARCHAR(200) NOT NULL,
  body TEXT NOT NULL,
  data JSON COMMENT 'Additional data payload',
  status TEXT DEFAULT 'pending',
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  failure_reason TEXT,
  language TEXT DEFAULT 'am',
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT, -- INDEX converted separately (user_id), -- INDEX converted separately (device_token), -- INDEX converted separately (status), -- INDEX converted separately (sent_at), -- INDEX converted separately (device_type), -- INDEX converted separately (created_at), -- INDEX converted separately (language),
  
  CONSTRAINTEGER chk_device_token_length CHECK (CHAR_LENGTH(device_token) >= 10)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
036_create_notification_templates_table.sql
sql
-- ============================================
-- TABLE: notification_templates
-- Purpose: Store notification templates
-- ============================================
CREATE TABLE IF NOT EXISTS notification_templates (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  template_type TEXT NOT NULL,
  template_code VARCHAR(100) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  subject VARCHAR(200),
  body_template TEXT NOT NULL,
  body_template_amharic TEXT,
  variables JSON COMMENT 'Array of template variable names',
  is_active INTEGER DEFAULT TRUE,
  priority INTEGER DEFAULT 0,
  default_language TEXT DEFAULT 'am',
  requires_translation INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (template_code), -- INDEX converted separately (template_type), -- INDEX converted separately (is_active), -- INDEX converted separately (priority), -- INDEX converted separately (default_language), -- INDEX converted separately (requires_translation),
  
  CONSTRAINTEGER chk_priority CHECK (priority >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
037_create_message_threads_table.sql
sql
-- ============================================
-- TABLE: message_threads
-- Purpose: Store message threads between users, organizers, and admins
-- ============================================
CREATE TABLE IF NOT EXISTS message_threads (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NULL,
  admin_id INTEGEREGER NULL,
  subject VARCHAR(200) NOT NULL,
  related_event_id INTEGEREGER NULL,
  related_ticket_id INTEGEREGER NULL,
  status TEXT DEFAULT 'open',
  priority TEXT DEFAULT 'medium',
  last_message_at TEXT NULL,
  last_message_by INTEGEREGER NULL,
  message_count INTEGEREGER DEFAULT 0,
  unread_count_user INTEGEREGER DEFAULT 0,
  unread_count_admin INTEGEREGER DEFAULT 0,
  unread_count_organizer INTEGEREGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  resolved_at TEXT NULL,
  closed_at TEXT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (related_event_id) REFERENCES events(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (related_ticket_id) REFERENCES individual_tickets(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (last_message_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (last_message_at), -- INDEX converted separately (priority), -- INDEX converted separately (admin_id), -- INDEX converted separately (related_event_id), -- INDEX converted separately (related_ticket_id), -- INDEX converted separately (last_message_by),
  
  CONSTRAINTEGER chk_message_counts CHECK (message_count >= 0 AND unread_count_user >= 0 AND unread_count_admin >= 0 AND unread_count_organizer >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
038_create_audit_logs_table.sql
sql
-- ============================================
-- TABLE: audit_logs
-- Purpose: Store audit trail for important actions
-- ============================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NULL,
  user_type TEXT NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id INTEGEREGER NOT NULL,
  old_values JSON COMMENT 'Previous values before change',
  new_values JSON COMMENT 'New values after change',
  changed_fields JSON COMMENT 'Array of field names that changed',
  ip_address VARCHAR(45),
  user_agent TEXT,
  device_id VARCHAR(255),
  session_id VARCHAR(100),
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  created_at TEXT DEFAULT CURRENT_TEXT, -- INDEX converted separately (user_id), -- INDEX converted separately (action), -- INDEX converted separately (entity_type, entity_id), -- INDEX converted separately (created_at), -- INDEX converted separately (user_type), -- INDEX converted separately (ip_address), -- INDEX converted separately (session_id), -- INDEX converted separately (entity_id),
  
  CONSTRAINTEGER chk_entity_id_positive CHECK (entity_id > 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
039_create_activity_logs_table.sql
sql
-- ============================================
-- TABLE: activity_logs
-- Purpose: Store user activity logs
-- ============================================
CREATE TABLE IF NOT EXISTS activity_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGEREGER NOT NULL,
  activity_type TEXT NOT NULL,
  activity_details TEXT,
  page_url VARCHAR(500),
  referrer_url VARCHAR(500),
  device_type TEXT DEFAULT 'mobile',
  browser VARCHAR(100),
  os VARCHAR(100),
  city_id INTEGEREGER NULL,
  estimated_location VARCHAR(255),
  load_time_ms INTEGER,
  created_at TEXT DEFAULT CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (user_id), -- INDEX converted separately (activity_type), -- INDEX converted separately (created_at), -- INDEX converted separately (city_id), -- INDEX converted separately (device_type), -- INDEX converted separately (page_url(100)), -- INDEX converted separately (referrer_url(100)),
  
  CONSTRAINTEGER chk_load_time CHECK (load_time_ms IS NULL OR load_time_ms >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
040_create_offline_sync_logs_table.sql
sql
-- ============================================
-- TABLE: offline_sync_logs
-- Purpose: Store offline sync logs
-- ============================================
CREATE TABLE IF NOT EXISTS offline_sync_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  device_id VARCHAR(255) NOT NULL,
  user_id INTEGEREGER NOT NULL,
  device_type TEXT NOT NULL,
  app_version VARCHAR(20),
  sync_type TEXT NOT NULL,
  records_count INTEGER DEFAULT 0,
  data_size_kb INTEGER,
  status TEXT DEFAULT 'pending',
  started_at TEXT NOT NULL,
  completed_at TEXT NULL,
  duration_ms INTEGER,
  connection_type TEXT DEFAULT 'unknown',
  network_speed_kbps INTEGER,
  city_id INTEGEREGER NULL,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (device_id), -- INDEX converted separately (user_id), -- INDEX converted separately (status), -- INDEX converted separately (started_at), -- INDEX converted separately (sync_type), -- INDEX converted separately (city_id), -- INDEX converted separately (connection_type), -- INDEX converted separately (completed_at),
  
  CONSTRAINTEGER chk_records_count CHECK (records_count >= 0),
  CONSTRAINTEGER chk_data_size CHECK (data_size_kb IS NULL OR data_size_kb >= 0),
  CONSTRAINTEGER chk_duration CHECK (duration_ms IS NULL OR duration_ms >= 0),
  CONSTRAINTEGER chk_network_speed CHECK (network_speed_kbps IS NULL OR network_speed_kbps >= 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
041_create_webhook_logs_table.sql
sql
-- ============================================
-- TABLE: webhook_logs
-- Purpose: Store webhook logs
-- ============================================
CREATE TABLE IF NOT EXISTS webhook_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  webhook_type TEXT NOT NULL,
  endpoINTEGER_url VARCHAR(500) NOT NULL,
  request_headers JSON COMMENT 'HTTP headers sent',
  request_body TEXT,
  request_method VARCHAR(10) DEFAULT 'POST',
  response_status INTEGER,
  response_headers JSON COMMENT 'HTTP headers received',
  response_body TEXT,
  response_time_ms INTEGER,
  status TEXT DEFAULT 'pending',
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,
  next_retry_at TEXT NULL,
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  created_at TEXT DEFAULT CURRENT_TEXT,
  sent_at TEXT NULL,
  delivered_at TEXT NULL, -- INDEX converted separately (webhook_type), -- INDEX converted separately (status), -- INDEX converted separately (created_at), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (next_retry_at), -- INDEX converted separately (endpoINTEGER_url(100)), -- INDEX converted separately (response_status), -- INDEX converted separately (sent_at),
  
  CONSTRAINTEGER chk_response_time CHECK (response_time_ms IS NULL OR response_time_ms >= 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0),
  CONSTRAINTEGER chk_response_status CHECK (response_status IS NULL OR response_status BETWEEN 100 AND 599)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
042_create_system_settings_table.sql
sql
-- ============================================
-- TABLE: system_settings
-- Purpose: Store system configuration settings
-- ============================================
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
    ON DELETE SET NULL
    ON UPDATE RESTRICT, -- INDEX converted separately (category), -- INDEX converted separately (setting_key), -- INDEX converted separately (is_public), -- INDEX converted separately (is_editable), -- INDEX converted separately (applies_to_country), -- INDEX converted separately (updated_by),
  
  CONSTRAINTEGER chk_setting_key_format -- CHECK (REGEXP not supported in SQLite '^[a-z][a-z0-9_]*$')
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
043_create_ethiopian_holidays_table.sql
sql
-- ============================================
-- TABLE: ethiopian_holidays
-- Purpose: Store Ethiopian holiday calendar
-- ============================================
CREATE TABLE IF NOT EXISTS ethiopian_holidays (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(200) NOT NULL,
  name_amharic VARCHAR(200),
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  holiday_type TEXT DEFAULT 'national',
  is_active INTEGER DEFAULT TRUE,
  year YEAR,
  recurring INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (start_date, end_date), -- INDEX converted separately (year), -- INDEX converted separately (is_active), -- INDEX converted separately (holiday_type), -- INDEX converted separately (recurring), -- UNIQUE INDEX converted separately (name, year),
  
  CONSTRAINTEGER chk_holiday_dates CHECK (end_date >= start_date),
  CONSTRAINTEGER chk_year_range CHECK (year BETWEEN 1900 AND 2100)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;