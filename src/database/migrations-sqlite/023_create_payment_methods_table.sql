-- Converted from MySQL to SQLite
-- Original file: 023_create_payment_methods_table.sql
-- Migration: 023_create_payment_methods_table.sql
-- Description: Store available payment methods for Ethiopian context
-- Purpose: Configure Telebirr, CBE, and other Ethiopian payment options
-- Ethiopian Context: Mobile money (Telebirr), bank transfers (CBE), QR payments, Ethiopian banking
-- Dependencies: None (standalone configuration table)
-- Production-safe with all critical issues fixed

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: payment_methods
-- Purpose: Store available payment methods (Telebirr, CBE, etc.)
-- Ethiopian Context: Local payment methods, ETB currency, Ethiopian bank INTEGERegration
-- ============================================

CREATE TABLE IF NOT EXISTS payment_methods (
  -- Primary identifier
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT COMMENT 'INTEGERernal payment method ID',
  
  -- Basic Information (Bilingual for Ethiopia)
  name VARCHAR(100) NOT NULL COMMENT 'Payment method name in English',
  name_amharic VARCHAR(100) COMMENT 'Payment method name in Amharic (አማርኛ)',
  code VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique code (e.g., telebirr, cbe_transfer, cbe_birr)',
  
  -- Classification
  type TEXT NOT NULL 
    COMMENT 'Payment type (mobile_money for Telebirr, bank_transfer for CBE)',
  
  -- Status & Display
  is_active INTEGER DEFAULT TRUE COMMENT 'Is this payment method currently available?',
  is_default INTEGER DEFAULT FALSE COMMENT 'Should this be the default selection?',
  sort_order INTEGER DEFAULT 0 COMMENT 'Display order (0 = first)',
  icon VARCHAR(255) COMMENT 'Icon URL or icon class',
  color VARCHAR(7) DEFAULT '#078930' COMMENT 'Display color (Ethiopian green default)',
  
  -- Environment & Deployment
  environment TEXT DEFAULT 'production' 
    COMMENT 'Environment (sandbox for testing, production for live)',
  
  -- Ethiopian Currency & Amount Limits
  currency CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Currency (ETB for Ethiopia)',
  min_amount REAL DEFAULT 1.00 COMMENT 'Minimum payment amount in ETB',
  max_amount REAL DEFAULT 1000000.00 COMMENT 'Maximum payment amount in ETB',
  
  -- Bank Information (for CBE and other banks)
  bank_name VARCHAR(100) NULL COMMENT 'Bank name (e.g., Commercial Bank of Ethiopia)',
  account_number VARCHAR(100) NULL COMMENT 'Platform bank account number',
  account_name VARCHAR(200) NULL COMMENT 'Account holder name',
  bank_branch VARCHAR(100) NULL COMMENT 'Bank branch name/location',
  swift_code VARCHAR(11) NULL COMMENT 'SWIFT/BIC code for INTEGERernational',
  
  -- QR Code Support (Ethiopian Mobile Payments)
  qr_supported INTEGER DEFAULT FALSE COMMENT 'Does this method support QR payments?',
  qr_schema VARCHAR(50) NULL COMMENT 'QR code schema (e.g., telebirr://, cbe://)',
  qr_template TEXT NULL COMMENT 'QR code data template with placeholders',
  
  -- Fees & Charges (Ethiopian Market Rates)
  has_fee INTEGER DEFAULT FALSE COMMENT 'Does this method have transaction fees?',
  fee_type TEXT DEFAULT 'none',
  fee_percentage REAL DEFAULT 0.00 COMMENT 'Percentage fee (e.g., 1.5%)',
  fee_fixed REAL DEFAULT 0.00 COMMENT 'Fixed fee in ETB',
  fee_capped_at REAL NULL COMMENT 'Maximum fee amount in ETB',
  who_pays_fee TEXT DEFAULT 'customer',
  
  -- API & INTEGERegration Configuration
  api_config JSON COMMENT 'Payment gateway configuration (API keys, endpoINTEGERs, etc.)',
  webhook_url VARCHAR(500) NULL COMMENT 'Webhook URL for payment notifications',
  callback_url_template VARCHAR(500) NULL COMMENT 'Callback URL template',
  api_version VARCHAR(20) DEFAULT 'v1' COMMENT 'API version for INTEGERegration',
  
  -- Instructions (Bilingual for Ethiopian Users)
  instructions TEXT COMMENT 'Payment instructions in English',
  instructions_amharic TEXT COMMENT 'Payment instructions in Amharic',
  short_description VARCHAR(500) COMMENT 'Brief description for display',
  short_description_amharic VARCHAR(500) COMMENT 'Brief description in Amharic',
  
  -- Ethiopian Compliance & Regulation
  requires_verification INTEGER DEFAULT FALSE COMMENT 'Requires manual verification (e.g., CBE transfers)',
  verification_time_minutes INTEGER DEFAULT 60 COMMENT 'Estimated verification time in minutes',
  supports_refunds INTEGER DEFAULT TRUE COMMENT 'Does this method support refunds?',
  refund_time_hours INTEGER DEFAULT 24 COMMENT 'Estimated refund processing time in hours',
  
  -- Availability & Restrictions
  available_for_country VARCHAR(3) DEFAULT 'ET' COMMENT 'Country code (ET for Ethiopia)',
  available_from_time TIME DEFAULT '00:00:00' COMMENT 'Available from time (24h)',
  available_to_time TIME DEFAULT '23:59:59' COMMENT 'Available to time (24h)',
  available_days VARCHAR(20) DEFAULT '1,2,3,4,5,6,7' COMMENT 'Days available (1=Sunday)',
  
  -- Performance & Metrics
  success_rate REAL DEFAULT 100.00 COMMENT 'Historical success rate percentage',
  avg_processing_seconds INTEGER DEFAULT 60 COMMENT 'Average processing time in seconds',
  total_transactions INTEGEREGER DEFAULT 0 COMMENT 'Total transactions processed',
  total_volume REAL DEFAULT 0.00 COMMENT 'Total transaction volume in ETB',
  
  -- Security & Fraud Prevention
  supports_3d_secure INTEGER DEFAULT FALSE COMMENT 'Supports 3D Secure authentication',
  fraud_score_threshold REAL DEFAULT 80.00 COMMENT 'Fraud score threshold for auto-rejection',
  requires_otp INTEGER DEFAULT TRUE COMMENT 'Requires OTP verification',
  
  -- TEXTs with soft delete support
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  activated_at TEXT NULL COMMENT 'When this payment method was activated',
  deactivated_at TEXT NULL COMMENT 'When this payment method was deactivated',
  deleted_at TEXT NULL COMMENT 'Soft delete TEXT',
  
  -- Indexes for Ethiopian-scale performance
  INDEX idx_code (code), -- INDEX converted separately (is_active), -- INDEX converted separately (type), -- INDEX converted separately (sort_order), -- INDEX converted separately (is_default), -- INDEX converted separately (bank_name), -- INDEX converted separately (available_for_country), -- INDEX converted separately (requires_verification), -- INDEX converted separately (environment), -- INDEX converted separately (deleted_at),
  
  -- Unique constraINTEGERs
  UNIQUE INDEX uq_code (code), -- UNIQUE INDEX converted separately (name, available_for_country, deleted_at),
  
  -- Ethiopian Business Logic ConstraINTEGERs
  CONSTRAINTEGER chk_min_max_amount CHECK (max_amount >= min_amount),
  CONSTRAINTEGER chk_fee_percentage CHECK (fee_percentage >= 0 AND fee_percentage <= 100),
  CONSTRAINTEGER chk_fee_fixed CHECK (fee_fixed >= 0),
  CONSTRAINTEGER chk_success_rate CHECK (success_rate BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_processing_time CHECK (avg_processing_seconds >= 0),
  CONSTRAINTEGER chk_currency_etb CHECK (currency = 'ETB'), -- Ethiopian-only for now
  CONSTRAINTEGER chk_country_et CHECK (available_for_country = 'ET'), -- Ethiopia only
  CONSTRAINTEGER chk_fee_capped CHECK (fee_capped_at IS NULL OR fee_capped_at >= 0)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTOINCREMENT=100
  COMMENT='Payment methods configuration for Ethiopian ticketing platform. Includes Telebirr, CBE, and local payment options with bilingual support. Production-safe with soft delete and environment support.';

-- ============================================
-- DEFAULT DATA: Ethiopian Payment Methods
-- Note: These are essential configurations, not sample/test data
-- ============================================

-- 1. Telebirr (Ethiopian Mobile Money - Most Important)
INSERT IGNORE INTEGERO payment_methods (
  name,
  name_amharic,
  code,
  type,
  is_active,
  is_default,
  sort_order,
  icon,
  color,
  environment,
  qr_supported,
  qr_schema,
  qr_template,
  has_fee,
  fee_type,
  fee_percentage,
  fee_fixed,
  who_pays_fee,
  api_config,
  instructions,
  instructions_amharic,
  short_description,
  short_description_amharic,
  requires_verification,
  verification_time_minutes,
  success_rate,
  avg_processing_seconds,
  available_from_time,
  available_to_time,
  available_days,
  activated_at
) VALUES (
  'Telebirr',
  'ቴሌብር',
  'telebirr',
  'mobile_money',
  TRUE,
  TRUE,
  1,
  '/assets/payment-icons/telebirr.svg',
  '#078930',
  'sandbox', -- Default to sandbox for safety
  TRUE,
  'telebirr://',
  '{"amount": "{amount}", "reference": "{reference}", "description": "{description}"}',
  FALSE,
  'none',
  0.00,
  0.00,
  'customer',
  '{"mode": "sandbox", "merchant_id": "TEST_MERCHANT", "api_key": "TEST_API_KEY", "api_secret": "TEST_API_SECRET"}',
  '1. Open Telebirr app\n2. Tap "Scan QR Code"\n3. Scan the QR code displayed\n4. Confirm payment\n5. You will receive SMS confirmation',
  '1. ቴሌብር አፕ ክፈት\n2. "QR ኮድ እሴን" ይጫኑ\n3. የተገለጸውን QR ኮድ ይቃኙ\n4. ክፍያውን ያረጋግጡ\n5. የSMS ማረጋገጫ ይደርሶታል',
  'Instant mobile payment via Telebirr',
  'በቴሌብር በፍጥነት የሚከፈል ሞባይል ክፍያ',
  FALSE,
  0, -- Instant verification via webhook
  98.5,
  30,
  '00:00:00',
  '23:59:59',
  '1,2,3,4,5,6,7', -- Available all days
  NOW()
);

-- 2. CBE Bank Transfer (Manual Verification)
INSERT IGNORE INTEGERO payment_methods (
  name,
  name_amharic,
  code,
  type,
  is_active,
  is_default,
  sort_order,
  icon,
  color,
  environment,
  bank_name,
  account_number,
  account_name,
  bank_branch,
  has_fee,
  fee_type,
  fee_percentage,
  fee_fixed,
  who_pays_fee,
  instructions,
  instructions_amharic,
  short_description,
  short_description_amharic,
  requires_verification,
  verification_time_minutes,
  success_rate,
  avg_processing_seconds,
  available_from_time,
  available_to_time,
  available_days,
  activated_at
) VALUES (
  'CBE Bank Transfer',
  'ሲ.ቢ.ኢ ባንክ ማስተላለፍ',
  'cbe_transfer',
  'bank_transfer',
  TRUE,
  FALSE,
  2,
  '/assets/payment-icons/cbe.svg',
  '#0D5B93',
  'production',
  'Commercial Bank of Ethiopia',
  '1000123456789',
  'Ethio Tickets PLC',
  'Head Office, Addis Ababa',
  TRUE,
  'fixed',
  0.00,
  15.00, -- CBE transfer fee
  'customer',
  '1. Visit any CBE branch or use CBE mobile app\n2. Transfer exact amount to account above\n3. Use reference number: {reference}\n4. Upload receipt after payment\n5. Admin will verify within 1-2 hours',
  '1. ማንኛውም የሲ.ቢ.ኢ ቅርንጫፍ ይጎበኙ ወይም ሞባይል አፕ ይጠቀሙ\n2. በትክክል ወደ ከፍተኛው ሂሳብ ያስተላልፉ\n3. የማጣቀሻ ቁጥር ይጠቀሙ: {reference}\n4. ክፍያውን ካጠናቀቁ በኋላ የተቀበሉትን ያስገቡ\n5. አስተዳዳሪ በ1-2 ሰዓታት ውስጥ ያረጋግጣል',
  'Bank transfer to CBE account (manual verification)',
  'ወደ ሲ.ቢ.ኢ ሂሳብ ባንክ ማስተላልፍ (መረጋገጫ ያስፈልጋል)',
  TRUE,
  120, -- 2 hours for manual verification
  99.0,
  7200, -- 2 hours in seconds
  '08:30:00',
  '16:30:00',
  '2,3,4,5,6', -- Weekdays only (Mon-Fri)
  NOW()
);

-- 3. CBE Birr (Mobile Banking)
INSERT IGNORE INTEGERO payment_methods (
  name,
  name_amharic,
  code,
  type,
  is_active,
  is_default,
  sort_order,
  icon,
  color,
  environment,
  bank_name,
  qr_supported,
  has_fee,
  fee_type,
  fee_percentage,
  fee_fixed,
  who_pays_fee,
  instructions,
  instructions_amharic,
  short_description,
  short_description_amharic,
  requires_verification,
  verification_time_minutes,
  success_rate,
  avg_processing_seconds,
  activated_at
) VALUES (
  'CBE Birr',
  'ሲ.ቢ.ኢ ብር',
  'cbe_birr',
  'mobile_money',
  TRUE,
  FALSE,
  3,
  '/assets/payment-icons/cbe-birr.svg',
  '#0D5B93',
  'production',
  'Commercial Bank of Ethiopia',
  TRUE,
  TRUE,
  'percentage',
  0.50, -- 0.5% fee
  0.00,
  'customer',
  '1. Open CBE Birr app\n2. Select "Payments" → "Scan to Pay"\n3. Scan QR code\n4. Confirm transaction',
  '1. ሲ.ቢ.ኢ ብር አፕ ክፈት\n2. "ክፍያዎች" → "ለመክፈል እሴን" ይምረጡ\n3. QR ኮድ ይቃኙ\n4. ግብይቱን ያረጋግጡ',
  'Mobile payment via CBE Birr app',
  'በሲ.ቢ.ኢ ብር አፕ ሞባይል ክፍያ',
  FALSE,
  5,
  97.0,
  45,
  NOW()
);

-- 4. Cash Payment (Ethiopian Events)
INSERT IGNORE INTEGERO payment_methods (
  name,
  name_amharic,
  code,
  type,
  is_active,
  is_default,
  sort_order,
  icon,
  color,
  environment,
  min_amount,
  max_amount,
  has_fee,
  instructions,
  instructions_amharic,
  short_description,
  short_description_amharic,
  requires_verification,
  verification_time_minutes,
  success_rate,
  avg_processing_seconds,
  available_from_time,
  available_to_time,
  activated_at
) VALUES (
  'Cash at Venue',
  'በቦታ ጥሬ ገንዘብ',
  'cash_venue',
  'cash',
  TRUE,
  FALSE,
  4,
  '/assets/payment-icons/cash.svg',
  '#28A745',
  'production',
  10.00,
  5000.00,
  FALSE,
  '1. Select "Cash at Venue" option\n2. Receive reservation code\n3. Pay cash at event entrance\n4. Show reservation code to collect ticket',
  '1. "በቦታ ጥሬ ገንዘብ" አማራጭ ይምረጡ\n2. የቦታ ማስያዝ ኮድ ይቀበሉ\n3. በዝግጅቱ መግቢያ ጥሬ ገንዘብ ይክፈሉ\n4. ትኬት ለመግዛት የቦታ ማስያዝ ኮድ ያሳዩ',
  'Pay cash at the event venue',
  'በዝግጅቱ ቦታ ጥሬ ገንዘብ ይክፈሉ',
  TRUE,
  0, -- Immediate at venue
  100.0,
  60,
  '06:00:00',
  '22:00:00',
  NOW()
);

-- 5. Awash Bank (Alternative Ethiopian Bank)
INSERT IGNORE INTEGERO payment_methods (
  name,
  name_amharic,
  code,
  type,
  is_active,
  is_default,
  sort_order,
  icon,
  color,
  environment,
  bank_name,
  account_number,
  account_name,
  has_fee,
  fee_type,
  fee_percentage,
  fee_fixed,
  who_pays_fee,
  instructions,
  instructions_amharic,
  short_description,
  short_description_amharic,
  requires_verification,
  verification_time_minutes,
  success_rate,
  activated_at
) VALUES (
  'Awash Bank',
  'አዋሽ ባንክ',
  'awash_bank',
  'bank_transfer',
  TRUE,
  FALSE,
  5,
  '/assets/payment-icons/awash.svg',
  '#E60026',
  'production',
  'Awash Bank',
  '0134567890123',
  'Ethio Tickets PLC',
  TRUE,
  'fixed',
  0.00,
  10.00,
  'customer',
  'Transfer to Awash Bank account. Use reference: {reference}',
  'ወደ አዋሽ ባንክ ሂሳብ ያስተላልፉ። የማጣቀሻ ቁጥር: {reference}',
  'Bank transfer to Awash Bank',
  'ወደ አዋሽ ባንክ ባንክ ማስተላልፍ',
  TRUE,
  180,
  98.0,
  NOW()
);

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- VIEWS: For Ethiopian Payment Analytics
-- ============================================

-- View 1: Active payment methods summary (Ethiopian context)
CREATE OR REPLACE VIEW vw_active_payment_methods_ethiopia AS
SELECT 
  code,
  name,
  name_amharic,
  type,
  environment,
  success_rate,
  avg_processing_seconds,
  total_transactions,
  total_volume,
  CASE 
    WHEN requires_verification = TRUE THEN 'Manual Verification'
    ELSE 'Instant'
  END AS verification_type,
  available_from_time,
  available_to_time,
  available_days
FROM payment_methods
WHERE is_active = TRUE 
  AND available_for_country = 'ET'
  AND deleted_at IS NULL
ORDER BY is_default DESC, sort_order, success_rate DESC;

-- View 2: Payment method fees comparison (Ethiopian market)
CREATE OR REPLACE VIEW vw_payment_fees_ethiopia AS
SELECT 
  code,
  name,
  environment,
  has_fee,
  fee_type,
  fee_percentage,
  fee_fixed,
  fee_capped_at,
  who_pays_fee,
  CONCAT(
    CASE 
      WHEN fee_type = 'percentage' THEN CONCAT(fee_percentage, '%')
      WHEN fee_type = 'fixed' THEN CONCAT(fee_fixed, ' ETB')
      WHEN fee_type = 'both' THEN CONCAT(fee_percentage, '% + ', fee_fixed, ' ETB')
      ELSE 'No fee'
    END,
    CASE 
      WHEN fee_capped_at IS NOT NULL THEN CONCAT(' (capped at ', fee_capped_at, ' ETB)')
      ELSE ''
    END
  ) AS fee_description
FROM payment_methods
WHERE is_active = TRUE
  AND deleted_at IS NULL
ORDER BY fee_percentage DESC, fee_fixed DESC;

-- View 3: Payment method availability check (Ethiopian runtime)
CREATE OR REPLACE VIEW vw_payment_availability_check_ethiopia AS
SELECT 
  code,
  name,
  is_active,
  available_from_time AS opens_at,
  available_to_time AS closes_at,
  available_days,
  CASE 
    WHEN available_to_time < available_from_time THEN 
      'Overnight availability (crosses midnight)'
    ELSE 
      'Regular hours'
  END AS availability_type
FROM payment_methods
WHERE available_for_country = 'ET'
  AND deleted_at IS NULL
ORDER BY available_from_time;

-- ============================================
-- TRIGGERS: For Ethiopian Payment Business Rules (FIXED)
-- ============================================

DELIMITER $$

-- Trigger 1: Ensure only one default payment method per country (FIXED for INSERT)
CREATE TRIGGER trg_payment_methods_one_default_per_country_insert
BEFORE INSERT ON payment_methods
FOR EACH ROW
BEGIN
  IF NEW.is_default = TRUE AND NEW.available_for_country IS NOT NULL THEN
    -- Remove default from other methods in same country
    UPDATE payment_methods
    SET is_default = FALSE,
        updated_at = CURRENT_TEXT
    WHERE available_for_country = NEW.available_for_country
      AND deleted_at IS NULL
      AND is_default = TRUE
      AND is_active = TRUE;
  END IF;
END$$

-- Trigger 2: Ensure only one default payment method per country (UPDATE)
CREATE TRIGGER trg_payment_methods_one_default_per_country_update
BEFORE UPDATE ON payment_methods
FOR EACH ROW
BEGIN
  IF NEW.is_default = TRUE AND OLD.is_default = FALSE 
     AND NEW.available_for_country IS NOT NULL THEN
    -- Remove default from other methods in same country
    UPDATE payment_methods
    SET is_default = FALSE,
        updated_at = CURRENT_TEXT
    WHERE available_for_country = NEW.available_for_country
      AND id != NEW.id
      AND deleted_at IS NULL
      AND is_default = TRUE
      AND is_active = TRUE;
  END IF;
END$$

-- Trigger 3: Update activation/deactivation TEXTs (FIXED)
CREATE TRIGGER trg_payment_methods_status_change
BEFORE UPDATE ON payment_methods
FOR EACH ROW
BEGIN
  -- Record when activated
  IF NEW.is_active = TRUE AND OLD.is_active = FALSE THEN
    SET NEW.activated_at = CURRENT_TEXT;
    SET NEW.deactivated_at = NULL;
  END IF;
  
  -- Record when deactivated
  IF NEW.is_active = FALSE AND OLD.is_active = TRUE THEN
    SET NEW.deactivated_at = CURRENT_TEXT;
  END IF;
  
  -- Prevent deactivating default method without replacement
  IF NEW.is_active = FALSE AND OLD.is_default = TRUE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot deactivate default payment method. Set another method as default first.';
  END IF;
END$$

-- Trigger 4: Safe Ethiopian validation (FIXED - won't block migration)
CREATE TRIGGER trg_payment_methods_ethiopian_validation_safe
BEFORE INSERT ON payment_methods
FOR EACH ROW
BEGIN
  -- Ethiopian bank account validation (only when provided)
  IF NEW.type = 'bank_transfer' THEN
    IF NEW.bank_name IS NULL OR NEW.account_number IS NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Bank transfer methods require bank name and account number';
    END IF;
  END IF;
  
  -- Ensure Ethiopian instructions have fallbacks
  IF NEW.name_amharic IS NULL THEN
    SET NEW.name_amharic = NEW.name; -- Fallback to English
  END IF;
  
  IF NEW.instructions_amharic IS NULL AND NEW.instructions IS NOT NULL THEN
    SET NEW.instructions_amharic = NEW.instructions; -- Fallback to English
  END IF;
  
  -- Set Telebirr to sandbox if no environment specified
  IF NEW.code = 'telebirr' AND NEW.environment IS NULL THEN
    SET NEW.environment = 'sandbox';
  END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURES: For Ethiopian Payment Operations
-- ============================================

DELIMITER $$

-- Procedure 1: Get available payment methods for Ethiopian customer (FIXED for overnight)
CREATE PROCEDURE sp_get_available_payment_methods_et(
  IN p_amount REAL,
  IN p_customer_country CHAR(3),
  IN p_current_time TIME,
  IN p_current_day INTEGER
)
BEGIN
  SELECT 
    id,
    code,
    name,
    name_amharic,
    type,
    icon,
    color,
    environment,
    short_description,
    short_description_amharic,
    requires_verification,
    verification_time_minutes,
    success_rate,
    avg_processing_seconds,
    fee_type,
    fee_percentage,
    fee_fixed,
    who_pays_fee,
    qr_supported,
    -- Check availability logic (handles overnight correctly)
    CASE
      WHEN available_to_time >= available_from_time THEN
        -- Normal hours (e.g., 08:00-17:00)
        p_current_time BETWEEN available_from_time AND available_to_time
      ELSE
        -- Overnight hours (e.g., 18:00-02:00)
        p_current_time >= available_from_time OR p_current_time <= available_to_time
    END AS is_available_now
  FROM payment_methods
  WHERE is_active = TRUE
    AND deleted_at IS NULL
    AND available_for_country = p_customer_country
    AND p_amount BETWEEN min_amount AND max_amount
    AND FIND_IN_SET(p_current_day, available_days) > 0
  ORDER BY is_default DESC, sort_order, success_rate DESC;
END$$

-- Procedure 2: Calculate Ethiopian payment fees
CREATE PROCEDURE sp_calculate_payment_fees_et(
  IN p_payment_method_code VARCHAR(50),
  IN p_amount REAL,
  OUT p_total_fee REAL,
  OUT p_net_amount REAL,
  OUT p_gross_amount REAL
)
BEGIN
  DECLARE v_fee_percentage REAL;
  DECLARE v_fee_fixed REAL;
  DECLARE v_fee_capped_at REAL;
  DECLARE v_fee_type TEXT;
  DECLARE v_calculated_fee REAL;
  
  -- Get fee configuration
  SELECT 
    fee_type,
    fee_percentage,
    fee_fixed,
    fee_capped_at
  INTEGERO 
    v_fee_type,
    v_fee_percentage,
    v_fee_fixed,
    v_fee_capped_at
  FROM payment_methods
  WHERE code = p_payment_method_code
    AND is_active = TRUE
    AND deleted_at IS NULL;
  
  -- Calculate fee based on type
  SET v_calculated_fee = 0.00;
  
  CASE v_fee_type
    WHEN 'percentage' THEN
      SET v_calculated_fee = p_amount * (v_fee_percentage / 100);
    WHEN 'fixed' THEN
      SET v_calculated_fee = v_fee_fixed;
    WHEN 'both' THEN
      SET v_calculated_fee = (p_amount * (v_fee_percentage / 100)) + v_fee_fixed;
    ELSE
      SET v_calculated_fee = 0.00;
  END CASE;
  
  -- Apply cap if exists
  IF v_fee_capped_at IS NOT NULL AND v_calculated_fee > v_fee_capped_at THEN
    SET v_calculated_fee = v_fee_capped_at;
  END IF;
  
  -- Set output parameters
  SET p_total_fee = v_calculated_fee;
  SET p_net_amount = p_amount - v_calculated_fee;
  SET p_gross_amount = p_amount;
END$$

-- Procedure 3: Soft delete payment method (Ethiopian archival)
CREATE PROCEDURE sp_soft_delete_payment_method_et(
  IN p_payment_method_id INTEGEREGER,
  IN p_deleted_by_user_id INTEGEREGER
)
BEGIN
  DECLARE v_is_default INTEGER;
  
  START TRANSACTION;
  
  -- Check if it's default
  SELECT is_default INTEGERO v_is_default
  FROM payment_methods
  WHERE id = p_payment_method_id
    AND deleted_at IS NULL;
  
  -- Cannot soft delete default method
  IF v_is_default = TRUE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete default payment method. Set another method as default first.';
  END IF;
  
  -- Soft delete the payment method
  UPDATE payment_methods
  SET 
    is_active = FALSE,
    deactivated_at = CURRENT_TEXT,
    deleted_at = CURRENT_TEXT,
    updated_at = CURRENT_TEXT
  WHERE id = p_payment_method_id
    AND deleted_at IS NULL;
  
  COMMIT;
END$$

DELIMITER ;