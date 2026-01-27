-- Migration: 022_create_checkin_logs_table.sql
-- Description: Store ticket check-in logs with Ethiopian context
-- Purpose: Audit trail for ticket validation, offline sync support, Ethiopian location tracking
-- Dependencies: Requires individual_tickets, events, organizers, users tables
-- Production-safe with MySQL best practices

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: checkin_logs
-- Purpose: Store ticket check-in logs
-- Ethiopian Context: Offline sync support, Ethiopian location coordinates, mobile device tracking
-- ============================================

CREATE TABLE IF NOT EXISTS `checkin_logs` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal check-in log ID',
  
  -- Ticket & Event Relationships
  `ticket_id` BIGINT UNSIGNED NOT NULL COMMENT 'References individual_tickets.id',
  `event_id` BIGINT UNSIGNED NOT NULL COMMENT 'References events.id',
  `organizer_id` BIGINT UNSIGNED NOT NULL COMMENT 'References organizers.id',
  
  -- Check-in Personnel
  `checked_in_by` BIGINT UNSIGNED NOT NULL COMMENT 'References users.id (staff who performed check-in)',
  
  -- Check-in Method (Ethiopian Context)
  `checkin_method` ENUM('qr_scan', 'manual_entry', 'offline_sync', 'batch_import') NOT NULL 
    COMMENT 'How check-in was performed (qr_scan for mobile, offline_sync for poor connectivity)',
  
  -- Timestamps
  `checkin_time` DATETIME NOT NULL COMMENT 'Actual check-in time (Ethiopian timezone aware)',
  `server_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When record reached server',
  
  -- Device Information (Ethiopian Mobile Context)
  `device_id` VARCHAR(255) COMMENT 'Unique device identifier (IMEI or generated UUID)',
  `device_type` ENUM('android', 'ios', 'web', 'other') DEFAULT 'android' 
    COMMENT 'Mobile device type (Android dominant in Ethiopia)',
  `app_version` VARCHAR(20) COMMENT 'App version for debugging',
  
  -- Location Information (Ethiopian Venues) - MySQL SPATIAL compatible
  `latitude` DECIMAL(10,8) NULL COMMENT 'GPS latitude (Addis Ababa ≈ 9.032, 38.746)',
  `longitude` DECIMAL(11,8) NULL COMMENT 'GPS longitude',
  `location_point` POINT GENERATED ALWAYS AS (
    IF(`latitude` IS NOT NULL AND `longitude` IS NOT NULL,
       ST_SRID(POINT(`longitude`, `latitude`), 4326),
       NULL)
  ) STORED COMMENT 'Spatial point for geographical queries (WGS 84)',
  `location_name` VARCHAR(255) COMMENT 'Human-readable location (e.g., "Millennium Hall Main Gate")',
  `city_id` BIGINT UNSIGNED NULL COMMENT 'References cities.id for Ethiopian city',
  
  -- Network & Connectivity (Ethiopian Infrastructure)
  `is_online` BOOLEAN DEFAULT TRUE COMMENT 'Was device online during check-in?',
  `connection_type` ENUM('wifi', 'cellular_2g', 'cellular_3g', 'cellular_4g', 'cellular_5g', 'unknown', 'offline') DEFAULT 'unknown'
    COMMENT 'Network type during check-in (important for Ethiopian connectivity analysis)',
  `network_speed_kbps` INT NULL COMMENT 'Network speed in kbps (for performance monitoring)',
  
  -- Offline Sync Support (Critical for Ethiopia)
  `sync_status` ENUM('pending', 'synced', 'failed', 'duplicate') DEFAULT 'synced'
    COMMENT 'Sync status for offline operations',
  `local_ticket_id` VARCHAR(100) NULL COMMENT 'Local ticket reference from offline device',
  `offline_session_id` VARCHAR(100) NULL COMMENT 'Offline session identifier',
  `synced_at` DATETIME NULL COMMENT 'When offline data was synced to server',
  
  -- Validation & Security
  `is_valid` BOOLEAN DEFAULT TRUE COMMENT 'Was this a valid check-in?',
  `validation_notes` TEXT COMMENT 'Notes on validation (e.g., "Ticket already checked in at 14:30")',
  `qr_scan_duration_ms` INT NULL COMMENT 'How long QR scan took in milliseconds',
  
  -- Audit Information
  `ip_address` VARCHAR(45) COMMENT 'IP address of check-in device',
  `user_agent` TEXT COMMENT 'Browser/device user agent',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Generated columns for Ethiopian business analytics
  `checkin_hour` TINYINT GENERATED ALWAYS AS (HOUR(`checkin_time`)) STORED 
    COMMENT 'Hour of check-in (24-hour format) for Ethiopian event timing analysis',
  `checkin_day_of_week` TINYINT GENERATED ALWAYS AS (DAYOFWEEK(`checkin_time`)) STORED 
    COMMENT 'Day of week (1=Sunday) for Ethiopian event patterns',
  
  -- Foreign Keys
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`checked_in_by`) REFERENCES `users`(`id`) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  -- Indexes for Ethiopian-scale performance
  INDEX `idx_ticket` (`ticket_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_checkin_time` (`checkin_time`),
  INDEX `idx_sync_status` (`sync_status`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  INDEX `idx_device_id` (`device_id`),
  
  -- Composite indexes for common Ethiopian queries
  INDEX `idx_event_checkin_time` (`event_id`, `checkin_time`),
  INDEX `idx_organizer_checkin_time` (`organizer_id`, `checkin_time`),
  INDEX `idx_ticket_checkin_time` (`ticket_id`, `checkin_time`),
  INDEX `idx_offline_sync` (`sync_status`, `synced_at`),
  INDEX `idx_checkin_method` (`checkin_method`, `checkin_time`),
  INDEX `idx_connection_type` (`connection_type`, `checkin_time`),
  
  -- Spatial index for Ethiopian location queries (MySQL-compatible)
  SPATIAL INDEX `idx_location` (`location_point`),
  
  -- Unique constraint: Only ONE valid check-in per ticket
  UNIQUE INDEX `uq_ticket_valid_checkin` (`ticket_id`, `is_valid`),
  
  -- Ethiopian Business Logic Constraints
  CONSTRAINT `chk_coordinates` CHECK (
    (`latitude` IS NULL AND `longitude` IS NULL) OR 
    (`latitude` IS NOT NULL AND `longitude` IS NOT NULL AND
     `latitude` BETWEEN -90 AND 90 AND
     `longitude` BETWEEN -180 AND 180)
  ),
  
  CONSTRAINT `chk_network_speed` CHECK (
    `network_speed_kbps` IS NULL OR `network_speed_kbps` >= 0
  ),
  
  CONSTRAINT `chk_scan_duration` CHECK (
    `qr_scan_duration_ms` IS NULL OR `qr_scan_duration_ms` >= 0
  ),
  
  CONSTRAINT `chk_ethiopian_hours` CHECK (
    `checkin_hour` BETWEEN 0 AND 23  -- Valid Ethiopian hours
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ticket check-in logs with Ethiopian context. Supports offline sync, location tracking, and mobile device analytics for Ethiopian event venues. Production-safe with MySQL spatial indexes.';

-- ============================================
-- VIEWS: For Ethiopian business reporting
-- ============================================

-- View 1: Daily check-ins by Ethiopian city (optimized)
CREATE OR REPLACE VIEW `vw_checkins_by_ethiopian_city` AS
SELECT 
  c.`name_en` AS `city_name`,
  c.`region` AS `region`,
  DATE(cl.`checkin_time`) AS `checkin_date`,
  COUNT(*) AS `total_checkins`,
  COUNT(DISTINCT cl.`event_id`) AS `unique_events`,
  AVG(cl.`qr_scan_duration_ms`) AS `avg_scan_time_ms`,
  GROUP_CONCAT(DISTINCT cl.`checkin_method`) AS `methods_used`
FROM `checkin_logs` cl
LEFT JOIN `cities` c ON cl.`city_id` = c.`id`
WHERE cl.`is_valid` = TRUE
GROUP BY c.`id`, DATE(cl.`checkin_time`)
ORDER BY `checkin_date` DESC, `total_checkins` DESC;

-- View 2: Offline vs Online check-in analysis (Ethiopian connectivity) - optimized
CREATE OR REPLACE VIEW `vw_ethiopian_connectivity_analysis` AS
SELECT 
  e.`title` AS `event_name`,
  o.`business_name` AS `organizer`,
  cl.`connection_type`,
  cl.`is_online`,
  COUNT(*) AS `checkin_count`,
  ROUND(AVG(cl.`network_speed_kbps`), 0) AS `avg_network_speed_kbps`,
  SUM(CASE WHEN cl.`sync_status` = 'pending' THEN 1 ELSE 0 END) AS `pending_syncs`,
  MIN(cl.`checkin_time`) AS `first_checkin`,
  MAX(cl.`checkin_time`) AS `last_checkin`
FROM `checkin_logs` cl
JOIN `events` e ON cl.`event_id` = e.`id`
JOIN `organizers` o ON cl.`organizer_id` = o.`id`
GROUP BY cl.`event_id`, cl.`connection_type`, cl.`is_online`
ORDER BY e.`start_date` DESC, `checkin_count` DESC;

-- View 3: Quick check-in stats for Ethiopian event dashboards
CREATE OR REPLACE VIEW `vw_event_checkin_summary` AS
SELECT 
  e.`id` AS `event_id`,
  e.`title` AS `event_name`,
  e.`start_date`,
  e.`city_id`,
  COUNT(cl.`id`) AS `total_checkins`,
  COUNT(DISTINCT cl.`ticket_id`) AS `unique_tickets_checked`,
  SUM(CASE WHEN cl.`is_online` = FALSE THEN 1 ELSE 0 END) AS `offline_checkins`,
  MIN(cl.`checkin_time`) AS `first_checkin`,
  MAX(cl.`checkin_time`) AS `last_checkin`
FROM `events` e
LEFT JOIN `checkin_logs` cl ON e.`id` = cl.`event_id` AND cl.`is_valid` = TRUE
GROUP BY e.`id`, e.`title`, e.`start_date`, e.`city_id`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================
-- TRIGGERS: For Ethiopian business rules (FIXED)
-- ============================================

DELIMITER $$

-- Trigger 1: Validate check-in time (replaces CHECK constraint)
CREATE TRIGGER `trg_checkin_logs_before_insert_time_check`
BEFORE INSERT ON `checkin_logs`
FOR EACH ROW
BEGIN
  DECLARE max_future_time DATETIME;
  
  -- Allow 1 hour buffer for clock drift in Ethiopian context
  SET max_future_time = NOW() + INTERVAL 1 HOUR;
  
  -- Reject check-ins too far in the future
  IF NEW.checkin_time > max_future_time THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'checkin_time cannot be more than 1 hour in the future';
  END IF;
  
  -- Auto-set server_time if not provided
  IF NEW.server_time IS NULL THEN
    SET NEW.server_time = CURRENT_TIMESTAMP;
  END IF;
  
  -- Auto-set sync_status for offline check-ins
  IF NEW.is_online = FALSE AND NEW.sync_status = 'synced' THEN
    SET NEW.sync_status = 'pending';
  END IF;
END$$

-- Trigger 2: Prevent duplicate valid check-ins (FIXED - removed NEW.id reference)
CREATE TRIGGER `trg_checkin_logs_before_insert_duplicate_check`
BEFORE INSERT ON `checkin_logs`
FOR EACH ROW
BEGIN
  DECLARE existing_valid_checkins INT;
  DECLARE ticket_status VARCHAR(50);
  
  -- Check if ticket already has a valid check-in
  SELECT COUNT(*) INTO existing_valid_checkins
  FROM `checkin_logs`
  WHERE `ticket_id` = NEW.ticket_id 
    AND `is_valid` = TRUE;
  
  -- Get ticket status
  SELECT `status` INTO ticket_status
  FROM `individual_tickets`
  WHERE `id` = NEW.ticket_id;
  
  -- Prevent duplicate valid check-ins
  IF existing_valid_checkins > 0 AND NEW.is_valid = TRUE THEN
    SET NEW.is_valid = FALSE;
    SET NEW.validation_notes = CONCAT_WS(' ',
      'Duplicate check-in. Previous valid check-in exists.',
      NEW.validation_notes
    );
    
    -- Still allow recording (as invalid) for audit trail
    SET NEW.sync_status = 'duplicate';
  END IF;
  
  -- Ensure ticket is paid before valid check-in
  IF NEW.is_valid = TRUE AND ticket_status != 'paid' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only paid tickets can be checked in';
  END IF;
END$$

-- Trigger 3: Update individual_tickets and events when valid check-in occurs
CREATE TRIGGER `trg_checkin_logs_after_insert_update_tickets`
AFTER INSERT ON `checkin_logs`
FOR EACH ROW
BEGIN
  -- Only process valid check-ins
  IF NEW.is_valid = TRUE THEN
    -- Update individual_tickets status
    UPDATE `individual_tickets`
    SET 
      `status` = 'checked_in',
      `checked_in_at` = NEW.checkin_time,
      `checked_in_by` = NEW.checked_in_by,
      `checkin_device_id` = NEW.device_id,
      `checkin_location` = NEW.location_name,
      `checkin_method` = NEW.checkin_method,
      `updated_at` = CURRENT_TIMESTAMP
    WHERE `id` = NEW.ticket_id;
    
    -- Update events checkins_count (using dedicated column)
    UPDATE `events`
    SET 
      `checkins_count` = COALESCE(`checkins_count`, 0) + 1,
      `updated_at` = CURRENT_TIMESTAMP
    WHERE `id` = NEW.event_id;
  END IF;
END$$

-- Trigger 4: Handle sync status updates
CREATE TRIGGER `trg_checkin_logs_before_update_sync`
BEFORE UPDATE ON `checkin_logs`
FOR EACH ROW
BEGIN
  -- When syncing offline records, update synced_at
  IF OLD.sync_status = 'pending' AND NEW.sync_status = 'synced' THEN
    SET NEW.synced_at = CURRENT_TIMESTAMP;
  END IF;
  
  -- Prevent changing valid check-ins to invalid without reason
  IF OLD.is_valid = TRUE AND NEW.is_valid = FALSE AND 
     (NEW.validation_notes IS NULL OR TRIM(NEW.validation_notes) = '') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Must provide validation_notes when marking valid check-in as invalid';
  END IF;
  
  -- Prevent making invalid check-ins valid retroactively
  IF OLD.is_valid = FALSE AND NEW.is_valid = TRUE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot change invalid check-in to valid. Create new valid check-in instead.';
  END IF;
END$$

DELIMITER ;

-- ============================================
-- MIGRATION: Add checkins_count to events table
-- ============================================

-- Note: This should be run as a separate migration if events table already exists
-- For new installations, add this column to events table creation
-- Here's the ALTER statement for existing installations:

-- ALTER TABLE `events` ADD COLUMN IF NOT EXISTS `checkins_count` INT DEFAULT 0 COMMENT 'Total valid check-ins for this event';