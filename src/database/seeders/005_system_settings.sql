-- ============================================
-- SEEDER: 005_system_settings.sql
-- Purpose: Seed system-wide configuration settings
-- Dependencies: system_settings table must exist
-- Ethiopian Context:
--   1. Commission rates for Ethiopian market
--   2. VAT configuration (15% Ethiopian VAT)
--   3. Business information in Amharic/English
--   4. Ethiopian business regulations
-- ============================================

-- Temporarily disable foreign key checks
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Clear existing settings (idempotent)
DELETE FROM `system_settings`;

-- ============================================
-- 1. PLATFORM IDENTITY & CONTACT
-- ============================================

INSERT INTO `system_settings` (
  `category`,
  `setting_key`,
  `setting_value`,
  `setting_type`,
  `label`,
  `description`,
  `is_public`,
  `is_editable`,
  `applies_to_country`,
  `validation_rules`,
  `options`,
  `created_at`,
  `updated_at`
) VALUES 
-- Platform Name (Bilingual)
(
  'platform_identity',
  'platform_name',
  'Ethio Tickets',
  'string',
  'Platform Name (English)',
  'Official name of the ticketing platform in English',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min_length', 2, 'max_length', 100),
  NULL,
  NOW(),
  NOW()
),
(
  'platform_identity',
  'platform_name_amharic',
  'ኢትዮ ቲኬትስ',
  'string',
  'Platform Name (Amharic)',
  'የቲኬት ስርአቱ አማርኛ ስም',
  TRUE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- Platform Contact Information
(
  'platform_identity',
  'support_phone',
  '+251911223344',
  'string',
  'Support Phone Number',
  'Primary customer support phone number',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('pattern', '^\\+251[0-9]{9}$'),
  NULL,
  NOW(),
  NOW()
),
(
  'platform_identity',
  'support_email',
  'support@ethiotickets.com',
  'string',
  'Support Email',
  'Primary customer support email',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('type', 'email'),
  NULL,
  NOW(),
  NOW()
),
(
  'platform_identity',
  'business_hours',
  '{"monday": {"open": "08:00", "close": "18:00"}, "tuesday": {"open": "08:00", "close": "18:00"}, "wednesday": {"open": "08:00", "close": "18:00"}, "thursday": {"open": "08:00", "close": "18:00"}, "friday": {"open": "08:00", "close": "17:00"}, "saturday": {"open": "09:00", "close": "14:00"}, "sunday": {"open": "closed", "close": "closed"}}',
  'json',
  'Business Hours',
  'Platform support hours in Ethiopian time',
  TRUE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 2. FINANCIAL CONFIGURATION (ETHIOPIAN)
-- ============================================

-- Commission Rates
(
  'financial',
  'default_commission_rate',
  '10.00',
  'number',
  'Default Commission Rate (%)',
  'Default platform commission percentage on ticket sales',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 0, 'max', 30, 'step', 0.5),
  NULL,
  NOW(),
  NOW()
),
(
  'financial',
  'organizer_min_commission',
  '5.00',
  'number',
  'Minimum Commission Rate (%)',
  'Minimum commission rate that can be set for organizers',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 0, 'max', 20),
  NULL,
  NOW(),
  NOW()
),
(
  'financial',
  'organizer_max_commission',
  '15.00',
  'number',
  'Maximum Commission Rate (%)',
  'Maximum commission rate that can be set for organizers',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 5, 'max', 30),
  NULL,
  NOW(),
  NOW()
),

