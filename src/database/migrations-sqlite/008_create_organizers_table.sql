-- Converted from MySQL to SQLite
-- Original file: 008_create_organizers_table.sql
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
