-- ============================================
-- TABLE: individual_tickets
-- Purpose: Store individual ticket instances
-- ============================================
CREATE TABLE IF NOT EXISTS `individual_tickets` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `ticket_number` VARCHAR(50) UNIQUE NOT NULL,
  `ticket_type_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `purchase_price` DECIMAL(10,2) NOT NULL,
  `vat_amount` DECIMAL(10,2) NOT NULL,
  `platform_commission` DECIMAL(10,2) NOT NULL,
  `organizer_earning` DECIMAL(10,2) NOT NULL,
  `qr_data` TEXT NOT NULL,
  `qr_image_url` VARCHAR(500),
  `qr_secret_key` VARCHAR(100),
  `status` ENUM('reserved', 'paid', 'checked_in', 'cancelled', 'refunded', 'transferred') DEFAULT 'reserved',
  `checked_in_at` DATETIME NULL,
  `checked_in_by` BIGINT UNSIGNED NULL,
  `checkin_device_id` VARCHAR(100),
  `checkin_location` VARCHAR(255),
  `checkin_method` ENUM('qr_scan', 'manual', 'offline_sync') NULL,
  `transferred_at` DATETIME NULL,
  `transferred_to_user` BIGINT UNSIGNED NULL,
  `transfer_token` VARCHAR(100),
  `cancelled_at` DATETIME NULL,
  `cancelled_by` BIGINT UNSIGNED NULL,
  `cancellation_reason` ENUM('user_request', 'event_cancelled', 'duplicate', 'fraud', 'other') NULL,
  `refund_amount` DECIMAL(10,2) NULL,
  `refunded_at` DATETIME NULL,
  `refund_transaction_id` VARCHAR(100),
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash', 'other') NULL,
  `payment_reference` VARCHAR(100),
  `device_id` VARCHAR(255),
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `reserved_at` DATETIME NULL,
  `expires_at` DATETIME NULL,
  `purchased_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
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
  
  INDEX `idx_ticket_number` (`ticket_number`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_purchased_at` (`purchased_at`),
  INDEX `idx_checked_in_at` (`checked_in_at`),
  INDEX `idx_qr_secret` (`qr_secret_key`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_checked_in_by` (`checked_in_by`),
  UNIQUE INDEX `idx_qr_data` (`qr_data`(100)),
  
  CONSTRAINT `chk_purchase_price` CHECK (`purchase_price` >= 0),
  CONSTRAINT `chk_vat_amount` CHECK (`vat_amount` >= 0),
  CONSTRAINT `chk_platform_commission` CHECK (`platform_commission` >= 0),
  CONSTRAINT `chk_organizer_earning` CHECK (`organizer_earning` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;