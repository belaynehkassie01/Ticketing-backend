-- Migration: 038_create_audit_logs_table.sql
-- Purpose: Store audit trail for important actions with Ethiopian compliance requirements

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Actor information
  `user_id` BIGINT UNSIGNED NULL,
  `user_type` VARCHAR(30) NULL COMMENT 'customer, organizer, admin, system, api_key',
  `user_name` VARCHAR(100) NULL,
  `user_email` VARCHAR(100) NULL,
  `user_phone` VARCHAR(20) NULL,
  
  -- Action details
  `action_type` VARCHAR(100) NOT NULL COMMENT 'CREATE, UPDATE, DELETE, LOGIN, LOGOUT, PAYMENT, REFUND, etc.',
  `action_category` VARCHAR(50) NOT NULL COMMENT 'user_management, payment, event, ticket, organizer, system, security',
  `action_description` VARCHAR(500) NOT NULL,
  `action_description_amharic` VARCHAR(500),
  
  -- Entity affected
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` BIGINT UNSIGNED NOT NULL,
  `entity_name` VARCHAR(200) NULL,
  
  -- Change details
  `old_values` JSON COMMENT 'Previous values before change',
  `new_values` JSON COMMENT 'New values after change',
  `changed_fields` JSON COMMENT 'Array of field names that changed',
  `diff_summary` TEXT COMMENT 'Human-readable summary of changes',
  
  -- Ethiopian compliance context
  `compliance_type` VARCHAR(50) NULL COMMENT 'gdpr, pci_dss, tax_record, financial_audit, user_consent',
  `retention_period_days` INT DEFAULT 365 COMMENT 'Days to retain this audit record',
  `requires_review` BOOLEAN DEFAULT FALSE COMMENT 'Flag for manual review',
  
  -- Request context
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `device_id` VARCHAR(255),
  `session_id` VARCHAR(100),
  `request_id` VARCHAR(100) COMMENT 'Unique request identifier',
  
  -- Location context
  `city_id` BIGINT UNSIGNED NULL,
  `country_code` VARCHAR(3) DEFAULT 'ET',
  `timezone` VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  `geolocation` JSON COMMENT 'Latitude/longitude if available',
  
  -- Performance metrics
  `execution_time_ms` INT NULL,
  `memory_usage_mb` DECIMAL(5,2) NULL,
  
  -- Status
  `status` VARCHAR(30) DEFAULT 'success' COMMENT 'success, failed, partial, warning',
  `error_message` TEXT,
  `error_stack` TEXT,
  
  -- Related entities
  `related_entity_type` VARCHAR(50) NULL,
  `related_entity_id` BIGINT UNSIGNED NULL,
  `correlation_id` VARCHAR(100) NULL COMMENT 'For grouping related audit logs',
  
  -- Business context
  `business_unit` VARCHAR(50) NULL COMMENT 'ticketing, payments, organizers, support',
  `risk_level` VARCHAR(20) DEFAULT 'low' COMMENT 'low, medium, high, critical',
  `requires_notification` BOOLEAN DEFAULT FALSE,
  
  -- Metadata
  `metadata` JSON,
  `tags` JSON COMMENT '["sensitive", "financial", "user_data", "compliance"]',
  
  -- Timestamp with high precision
  `action_timestamp` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign Keys
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes (optimized for Ethiopian compliance queries)
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_action_category` (`action_category`),
  INDEX `idx_entity` (`entity_type`, `entity_id`),
  INDEX `idx_action_timestamp` (`action_timestamp`),
  INDEX `idx_ip_address` (`ip_address`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_compliance_type` (`compliance_type`),
  INDEX `idx_risk_level` (`risk_level`),
  INDEX `idx_correlation_id` (`correlation_id`),
  INDEX `idx_requires_review` (`requires_review`),
  INDEX `idx_created_at` (`created_at`),
  
  -- Partitioning hint for large-scale Ethiopian deployment
  -- PARTITION BY RANGE (YEAR(action_timestamp)) (
  --   PARTITION p2023 VALUES LESS THAN (2024),
  --   PARTITION p2024 VALUES LESS THAN (2025),
  --   PARTITION p2025 VALUES LESS THAN (2026)
  -- )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Comprehensive audit trail for Ethiopian compliance and security monitoring';