-- ============================================
-- TABLE: qr_codes
-- Purpose: Store QR code data for tickets and payments
-- ============================================
CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `qr_data` TEXT NOT NULL,
  `qr_hash` VARCHAR(64) UNIQUE NOT NULL,
  `qr_image_url` VARCHAR(500),
  `entity_type` ENUM('ticket', 'event', 'organizer', 'user', 'payment') NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `scan_count` INT UNSIGNED DEFAULT 0,
  `last_scanned_at` DATETIME NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `expires_at` DATETIME NULL,
  `generated_in_country` VARCHAR(3) DEFAULT 'ET',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_last_scanned_at` (`last_scanned_at`),
  
  CONSTRAINT `chk_entity_id` CHECK (`entity_id` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;