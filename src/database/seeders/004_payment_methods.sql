-- ============================================
-- SEEDER: 004_payment_methods.sql
-- Purpose: Seed Ethiopian payment methods for ticketing platform
-- Dependencies: payment_methods table must exist
-- Ethiopian Context:
--   1. Telebirr mobile money (Primary)
--   2. CBE Bank Transfer (Manual verification)
--   3. Other Ethiopian bank options
--   4. Cash payment option for offline
-- ============================================

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Clear existing payment methods (idempotent)
DELETE FROM `payment_methods`;

-- ============================================
-- PRIMARY PAYMENT METHODS (Active & Featured)
-- ============================================

INSERT INTO `payment_methods` (
  `name`,
  `name_amharic`,
  `code`,
  `type`,
  `is_active`,
  `is_default`,
  `sort_order`,
  `min_amount`,
  `max_amount`,
  `bank_name`,
  `account_number`,
  `account_name`,
  `qr_supported`,
  `has_fee`,
  `fee_type`,
  `fee_percentage`,
  `fee_fixed`,
  `api_config`,
  `webhook_url`,
  `icon`,
  `instructions`,
  `instructions_amharic`,
  `created_at`,
  `updated_at`
) VALUES 
-- ============================================
-- 1. TELEBIRR (Mobile Money - PRIMARY)
-- ============================================
(
  'Telebirr',
  'ቴሌብር',
  'telebirr',
  'mobile_money',
  TRUE,              -- Active
  TRUE,              -- Default payment method
  1,                 -- Sort first
  1.00,              -- Min 1 ETB
  50000.00,          -- Max 50,000 ETB
  NULL,              -- Not a bank
  NULL,              -- Not a bank account
  NULL,              -- Not a bank account
  TRUE,              -- QR code supported
  FALSE,             -- No fee for customers
  'percentage',      -- Fee type (if applicable)
  0.00,              -- 0% fee
  0.00,              -- No fixed fee
  -- API Configuration (Development/Staging)
  JSON_OBJECT(
    'environment', 'sandbox',
    'app_id', 'YOUR_TELEBIRR_APP_ID',
    'app_key', 'YOUR_TELEBIRR_APP_KEY',
    'merchant_code', 'ETHIOTICKETS',
    'merchant_name', 'Ethio Tickets Platform',
    'public_key', 'YOUR_TELEBIRR_PUBLIC_KEY',
    'private_key', 'YOUR_TELEBIRR_PRIVATE_KEY',
    'callback_url', 'https://api.ethiotickets.com/webhook/telebirr',
    'timeout_seconds', 300,
    'version', '1.0'
  ),
  '/api/webhook/telebirr',
  'smartphone',      -- Icon name
  '1. Select Telebirr as payment method\n2. Scan the QR code with your Telebirr app\n3. Confirm payment in the app\n4. Payment will be verified automatically',
  '1. ቴሌብርን ክፍያ ዘዴ በመምረጥ\n2. QR ኮድን በቴሌብር መተግበሪያ በመቃኘት\n3. ክፍያውን በመተግበሪያው ውስጥ በማረጋገጥ\n4. ክፍያው በራስ ሰር ይረጋገጣል',
  NOW(),
  NOW()
),

-- ============================================
-- 2. CBE BANK TRANSFER (Manual Verification)
-- ============================================
(
  'CBE Bank Transfer',
  'ሲቢኢ ባንክ ሽያጭ',
  'cbe_transfer',
  'bank_transfer',
  TRUE,              -- Active
  FALSE,             -- Not default
  2,                 -- Sort second
  10.00,             -- Min 10 ETB
  100000.00,         -- Max 100,000 ETB
  'Commercial Bank of Ethiopia',
  '1000123456789',   -- Platform CBE account
  'ETHIO TICKETS PLC',
  FALSE,             -- No QR for bank transfer
  FALSE,             -- No fee
  'percentage',
  0.00,
  0.00,
  -- Manual verification configuration
  JSON_OBJECT(
    'verification_type', 'manual',
    'account_branch', 'Addis Ababa Main Branch',
    'reference_format', 'CBE-TKT-{DATE}-{ID}',
    'verification_time_hours', 24,
    'admin_notification', TRUE,
    'auto_approve_under', 1000.00,
    'require_receipt_upload', TRUE,
    'allowed_receipt_formats', JSON_ARRAY('image/jpeg', 'image/png', 'application/pdf')
  ),
  NULL,              -- No webhook for manual transfer
  'bank',            -- Icon name
  '1. Transfer exact amount to CBE account shown\n2. Use the reference number provided\n3. Upload payment receipt/screenshot\n4. Admin will verify within 24 hours\n5. Ticket will be issued after verification',
  '1. በትክክል ያለውን መጠን ወደ የሚታየው ሲቢኢ መለያ ያስተላልፉ\n2. የተሰጠውን ማጣቀሻ ቁጥር ይጠቀሙ\n3. የክፍያ ደረሰኝ/ስክሪንሾት ይጫኑ\n4. አስተዳዳሪ በ24 ሰዓታት ውስጥ ያረጋግጣል\n5. ክፍያ ከተረጋገጠ በኋላ ቲኬት ይሰጣል',
  NOW(),
  NOW()
),

