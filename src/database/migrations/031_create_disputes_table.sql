-- ============================================
-- TABLE: disputes
-- Purpose: Store dispute records between users and organizers
-- ============================================
CREATE TABLE IF NOT EXISTS `disputes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `dispute_reference` VARCHAR(100) UNIQUE NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `ticket_id` BIGINT UNSIGNED NULL,
  `payment_id` BIGINT UNSIGNED NULL,
  `type` ENUM('refund_request', 'event_cancelled', 'ticket_not_valid', 'organizer_no_show', 'event_different', 'fraud', 'technical_issue', 'other') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT NOT NULL,
  `desired_outcome` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'apology', 'other') NOT NULL,
  `status` ENUM('open', 'under_review', 'awaiting_response', 'resolved', 'closed', 'escalated') DEFAULT 'open',
  `resolution` ENUM('full_refund', 'partial_refund', 'ticket_replacement', 'organizer_penalty', 'rejected', 'other') NULL,
  `resolution_amount` DECIMAL(10,2) NULL,
  `resolution_details` TEXT,
  `assigned_to` BIGINT UNSIGNED NULL,
  `assigned_at` DATETIME NULL,
  `resolved_at` DATETIME NULL,
  `resolved_by` BIGINT UNSIGNED NULL,
  `closed_at` DATETIME NULL,
  `requires_mediation` BOOLEAN DEFAULT FALSE,
  `mediation_notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_dispute_reference` (`dispute_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_assigned_to` (`assigned_to`, `status`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_type` (`type`),
  INDEX `idx_resolved_at` (`resolved_at`),
  
  CONSTRAINT `chk_resolution_amount` CHECK (`resolution_amount` IS NULL OR `resolution_amount` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;