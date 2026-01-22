-- ============================================
-- TABLE: message_threads
-- Purpose: Store message threads between users, organizers, and admins
-- ============================================
CREATE TABLE IF NOT EXISTS `message_threads` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NULL,
  `admin_id` BIGINT UNSIGNED NULL,
  `subject` VARCHAR(200) NOT NULL,
  `related_event_id` BIGINT UNSIGNED NULL,
  `related_ticket_id` BIGINT UNSIGNED NULL,
  `status` ENUM('open', 'waiting_reply', 'resolved', 'closed') DEFAULT 'open',
  `priority` ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
  `last_message_at` DATETIME NULL,
  `last_message_by` BIGINT UNSIGNED NULL,
  `message_count` INT UNSIGNED DEFAULT 0,
  `unread_count_user` INT UNSIGNED DEFAULT 0,
  `unread_count_admin` INT UNSIGNED DEFAULT 0,
  `unread_count_organizer` INT UNSIGNED DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` DATETIME NULL,
  `closed_at` DATETIME NULL,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`related_event_id`) REFERENCES `events`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`related_ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  FOREIGN KEY (`last_message_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_last_message_at` (`last_message_at`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_admin_id` (`admin_id`),
  INDEX `idx_related_event_id` (`related_event_id`),
  INDEX `idx_related_ticket_id` (`related_ticket_id`),
  INDEX `idx_last_message_by` (`last_message_by`),
  
  CONSTRAINT `chk_message_counts` CHECK (`message_count` >= 0 AND `unread_count_user` >= 0 AND `unread_count_admin` >= 0 AND `unread_count_organizer` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;