-- ============================================
-- 3. CBE BIRR (Mobile Banking)
-- ============================================
(
  'CBE Birr',
  'ሲቢኢ ብር',
  'cbe_birr',
  'mobile_money',
  TRUE,              -- Active
  FALSE,             -- Not default
  3,                 -- Sort third
  1.00,              -- Min 1 ETB
  25000.00,          -- Max 25,000 ETB
  'Commercial Bank of Ethiopia',
  NULL,              -- Not applicable
  NULL,              -- Not applicable
  TRUE,              -- QR supported
  FALSE,             -- No fee
  'percentage',
  0.00,
  0.00,
  -- CBE Birr configuration
  JSON_OBJECT(
    'integration_type', 'api',
    'merchant_id', 'ETHIOTICKETS001',
    'api_version', '2.0',
    'callback_url', 'https://api.ethiotickets.com/webhook/cbe-birr',
    'timeout_seconds', 180
  ),
  '/api/webhook/cbe-birr',
  'credit-card',     -- Icon name
  '1. Select CBE Birr payment\n2. Enter your CBE Birr PIN\n3. Confirm transaction\n4. Payment verified instantly',
  '1. ሲቢኢ ብር ክፍያ ዘዴ ይምረጡ\n2. የሲቢኢ ብር PIN ያስገቡ\n3. ግብይቱን ያረጋግጡ\n4. ክፍያው ወዲያውኑ ይረጋገጣል',
  NOW(),
  NOW()
),

-- ============================================
-- 4. AWASH BANK ONLINE
-- ============================================
(
  'Awash Bank Online',
  'አዋሽ ባንክ ኦንላይን',
  'awash_online',
  'bank_transfer',
  TRUE,              -- Active
  FALSE,             -- Not default
  4,                 -- Sort fourth
  10.00,             -- Min 10 ETB
  50000.00,          -- Max 50,000 ETB
  'Awash Bank',
  '0134567890123',   -- Platform Awash account
  'ETHIO TICKETS PLC',
  FALSE,             -- No QR
  TRUE,              -- Has fee
  'fixed',           -- Fixed fee
  0.00,              -- 0% percentage
  2.00,              -- 2 ETB fixed fee
  JSON_OBJECT(
    'verification_type', 'manual',
    'account_branch', 'Addis Ababa Main',
    'reference_format', 'AWASH-TKT-{ID}',
    'fee_note', '2 ETB processing fee applies'
  ),
  NULL,
  'bank',            -- Icon name
  '1. Transfer to Awash Bank account\n2. Include reference number\n3. Upload receipt\n4. Admin verification required',
  '1. ወደ አዋሽ ባንክ መለያ ያስተላልፉ\n2. ማጣቀሻ ቁጥር ያካትቱ\n3. ደረሰኝ ይጫኑ\n4. የአስተዳዳሪ ማረጋገጫ ያስፈልጋል',
  NOW(),
  NOW()
),

