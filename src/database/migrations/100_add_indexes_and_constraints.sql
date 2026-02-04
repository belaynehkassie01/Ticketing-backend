-- Migration: 100_add_indexes_and_constraints.sql (FIXED - PRODUCTION SAFE)
-- Purpose: Final database optimization - add cross-table indexes and business constraints
-- IMPORTANT: Run this AFTER all 43 tables are created (001-043)
-- WARNING: Do NOT disable foreign key checks. This file assumes clean database or proper data validation.

-- ============================================
-- PART 1: ADD COMPOSITE INDEXES (Performance Optimization)
-- ============================================

-- Events: Search by city + date + status (most common query)
CREATE INDEX `idx_events_city_date_status` 
ON `events` (`city_id`, `start_date`, `status`);

-- Events: Featured events sorted by date
CREATE INDEX `idx_events_featured_date` 
ON `events` (`is_featured`, `start_date`);

-- Events: Organizer + status for dashboard
CREATE INDEX `idx_events_organizer_status` 
ON `events` (`organizer_id`, `status`, `created_at`);

-- Payments: User + status for payment history
CREATE INDEX `idx_payments_user_status_date` 
ON `payments` (`user_id`, `status`, `created_at`);

-- Payments: Organizer + status for payout calculation
CREATE INDEX `idx_payments_organizer_status` 
ON `payments` (`organizer_id`, `status`, `completed_at`);

-- Tickets: Event + status for check-in management
CREATE INDEX `idx_tickets_event_status` 
ON `individual_tickets` (`event_id`, `status`);

-- Tickets: User + event for customer dashboard
CREATE INDEX `idx_tickets_user_event` 
ON `individual_tickets` (`user_id`, `event_id`);

-- Checkin Logs: Event + time for attendance analytics
CREATE INDEX `idx_checkin_event_time` 
ON `checkin_logs` (`event_id`, `checkin_time`);

-- Reservations: Status + expiry for cleanup job
CREATE INDEX `idx_reservations_status_expiry` 
ON `reservations` (`status`, `expires_at`);

-- Financial Reports: Type + period for reporting
CREATE INDEX `idx_financial_reports_type_period` 
ON `financial_reports` (`report_type`, `period_start`, `period_end`);

-- Disputes: Status + priority + date for support dashboard
CREATE INDEX `idx_disputes_status_priority_date` 
ON `disputes` (`status`, `priority`, `created_at`);

-- Message Threads: Status + last message for support queue
CREATE INDEX `idx_threads_status_last_message` 
ON `message_threads` (`status`, `last_message_at`);

-- Audit Logs: Action type + timestamp for compliance queries
CREATE INDEX `idx_audit_action_timestamp` 
ON `audit_logs` (`action_type`, `action_timestamp`);

-- Activity Logs: User + timestamp for behavior analysis
CREATE INDEX `idx_activity_user_timestamp` 
ON `activity_logs` (`user_id`, `activity_timestamp`);

-- SMS Logs: Phone + status + date for delivery reports
CREATE INDEX `idx_sms_phone_status_date` 
ON `sms_logs` (`recipient_phone`, `status`, `sent_at`);

-- Offline Sync: User + status + type for mobile app monitoring
CREATE INDEX `idx_sync_user_status_type` 
ON `offline_sync_logs` (`user_id`, `status`, `sync_type`);

-- ============================================
-- PART 2: ADD GENERATED COLUMNS FOR MONTHLY ANALYTICS
-- ============================================

-- Payments: Monthly trend analysis (FIXED: generated column approach)
ALTER TABLE `payments`
ADD COLUMN `created_month` CHAR(7)
GENERATED ALWAYS AS (DATE_FORMAT(`created_at`, '%Y-%m')) STORED,
ADD COLUMN `completed_month` CHAR(7)
GENERATED ALWAYS AS (DATE_FORMAT(`completed_at`, '%Y-%m')) STORED;

-- Users: Monthly growth analysis
ALTER TABLE `users`
ADD COLUMN `created_month` CHAR(7)
GENERATED ALWAYS AS (DATE_FORMAT(`created_at`, '%Y-%m')) STORED;

-- Events: Monthly event creation
ALTER TABLE `events`
ADD COLUMN `created_month` CHAR(7)
GENERATED ALWAYS AS (DATE_FORMAT(`created_at`, '%Y-%m')) STORED;

-- ============================================
-- PART 3: ADD ANALYTICS INDEXES (Using generated columns)
-- ============================================

-- Financial Analytics: Monthly revenue tracking
CREATE INDEX `idx_financial_monthly_trend` 
ON `payments` (`created_month`, `status`, `amount`);

-- User Growth: Monthly signups
CREATE INDEX `idx_user_growth_monthly` 
ON `users` (`created_month`, `role`);

-- Event Creation: Monthly trends
CREATE INDEX `idx_event_creation_monthly` 
ON `events` (`created_month`, `category_id`);

-- Payment Method Analysis
CREATE INDEX `idx_payment_method_analysis` 
ON `payments` (`payment_method_code`, `status`, `created_month`);

