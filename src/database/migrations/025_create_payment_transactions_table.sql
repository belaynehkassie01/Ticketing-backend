-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs for payment gateway interactions
-- Ethiopian Context: Logs Telebirr, CBE, and other payment gateway interactions
-- ============================================

CREATE TABLE IF NOT EXISTS `payment_transactions` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal transaction log ID',
  
  -- Reference to main payment
  `payment_id` BIGINT UNSIGNED NOT NULL COMMENT 'References payments.id',
  `payment_reference` VARCHAR(100) NOT NULL COMMENT 'Copy of payments.payment_reference for quick lookup',
  
  -- Transaction Type
  `transaction_type` ENUM('payment', 'refund', 'adjustment', 'reversal', 'fee', 'commission') 
    DEFAULT 'payment' COMMENT 'Type of transaction',
  `transaction_subtype` VARCHAR(50) NULL COMMENT 'Subtype: telebirr_qr, cbe_transfer, etc.',
  
  -- Financial Details
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'Transaction amount in ETB',
  `currency` CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Currency (always ETB)',
  `exchange_rate` DECIMAL(10,6) DEFAULT 1.000000 COMMENT 'Exchange rate if different currency',
  
  -- Ethiopian Payment Gateway Details
  `gateway` VARCHAR(50) NOT NULL COMMENT 'Gateway: telebirr, cbe, awash, dashen, etc.',
  `gateway_version` VARCHAR(20) NULL COMMENT 'Gateway API version',
  `gateway_session_id` VARCHAR(100) NULL COMMENT 'Gateway session identifier',
  
  -- Transaction Status & Flow
  `status` ENUM('initiated', 'pending', 'processing', 'completed', 'failed', 'cancelled', 'timeout', 'retrying') 
    DEFAULT 'initiated' COMMENT 'Transaction status',
  `error_code` VARCHAR(50) NULL COMMENT 'Gateway error code',
  `error_message` VARCHAR(500) NULL COMMENT 'Gateway error message',
  
  -- External References (Critical for Ethiopian banks)
  `external_transaction_id` VARCHAR(100) NULL COMMENT 'External transaction ID (gateway provided)',
  `external_reference` VARCHAR(100) NULL COMMENT 'External reference number',
  `external_status` VARCHAR(50) NULL COMMENT 'External status from gateway',
  `external_status_message` VARCHAR(500) NULL COMMENT 'External status message',
  
  -- Request/Response Data (For debugging Ethiopian payment issues)
  `request_endpoint` VARCHAR(500) NULL COMMENT 'API endpoint called',
  `request_method` VARCHAR(10) DEFAULT 'POST' COMMENT 'HTTP method',
  `request_headers` JSON COMMENT 'HTTP request headers',
  `request_body` JSON COMMENT 'Request payload sent to gateway',
  `request_timestamp` DATETIME NULL COMMENT 'When request was sent',
  
  `response_status_code` INT NULL COMMENT 'HTTP status code received',
  `response_headers` JSON COMMENT 'HTTP response headers',
  `response_body` JSON COMMENT 'Raw response from gateway',
  `response_timestamp` DATETIME NULL COMMENT 'When response was received',
  
  -- Telebirr-specific fields
  `telebirr_qr_id` VARCHAR(100) NULL COMMENT 'Telebirr QR identifier',
  `telebirr_order_id` VARCHAR(100) NULL COMMENT 'Telebirr order ID',
  `telebirr_merchant_id` VARCHAR(100) NULL COMMENT 'Telebirr merchant ID',
  
  -- CBE-specific fields
  `cbe_transaction_id` VARCHAR(100) NULL COMMENT 'CBE transaction ID',
  `cbe_branch_code` VARCHAR(50) NULL COMMENT 'CBE branch code',
  `cbe_teller_id` VARCHAR(50) NULL COMMENT 'CBE teller ID',
  `cbe_receipt_number` VARCHAR(100) NULL COMMENT 'CBE receipt number',
  
  -- Retry Logic (Important for Ethiopian network issues)
  `retry_count` INT UNSIGNED DEFAULT 0 COMMENT 'Number of retry attempts',
  `max_retries` INT UNSIGNED DEFAULT 3 COMMENT 'Maximum retry attempts',
  `retry_reason` VARCHAR(200) NULL COMMENT 'Reason for retry',
  `next_retry_at` DATETIME NULL COMMENT 'When to retry',
  
  -- Validation & Security
  `is_validated` BOOLEAN DEFAULT FALSE COMMENT 'Whether response was validated',
  `validation_errors` JSON COMMENT 'Validation errors if any',
  `signature_verified` BOOLEAN DEFAULT FALSE COMMENT 'Whether gateway signature was verified',
  `ip_address` VARCHAR(45) NULL COMMENT 'IP address that made the request',
  
  -- Performance Metrics (For Ethiopian network monitoring)
  `response_time_ms` INT UNSIGNED NULL COMMENT 'Response time in milliseconds',
  `network_latency_ms` INT UNSIGNED NULL COMMENT 'Network latency',
  `processing_time_ms` INT UNSIGNED NULL COMMENT 'Gateway processing time',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `initiated_at` DATETIME NULL COMMENT 'When transaction was initiated',
  `processed_at` DATETIME NULL COMMENT 'When gateway processed it',
  `completed_at` DATETIME NULL COMMENT 'When transaction completed',
  `failed_at` DATETIME NULL COMMENT 'When transaction failed',
  
  -- Soft delete
  `deleted_at` DATETIME NULL COMMENT 'Soft delete timestamp',
  
  -- Foreign Keys
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
  
  -- Indexes (Optimized for Ethiopian payment query patterns)
  INDEX `idx_payment_id` (`payment_id`),
  INDEX `idx_payment_reference` (`payment_reference`),
  INDEX `idx_status` (`status`),
  INDEX `idx_gateway` (`gateway`),
  INDEX `idx_external_id` (`external_transaction_id`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_completed_at` (`completed_at`),
  INDEX `idx_retry` (`retry_count`, `next_retry_at`),
  INDEX `idx_gateway_status` (`gateway`, `status`, `created_at`),
  
  -- Composite indexes for common queries
  INDEX `idx_payment_gateway` (`payment_id`, `gateway`, `created_at`),
  INDEX `idx_external_reference` (`external_transaction_id`, `external_reference`),
  INDEX `idx_status_date` (`status`, `created_at`),
  INDEX `idx_retry_status` (`retry_count`, `status`, `next_retry_at`),
  
  -- Unique constraints
  UNIQUE INDEX `uq_external_transaction` (`gateway`, `external_transaction_id`),
  UNIQUE INDEX `uq_telebirr_order` (`telebirr_order_id`),
  UNIQUE INDEX `uq_cbe_receipt` (`cbe_receipt_number`),
  
  -- Business Logic Constraints
  CONSTRAINT `chk_amount_non_zero` CHECK (`amount` != 0),
  CONSTRAINT `chk_retry_count` CHECK (`retry_count` >= 0),
  CONSTRAINT `chk_response_time` CHECK (`response_time_ms` IS NULL OR `response_time_ms` >= 0),
  CONSTRAINT `chk_currency_etb` CHECK (`currency` = 'ETB'),
  CONSTRAINT `chk_timestamps_order` CHECK (
    (`initiated_at` IS NULL OR `initiated_at` <= COALESCE(`processed_at`, `initiated_at`)) AND
    (`processed_at` IS NULL OR `processed_at` <= COALESCE(`completed_at`, `processed_at`))
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTO_INCREMENT=1000000
  COMMENT='Detailed transaction logs for Ethiopian payment gateways. One payment can have multiple transactions (initiate, confirm, webhook).';