-- VAT Configuration (Ethiopian 15%)
(
  'financial',
  'vat_rate',
  '15.00',
  'number',
  'VAT Rate (%)',
  'Value Added Tax rate as per Ethiopian tax law',
  TRUE,
  FALSE,
  'ET',
  JSON_OBJECT('min', 0, 'max', 100),
  NULL,
  NOW(),
  NOW()
),
(
  'financial',
  'vat_included_by_default',
  'true',
  'boolean',
  'VAT Included by Default',
  'Whether ticket prices include VAT by default',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- Currency Configuration
(
  'financial',
  'default_currency',
  'ETB',
  'string',
  'Default Currency',
  'Default currency for all transactions',
  TRUE,
  FALSE,
  'ET',
  NULL,
  JSON_ARRAY('ETB'),
  NOW(),
  NOW()
),
(
  'financial',
  'currency_symbol',
  'Br',
  'string',
  'Currency Symbol',
  'Symbol used for Ethiopian Birr',
  TRUE,
  FALSE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 3. PAYMENT & PAYOUT SETTINGS
-- ============================================

-- Payment Settings
(
  'payment',
  'payment_timeout_minutes',
  '15',
  'number',
  'Payment Timeout (Minutes)',
  'Time before pending payments expire',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 5, 'max', 60),
  NULL,
  NOW(),
  NOW()
),
(
  'payment',
  'auto_cancel_unpaid_reservations',
  'true',
  'boolean',
  'Auto-cancel Unpaid Reservations',
  'Automatically cancel reservations when payment times out',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- Payout Settings
(
  'payment',
  'payout_minimum_amount',
  '500.00',
  'number',
  'Minimum Payout Amount (ETB)',
  'Minimum balance required to request a payout',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 100, 'max', 5000),
  NULL,
  NOW(),
  NOW()
),
(
  'payment',
  'payout_processing_days',
  '3',
  'number',
  'Payout Processing Time (Days)',
  'Number of business days to process payout requests',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 14),
  NULL,
  NOW(),
  NOW()
),
(
  'payment',
  'commission_hold_days',
  '7',
  'number',
  'Commission Hold Period (Days)',
  'Days to hold commission before making available for payout',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 0, 'max', 30),
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 4. TICKET & EVENT SETTINGS
-- ============================================

-- Ticket Settings
(
  'tickets',
  'max_tickets_per_user',
  '10',
  'number',
  'Maximum Tickets Per User',
  'Maximum number of tickets a user can purchase in one transaction',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 50),
  NULL,
  NOW(),
  NOW()
),
(
  'tickets',
  'ticket_transfer_enabled',
  'true',
  'boolean',
  'Ticket Transfer Enabled',
  'Allow users to transfer tickets to others',
  TRUE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'tickets',
  'ticket_refund_deadline_hours',
  '48',
  'number',
  'Refund Deadline (Hours)',
  'Hours before event start time when refunds are allowed',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 0, 'max', 168),
  NULL,
  NOW(),
  NOW()
),

-- Event Settings
(
  'events',
  'event_creation_requires_approval',
  'true',
  'boolean',
  'Event Creation Requires Approval',
  'New events require admin approval before being published',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'events',
  'event_cancellation_notice_hours',
  '24',
  'number',
  'Event Cancellation Notice (Hours)',
  'Minimum hours notice required for event cancellation',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 168),
  NULL,
  NOW(),
  NOW()
),
(
  'events',
  'max_events_per_organizer',
  '50',
  'number',
  'Maximum Events Per Organizer',
  'Maximum number of active events an organizer can have',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 200),
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 5. ETHIOPIAN-SPECIFIC SETTINGS
-- ============================================

-- Localization
(
  'localization',
  'default_language',
  'am',
  'string',
  'Default Language',
  'Default language for the platform',
  TRUE,
  TRUE,
  'ET',
  NULL,
  JSON_ARRAY('am', 'en'),
  NOW(),
  NOW()
),
(
  'localization',
  'timezone',
  'Africa/Addis_Ababa',
  'string',
  'Default Timezone',
  'Default timezone for the platform',
  TRUE,
  FALSE,
  'ET',
  NULL,
  JSON_ARRAY('Africa/Addis_Ababa'),
  NOW(),
  NOW()
),
(
  'localization',
  'date_format',
  'dd/MM/yyyy',
  'string',
  'Date Format',
  'Default date display format',
  TRUE,
  TRUE,
  'ET',
  NULL,
  JSON_ARRAY('dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd', 'dd MMM yyyy'),
  NOW(),
  NOW()
),