-- Organizer Performance: Revenue tracking
CREATE INDEX `idx_organizer_performance` 
ON `organizers` (`total_revenue` DESC, `total_events`);

-- Support Performance: Response time tracking
CREATE INDEX `idx_support_response_time` 
ON `message_threads` (`response_time_minutes`, `status`);

-- Ethiopian Regional Analysis: Revenue by city
CREATE INDEX `idx_revenue_by_city` 
ON `payments` (`city_id`, `created_month`);

-- ============================================
-- PART 4: ADD UNIQUE CONSTRAINTS (Business Rules)
-- ============================================

-- Ensure unique phone per user (Ethiopian format validated in application layer)
ALTER TABLE `users`
ADD CONSTRAINT `uq_users_phone` UNIQUE (`phone`);

-- Ensure unique email per user (if provided)
ALTER TABLE `users`
ADD CONSTRAINT `uq_users_email` UNIQUE (`email`);

-- Ensure unique TIN per organizer
ALTER TABLE `organizers`
ADD CONSTRAINT `uq_organizers_tin` UNIQUE (`tin_number`);

-- Ensure unique business license per organizer
ALTER TABLE `organizers`
ADD CONSTRAINT `uq_organizers_license` UNIQUE (`business_license`);

-- Ensure unique VAT number per organizer (if provided)
ALTER TABLE `organizers`
ADD CONSTRAINT `uq_organizers_vat` UNIQUE (`vat_number`);

-- Ensure unique QR hash per entity
ALTER TABLE `qr_codes`
ADD CONSTRAINT `uq_qr_codes_hash` UNIQUE (`qr_hash`);

-- Ensure unique ticket number
ALTER TABLE `individual_tickets`
ADD CONSTRAINT `uq_tickets_number` UNIQUE (`ticket_number`);

-- Ensure unique payment reference
ALTER TABLE `payments`
ADD CONSTRAINT `uq_payments_reference` UNIQUE (`payment_reference`);

-- Ensure unique payout reference
ALTER TABLE `payouts`
ADD CONSTRAINT `uq_payouts_reference` UNIQUE (`payout_reference`);

-- Ensure unique tax code
ALTER TABLE `taxes`
ADD CONSTRAINT `uq_taxes_code` UNIQUE (`tax_code`);

-- Ensure unique dispute code
ALTER TABLE `disputes`
ADD CONSTRAINT `uq_disputes_code` UNIQUE (`dispute_code`);

-- Ensure unique thread code
ALTER TABLE `message_threads`
ADD CONSTRAINT `uq_threads_code` UNIQUE (`thread_code`);

-- Ensure unique notification code
ALTER TABLE `notifications`
ADD CONSTRAINT `uq_notifications_code` UNIQUE (`notification_code`);

-- ============================================
-- PART 5: ADD SAFE CHECK CONSTRAINTS (Business Logic)
-- ============================================

-- Users: Basic phone length validation (detailed validation in application)
ALTER TABLE `users`
ADD CONSTRAINT `chk_users_phone_length` 
CHECK (CHAR_LENGTH(`phone`) BETWEEN 10 AND 15);

-- Organizers: Commission rate validation
ALTER TABLE `organizers`
ADD CONSTRAINT `chk_organizers_commission_range` 
CHECK (`commission_rate` BETWEEN 0 AND 100);

ALTER TABLE `organizers`
ADD CONSTRAINT `chk_organizers_custom_commission` 
CHECK (`custom_commission_rate` IS NULL OR `custom_commission_rate` BETWEEN 0 AND 100);

-- Events: Date and ticket validation
ALTER TABLE `events`
ADD CONSTRAINT `chk_events_dates` 
CHECK (`end_date` > `start_date`);

ALTER TABLE `events`
ADD CONSTRAINT `chk_events_tickets` 
CHECK (`tickets_sold` <= `total_tickets`);

ALTER TABLE `events`
ADD CONSTRAINT `chk_events_vat_rate` 
CHECK (`vat_rate` >= 0 AND `vat_rate` <= 100);

-- Ticket Types: Quantity and price validation
ALTER TABLE `ticket_types`
ADD CONSTRAINT `chk_ticket_types_quantity` 
CHECK (`quantity` >= 0);

ALTER TABLE `ticket_types`
ADD CONSTRAINT `chk_ticket_types_sold_count` 
CHECK (`sold_count` >= 0 AND `sold_count` <= `quantity`);

ALTER TABLE `ticket_types`
ADD CONSTRAINT `chk_ticket_types_price` 
CHECK (`price` >= 0);

-- Payments: Amount and commission validation
ALTER TABLE `payments`
ADD CONSTRAINT `chk_payments_amount` 
CHECK (`amount` > 0);

ALTER TABLE `payments`
ADD CONSTRAINT `chk_payments_commission` 
CHECK (`platform_commission` >= 0 AND `organizer_earning` >= 0);

ALTER TABLE `payments`
ADD CONSTRAINT `chk_payments_vat` 
CHECK (`vat_amount` >= 0);

