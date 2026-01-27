-- Migration: 020_create_reservations_table.sql (IMPROVED VERSION)
-- Description: Store temporary ticket reservations before payment
-- Dependencies: Requires users, events, ticket_types tables
-- Ethiopian Context: Telebirr and CBE payment methods, ETB currency

-- ============================================
-- TABLE: reservations (IMPROVED)
-- Purpose: Store temporary ticket reservations before payment
-- Important: Reservation rules enforced in application logic
-- ============================================

CREATE TABLE IF NOT EXISTS `reservations` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Reservation Identification
  `reservation_code` VARCHAR(32) UNIQUE NOT NULL COMMENT 'Format: RSV-ETH-YYYYMMDD-XXXXXX',
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_type_id` BIGINT UNSIGNED NOT NULL,
  
  -- Reservation Details
  `quantity` INT NOT NULL,
  `total_amount` DECIMAL(15,2) NOT NULL COMMENT 'Total in ETB (supports group bookings)',
  `currency` VARCHAR(3) DEFAULT 'ETB',
  
  -- Status & Lifecycle
  `status` ENUM('active', 'completed', 'expired', 'cancelled', 'payment_pending') DEFAULT 'active',
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash', 'other') NULL,
  
  -- Timing & Expiry
  `expires_at` DATETIME NOT NULL,
  `completed_at` DATETIME NULL,
  `cancelled_at` DATETIME NULL,
  `expired_at` DATETIME NULL COMMENT 'When system marked as expired',
  
  -- User Session & Device Information
  `session_id` VARCHAR(100),
  `device_id` VARCHAR(255),
  `device_type` ENUM('mobile', 'tablet', 'desktop', 'unknown') DEFAULT 'mobile',
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  
  -- Ethiopian Payment Context
  `telebirr_qr_data` TEXT COMMENT 'Telebirr QR code data if payment method is Telebirr',
  `cbe_reference_number` VARCHAR(50) COMMENT 'CBE reference number for bank transfer',
  `payment_instructions` TEXT COMMENT 'Payment instructions in Amharic/English',
  
  -- Audit & Metadata
  `cancellation_reason` ENUM('user_cancelled', 'timeout', 'payment_failed', 'admin_cancelled', 'other') NULL,
  `metadata` JSON DEFAULT NULL COMMENT 'Reservation metadata',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_reservation_code` (`reservation_code`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status_expires` (`status`, `expires_at`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_payment_method` (`payment_method`),
  
  -- Composite Indexes for Performance
  INDEX `idx_user_event_status` (`user_id`, `event_id`, `status`),
  INDEX `idx_ticket_active` (`ticket_type_id`, `status`, `expires_at`),
  INDEX `idx_event_ticket_status` (`event_id`, `ticket_type_id`, `status`),
  INDEX `idx_expiry_cleanup` (`status`, `expires_at`, `created_at`),
  INDEX `idx_user_reservations` (`user_id`, `created_at`, `status`),
  
  -- Application-enforced constraints (documented)
  CONSTRAINT `chk_quantity` CHECK (`quantity` > 0 AND `quantity` <= 100),
  CONSTRAINT `chk_total_amount` CHECK (`total_amount` > 0),
  CONSTRAINT `chk_expires_at` CHECK (`expires_at` > `created_at`),
  CONSTRAINT `chk_status_dates` CHECK (
    (`status` = 'completed' AND `completed_at` IS NOT NULL) OR
    (`status` = 'cancelled' AND `cancelled_at` IS NOT NULL) OR
    (`status` = 'expired' AND `expired_at` IS NOT NULL) OR
    (`status` IN ('active', 'payment_pending'))
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ticket reservations with Ethiopian payment support. Reservation rules enforced in application.';

-- ============================================
-- VIEWS FOR RESERVATION MANAGEMENT
-- ============================================

-- View for active reservations (for cleanup jobs)
CREATE OR REPLACE VIEW `vw_active_reservations` AS
SELECT 
    r.id,
    r.reservation_code,
    r.user_id,
    u.full_name as user_name,
    u.phone as user_phone,
    r.event_id,
    e.title as event_title,
    r.ticket_type_id,
    tt.name as ticket_type_name,
    r.quantity,
    r.total_amount,
    r.status,
    r.expires_at,
    r.created_at,
    -- Time until expiry
    TIMESTAMPDIFF(MINUTE, NOW(), r.expires_at) as minutes_until_expiry,
    -- Reservation age
    TIMESTAMPDIFF(MINUTE, r.created_at, NOW()) as age_minutes,
    -- Payment status
    CASE 
        WHEN r.payment_method IS NOT NULL THEN 'PAYMENT_INITIATED'
        ELSE 'NO_PAYMENT'
    END as payment_status
FROM `reservations` r
JOIN `users` u ON r.user_id = u.id
JOIN `events` e ON r.event_id = e.id
JOIN `ticket_types` tt ON r.ticket_type_id = tt.id
WHERE r.status IN ('active', 'payment_pending')
  AND r.deleted_at IS NULL
  AND r.expires_at > NOW()
ORDER BY r.expires_at ASC;

-- View for reservation analytics
CREATE OR REPLACE VIEW `vw_reservation_analytics` AS
SELECT 
    DATE(r.created_at) as reservation_date,
    COUNT(*) as total_reservations,
    SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) as completed_count,
    SUM(CASE WHEN r.status = 'expired' THEN 1 ELSE 0 END) as expired_count,
    SUM(CASE WHEN r.status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count,
    SUM(r.quantity) as total_tickets_reserved,
    SUM(r.total_amount) as total_value_etb,
    -- Conversion rates
    ROUND(
        (SUM(CASE WHEN r.status = 'completed' THEN 1 ELSE 0 END) / COUNT(*)) * 100,
        2
    ) as conversion_rate_percent,
    -- Average reservation value
    ROUND(AVG(r.total_amount), 2) as avg_reservation_value,
    -- Popular payment methods
    MAX(CASE WHEN r.payment_method = 'telebirr' THEN 'Telebirr' END) as top_payment_method
FROM `reservations` r
WHERE r.deleted_at IS NULL
  AND r.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY DATE(r.created_at)
ORDER BY reservation_date DESC;

-- View for user reservation history
CREATE OR REPLACE VIEW `vw_user_reservations` AS
SELECT 
    r.id,
    r.reservation_code,
    r.user_id,
    r.event_id,
    e.title as event_title,
    e.start_date as event_date,
    r.ticket_type_id,
    tt.name as ticket_type_name,
    r.quantity,
    r.total_amount,
    r.status,
    r.payment_method,
    r.created_at,
    r.completed_at,
    r.cancelled_at,
    r.expired_at,
    -- Status description
    CASE r.status
        WHEN 'active' THEN 'Reservation Active'
        WHEN 'completed' THEN 'Completed Purchase'
        WHEN 'expired' THEN 'Expired'
        WHEN 'cancelled' THEN 'Cancelled'
        WHEN 'payment_pending' THEN 'Awaiting Payment'
        ELSE r.status
    END as status_description,
    -- Event status
    CASE 
        WHEN e.start_date < NOW() THEN 'EVENT_PASSED'
        WHEN e.cancelled_at IS NOT NULL THEN 'EVENT_CANCELLED'
        ELSE 'EVENT_UPCOMING'
    END as event_status
FROM `reservations` r
JOIN `events` e ON r.event_id = e.id
JOIN `ticket_types` tt ON r.ticket_type_id = tt.id
WHERE r.deleted_at IS NULL
ORDER BY r.created_at DESC;