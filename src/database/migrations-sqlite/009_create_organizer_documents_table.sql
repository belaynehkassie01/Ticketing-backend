-- Converted from MySQL to SQLite
-- Original file: 009_create_organizer_documents_table.sql
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