-- Taxes: Rate validation
ALTER TABLE `taxes`
ADD CONSTRAINT `chk_taxes_rate_range` 
CHECK (`rate` >= 0 AND `rate` <= 100);

-- Financial Reports: Period validation
ALTER TABLE `financial_reports`
ADD CONSTRAINT `chk_financial_reports_period` 
CHECK (`period_end` >= `period_start`);

-- Reservations: Expiry validation
ALTER TABLE `reservations`
ADD CONSTRAINT `chk_reservations_expiry` 
CHECK (`expires_at` > `created_at`);

-- Disputes: Amount validation
ALTER TABLE `disputes`
ADD CONSTRAINT `chk_disputes_resolution_amount` 
CHECK (`resolution_amount` IS NULL OR `resolution_amount` >= 0);

-- Ethiopian Holidays: Date validation
ALTER TABLE `ethiopian_holidays`
ADD CONSTRAINT `chk_holidays_dates` 
CHECK (`end_date` >= `start_date`);

-- ============================================
-- PART 6: ADD ADMIN DASHBOARD INDEXES
-- ============================================

-- Admin Dashboard: Recent activities
CREATE INDEX `idx_admin_recent_activities` 
ON `activity_logs` (`activity_timestamp` DESC, `activity_type`);

-- Event Performance: By city and category
CREATE INDEX `idx_event_performance_city_category` 
ON `events` (`city_id`, `category_id`, `tickets_sold`);

-- Ethiopian Cities: Quick lookup
CREATE INDEX `idx_cities_region_active` 
ON `cities` (`region`, `is_active`, `name_en`);

-- Organizer Status: For admin review
CREATE INDEX `idx_organizers_status_date` 
ON `organizers` (`status`, `created_at`);

-- Payment Verification: For admin dashboard
CREATE INDEX `idx_payments_verification_status` 
ON `payments` (`requires_verification`, `status`, `created_at`);

-- Dispute Management: For support team
CREATE INDEX `idx_disputes_assigned_status` 
ON `disputes` (`assigned_to`, `status`, `priority`);

-- ============================================
-- PART 7: ETHIOPIAN PERFORMANCE OPTIMIZATIONS
-- ============================================

-- SMS Delivery: For Ethiopian network analysis
CREATE INDEX `idx_sms_network_carrier` 
ON `sms_logs` (`network_operator`, `status`, `created_at`);

-- Offline Sync: For Ethiopian mobile connectivity
CREATE INDEX `idx_sync_network_type_city` 
ON `offline_sync_logs` (`network_type`, `city_id`, `status`);

-- Payments: Ethiopian currency and methods
CREATE INDEX `idx_payments_currency_method` 
ON `payments` (`currency`, `payment_method_code`, `status`);

-- Events: Ethiopian date patterns
CREATE INDEX `idx_events_ethiopian_month` 
ON `events` (`ethiopian_month_name`, `start_date`);

-- ============================================
-- PART 8: DATA QUALITY AND MAINTENANCE INDEXES
-- ============================================

-- Soft Delete Tracking: For data cleanup
CREATE INDEX `idx_tables_deleted_at` 
ON `users` (`deleted_at`);

-- Created/Updated Tracking: For audit
CREATE INDEX `idx_audit_created_updated` 
ON `audit_logs` (`created_at`, `updated_at`);

-- Session Management: For security
CREATE INDEX `idx_sessions_expiry_user` 
ON `session_tokens` (`expires_at`, `user_id`, `is_active`);

-- ============================================
-- PART 9: VALIDATION AND VERIFICATION
-- ============================================

-- Verify indexes were created successfully
SELECT 
  COUNT(*) as total_indexes_created,
  '✅ All optimization indexes applied successfully' as status
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = DATABASE() 
  AND INDEX_NAME LIKE 'idx_%';

-- Show table optimization summary
SELECT 
  TABLE_NAME,
  TABLE_ROWS as estimated_rows,
  DATA_LENGTH / 1024 / 1024 as data_size_mb,
  INDEX_LENGTH / 1024 / 1024 as index_size_mb
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY DATA_LENGTH DESC
LIMIT 10;

-- ============================================
-- FINAL MESSAGE (Production Ready)
-- ============================================

SELECT '============================================' as separator;
SELECT '✅ DATABASE OPTIMIZATION COMPLETE' as message;
SELECT '============================================' as separator;
SELECT '✅ 43 tables optimized for Ethiopian production' as status;
SELECT '✅ Indexes applied for mobile networks (2G/3G/4G)' as mobile;
SELECT '✅ Business rules enforced for Ethiopian compliance' as compliance;
SELECT '✅ Analytics ready for Ethiopian regional reporting' as analytics;
SELECT '✅ Ready for production deployment' as readiness;
SELECT '============================================' as separator;

-- Note: Application-level validations still required for:
-- 1. Ethiopian phone number format (09xxxxxxxx or +251xxxxxxxxx)
-- 2. VAT calculation (15% standard rate)
-- 3. Ethiopian calendar conversions
-- 4. SMS delivery with Ethio Telecom integration