-- Ethiopian Business Regulations
(
  'compliance',
  'business_license_required',
  'true',
  'boolean',
  'Business License Required',
  'Organizers must provide business license for verification',
  TRUE,
  FALSE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'compliance',
  'tin_required',
  'true',
  'boolean',
  'TIN Required',
  'Organizers must provide Tax Identification Number',
  FALSE,
  FALSE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'compliance',
  'vat_registration_required',
  'false',
  'boolean',
  'VAT Registration Required',
  'Whether organizers must be VAT registered',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 6. NOTIFICATION & COMMUNICATION
-- ============================================

-- SMS Settings
(
  'notifications',
  'sms_enabled',
  'true',
  'boolean',
  'SMS Notifications Enabled',
  'Enable SMS notifications for users',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'notifications',
  'sms_provider',
  'ethio_telecom',
  'string',
  'SMS Provider',
  'Primary SMS service provider',
  FALSE,
  TRUE,
  'ET',
  NULL,
  JSON_ARRAY('ethio_telecom', 'other'),
  NOW(),
  NOW()
),

-- Email Settings
(
  'notifications',
  'email_enabled',
  'true',
  'boolean',
  'Email Notifications Enabled',
  'Enable email notifications for users',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'notifications',
  'send_event_reminder_hours',
  '24,2',
  'string',
  'Event Reminder Hours',
  'Hours before event to send reminders (comma separated)',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 7. SECURITY & AUTHENTICATION
-- ============================================

-- Authentication
(
  'security',
  'max_login_attempts',
  '5',
  'number',
  'Maximum Login Attempts',
  'Maximum failed login attempts before lockout',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 3, 'max', 10),
  NULL,
  NOW(),
  NOW()
),
(
  'security',
  'account_lockout_minutes',
  '30',
  'number',
  'Account Lockout Duration (Minutes)',
  'Minutes to lock account after max failed attempts',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 5, 'max', 1440),
  NULL,
  NOW(),
  NOW()
),
(
  'security',
  'session_timeout_minutes',
  '120',
  'number',
  'Session Timeout (Minutes)',
  'Minutes of inactivity before automatic logout',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 15, 'max', 1440),
  NULL,
  NOW(),
  NOW()
),

-- OTP Settings
(
  'security',
  'otp_length',
  '6',
  'number',
  'OTP Length',
  'Number of digits in OTP codes',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 4, 'max', 8),
  NULL,
  NOW(),
  NOW()
),
(
  'security',
  'otp_expiry_minutes',
  '10',
  'number',
  'OTP Expiry (Minutes)',
  'Minutes before OTP code expires',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 5, 'max', 30),
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 8. FILE UPLOAD & MEDIA
-- ============================================

