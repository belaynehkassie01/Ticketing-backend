-- Migration: 031_create_disputes_table.sql (ENHANCED)
-- Purpose: Store dispute records with Ethiopian mediation - IMPROVED VERSION

CREATE TABLE IF NOT EXISTS `disputes` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Dispute identification
  `dispute_code` VARCHAR(50) UNIQUE NOT NULL COMMENT 'DSP-ET-2024-001',
  
  -- IMPROVEMENT #1: Added dispute source
  `dispute_source` VARCHAR(20) DEFAULT 'customer' COMMENT 'customer, organizer, system, payment_gateway, admin, automated_monitoring',
  
  -- Parties involved (Ethiopian context)
  `customer_id` BIGINT UNSIGNED NOT NULL,
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  
  -- Related entities
  `ticket_id` BIGINT UNSIGNED NULL,
  `payment_id` BIGINT UNSIGNED NULL,
  `refund_id` BIGINT UNSIGNED NULL,
  
  -- IMPROVEMENT #2: Link to tax transactions (optional)
  `related_tax_transaction_id` BIGINT UNSIGNED NULL,
  
  -- Dispute classification
  `dispute_type` VARCHAR(50) NOT NULL COMMENT 'refund_request, event_cancelled, ticket_not_valid, organizer_no_show, event_different, fraud, technical_issue, quality_issue, other',
  `dispute_subtype` VARCHAR(50) NULL COMMENT 'late_start, wrong_venue, misrepresentation, safety_issue, service_quality',
  
  -- Ethiopian mediation context
  `city_id` BIGINT UNSIGNED NULL,
  `region` VARCHAR(100) NULL,
  `preferred_language` ENUM('am', 'en', 'or', 'ti', 'so') DEFAULT 'am',
  
  -- Dispute details
  `title` VARCHAR(200) NOT NULL,
  `title_amharic` VARCHAR(200),
  `description` TEXT NOT NULL,
  `description_amharic` TEXT,
  
  -- Customer demands
  `desired_outcome` VARCHAR(50) NOT NULL COMMENT 'full_refund, partial_refund, ticket_replacement, rescheduled_event, apology, compensation, organizer_penalty, other',
  `desired_amount` DECIMAL(10,2) NULL,
  `desired_notes` TEXT,
  
  -- Evidence
  `evidence_files` JSON COMMENT 'Array of URLs: photos, videos, receipts',
  `supporting_documents` JSON,
  `witness_contacts` JSON COMMENT 'Array of witness phone/email',
  
  -- Status tracking
  `status` VARCHAR(30) DEFAULT 'open' COMMENT 'open, under_review, awaiting_customer_response, awaiting_organizer_response, mediation_in_progress, resolved, closed, escalated',
  `priority` VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  `severity` VARCHAR(20) DEFAULT 'normal' COMMENT 'minor, normal, major, critical',
  
  -- Assignment and workflow
  `assigned_to` BIGINT UNSIGNED NULL COMMENT 'Admin/staff handling',
  `assigned_at` DATETIME NULL,
  `assigned_by` BIGINT UNSIGNED NULL,
  `last_reassigned_at` DATETIME NULL,
  
  -- Resolution
  `resolution_type` VARCHAR(50) NULL COMMENT 'full_refund, partial_refund, ticket_replacement, organizer_penalty, customer_compensation, rejected, withdrawn, other',
  `resolution_amount` DECIMAL(10,2) NULL,
  `resolution_details` TEXT,
  `resolution_details_amharic` TEXT,
  
  -- Ethiopian mediation process
  `requires_mediation` BOOLEAN DEFAULT FALSE,
  `mediation_attempts` INT DEFAULT 0,
  `mediation_successful` BOOLEAN DEFAULT FALSE,
  `mediation_notes` TEXT,
  `mediation_date` DATETIME NULL,
  `mediator_id` BIGINT UNSIGNED NULL COMMENT 'Third-party mediator if needed',
  
  -- Communication tracking
  `last_customer_response_at` DATETIME NULL,
  `last_organizer_response_at` DATETIME NULL,
  `response_deadline` DATETIME NULL,
  `response_reminders_sent` INT DEFAULT 0,
  `escalation_level` INT DEFAULT 1 COMMENT '1=Customer Support, 2=Senior Support, 3=Management',
  
  -- Timeline
  `acknowledged_at` DATETIME NULL,
  `investigation_started_at` DATETIME NULL,
  `mediation_started_at` DATETIME NULL,
  `resolved_at` DATETIME NULL,
  `resolved_by` BIGINT UNSIGNED NULL,
  `closed_at` DATETIME NULL,
  `closed_by` BIGINT UNSIGNED NULL,
  `escalated_at` DATETIME NULL,
  
  -- Financial impact
  `refund_issued` BOOLEAN DEFAULT FALSE,
  `refund_amount` DECIMAL(10,2) DEFAULT 0.00,
  `penalty_applied` BOOLEAN DEFAULT FALSE,
  `penalty_amount` DECIMAL(10,2) DEFAULT 0.00,
  `compensation_awarded` BOOLEAN DEFAULT FALSE,
  `compensation_amount` DECIMAL(10,2) DEFAULT 0.00,
  
  -- Customer satisfaction
  `customer_satisfaction` TINYINT NULL COMMENT '1-5 rating',
  `customer_feedback` TEXT,
  `organizer_feedback` TEXT,
  `platform_learnings` TEXT COMMENT 'What we learned to prevent future disputes',
  
  -- Audit and compliance
  `audit_trail` JSON,
  `compliance_notes` TEXT,
  `legal_notes` TEXT,
  
  -- Timestamps with soft delete
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys
  FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (`ticket_id`) REFERENCES `individual_tickets`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`refund_id`) REFERENCES `refunds`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  -- IMPROVEMENT #2: Tax transaction link
  FOREIGN KEY (`related_tax_transaction_id`) REFERENCES `tax_transactions`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`assigned_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`resolved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`closed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`mediator_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_dispute_code` (`dispute_code`),
  INDEX `idx_customer_id` (`customer_id`),
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_event_id` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_dispute_type` (`dispute_type`),
  
  -- IMPROVEMENT #3: Added resolution_type index
  INDEX `idx_resolution_type` (`resolution_type`),
  
  INDEX `idx_dispute_source` (`dispute_source`),
  INDEX `idx_assigned_to` (`assigned_to`),
  INDEX `idx_priority` (`priority`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_resolved_at` (`resolved_at`),
  INDEX `idx_closed_at` (`closed_at`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_preferred_language` (`preferred_language`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Business constraints
  CONSTRAINT `chk_resolution_amount` CHECK (`resolution_amount` IS NULL OR `resolution_amount` >= 0),
  CONSTRAINT `chk_customer_satisfaction` CHECK (`customer_satisfaction` IS NULL OR `customer_satisfaction` BETWEEN 1 AND 5),
  CONSTRAINT `chk_dispute_source` CHECK (`dispute_source` IN ('customer', 'organizer', 'system', 'payment_gateway', 'admin', 'automated_monitoring'))
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian dispute resolution system - ENHANCED with source tracking and tax links';