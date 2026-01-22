-- ============================================
-- TABLE: reservations
-- Purpose: Store temporary ticket reservations before payment
-- ============================================
CREATE TABLE IF NOT EXISTS `reservations` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `reservation_code` VARCHAR(20) UNIQUE NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_type_id` BIGINT UNSIGNED NOT NULL,
  `quantity` INT NOT NULL,
  `total_amount` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'ETB',
  `status` ENUM('active', 'completed', 'expired', 'cancelled') DEFAULT 'active',
  `payment_method` ENUM('telebirr', 'cbe_transfer', 'cbe_birr', 'cash') NULL,
  `expires_at` DATETIME NOT NULL,
  `completed_at` DATETIME NULL,
  `session_id` VARCHAR(100),
  `device_id` VARCHAR(255),
  `ip_address` VARCHAR(45),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`ticket_type_id`) REFERENCES `ticket_types`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_reservation_code` (`reservation_code`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_status_expires` (`status`, `expires_at`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_ticket_type_id` (`ticket_type_id`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_quantity` CHECK (`quantity` > 0),
  CONSTRAINT `chk_total_amount` CHECK (`total_amount` > 0),
  CONSTRAINT `chk_expires_at` CHECK (`expires_at` > `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;