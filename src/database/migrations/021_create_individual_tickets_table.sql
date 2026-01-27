-- Migration: 021_create_individual_tickets_table.sql
-- Description: Store individual ticket instances with Ethiopian context
-- Production-ready with enterprise best practices
-- Dependencies: Requires ticket_types, users, events, organizers tables

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: individual_tickets
-- Purpose: Store individual ticket instances
-- Ethiopian Context: QR codes for check-in, ETB pricing, VAT calculations
-- Production Features: Hash-based QR validation, financial precision, audit trail
-- ============================================

CREATE TABLE IF NOT EXISTS `individual_tickets` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal ticket ID',
  
  -- Ticket Identification
  `ticket_number` VARCHAR(50) UNIQUE NOT NULL COMMENT 'Unique ticket number for customer reference (e.g., TKT-ET-2024-001)',
  
  -- Relationships
  `ticket_type_id` BIGINT UNSIGNED NOT NULL COMMENT 'References ticket_types.id',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'References users.id (buyer)',
  `event_id` BIGINT UNSIGNED NOT NULL COMMENT 'References events.id',
  `organizer_id` BIGINT UNSIGNED NOT NULL COMMENT 'References organizers.id',
  
  -- Financial Information (ETB)
  `currency` CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Currency code (ETB for Ethiopia)',
  `purchase_price` DECIMAL(15,2) NOT NULL COMMENT 'Price paid in ETB (supports large events)',
  `vat_amount` DECIMAL(15,2) NOT NULL COMMENT '15% VAT included',
  `platform_commission` DECIMAL(15,2) NOT NULL COMMENT 'Platform commission amount',
  `organizer_earning` DECIMAL(15,2) NOT NULL COMMENT 'Organizer earning after commission',
  
  -- QR Code for Ethiopian Mobile Check-in
  `qr_data` TEXT NOT NULL COMMENT 'Encrypted QR data for check-in',
  `qr_hash` CHAR(64) NOT NULL COMMENT 'SHA-256 hash of qr_data for uniqueness validation',
  `qr_image_url` VARCHAR(500) COMMENT 'Optional QR image URL for download',
  `qr_secret_key` VARCHAR(100) COMMENT 'Secret for QR validation (rotated periodically)',
  
  -- Ticket Status
  `status` ENUM('reserved', 'paid', 'checked_in', 'cancelled', 'refunded', 'transferred') DEFAULT 'reserved',
  
  -- Check-in Information (Ethiopian Context)
  `checked_in_at` DATETIME NULL,
  `checked_in_by` BIGINT UNSIGNED NULL COMMENT 'References users.id (check-in staff)',
  `checkin_device_id` VARCHAR(100) COMMENT 'Device ID used for check-in',
  `checkin_location` VARCHAR(255) COMMENT 'Location description (e.g., "Main Gate, Addis Ababa")',
  `checkin_method` ENUM('qr_scan', 'manual', 'offline_sync') NULL,
  
  -- Transfer Information
  `transferred_at` DATETIME NULL,
  `transferred_to_user` BIGINT UNSIGNED NULL COMMENT 'References users.id (new ticket owner)',
  `transfer_token` VARCHAR(100) COMMENT 'One-time token for secure transfer',
  
  -- Cancellation & Refunds
  `cancelled_at` DATETIME NULL,
  `cancelled_by` BIGINT UNSIGNED NULL COMMENT 'References users.id (who cancelled)',
  `cancellation_reason` ENUM('user_request', 'event_cancelled', 'duplicate', 'fraud', 'other') NULL,
  `refund_amount` DECIMAL(15,2) NULL COMMENT 'Amount refunded in ETB',
  `refunded_at` DATETIME NULL,
  `refund_transaction_id` VARCHAR(100) COMMENT 'External refund transaction ID',
  
  -- Payment Information (Ethiopian Methods)
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash', 'other') NULL,
  `payment_reference` VARCHAR(100) COMMENT 'Payment gateway reference',
  
  -- Device & Session Info (for audit)
  `device_id` VARCHAR(255) COMMENT 'Customer device ID',
  `ip_address` VARCHAR(45) COMMENT 'Customer IP address',
  `user_agent` TEXT COMMENT 'Customer browser/device info',
  
  -- Timestamps with Ethiopian timezone consideration
  `reserved_at` DATETIME NULL COMMENT 'When ticket was reserved',
  `expires_at` DATETIME NULL COMMENT 'When reservation expires',
  `purchased_at` DATETIME NULL COMMENT 'When payment was completed',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Generated columns for business logic
  `is_expired` BOOLEAN GENERATED ALWAYS AS (
    `status` = 'reserved' AND `expires_at` IS NOT NULL AND `expires_at` < NOW()
  ) STORED COMMENT 'Auto-calculated expiration status',
  
  `days_until_event` INT GENERATED ALWAYS AS (
    DATEDIFF(
      (SELECT start_date FROM events WHERE id = `event_id`),
      NOW()
    )
  ) STORED COMMENT 'Days until event (for reminders)',
  
  -- Foreign Keys with Ethiopian naming convention
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`cancelled_by`) REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`transferred_to_user`) REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  -- Indexes for Ethiopian-scale performance
  INDEX `idx_ticket_number` (`ticket_number`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_purchased_at` (`purchased_at`),
  INDEX `idx_checked_in_at` (`checked_in_at`),
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  
  -- Composite indexes for common Ethiopian queries
  INDEX `idx_status_event` (`status`, `event_id`),
  INDEX `idx_user_event` (`user_id`, `event_id`),
  INDEX `idx_event_status` (`event_id`, `status`),
  INDEX `idx_organizer_event` (`organizer_id`, `event_id`),
  INDEX `idx_reservation_expiry` (`status`, `expires_at`) WHERE `status` = 'reserved',
  INDEX `idx_payment_status` (`payment_method`, `status`),
  
  -- Unique constraints
  UNIQUE INDEX `uq_qr_hash` (`qr_hash`),
  UNIQUE INDEX `uq_ticket_number` (`ticket_number`),
  
  -- Ethiopian Business Logic Constraints
  CONSTRAINT `chk_purchase_price` CHECK (`purchase_price` >= 0),
  CONSTRAINT `chk_vat_amount` CHECK (`vat_amount` >= 0),
  CONSTRAINT `chk_platform_commission` CHECK (`platform_commission` >= 0),
  CONSTRAINT `chk_organizer_earning` CHECK (`organizer_earning` >= 0),
  CONSTRAINT `chk_refund_amount` CHECK (`refund_amount` IS NULL OR `refund_amount` >= 0),
  CONSTRAINT `chk_currency_etb` CHECK (`currency` = 'ETB'), -- Ethiopian-only for now
  CONSTRAINT `chk_status_dates` CHECK (
    (`status` != 'checked_in' OR `checked_in_at` IS NOT NULL) AND
    (`status` != 'paid' OR `purchased_at` IS NOT NULL) AND
    (`status` != 'transferred' OR `transferred_at` IS NOT NULL) AND
    (`status` != 'cancelled' OR `cancelled_at` IS NOT NULL) AND
    (`status` != 'refunded' OR `refunded_at` IS NOT NULL)
  ),
  CONSTRAINT `chk_expiry_logic` CHECK (
    `expires_at` IS NULL OR `expires_at` > `reserved_at`
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTO_INCREMENT=1000000  -- Start ticket IDs at 1 million for Ethiopian scale
  COMMENT='Individual ticket instances with Ethiopian QR check-in support. Enterprise-grade with hash-based validation and financial precision.';

-- Note: Sample data should be in SEEDERS, not migrations
-- Use backend/src/database/seeds/021_individual_tickets_seed.sql for test data

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- TRIGGERS: For Ethiopian business rules
-- ============================================

DELIMITER $$

-- Trigger 1: Ensure QR hash is generated (application should do this, but DB backup)
CREATE TRIGGER `trg_individual_tickets_qr_hash`
BEFORE INSERT ON `individual_tickets`
FOR EACH ROW
BEGIN
  -- Application should set qr_hash, but ensure it's not empty
  IF NEW.qr_hash IS NULL OR NEW.qr_hash = '' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'qr_hash must be provided (SHA-256 of qr_data)';
  END IF;
END$$

-- Trigger 2: Auto-update event ticket counts
CREATE TRIGGER `trg_individual_tickets_after_insert`
AFTER INSERT ON `individual_tickets`
FOR EACH ROW
BEGIN
  -- Update tickets_sold count in events table
  UPDATE `events` 
  SET `tickets_sold` = `tickets_sold` + 1
  WHERE `id` = NEW.event_id;
  
  -- Update sold_count in ticket_types table
  UPDATE `ticket_types`
  SET `sold_count` = `sold_count` + 1
  WHERE `id` = NEW.ticket_type_id;
END$$

-- Trigger 3: Prevent invalid status transitions
CREATE TRIGGER `trg_individual_tickets_status_validation`
BEFORE UPDATE ON `individual_tickets`
FOR EACH ROW
BEGIN
  DECLARE error_msg VARCHAR(255);
  
  -- Define allowed status transitions
  IF OLD.status = 'cancelled' AND NEW.status != 'cancelled' THEN
    SET error_msg = 'Cannot change status from cancelled';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
  END IF;
  
  IF OLD.status = 'refunded' AND NEW.status != 'refunded' THEN
    SET error_msg = 'Cannot change status from refunded';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
  END IF;
  
  -- Check-in can only happen on paid tickets
  IF NEW.status = 'checked_in' AND OLD.status != 'paid' THEN
    SET error_msg = 'Only paid tickets can be checked in';
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_msg;
  END IF;
END$$

DELIMITER ;