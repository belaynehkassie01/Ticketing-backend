-- ============================================
-- TABLE: commissions
-- Purpose: Store commission calculations for payments
-- ============================================
CREATE TABLE IF NOT EXISTS `commissions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `payment_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_amount` DECIMAL(10,2) NOT NULL,
  `commission_rate` DECIMAL(5,2) NOT NULL,
  `commission_amount` DECIMAL(10,2) NOT NULL,
  `organizer_amount` DECIMAL(10,2) NOT NULL,
  `status` ENUM('pending', 'held', 'released', 'paid') DEFAULT 'pending',
  `held_until` DATETIME NULL,
  `released_at` DATETIME NULL,
  `paid_at` DATETIME NULL,
  `payout_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payout_id`) REFERENCES `payouts`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_payout_id` (`payout_id`),
  INDEX `idx_held_until` (`held_until`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_commission_rate` CHECK (`commission_rate` BETWEEN 0 AND 100),
  CONSTRAINT `chk_amounts` CHECK (`ticket_amount` = `commission_amount` + `organizer_amount` AND `ticket_amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;