-- ============================================
-- 5. DASHEN BANK ONLINE
-- ============================================
(
  'Dashen Bank Online',
  'ዳሸን ባንክ ኦንላይን',
  'dashen_online',
  'bank_transfer',
  TRUE,              -- Active
  FALSE,             -- Not default
  5,                 -- Sort fifth
  10.00,             -- Min 10 ETB
  50000.00,          -- Max 50,000 ETB
  'Dashen Bank',
  '0212345678901',   -- Platform Dashen account
  'ETHIO TICKETS PLC',
  FALSE,             -- No QR
  TRUE,              -- Has fee
  'fixed',
  0.00,
  2.50,              -- 2.5 ETB fixed fee
  JSON_OBJECT(
    'verification_type', 'manual',
    'account_branch', 'Addis Ababa Bole',
    'reference_format', 'DASHEN-TKT-{DATE}',
    'fee_note', '2.5 ETB processing fee'
  ),
  NULL,
  'bank',            -- Icon name
  '1. Transfer to Dashen Bank account\n2. Include reference number\n3. Upload receipt\n4. 2.5 ETB fee applies',
  '1. ወደ ዳሸን ባንክ መለያ ያስተላልፉ\n2. ማጣቀሻ ቁጥር ያካትቱ\n3. ደረሰኝ ይጫኑ\n4. 2.5 ብር ክፍያ ይከፈላል',
  NOW(),
  NOW()
),

-- ============================================
-- 6. CASH PAYMENT (Offline/Box Office)
-- ============================================
(
  'Cash Payment',
  'በጥሬ ገንዘብ ክፍያ',
  'cash',
  'cash',
  TRUE,              -- Active
  FALSE,             -- Not default
  6,                 -- Sort sixth
  10.00,             -- Min 10 ETB
  10000.00,          -- Max 10,000 ETB (cash limit)
  NULL,
  NULL,
  NULL,
  FALSE,             -- No QR
  FALSE,             -- No fee
  'percentage',
  0.00,
  0.00,
  JSON_OBJECT(
    'verification_type', 'immediate',
    'allowed_locations', JSON_ARRAY('box_office', 'organizer_office'),
    'receipt_required', TRUE,
    'max_cash_amount', 10000.00,
    'reporting_required', TRUE
  ),
  NULL,
  'dollar-sign',     -- Icon name
  '1. Visit event box office or organizer office\n2. Pay cash to authorized personnel\n3. Receive physical receipt\n4. Tickets issued immediately',
  '1. የዝግጅቱን ቦክስ ኦፊስ ወይም የአዘጋጅ ቢሮ ይጎበኙ\n2. ለተፈቀደላቸው ሠራተኞች በጥሬ ገንዘብ ይክፈሉ\n3. አካላዊ ደረሰኝ ይቀበሉ\n4. ቲኬቶች ወዲያውኑ ይሰጣሉ',
  NOW(),
  NOW()
),

-- ============================================
-- 7. ABYSSINIA BANK ONLINE
-- ============================================
(
  'Abyssinia Bank',
  'አቢሲንያ ባንክ',
  'abyssinia_bank',
  'bank_transfer',
  TRUE,              -- Active
  FALSE,             -- Not default
  7,                 -- Sort seventh
  10.00,             -- Min 10 ETB
  50000.00,          -- Max 50,000 ETB
  'Abyssinia Bank',
  '0312345678901',   -- Platform Abyssinia account
  'ETHIO TICKETS PLC',
  FALSE,             -- No QR
  TRUE,              -- Has fee
  'percentage',      -- Percentage fee
  1.50,              -- 1.5% fee
  0.00,              -- No fixed fee
  JSON_OBJECT(
    'verification_type', 'manual',
    'account_branch', 'Addis Ababa Kazanchis',
    'fee_note', '1.5% bank charge applies',
    'verification_time_hours', 12
  ),
  NULL,
  'bank',            -- Icon name
  '1. Transfer to Abyssinia Bank account\n2. 1.5% bank fee will be added\n3. Upload receipt\n4. Verification within 12 hours',
  '1. ወደ አቢሲንያ ባንክ መለያ ያስተላልፉ\n2. 1.5% የባንክ ክፍያ ይከፈላል\n3. ደረሰኝ ይጫኑ\n4. ማረጋገጫ በ12 ሰዓታት ውስጥ',
  NOW(),
  NOW()
),

