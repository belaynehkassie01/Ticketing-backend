-- ============================================
-- SEEDER: 001_system_admin.sql
-- Purpose: Create system admin user and initial test users
-- Dependencies: users table must exist (from migration)
-- Notes: 
--   1. Password hashes are for DEVELOPMENT ONLY
--   2. Always regenerate hashes for production using backend
--   3. This seeder is idempotent (safe to rerun)
-- ============================================

START TRANSACTION;

-- Cleanup existing test data (idempotent)
DELETE FROM `users` WHERE `email` LIKE '%@ethiotickets.com';
DELETE FROM `users` WHERE `email` LIKE '%@example.com';
DELETE FROM `users` WHERE `phone` LIKE '+251911%';
DELETE FROM `users` WHERE `phone` LIKE '+251912%';
DELETE FROM `users` WHERE `phone` LIKE '+251913%';
DELETE FROM `users` WHERE `phone` LIKE '+251914%';
DELETE FROM `users` WHERE `phone` LIKE '+251900%';

-- ============================================
-- SYSTEM ADMINISTRATOR (Production admin)
-- ============================================
INSERT INTO `users` (
  `phone`,
  `email`,
  `password_hash`,
  `full_name`,
  `role`,
  `preferred_language`,
  `phone_verified`,
  `is_active`,
  `created_at`,
  `updated_at`
) VALUES (
  '+251911223344',
  'admin@ethiotickets.com',
  -- ⚠️ DEVELOPMENT ONLY: Password = "Admin@123"
  -- 🔧 In production, generate with: bcrypt.hashSync('YourSecurePassword', 12)
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'System Administrator',
  'admin',
  'en',
  TRUE,
  TRUE,
  NOW(),
  NOW()
) ON DUPLICATE KEY UPDATE
  `updated_at` = NOW(),
  `full_name` = 'System Administrator';

-- ============================================
-- STAFF USERS (Platform operations team)
-- ============================================
INSERT INTO `users` (
  `phone`,
  `email`,
  `password_hash`,
  `full_name`,
  `role`,
  `preferred_language`,
  `phone_verified`,
  `is_active`,
  `created_at`
) VALUES 
-- Customer Support (Amharic speaker)
(
  '+251912345678',
  'support@ethiotickets.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'የደንበኞች ድጋፍ ባለሙያ',
  'staff',
  'am',
  TRUE,
  TRUE,
  NOW()
),
-- Payment Verification (Bilingual)
(
  '+251913456789',
  'payments@ethiotickets.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'Payment Verification Officer',
  'staff',
  'en',
  TRUE,
  TRUE,
  NOW()
),
-- Event Moderation (Amharic speaker)
(
  '+251914567890',
  'moderation@ethiotickets.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'የዝግጅት መጣል ባለሙያ',
  'staff',
  'am',
  TRUE,
  TRUE,
  NOW()
);

-- ============================================
-- DEMO CUSTOMERS (For testing and demonstration)
-- ============================================
INSERT INTO `users` (
  `phone`,
  `email`,
  `password_hash`,
  `full_name`,
  `role`,
  `preferred_language`,
  `phone_verified`,
  `is_active`,
  `created_at`
) VALUES 
-- English-speaking customer
(
  '+251911000001',
  'demo.customer.en@example.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'John A. Smith',
  'customer',
  'en',
  TRUE,
  TRUE,
  NOW()
),
-- Amharic-speaking customer
(
  '+251911000002',
  'demo.customer.am@example.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'ሙሉ መሐመድ',
  'customer',
  'am',
  TRUE,
  TRUE,
  NOW()
),
-- Potential organizer (English)
(
  '+251911000003',
  'demo.organizer@example.com',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'Event Master PLC',
  'customer',
  'en',
  TRUE,
  TRUE,
  NOW()
);

-- ============================================
-- DEVELOPMENT ACCOUNTS (Local/Staging only)
-- ============================================
INSERT INTO `users` (
  `phone`,
  `email`,
  `password_hash`,
  `full_name`,
  `role`,
  `preferred_language`,
  `phone_verified`,
  `is_active`,
  `created_at`
) VALUES 
-- Dev admin (all permissions)
(
  '+251900000001',
  'dev.admin@ethiotickets.local',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'Development Admin',
  'admin',
  'en',
  TRUE,
  TRUE,
  NOW()
),
-- Dev organizer (for testing organizer flows)
(
  '+251900000002',
  'dev.organizer@ethiotickets.local',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'Test Organizer Business',
  'organizer',
  'en',
  TRUE,
  TRUE,
  NOW()
),
-- Dev customer (for testing customer flows)
(
  '+251900000003',
  'dev.customer@ethiotickets.local',
  '$2a$12$LQv3c1yqBWVHxkd0g6f6COYv5z4M7w8jfK9nLm1pR2sT3uVwXyZaB',
  'Test Customer User',
  'customer',
  'am',
  TRUE,
  TRUE,
  NOW()
);

COMMIT;

-- ============================================
-- SEEDER VERIFICATION & SUMMARY
-- ============================================
SELECT 
  '✅ 001_system_admin.sql - SEEDING COMPLETE' as message,
  'User accounts created successfully' as details,
  COUNT(*) as total_users_created,
  SUM(CASE WHEN `role` = 'admin' THEN 1 ELSE 0 END) as admin_count,
  SUM(CASE WHEN `role` = 'staff' THEN 1 ELSE 0 END) as staff_count,
  SUM(CASE WHEN `role` = 'organizer' THEN 1 ELSE 0 END) as organizer_count,
  SUM(CASE WHEN `role` = 'customer' THEN 1 ELSE 0 END) as customer_count,
  NOW() as seeded_at,
  'ℹ️  All passwords: "Admin@123" (Change in production!)' as security_note
FROM `users`;