-- Converted from MySQL to SQLite
-- Original file: 020_create_reservations_table.sql
-- Migration: 020_create_reservations_table.sql (IMPROVED VERSION)
-- Description: Store temporary ticket reservations before payment
-- Dependencies: Requires users, events, ticket_types tables
-- Ethiopian Context: Telebirr and CBE payment methods, ETB currency

-- ============================================
-- TABLE: reservations (IMPROVED)
-- Purpose: Store temporary ticket reservations before payment
-- Important: Reservation rules enforced in application logic
-- ============================================

CREATE TABLE IF NOT EXISTS reservations (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Reservation Identification
  reservation_code VARCHAR(32) UNIQUE NOT NULL COMMENT 'Format: RSV-ETH-YYYYMMDD-XXXXXX',
  user_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  ticket_type_id INTEGEREGER NOT NULL,
  
  -- Reservation Details
  quantity INTEGER NOT NULL,
  total_amount REAL NOT NULL COMMENT 'Total in ETB (supports group bookings)',
  currency VARCHAR(3) DEFAULT 'ETB',
  
  -- Status & Lifecycle
  status TEXT DEFAULT 'active',
  payment_method TEXT NULL,
  
  -- Timing & Expiry
  expires_at TEXT NOT NULL,
  completed_at TEXT NULL,
  cancelled_at TEXT NULL,
  expired_at TEXT NULL COMMENT 'When system marked as expired',
  
  -- User Session & Device Information
  session_id VARCHAR(100),
  device_id VARCHAR(255),
  device_type TEXT DEFAULT 'mobile',
  ip_address VARCHAR(45),
  user_agent TEXT,
  
  -- Ethiopian Payment Context
  telebirr_qr_data TEXT COMMENT 'Telebirr QR code data if payment method is Telebirr',
  cbe_reference_number VARCHAR(50) COMMENT 'CBE reference number for bank transfer',
  payment_instructions TEXT COMMENT 'Payment instructions in Amharic/English',
  
  -- Audit & Metadata
  cancellation_reason TEXT NULL,
  metadata JSON DEFAULT NULL COMMENT 'Reservation metadata',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (ticket_type_id) REFERENCES ticket_types(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_reservation_code (reservation_code), -- INDEX converted separately (user_id), -- INDEX converted separately (status, expires_at), -- INDEX converted separately (event_id), -- INDEX converted separately (ticket_type_id), -- INDEX converted separately (created_at), -- INDEX converted separately (deleted_at), -- INDEX converted separately (payment_method),
  
  -- Composite Indexes for Performance
  INDEX idx_user_event_status (user_id, event_id, status), -- INDEX converted separately (ticket_type_id, status, expires_at), -- INDEX converted separately (event_id, ticket_type_id, status), -- INDEX converted separately (status, expires_at, created_at), -- INDEX converted separately (user_id, created_at, status),
  
  -- Application-enforced constraINTEGERs (documented)
  CONSTRAINTEGER chk_quantity CHECK (quantity > 0 AND quantity <= 100),
  CONSTRAINTEGER chk_total_amount CHECK (total_amount > 0),
  CONSTRAINTEGER chk_expires_at CHECK (expires_at > created_at),
  CONSTRAINTEGER chk_status_dates CHECK (
    (status = 'completed' AND completed_at IS NOT NULL) OR
    (status = 'cancelled' AND cancelled_at IS NOT NULL) OR
    (status = 'expired' AND expired_at IS NOT NULL) OR
    (status IN ('active', 'payment_pending'))
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ticket reservations with Ethiopian payment support. Reservation rules enforced in application.';

-- ============================================
-- VIEWS FOR RESERVATION MANAGEMENT
-- ============================================

-- View for active reservations (for cleanup jobs)
CREATE OR REPLACE VIEW vw_active_reservations AS
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
    TEXTDIFF(MINUTE, NOW(), r.expires_at) as minutes_until_expiry,
    -- Reservation age
    TEXTDIFF(MINUTE, r.created_at, NOW()) as age_minutes,
    -- Payment status
    CASE 
        WHEN r.payment_method IS NOT NULL THEN 'PAYMENT_INITIATED'
        ELSE 'NO_PAYMENT'
    END as payment_status
FROM reservations r
JOIN users u ON r.user_id = u.id
JOIN events e ON r.event_id = e.id
JOIN ticket_types tt ON r.ticket_type_id = tt.id
WHERE r.status IN ('active', 'payment_pending')
  AND r.deleted_at IS NULL
  AND r.expires_at > NOW()
ORDER BY r.expires_at ASC;

-- View for reservation analytics
CREATE OR REPLACE VIEW vw_reservation_analytics AS
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
FROM reservations r
WHERE r.deleted_at IS NULL
  AND r.created_at >= DATE_SUB(NOW(), INTEGERERVAL 30 DAY)
GROUP BY DATE(r.created_at)
ORDER BY reservation_date DESC;

-- View for user reservation history
CREATE OR REPLACE VIEW vw_user_reservations AS
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
FROM reservations r
JOIN events e ON r.event_id = e.id
JOIN ticket_types tt ON r.ticket_type_id = tt.id
WHERE r.deleted_at IS NULL
ORDER BY r.created_at DESC;