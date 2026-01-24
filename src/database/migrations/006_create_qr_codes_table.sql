-- Migration: 006_create_qr_codes_table.sql
-- Description: Create QR codes table for tickets, payments, and Ethiopian TeleBirr
-- Dependencies: Requires users table (optional foreign keys)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `qr_codes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  `qr_data` TEXT NOT NULL,
  `qr_hash` VARCHAR(64) UNIQUE NOT NULL,
  `qr_image_url` VARCHAR(500),
  `qr_image_path` VARCHAR(500),
  
  `entity_type` ENUM('ticket', 'event', 'organizer', 'user', 'payment', 'telebirr', 'promo') NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  
  `qr_format` ENUM('telebirr', 'ticket', 'promo', 'generic') DEFAULT 'ticket',
  `qr_version` VARCHAR(20) DEFAULT '1.0',
  `generated_in_country` VARCHAR(3) DEFAULT 'ET',
  `generated_by_user` BIGINT UNSIGNED NULL,
  
  `scan_count` INT UNSIGNED DEFAULT 0,
  `max_scans` INT UNSIGNED NULL,
  `last_scanned_at` DATETIME NULL,
  `last_scanned_by` BIGINT UNSIGNED NULL,
  `last_scanned_device_id` VARCHAR(255),
  `last_scanned_ip` VARCHAR(45),
  
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_valid` BOOLEAN DEFAULT TRUE,
  `expires_at` DATETIME NULL,
  `invalidated_at` DATETIME NULL,
  `invalidation_reason` ENUM('used', 'expired', 'compromised', 'replaced', 'cancelled') NULL,
  `invalidated_by` BIGINT UNSIGNED NULL,
  
  `ticket_data` JSON NULL,
  `payment_data` JSON NULL,
  `telebirr_data` JSON NULL,
  `promo_data` JSON NULL,
  
  `meta_data` JSON DEFAULT NULL,
  
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  INDEX `idx_qr_hash` (`qr_hash`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_expires_at` (`expires_at`),
  INDEX `idx_last_scanned_at` (`last_scanned_at`),
  INDEX `idx_qr_format` (`qr_format`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_generated_by_user` (`generated_by_user`),
  
  INDEX `idx_active_expires` (`is_active`, `expires_at`),
  INDEX `idx_entity_active` (`entity_type`, `entity_id`, `is_active`),
  INDEX `idx_format_active` (`qr_format`, `is_active`),
  INDEX `idx_entity_format` (`entity_type`, `qr_format`),
  
  -- Optional foreign keys (remove if users table not ready)
  FOREIGN KEY (`generated_by_user`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`last_scanned_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  FOREIGN KEY (`invalidated_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,
  
  CONSTRAINT `chk_entity_id` CHECK (`entity_id` > 0),
  CONSTRAINT `chk_scan_count` CHECK (`scan_count` >= 0),
  CONSTRAINT `chk_max_scans` CHECK (`max_scans` IS NULL OR `max_scans` > 0),
  CONSTRAINT `chk_expiry` CHECK (`expires_at` IS NULL OR `expires_at` > `created_at`)
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;