-- Converted from MySQL to SQLite
-- Original file: 011_create_payout_requests_table.sql
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
