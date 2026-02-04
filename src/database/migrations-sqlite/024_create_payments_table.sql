-- Converted from MySQL to SQLite
-- Original file: 024_create_payments_table.sql
-- Migration: 024_create_payments_table.sql
-- Description: Store payment transactions for Ethiopian ticketing platform
-- PRODUCTION-FIXED: All MySQL and logic issues resolved
-- Critical fixes: DATE() index, CHECK constraINTEGERs, triggers, procedures

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: payments
-- Purpose: Store payment transactions
-- ============================================

CREATE TABLE IF NOT EXISTS payments (
  -- Primary identifier
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT COMMENT 'INTEGERernal payment ID',
  
  -- Payment Identification
  payment_reference VARCHAR(100) UNIQUE NULL COMMENT 'Public reference - populated by trigger',
  INTEGERernal_reference VARCHAR(100) UNIQUE NULL COMMENT 'INTEGERernal system reference - populated by trigger',
  
  -- User & Relationships
  user_id INTEGEREGER NOT NULL COMMENT 'References users.id (payer)',
  organizer_id INTEGEREGER NOT NULL COMMENT 'References organizers.id',
  event_id INTEGEREGER NOT NULL COMMENT 'References events.id',
  reservation_id INTEGEREGER NULL COMMENT 'References reservations.id',
  ticket_id INTEGEREGER NULL COMMENT 'References individual_tickets.id',
  
  -- Financial Amounts (ETB with Ethiopian VAT)
  currency CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Currency (ETB for Ethiopia)',
  amount REAL NOT NULL COMMENT 'Total amount paid (VAT-INCLUSIVE)',
  vat_rate REAL DEFAULT 15.00 COMMENT 'VAT rate percentage',
  
  -- Generated VAT calculations
  vat_amount REAL GENERATED ALWAYS AS (
    amount - (amount / (1 + (vat_rate / 100)))
  ) STORED COMMENT 'VAT amount - auto-calculated',
  
  net_amount REAL GENERATED ALWAYS AS (
    amount / (1 + (vat_rate / 100))
  ) STORED COMMENT 'Net amount before VAT - auto-calculated',
  
  -- Commission & Earnings
  commission_rate REAL NOT NULL COMMENT 'Platform commission percentage',
  platform_commission REAL NOT NULL COMMENT 'Commission amount in ETB',
  organizer_earning REAL NOT NULL COMMENT 'Organizer earnings after commission',
  
  -- Payment Method
  payment_method_id INTEGEREGER NOT NULL COMMENT 'References payment_methods.id',
  payment_method_code VARCHAR(50) NOT NULL COMMENT 'Payment method code',
  payment_method_type VARCHAR(20) NOT NULL COMMENT 'Payment type from payment_methods',
  
  -- Transaction References
  transaction_id VARCHAR(100) NULL COMMENT 'External transaction ID',
  external_reference VARCHAR(100) NULL COMMENT 'External payment reference',
  telebirr_qr_id VARCHAR(100) NULL COMMENT 'Telebirr QR code identifier',
  cbe_reference_number VARCHAR(100) NULL COMMENT 'CBE transfer reference number',
  
  -- Payment Status
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'initiated',
  
  -- Ethiopian Verification Workflow
  requires_verification INTEGER DEFAULT FALSE COMMENT 'Requires manual verification',
  verification_status TEXT DEFAULT 'pending',
  verified_by INTEGEREGER NULL COMMENT 'References users.id (admin who verified)',
  verified_at TEXT NULL COMMENT 'When payment was manually verified',
  verification_notes TEXT COMMENT 'Notes from verification',
  bank_statement_image VARCHAR(255) NULL COMMENT 'Bank statement image URL',
  
  -- Customer Information
  customer_phone VARCHAR(20) NOT NULL COMMENT 'Customer phone',
  customer_email VARCHAR(100) NULL COMMENT 'Customer email',
  customer_name VARCHAR(100) NULL COMMENT 'Customer name',
  customer_city_id INTEGEREGER NULL COMMENT 'References cities.id',
  
  -- Notification Status
  sms_sent INTEGER DEFAULT FALSE COMMENT 'Payment confirmation SMS sent',
  sms_delivered INTEGER DEFAULT FALSE COMMENT 'SMS delivery confirmed',
  sms_message_id VARCHAR(100) NULL COMMENT 'SMS gateway message ID',
  email_sent INTEGER DEFAULT FALSE COMMENT 'Payment confirmation email sent',
  email_message_id VARCHAR(200) NULL COMMENT 'Email service message ID',
  receipt_sent INTEGER DEFAULT FALSE COMMENT 'Digital receipt sent',
  receipt_url VARCHAR(500) NULL COMMENT 'Digital receipt URL',
  
  -- Fraud Detection
  fraud_score REAL DEFAULT 0.00 COMMENT 'Fraud risk score (0-100)',
  fraud_flags JSON COMMENT 'Array of fraud detection flags',
  is_suspicious INTEGER DEFAULT FALSE COMMENT 'Marked as suspicious',
  fraud_reviewed_by INTEGEREGER NULL COMMENT 'References users.id (fraud reviewer)',
  fraud_reviewed_at TEXT NULL COMMENT 'When fraud review occurred',
  fraud_review_notes TEXT COMMENT 'Fraud review findings',
  
  -- Device & Session
  device_id VARCHAR(255) COMMENT 'Customer device identifier',
  device_type TEXT DEFAULT 'android',
  ip_address VARCHAR(45) COMMENT 'Customer IP address',
  user_agent TEXT COMMENT 'Browser/device info',
  session_id VARCHAR(100) COMMENT 'Web session identifier',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  initiated_at TEXT NULL COMMENT 'When payment was initiated',
  authorized_at TEXT NULL COMMENT 'When payment was authorized',
  captured_at TEXT NULL COMMENT 'When payment was captured',
  completed_at TEXT NULL COMMENT 'When payment was completed',
  failed_at TEXT NULL COMMENT 'When payment failed',
  cancelled_at TEXT NULL COMMENT 'When payment was cancelled',
  refunded_at TEXT NULL COMMENT 'When payment was refunded',
  
  -- Generated completion date for indexing (FIXED: No DATE() in index)
  completed_date DATE GENERATED ALWAYS AS (DATE(completed_at)) STORED COMMENT 'Completion date for indexing',
  
  -- Soft delete
  deleted_at TEXT NULL COMMENT 'Soft delete TEXT',
  
  -- Generated columns
  is_telebirr INTEGER GENERATED ALWAYS AS (payment_method_code = 'telebirr') STORED,
  is_cbe INTEGER GENERATED ALWAYS AS (payment_method_code LIKE 'cbe%') STORED,
  is_instant INTEGER GENERATED ALWAYS AS (requires_verification = FALSE) STORED,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (organizer_id) REFERENCES organizers(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE SET NULL ON UPDATE RESTRICT,
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id) ON DELETE SET NULL ON UPDATE RESTRICT,
  FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
  FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE RESTRICT,
  FOREIGN KEY (customer_city_id) REFERENCES cities(id) ON DELETE SET NULL ON UPDATE RESTRICT,
  FOREIGN KEY (fraud_reviewed_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes (FIXED: Removed DATE() in index)
  INDEX idx_payment_reference (payment_reference), -- INDEX converted separately (INTEGERernal_reference), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (payment_method_code), -- INDEX converted separately (created_at), -- INDEX converted separately (transaction_id), -- INDEX converted separately (requires_verification, status), -- INDEX converted separately (event_id), -- INDEX converted separately (reservation_id), -- INDEX converted separately (ticket_id), -- INDEX converted separately (payment_method_id), -- INDEX converted separately (verified_by), -- INDEX converted separately (completed_at), -- INDEX converted separately (completed_date, status), -- INDEX converted separately (customer_phone), -- INDEX converted separately (verification_status), -- INDEX converted separately (fraud_score, is_suspicious), -- INDEX converted separately (device_id), -- INDEX converted separately (ip_address(20)), -- INDEX converted separately (deleted_at),
  
  -- Composite indexes
  INDEX idx_user_status_date (user_id, status, created_at), -- INDEX converted separately (organizer_id, status, created_at), -- INDEX converted separately (event_id, status, created_at), -- INDEX converted separately (payment_method_code, status, created_at), -- INDEX converted separately (requires_verification, verification_status, created_at), -- INDEX converted separately (is_suspicious, fraud_reviewed_at, status), -- INDEX converted separately (sms_sent, sms_delivered, created_at),
  
  -- Unique constraINTEGERs
  UNIQUE INDEX uq_payment_reference (payment_reference), -- UNIQUE INDEX converted separately (INTEGERernal_reference), -- UNIQUE INDEX converted separately (transaction_id), -- UNIQUE INDEX converted separately (telebirr_qr_id), -- UNIQUE INDEX converted separately (cbe_reference_number),
  
  -- Business Logic ConstraINTEGERs (FIXED: Removed problematic CHECK constraINTEGERs)
  CONSTRAINTEGER chk_amount CHECK (amount > 0),
  CONSTRAINTEGER chk_vat_rate CHECK (vat_rate >= 0 AND vat_rate <= 100),
  CONSTRAINTEGER chk_commission_rate CHECK (commission_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_platform_commission CHECK (platform_commission >= 0),
  CONSTRAINTEGER chk_organizer_earning CHECK (organizer_earning >= 0),
  CONSTRAINTEGER chk_fraud_score CHECK (fraud_score BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_currency_etb CHECK (currency = 'ETB'),
  CONSTRAINTEGER chk_customer_phone_format -- CHECK (REGEXP not supported in SQLite '^09[0-9]{8}$|^\\+2519[0-9]{8}$')
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTOINCREMENT=1000000
  COMMENT='Payment transactions for Ethiopian ticketing platform. Production-safe.';

-- ============================================
-- TRIGGERS: FIXED all issues
-- ============================================

DELIMITER $$

-- Trigger 1: Generate payment references BEFORE insert (FIXED: No AFTER UPDATE)
CREATE TRIGGER trg_payments_before_insert_references
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
  DECLARE date_prefix VARCHAR(10);
  DECLARE payment_num VARCHAR(10);
  DECLARE next_id BIGINTEGER;
  
  -- Get next ID safely
  IF NEW.id IS NULL OR NEW.id = 0 THEN
    -- For new inserts, we'll use a placeholder, then update in app
    SET NEW.payment_reference = CONCAT('PAY-ET-TEMP-', UNIX_TEXT(), '-', RAND());
    SET NEW.INTEGERernal_reference = CONCAT('INTEGER-ET-TEMP-', UNIX_TEXT(), '-', RAND());
  ELSE
    -- For inserts with known ID
    SET date_prefix = DATE_FORMAT(NOW(), '%Y%m%d');
    SET payment_num = NEW.id; -- No LPAD, use actual ID
    SET NEW.payment_reference = CONCAT('PAY-ET-', date_prefix, '-', payment_num);
    SET NEW.INTEGERernal_reference = CONCAT('INTEGER-ET-', date_prefix, '-', payment_num);
  END IF;
  
  -- Set customer phone if not provided
  IF NEW.customer_phone IS NULL OR NEW.customer_phone = '' THEN
    SELECT phone INTEGERO NEW.customer_phone
    FROM users
    WHERE id = NEW.user_id;
  END IF;
  
  -- Set requires_verification based on payment method (FIXED: check FALSE not NULL)
  IF NEW.requires_verification IS NULL THEN
    SELECT COALESCE(requires_verification, FALSE) INTEGERO NEW.requires_verification
    FROM payment_methods 
    WHERE id = NEW.payment_method_id;
  END IF;
  
  -- Set payment_method_type
  IF NEW.payment_method_type IS NULL OR NEW.payment_method_type = '' THEN
    SELECT type INTEGERO NEW.payment_method_type
    FROM payment_methods
    WHERE id = NEW.payment_method_id;
  END IF;
  
  -- Set initiated TEXT
  IF NEW.initiated_at IS NULL THEN
    SET NEW.initiated_at = NOW();
  END IF;
  
  -- Calculate commission if NULL (FIXED: Only if NULL, not 0)
  IF NEW.platform_commission IS NULL AND NEW.commission_rate > 0 AND NEW.amount > 0 THEN
    SET NEW.platform_commission = NEW.amount * (NEW.commission_rate / 100);
    SET NEW.organizer_earning = NEW.amount - NEW.platform_commission;
  END IF;
END$$

-- Trigger 2: Validate status transitions and dates (FIXED: Removed from CHECK)
CREATE TRIGGER trg_payments_before_update_validation
BEFORE UPDATE ON payments
FOR EACH ROW
BEGIN
  -- Validate status dates
  IF NEW.status = 'completed' AND OLD.status != 'completed' THEN
    IF NEW.completed_at IS NULL THEN
      SET NEW.completed_at = NOW();
    END IF;
    SET NEW.payment_status = 'captured';
    SET NEW.captured_at = NOW();
  END IF;
  
  IF NEW.status = 'failed' AND OLD.status != 'failed' THEN
    IF NEW.failed_at IS NULL THEN
      SET NEW.failed_at = NOW();
    END IF;
    SET NEW.payment_status = 'declined';
  END IF;
  
  IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
    IF NEW.cancelled_at IS NULL THEN
      SET NEW.cancelled_at = NOW();
    END IF;
  END IF;
  
  IF NEW.status = 'refunded' AND OLD.status != 'refunded' THEN
    IF NEW.refunded_at IS NULL THEN
      SET NEW.refunded_at = NOW();
    END IF;
  END IF;
  
  IF NEW.payment_status = 'authorized' AND OLD.payment_status != 'authorized' THEN
    IF NEW.authorized_at IS NULL THEN
      SET NEW.authorized_at = NOW();
    END IF;
  END IF;
  
  IF NEW.payment_status = 'captured' AND OLD.payment_status != 'captured' THEN
    IF NEW.captured_at IS NULL THEN
      SET NEW.captured_at = NOW();
    END IF;
  END IF;
  
  -- Validate verification
  IF NEW.verification_status = 'verified' AND OLD.verification_status != 'verified' THEN
    IF NEW.verified_at IS NULL THEN
      SET NEW.verified_at = NOW();
    END IF;
    IF NEW.verified_by IS NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'verified_by must be set when verification_status is verified';
    END IF;
  END IF;
END$$

-- Trigger 3: Basic fraud detection
CREATE TRIGGER trg_payments_before_insert_fraud_basic
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
  DECLARE basic_fraud_score REAL DEFAULT 0;
  DECLARE fraud_flags_array JSON DEFAULT JSON_ARRAY();
  
  -- High amount check
  IF NEW.amount > 50000 THEN
    SET fraud_flags_array = JSON_ARRAY_APPEND(fraud_flags_array, '$', 'high_amount');
    SET basic_fraud_score = basic_fraud_score + 20;
  END IF;
  
  -- CBE payment without reference
  IF NEW.payment_method_code LIKE 'cbe%' AND (NEW.cbe_reference_number IS NULL OR NEW.cbe_reference_number = '') THEN
    SET fraud_flags_array = JSON_ARRAY_APPEND(fraud_flags_array, '$', 'cbe_no_reference');
    SET basic_fraud_score = basic_fraud_score + 30;
  END IF;
  
  -- Set fraud detection
  IF basic_fraud_score > 0 THEN
    SET NEW.fraud_score = basic_fraud_score;
    SET NEW.fraud_flags = fraud_flags_array;
    SET NEW.is_suspicious = CASE WHEN basic_fraud_score >= 50 THEN TRUE ELSE FALSE END;
  END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURES: FIXED all issues
-- ============================================

DELIMITER $$

-- Procedure 1: Create new payment (FIXED: No ENUM in DECLARE, no user variables)
CREATE PROCEDURE sp_create_payment_et(
  IN p_user_id INTEGEREGER,
  IN p_event_id INTEGEREGER,
  IN p_organizer_id INTEGEREGER,
  IN p_payment_method_code VARCHAR(50),
  IN p_amount REAL,
  IN p_device_id VARCHAR(255),
  IN p_ip_address VARCHAR(45),
  IN p_user_agent TEXT,
  IN p_reservation_id INTEGEREGER,
  IN p_ticket_id INTEGEREGER,
  OUT p_payment_id INTEGEREGER,
  OUT p_payment_reference VARCHAR(100),
  OUT p_error_message VARCHAR(500)
)
BEGIN
  DECLARE v_payment_method_id INTEGEREGER;
  DECLARE v_commission_rate REAL;
  DECLARE v_requires_verification INTEGER;
  DECLARE v_payment_method_type VARCHAR(20);
  DECLARE v_customer_phone VARCHAR(20);
  DECLARE v_customer_city_id INTEGEREGER;
  DECLARE v_vat_rate REAL;
  DECLARE v_platform_commission REAL;
  DECLARE v_organizer_earning REAL;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_error_message = MESSAGE_TEXT;
    SET p_payment_id = NULL;
    SET p_payment_reference = NULL;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- Get payment method details
  SELECT 
    id, 
    COALESCE(commission_rate, 10.00), -- Default 10%
    COALESCE(requires_verification, FALSE),
    type
  INTEGERO 
    v_payment_method_id, 
    v_commission_rate, 
    v_requires_verification,
    v_payment_method_type
  FROM payment_methods
  WHERE code = p_payment_method_code
    AND is_active = TRUE
    AND deleted_at IS NULL;
  
  IF v_payment_method_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid or inactive payment method';
  END IF;
  
  -- Get customer details
  SELECT phone, city_id INTEGERO v_customer_phone, v_customer_city_id
  FROM users
  WHERE id = p_user_id;
  
  -- Ethiopian VAT rate
  SET v_vat_rate = 15.00;
  
  -- Calculate amounts (local variables, not user variables)
  SET v_platform_commission = p_amount * (v_commission_rate / 100);
  SET v_organizer_earning = p_amount - v_platform_commission;
  
  -- Insert payment
  INSERT INTEGERO payments (
    user_id,
    event_id,
    organizer_id,
    reservation_id,
    ticket_id,
    payment_method_id,
    payment_method_code,
    payment_method_type,
    amount,
    vat_rate,
    commission_rate,
    platform_commission,
    organizer_earning,
    requires_verification,
    customer_phone,
    customer_city_id,
    device_id,
    device_type,
    ip_address,
    user_agent
  ) VALUES (
    p_user_id,
    p_event_id,
    p_organizer_id,
    p_reservation_id,
    p_ticket_id,
    v_payment_method_id,
    p_payment_method_code,
    v_payment_method_type,
    p_amount,
    v_vat_rate,
    v_commission_rate,
    v_platform_commission,
    v_organizer_earning,
    v_requires_verification,
    v_customer_phone,
    v_customer_city_id,
    p_device_id,
    CASE 
      WHEN p_user_agent LIKE '%Android%' THEN 'android'
      WHEN p_user_agent LIKE '%iPhone%' OR p_user_agent LIKE '%iPad%' THEN 'ios'
      WHEN p_user_agent LIKE '%Windows%' OR p_user_agent LIKE '%Mac%' THEN 'web'
      ELSE 'other'
    END,
    p_ip_address,
    p_user_agent
  );
  
  -- Get the inserted payment ID
  SET p_payment_id = LAST_INSERT_ID();
  
  -- Get the generated payment reference
  SELECT payment_reference INTEGERO p_payment_reference
  FROM payments
  WHERE id = p_payment_id;
  
  COMMIT;
END$$

-- Procedure 2: Verify CBE payment (FIXED: No checkins_count update)
CREATE PROCEDURE sp_verify_cbe_payment_et(
  IN p_payment_reference VARCHAR(100),
  IN p_admin_user_id INTEGEREGER,
  IN p_verification_status VARCHAR(50), -- FIXED: VARCHAR not ENUM
  IN p_verification_notes TEXT,
  IN p_bank_statement_image VARCHAR(255),
  OUT p_success INTEGER,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_payment_id INTEGEREGER;
  DECLARE v_current_status VARCHAR(50);
  DECLARE v_payment_method_code VARCHAR(50);
  DECLARE v_organizer_id INTEGEREGER;
  DECLARE v_amount REAL;
  
  -- Validate verification_status
  IF p_verification_status NOT IN ('verified', 'rejected', 'needs_clarification') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid verification_status';
  END IF;
  
  START TRANSACTION;
  
  -- Get payment details
  SELECT id, status, payment_method_code, organizer_id, amount
  INTEGERO v_payment_id, v_current_status, v_payment_method_code, v_organizer_id, v_amount
  FROM payments
  WHERE payment_reference = p_payment_reference
    AND deleted_at IS NULL;
  
  IF v_payment_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment not found';
  END IF;
  
  IF v_current_status != 'processing' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment is not in processing status';
  END IF;
  
  IF NOT (v_payment_method_code LIKE 'cbe%' OR v_payment_method_code = 'awash_bank') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only CBE/Awash bank payments can be manually verified';
  END IF;
  
  -- Update verification
  UPDATE payments
  SET 
    verification_status = p_verification_status,
    verified_by = p_admin_user_id,
    verification_notes = p_verification_notes,
    bank_statement_image = p_bank_statement_image,
    updated_at = CURRENT_TEXT
  WHERE id = v_payment_id;
  
  -- If verified, complete the payment
  IF p_verification_status = 'verified' THEN
    UPDATE payments
    SET 
      status = 'completed',
      verified_at = NOW(),
      updated_at = CURRENT_TEXT
    WHERE id = v_payment_id;
    
    -- Update organizer revenue (FIXED: This is correct business logic)
    UPDATE organizers
    SET 
      total_revenue = COALESCE(total_revenue, 0) + v_amount,
      updated_at = CURRENT_TEXT
    WHERE id = v_organizer_id;
  END IF;
  
  SET p_success = TRUE;
  SET p_message = CONCAT('Payment verification updated to: ', p_verification_status);
  
  COMMIT;
END$$

-- Procedure 3: Get payment details
CREATE PROCEDURE sp_get_payment_details_et(
  IN p_payment_reference VARCHAR(100),
  IN p_user_id INTEGEREGER
)
BEGIN
  SELECT 
    p.id,
    p.payment_reference,
    p.amount,
    p.currency,
    p.vat_amount,
    p.vat_rate,
    p.net_amount,
    p.status,
    p.payment_status,
    p.payment_method_code,
    p.requires_verification,
    p.verification_status,
    p.created_at,
    p.completed_at,
    p.customer_phone,
    p.customer_name,
    e.title AS event_name,
    e.start_date AS event_date,
    o.business_name AS organizer_name,
    pm.name AS payment_method_name,
    pm.name_amharic AS payment_method_name_amharic,
    pm.instructions AS payment_instructions,
    pm.instructions_amharic AS payment_instructions_amharic,
    -- Bank details for CBE payments
    CASE 
      WHEN p.payment_method_code LIKE 'cbe%' OR p.payment_method_code = 'awash_bank' THEN
        CONCAT_WS('\n',
          CONCAT('Bank: ', COALESCE(pm.bank_name, '')),
          CONCAT('Account: ', COALESCE(pm.account_number, '')),
          CONCAT('Name: ', COALESCE(pm.account_name, '')),
          CONCAT('Reference: ', COALESCE(p.cbe_reference_number, p.payment_reference))
        )
      ELSE NULL
    END AS bank_details,
    -- QR data for Telebirr
    CASE 
      WHEN p.payment_method_code = 'telebirr' AND p.status = 'pending' THEN
        CONCAT(
          'telebirr://pay?amount=', p.amount,
          '&reference=', p.payment_reference,
          '&description=', REPLACE(COALESCE(e.title, ''), ' ', '%20')
        )
      ELSE NULL
    END AS telebirr_qr_data
  FROM payments p
  JOIN events e ON p.event_id = e.id
  JOIN organizers o ON p.organizer_id = o.id
  JOIN payment_methods pm ON p.payment_method_id = pm.id
  WHERE p.payment_reference = p_payment_reference
    AND p.user_id = p_user_id
    AND p.deleted_at IS NULL;
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;