-- ============================================
-- TABLE: admin_actions
-- Purpose: Store administrative action logs
-- ============================================
CREATE TABLE IF NOT EXISTS `admin_actions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `admin_id` BIGINT UNSIGNED NOT NULL,
  `action_type` ENUM('payment_verification', 'payout_processing', 'organizer_approval', 'event_moderation', 'user_management', 'dispute_resolution', 'system_config', 'data_export', 'other') NOT NULL,
  `action_details` TEXT NOT NULL,
  `target_type` VARCHAR(50),
  `target_id` BIGINT UNSIGNED,
  `changes_made` JSON COMMENT 'JSON object of old vs new values',
  `requires_approval` BOOLEAN DEFAULT FALSE,
  `approved_by` BIGINT UNSIGNED NULL,
  `approved_at` DATETIME NULL,
  `approval_notes` TEXT,
  `performed_at_local` DATETIME,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_admin` (`admin_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_target` (`target_type`, `target_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_requires_approval` (`requires_approval`, `approved_at`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_performed_at` (`performed_at_local`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;