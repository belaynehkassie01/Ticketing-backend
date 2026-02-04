-- Converted from MySQL to SQLite
-- Original file: 025_create_payment_transactions_table.sql
-- ============================================
-- TABLE: payment_transactions
-- Purpose: Store detailed transaction logs for payment gateway INTEGEReractions
-- Ethiopian Context: Logs Telebirr, CBE, and other payment gateway INTEGEReractions
-- ============================================

CREATE TABLE IF NOT EXISTS payment_transactions (
  -- Primary identifier
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT COMMENT 'INTEGERernal transaction log ID',
  
  -- Reference to main payment
  payment_id INTEGEREGER NOT NULL COMMENT 'References payments.id',
  payment_reference VARCHAR(100) NOT NULL COMMENT 'Copy of payments.payment_reference for quick lookup',
  
  -- Transaction Type
  transaction_type TEXT 
    DEFAULT 'payment' COMMENT 'Type of transaction',
  transaction_subtype VARCHAR(50) NULL COMMENT 'Subtype: telebirr_qr, cbe_transfer, etc.',
  
  -- Financial Details
  amount REAL NOT NULL COMMENT 'Transaction amount in ETB',
  currency CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Currency (always ETB)',
  exchange_rate REAL DEFAULT 1.000000 COMMENT 'Exchange rate if different currency',
  
  -- Ethiopian Payment Gateway Details
  gateway VARCHAR(50) NOT NULL COMMENT 'Gateway: telebirr, cbe, awash, dashen, etc.',
  gateway_version VARCHAR(20) NULL COMMENT 'Gateway API version',
  gateway_session_id VARCHAR(100) NULL COMMENT 'Gateway session identifier',
  
  -- Transaction Status & Flow
  status TEXT 
    DEFAULT 'initiated' COMMENT 'Transaction status',
  error_code VARCHAR(50) NULL COMMENT 'Gateway error code',
  error_message VARCHAR(500) NULL COMMENT 'Gateway error message',
  
  -- External References (Critical for Ethiopian banks)
  external_transaction_id VARCHAR(100) NULL COMMENT 'External transaction ID (gateway provided)',
  external_reference VARCHAR(100) NULL COMMENT 'External reference number',
  external_status VARCHAR(50) NULL COMMENT 'External status from gateway',
  external_status_message VARCHAR(500) NULL COMMENT 'External status message',
  
  -- Request/Response Data (For debugging Ethiopian payment issues)
  request_endpoINTEGER VARCHAR(500) NULL COMMENT 'API endpoINTEGER called',
  request_method VARCHAR(10) DEFAULT 'POST' COMMENT 'HTTP method',
  request_headers JSON COMMENT 'HTTP request headers',
  request_body JSON COMMENT 'Request payload sent to gateway',
  request_TEXT TEXT NULL COMMENT 'When request was sent',
  
  response_status_code INTEGER NULL COMMENT 'HTTP status code received',
  response_headers JSON COMMENT 'HTTP response headers',
  response_body JSON COMMENT 'Raw response from gateway',
  response_TEXT TEXT NULL COMMENT 'When response was received',
  
  -- Telebirr-specific fields
  telebirr_qr_id VARCHAR(100) NULL COMMENT 'Telebirr QR identifier',
  telebirr_order_id VARCHAR(100) NULL COMMENT 'Telebirr order ID',
  telebirr_merchant_id VARCHAR(100) NULL COMMENT 'Telebirr merchant ID',
  
  -- CBE-specific fields
  cbe_transaction_id VARCHAR(100) NULL COMMENT 'CBE transaction ID',
  cbe_branch_code VARCHAR(50) NULL COMMENT 'CBE branch code',
  cbe_teller_id VARCHAR(50) NULL COMMENT 'CBE teller ID',
  cbe_receipt_number VARCHAR(100) NULL COMMENT 'CBE receipt number',
  
  -- Retry Logic (Important for Ethiopian network issues)
  retry_count INTEGEREGER DEFAULT 0 COMMENT 'Number of retry attempts',
  max_retries INTEGEREGER DEFAULT 3 COMMENT 'Maximum retry attempts',
  retry_reason VARCHAR(200) NULL COMMENT 'Reason for retry',
  next_retry_at TEXT NULL COMMENT 'When to retry',
  
  -- Validation & Security
  is_validated INTEGER DEFAULT FALSE COMMENT 'Whether response was validated',
  validation_errors JSON COMMENT 'Validation errors if any',
  signature_verified INTEGER DEFAULT FALSE COMMENT 'Whether gateway signature was verified',
  ip_address VARCHAR(45) NULL COMMENT 'IP address that made the request',
  
  -- Performance Metrics (For Ethiopian network monitoring)
  response_time_ms INTEGEREGER NULL COMMENT 'Response time in milliseconds',
  network_latency_ms INTEGEREGER NULL COMMENT 'Network latency',
  processing_time_ms INTEGEREGER NULL COMMENT 'Gateway processing time',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  initiated_at TEXT NULL COMMENT 'When transaction was initiated',
  processed_at TEXT NULL COMMENT 'When gateway processed it',
  completed_at TEXT NULL COMMENT 'When transaction completed',
  failed_at TEXT NULL COMMENT 'When transaction failed',
  
  -- Soft delete
  deleted_at TEXT NULL COMMENT 'Soft delete TEXT',
  
  -- Foreign Keys
  FOREIGN KEY (payment_id) REFERENCES payments(id) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
  
  -- Indexes (Optimized for Ethiopian payment query patterns)
  INDEX idx_payment_id (payment_id), -- INDEX converted separately (payment_reference), -- INDEX converted separately (status), -- INDEX converted separately (gateway), -- INDEX converted separately (external_transaction_id), -- INDEX converted separately (created_at), -- INDEX converted separately (completed_at), -- INDEX converted separately (retry_count, next_retry_at), -- INDEX converted separately (gateway, status, created_at),
  
  -- Composite indexes for common queries
  INDEX idx_payment_gateway (payment_id, gateway, created_at), -- INDEX converted separately (external_transaction_id, external_reference), -- INDEX converted separately (status, created_at), -- INDEX converted separately (retry_count, status, next_retry_at),
  
  -- Unique constraINTEGERs
  UNIQUE INDEX uq_external_transaction (gateway, external_transaction_id), -- UNIQUE INDEX converted separately (telebirr_order_id), -- UNIQUE INDEX converted separately (cbe_receipt_number),
  
  -- Business Logic ConstraINTEGERs
  CONSTRAINTEGER chk_amount_non_zero CHECK (amount != 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0),
  CONSTRAINTEGER chk_response_time CHECK (response_time_ms IS NULL OR response_time_ms >= 0),
  CONSTRAINTEGER chk_currency_etb CHECK (currency = 'ETB'),
  CONSTRAINTEGER chk_TEXTs_order CHECK (
    (initiated_at IS NULL OR initiated_at <= COALESCE(processed_at, initiated_at)) AND
    (processed_at IS NULL OR processed_at <= COALESCE(completed_at, processed_at))
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTOINCREMENT=1000000
  COMMENT='Detailed transaction logs for Ethiopian payment gateways. One payment can have multiple transactions (initiate, confirm, webhook).';