(
  'media',
  'max_image_size_mb',
  '5',
  'number',
  'Maximum Image Size (MB)',
  'Maximum allowed image file size',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 20),
  NULL,
  NOW(),
  NOW()
),
(
  'media',
  'max_document_size_mb',
  '10',
  'number',
  'Maximum Document Size (MB)',
  'Maximum allowed document file size',
  TRUE,
  TRUE,
  'ET',
  JSON_OBJECT('min', 1, 'max', 50),
  NULL,
  NOW(),
  NOW()
),
(
  'media',
  'allowed_image_types',
  'image/jpeg,image/png,image/webp',
  'string',
  'Allowed Image Types',
  'Comma separated list of allowed image MIME types',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 9. MERCHANT BANK ACCOUNTS (ETHIOPIAN BANKS)
-- ============================================

-- CBE Account (Primary)
(
  'merchant_accounts',
  'cbe_account_number',
  '1000123456789',
  'string',
  'CBE Account Number',
  'Commercial Bank of Ethiopia merchant account',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('pattern', '^[0-9]{10,15}$'),
  NULL,
  NOW(),
  NOW()
),
(
  'merchant_accounts',
  'cbe_account_name',
  'ETHIO TICKETS PLC',
  'string',
  'CBE Account Name',
  'Account holder name for CBE',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'merchant_accounts',
  'cbe_bank_branch',
  'Addis Ababa Main Branch',
  'string',
  'CBE Bank Branch',
  'Branch name for CBE account',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),

-- Awash Bank Account
(
  'merchant_accounts',
  'awash_account_number',
  '0134567890123',
  'string',
  'Awash Bank Account',
  'Awash Bank merchant account',
  FALSE,
  TRUE,
  'ET',
  JSON_OBJECT('pattern', '^[0-9]{10,15}$'),
  NULL,
  NOW(),
  NOW()
),

-- ============================================
-- 10. SYSTEM OPERATIONAL SETTINGS
-- ============================================

(
  'system',
  'maintenance_mode',
  'false',
  'boolean',
  'Maintenance Mode',
  'Put the system in maintenance mode',
  TRUE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'system',
  'cron_job_enabled',
  'true',
  'boolean',
  'Cron Jobs Enabled',
  'Enable scheduled background jobs',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'system',
  'enable_analytics',
  'true',
  'boolean',
  'Analytics Enabled',
  'Enable collection of usage analytics',
  FALSE,
  TRUE,
  'ET',
  NULL,
  NULL,
  NOW(),
  NOW()
),
(
  'system',
  'log_level',
  'info',
  'string',
  'Log Level',
  'System logging level',
  FALSE,
  TRUE,
  'ET',
  NULL,
  JSON_ARRAY('error', 'warn', 'info', 'debug'),
  NOW(),
  NOW()
);

COMMIT;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- SEEDER VERIFICATION & SUMMARY
-- ============================================

SELECT 
  '✅ 005_system_settings.sql - SEEDING COMPLETE' as message,
  'System configuration settings seeded successfully' as details,
  NOW() as seeded_at
UNION ALL
SELECT 
  '📊 SETTINGS SUMMARY' as message,
  CONCAT(
    'Total Settings: ', COUNT(*),
    ' | Public: ', SUM(CASE WHEN is_public = TRUE THEN 1 ELSE 0 END),
    ' | Editable: ', SUM(CASE WHEN is_editable = TRUE THEN 1 ELSE 0 END)
  ) as details,
  NULL as seeded_at
FROM `system_settings`
UNION ALL
SELECT 
  '📁 CATEGORY BREAKDOWN' as message,
  CONCAT(
    GROUP_CONCAT(
      CONCAT(category, ': ', COUNT(*))
      ORDER BY COUNT(*) DESC
      SEPARATOR ' | '
    )
  ) as details,
  NULL as seeded_at
FROM `system_settings`
GROUP BY category
ORDER BY COUNT(*) DESC
UNION ALL
SELECT 
  '💰 FINANCIAL CONFIGURATION' as message,
  CONCAT(
    'Commission: ', 
    (SELECT setting_value FROM system_settings WHERE setting_key = 'default_commission_rate'), 
    '% | VAT: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'vat_rate'),
    '% | Currency: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'default_currency')
  ) as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
UNION ALL
SELECT 
  '🌍 ETHIOPIAN CONTEXT' as message,
  CONCAT(
    'Default Language: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'default_language'),
    ' | Timezone: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'timezone'),
    ' | VAT Included: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'vat_included_by_default')
  ) as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
UNION ALL
SELECT 
  '🔐 SECURITY SETTINGS' as message,
  CONCAT(
    'Max Login Attempts: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'max_login_attempts'),
    ' | OTP Expiry: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'otp_expiry_minutes'),
    ' min | Session Timeout: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'session_timeout_minutes'),
    ' min'
  ) as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
UNION ALL
SELECT 
  '📞 CONTACT INFORMATION' as message,
  CONCAT(
    'Support Phone: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'support_phone'),
    ' | Support Email: ',
    (SELECT setting_value FROM system_settings WHERE setting_key = 'support_email')
  ) as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
UNION ALL
SELECT 
  '⚠️ PRODUCTION NOTES' as message,
  '1. Update merchant bank account details\n2. Configure SMS/email providers\n3. Set actual business contact info\n4. Review all commission rates' as details,
  NULL as seeded_at
FROM (SELECT 1 as dummy) as t
ORDER BY 
  CASE 
    WHEN message LIKE '✅%' THEN 1
    WHEN message LIKE '📊%' THEN 2
    WHEN message LIKE '📁%' THEN 3
    WHEN message LIKE '💰%' THEN 4
    WHEN message LIKE '🌍%' THEN 5
    WHEN message LIKE '🔐%' THEN 6
    WHEN message LIKE '📞%' THEN 7
    WHEN message LIKE '⚠️%' THEN 8
    ELSE 9
  END;
  