-- ============================================
-- 8. NIB INTERNATIONAL BANK
-- ============================================
(
  'NIB International Bank',
  'ኤንአይቢ ኢንተርናሽናል ባንክ',
  'nib_bank',
  'bank_transfer',
  FALSE,             -- Inactive by default (can activate later)
  FALSE,             -- Not default
  8,                 -- Sort eighth
  10.00,             -- Min 10 ETB
  50000.00,          -- Max 50,000 ETB
  'NIB International Bank',
  '0412345678901',   -- Platform NIB account
  'ETHIO TICKETS PLC',
  FALSE,             -- No QR
  TRUE,              -- Has fee
  'percentage',
  1.00,              -- 1% fee
  0.00,
  JSON_OBJECT(
    'verification_type', 'manual',
    'account_branch', 'Addis Ababa Bole',
    'status', 'inactive',
    'activation_date', NULL
  ),
  NULL,
  'bank',            -- Icon name
  'Currently unavailable. Coming soon.',
  'በአሁኑ ጊዜ አይገኝም። በቅርብ ጊዜ ይገኛል።',
  NOW(),
  NOW()
);

COMMIT;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- SEEDER VERIFICATION & DETAILED SUMMARY
-- ============================================

SELECT 
  '✅ 004_payment_methods.sql - SEEDING COMPLETE' as message,
  'Ethiopian payment methods seeded successfully' as details,
  NOW() as seeded_at
UNION ALL
SELECT 
  '💰 PAYMENT METHODS SUMMARY' as message,
  CONCAT(
    'Total Methods: ', COUNT(*),
    ' | Active: ', SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END),
    ' | Mobile Money: ', SUM(CASE WHEN type = 'mobile_money' THEN 1 ELSE 0 END),
    ' | Bank Transfer: ', SUM(CASE WHEN type = 'bank_transfer' THEN 1 ELSE 0 END),
    ' | Cash: ', SUM(CASE WHEN type = 'cash' THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `payment_methods`
UNION ALL
SELECT 
  '📱 MOBILE MONEY OPTIONS' as message,
  CONCAT(
    GROUP_CONCAT(
      CONCAT(name, ' (', code, ')') 
      SEPARATOR ', '
    )
  ) as details,
  NULL as seeded_at
FROM `payment_methods` 
WHERE type = 'mobile_money' AND is_active = TRUE
UNION ALL
SELECT 
  '🏦 BANK TRANSFER OPTIONS' as message,
  CONCAT(
    GROUP_CONCAT(
      CONCAT(name, IF(has_fee = TRUE, ' (fee applies)', '')) 
      SEPARATOR ', '
    )
  ) as details,
  NULL as seeded_at
FROM `payment_methods` 
WHERE type = 'bank_transfer' AND is_active = TRUE
UNION ALL
SELECT 
  '🎯 DEFAULT PAYMENT METHOD' as message,
  CONCAT(
    name, ' (', code, ') - ', 
    CASE type 
      WHEN 'mobile_money' THEN 'Mobile Money'
      WHEN 'bank_transfer' THEN 'Bank Transfer'
      WHEN 'cash' THEN 'Cash'
      ELSE type 
    END
  ) as details,
  NULL as seeded_at
FROM `payment_methods` 
WHERE is_default = TRUE
UNION ALL
SELECT 
  '🔧 CONFIGURATION STATUS' as message,
  CONCAT(
    'QR Supported: ', SUM(CASE WHEN qr_supported = TRUE THEN 1 ELSE 0 END),
    ' | Fees Applied: ', SUM(CASE WHEN has_fee = TRUE THEN 1 ELSE 0 END),
    ' | Manual Verification: ', SUM(CASE WHEN type = 'bank_transfer' THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `payment_methods`
WHERE is_active = TRUE
UNION ALL
SELECT 
  '⚠️ IMPORTANT NOTES' as message,
  '1. Telebirr is default payment method\n2. CBE requires manual verification\n3. Update bank details before production\n4. Configure API keys in environment' as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
ORDER BY 
  CASE 
    WHEN message LIKE '✅%' THEN 1
    WHEN message LIKE '💰%' THEN 2
    WHEN message LIKE '📱%' THEN 3
    WHEN message LIKE '🏦%' THEN 4
    WHEN message LIKE '🎯%' THEN 5
    WHEN message LIKE '🔧%' THEN 6
    WHEN message LIKE '⚠️%' THEN 7
    ELSE 8
  END;