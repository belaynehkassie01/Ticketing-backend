-- Migration: 010_create_admin_actions_table.sql
-- Description: Store administrative action logs for audit trail and compliance
-- Dependencies: Requires users table (admin_id FK)
-- Best Practices: Ethiopian timezone handled in app, no dangerous defaults, clear JSON structure

-- ============================================
-- TABLE: admin_actions
-- Purpose: Audit trail of all administrative actions for compliance, security, and accountability
-- Ethiopian Context: Local timezone tracking via application logic
-- ============================================

CREATE TABLE IF NOT EXISTS `admin_actions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Admin Information (historical snapshot - application must provide)
  `admin_id` BIGINT UNSIGNED NOT NULL COMMENT 'User who performed the action',
  `admin_role_at_time` ENUM('super_admin', 'admin', 'moderator', 'support', 'financial') NOT NULL COMMENT 'Role at time of action (application must provide)',
  
  -- Action Details
  `action_type` ENUM(
    'payment_verification', 
    'payout_processing', 
    'organizer_approval', 
    'event_moderation', 
    'user_management', 
    'dispute_resolution', 
    'system_config', 
    'data_export', 
    'refund_processing',
    'ticket_management',
    'commission_adjustment',
    'promo_management',
    'report_generation',
    'bulk_operation',
    'other'
  ) NOT NULL,
  
  `action_name` VARCHAR(100) NOT NULL,
  `action_description` TEXT,
  
  -- Target Information (application rule: if target_id exists, target_type must be set)
  `target_type` ENUM(
    'user', 
    'organizer', 
    'event', 
    'ticket', 
    'payment', 
    'payout', 
    'dispute', 
    'commission', 
    'refund',
    'promotion',
    'category',
    'venue',
    'system_setting',
    'notification',
    'report'
  ) DEFAULT NULL COMMENT 'Must be set if target_id is provided',
  
  `target_id` BIGINT UNSIGNED DEFAULT NULL,
  `target_name` VARCHAR(200),
  
  -- Change Tracking (Before/After) - Clear JSON structure
  `previous_values` JSON COMMENT '{"field_name": "old_value", ...} - Snapshot before change',
  `new_values` JSON COMMENT '{"field_name": "new_value", ...} - Snapshot after change',
  `changed_fields` JSON COMMENT '["field1", "field2", ...] - Array of modified field names',
  
  -- Action Metadata
  `requires_approval` BOOLEAN DEFAULT FALSE COMMENT 'Sensitive actions requiring supervisor approval',
  `approved_by` BIGINT UNSIGNED NULL COMMENT 'Supervisor who approved the action',
  `approved_at` DATETIME NULL,
  `approval_notes` TEXT,
  
  `requires_review` BOOLEAN DEFAULT FALSE COMMENT 'Actions that need periodic review',
  `reviewed_by` BIGINT UNSIGNED NULL,
  `reviewed_at` DATETIME NULL,
  `review_notes` TEXT,
  
  -- Ethiopian Context (Application sets local time)
  `performed_at_local` DATETIME NULL COMMENT 'Local time in Africa/Addis_Ababa (set by application)',
  `performed_in_city_id` BIGINT UNSIGNED NULL COMMENT 'City where action was performed',
  `performed_from_ip` VARCHAR(45),
  
  -- Device & Session Information
  `device_id` VARCHAR(255),
  `device_type` ENUM('mobile', 'tablet', 'desktop', 'server', 'api') DEFAULT 'desktop',
  `session_id` VARCHAR(100),
  `user_agent` TEXT,
  `browser_fingerprint` TEXT,
  
  -- Status & Impact
  `status` ENUM('pending', 'completed', 'failed', 'reverted', 'needs_attention') DEFAULT 'completed',
  `error_message` TEXT,
  `retry_count` INT DEFAULT 0,
  
  `impact_level` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
  `affected_users_count` INT DEFAULT 1,
  `financial_impact_etb` DECIMAL(15,2) DEFAULT 0.00,
  
  -- Related Entities
  `related_actions` JSON COMMENT 'Array of related action IDs: [123, 456, ...]',
  `batch_id` VARCHAR(100) COMMENT 'For bulk operations',
  
  -- Compliance & Auditing
  `compliance_reference` VARCHAR(100),
  `audit_trail_id` VARCHAR(100),
  `gdpr_impact` BOOLEAN DEFAULT FALSE,
  `requires_notification` BOOLEAN DEFAULT FALSE,
  
  -- Metadata
  `meta_data` JSON DEFAULT NULL,
  `tags` JSON DEFAULT NULL COMMENT 'Tags for categorization and search: ["financial", "urgent", ...]',
  
  -- Timestamps (Server UTC)
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  `archived_at` DATETIME NULL COMMENT 'For GDPR compliance archiving',
  
  -- Foreign Keys (Application will enforce consistency rules)
  FOREIGN KEY (`admin_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`performed_in_city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Core Indexes (Optimized for common queries)
  INDEX `idx_admin_id` (`admin_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_target` (`target_type`, `target_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_requires_approval` (`requires_approval`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_status` (`status`),
  INDEX `idx_batch_id` (`batch_id`),
  INDEX `idx_performed_at_local` (`performed_at_local`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_impact_level` (`impact_level`),
  
  -- Composite Indexes for Performance (Carefully selected)
  INDEX `idx_admin_action_time` (`admin_id`, `action_type`, `created_at`),
  INDEX `idx_target_audit` (`target_type`, `target_id`, `created_at`),
  INDEX `idx_approval_status` (`requires_approval`, `approved_at`, `status`),
  INDEX `idx_admin_time_range` (`admin_id`, `created_at`),
  INDEX `idx_action_status_time` (`action_type`, `status`, `created_at`)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit trail of administrative actions. Ethiopian timezone handled in app. Target consistency: if target_id exists, target_type must be set.';

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View for admin dashboard (optimized)
CREATE OR REPLACE VIEW `vw_admin_action_summary` AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.target_name,
    aa.status,
    aa.impact_level,
    aa.financial_impact_etb,
    aa.requires_approval,
    aa.approved_by,
    aa.performed_at_local,
    aa.created_at,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    -- Calculate action duration if available
    TIMESTAMPDIFF(SECOND, aa.created_at, aa.updated_at) as duration_seconds,
    -- Count affected users
    aa.affected_users_count,
    -- Format for display
    DATE_FORMAT(aa.created_at, '%Y-%m-%d %H:%i:%s') as formatted_time,
    DATE_FORMAT(aa.performed_at_local, '%Y-%m-%d %H:%i:%s') as formatted_local_time
FROM `admin_actions` aa
LEFT JOIN `users` u ON aa.admin_id = u.id
LEFT JOIN `cities` c ON aa.performed_in_city_id = c.id
WHERE aa.deleted_at IS NULL
ORDER BY aa.created_at DESC;

-- View for compliance reporting
CREATE OR REPLACE VIEW `vw_compliance_audit_log` AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    u.phone as admin_phone,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.previous_values,
    aa.new_values,
    aa.changed_fields,
    aa.requires_approval,
    aa.approved_by,
    ab.full_name as approved_by_name,
    aa.approved_at,
    aa.approval_notes,
    aa.performed_at_local,
    aa.performed_from_ip,
    aa.device_type,
    aa.session_id,
    aa.gdpr_impact,
    aa.compliance_reference,
    aa.created_at,
    -- Data privacy flags (application-level logic)
    CASE 
        WHEN aa.gdpr_impact = TRUE THEN 'GDPR_RELEVANT'
        WHEN aa.target_type IN ('user', 'organizer') THEN 'PERSONAL_DATA'
        ELSE 'GENERAL_ACTION'
    END as data_privacy_level
FROM `admin_actions` aa
LEFT JOIN `users` u ON aa.admin_id = u.id
LEFT JOIN `users` ab ON aa.approved_by = ab.id
WHERE aa.deleted_at IS NULL
  AND (aa.gdpr_impact = TRUE OR aa.target_type IN ('user', 'organizer', 'payment'))
ORDER BY aa.created_at DESC;
