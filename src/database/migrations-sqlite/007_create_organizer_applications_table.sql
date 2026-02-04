-- Converted from MySQL to SQLite
-- Original file: 007_create_organizer_applications_table.sql
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


