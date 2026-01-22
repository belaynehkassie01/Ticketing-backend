-- ============================================
-- TABLE: audit_logs
-- Purpose: Store audit trail for important actions
-- ============================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED NULL,
  `user_type` ENUM('customer', 'organizer', 'admin', 'system') NULL,
  `action` VARCHAR(100) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `old_values` JSON COMMENT 'Previous values before change',
  `new_values` JSON COMMENT 'New values after change',
  `changed_fields` JSON COMMENT 'Array of field names that changed',
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `device_id` VARCHAR(255),
  `session_id` VARCHAR(100),
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX `idx_user` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_user_type` (`user_type`),
  INDEX `idx_ip_address` (`ip_address`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_entity_id` (`entity_id`),
  
  CONSTRAINT `chk_entity_id_positive` CHECK (`entity_id` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;