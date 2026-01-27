-- Migration: 011_create_payout_requests_table.sql
-- Description: Store organizer payout requests (Ethiopian banking & Telebirr)
-- Dependencies: organizers, users
-- MySQL-safe: No CHECK constraints, app-enforced validation

CREATE TABLE IF NOT EXISTS `payout_requests` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,

  -- Organizer
  `organizer_id` BIGINT UNSIGNED NOT NULL,

  -- Financial Snapshot
  `requested_amount` DECIMAL(15,2) NOT NULL COMMENT 'Requested payout amount (ETB)',
  `available_balance` DECIMAL(15,2) NOT NULL COMMENT 'Balance at request time',
  `currency` CHAR(3) DEFAULT 'ETB',

  -- Ethiopian Bank Details
  `bank_name` ENUM(
    'cbe',
    'awash',
    'dashen',
    'abyssinia',
    'nib',
    'cbe_birr',
    'telebirr',
    'other'
  ) NOT NULL,

  `bank_account_number` VARCHAR(100) NOT NULL,
  `account_holder_name` VARCHAR(100) NOT NULL,
  `bank_branch` VARCHAR(100),
  `bank_branch_city` VARCHAR(100),

  -- Workflow Status
  `status` ENUM(
    'pending',
    'approved',
    'processing',
    'completed',
    'rejected',
    'cancelled',
    'failed'
  ) DEFAULT 'pending',

  -- Workflow Timestamps
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` DATETIME NULL,
  `processed_at` DATETIME NULL,
  `completed_at` DATETIME NULL,
  `cancelled_at` DATETIME NULL,

  -- Admin Review
  `reviewed_by` BIGINT UNSIGNED NULL,
  `review_notes` TEXT,
  `rejection_reason` TEXT,

  -- Processing Details
  `processing_method` ENUM(
    'cbe_online',
    'cbe_branch',
    'telebirr',
    'other_bank_transfer'
  ) DEFAULT 'cbe_online',

  `processing_reference` VARCHAR(100),
  `processing_fee` DECIMAL(10,2) DEFAULT 0.00,
  `processing_notes` TEXT,

  -- Tax & Compliance
  `tax_deducted` BOOLEAN DEFAULT FALSE,
  `tax_amount` DECIMAL(10,2) DEFAULT 0.00,
  `tax_reference` VARCHAR(100),

  -- Security & Audit
  `ip_address` VARCHAR(45),
  `device_id` VARCHAR(255),
  `user_agent` TEXT,

  -- Metadata
  `meta_data` JSON DEFAULT NULL,

  -- Soft delete & timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,

  -- Foreign Keys
  CONSTRAINT `fk_payout_requests_organizer`
    FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  CONSTRAINT `fk_payout_requests_reviewed_by`
    FOREIGN KEY (`reviewed_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,

  -- Indexes
  INDEX `idx_organizer_id` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested_at` (`requested_at`),
  INDEX `idx_reviewed_by` (`reviewed_by`),
  INDEX `idx_bank_name` (`bank_name`),
  INDEX `idx_deleted_at` (`deleted_at`),

  -- Composite indexes (important)
  INDEX `idx_organizer_status` (`organizer_id`, `status`),
  INDEX `idx_status_requested_at` (`status`, `requested_at`),
  INDEX `idx_bank_status` (`bank_name`, `status`)

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Organizer payout requests with Ethiopian banking & Telebirr support';
