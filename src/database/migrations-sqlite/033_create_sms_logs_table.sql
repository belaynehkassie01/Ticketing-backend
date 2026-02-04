-- Converted from MySQL to SQLite
-- Original file: 033_create_sms_logs_table.sql
-- Migration: 033_create_sms_logs_table.sql
-- Purpose: Store Ethiopian SMS delivery logs (Ethio Telecom INTEGERegration)

CREATE TABLE IF NOT EXISTS sms_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- SMS identification
  sms_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'INTEGERernal message ID',
  provider_message_id VARCHAR(200) NULL COMMENT 'External provider ID',
  
  -- Recipient info (Ethiopian format)
  recipient_phone VARCHAR(20) NOT NULL COMMENT '0912345678 or +251912345678',
  recipient_name VARCHAR(100),
  recipient_user_id INTEGEREGER NULL,
  
  -- SMS content
  message_type VARCHAR(50) NOT NULL COMMENT 'otp, payment_confirmation, ticket_delivery, event_reminder, promotional, system, dispute_update',
  template_id VARCHAR(100) NULL,
  message_text TEXT NOT NULL,
  message_text_amharic TEXT,
  language TEXT DEFAULT 'am',
  unicode INTEGER DEFAULT FALSE COMMENT 'For Amharic/Unicode characters',
  character_count INTEGER,
  segments INTEGER DEFAULT 1,
  
  -- Ethiopian SMS provider
  gateway VARCHAR(50) DEFAULT 'ethio_telecom' COMMENT 'ethio_telecom, awash_sms, cbe_sms, other',
  route VARCHAR(50) DEFAULT 'transactional' COMMENT 'transactional, promotional',
  sender_id VARCHAR(20) DEFAULT 'ET-TICKETS',
  gateway_account VARCHAR(100) NULL COMMENT 'Which account/API key used',
  
  -- Delivery tracking
  status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, expired, rejected',
  delivery_status VARCHAR(100) NULL COMMENT 'Provider delivery status',
  delivery_report JSON COMMENT 'Full delivery report from gateway',
  attempt_count INTEGER DEFAULT 1,
  last_attempt_at TEXT NULL,
  error_code VARCHAR(50),
  error_message TEXT,
  
  -- Costs and billing (Ethiopian pricing)
  cost_per_sms REAL DEFAULT 0.10 COMMENT 'Cost in ETB per SMS',
  total_cost REAL DEFAULT 0.10,
  billing_month VARCHAR(7) NULL COMMENT 'YYYY-MM for billing reconciliation',
  is_billed INTEGER DEFAULT FALSE,
  
  -- Ethiopian network information
  city_id INTEGEREGER NULL,
  region VARCHAR(100) NULL,
  network_operator VARCHAR(50) NULL COMMENT 'Ethio Telecom, Safaricom Ethiopia, etc.',
  network_type VARCHAR(20) NULL COMMENT '2g, 3g, 4g, 5g',
  
  -- Timing
  scheduled_for TEXT NULL,
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  failed_at TEXT NULL,
  expires_at TEXT NULL,
  read_at TEXT NULL COMMENT 'If SMS was marked as read (if supported)',
  
  -- Related entities
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  notification_id INTEGEREGER NULL,
  otp_id INTEGEREGER NULL COMMENT 'If this SMS contains OTP',
  
  -- Metadata
  metadata JSON,
  audit_trail JSON,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  -- Foreign Keys
  FOREIGN KEY (recipient_user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (notification_id) REFERENCES notifications(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (otp_id) REFERENCES session_tokens(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_sms_id (sms_id), -- INDEX converted separately (recipient_phone), -- INDEX converted separately (recipient_user_id), -- INDEX converted separately (message_type), -- INDEX converted separately (status), -- INDEX converted separately (sent_at), -- INDEX converted separately (gateway), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (created_at), -- INDEX converted separately (network_operator), -- INDEX converted separately (language), -- INDEX converted separately (template_id), -- INDEX converted separately (billing_month),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_phone_format -- CHECK (REGEXP not supported in SQLite '^(09[0-9]{8}|\\+251[0-9]{9})$'),
  CONSTRAINTEGER chk_cost_non_negative CHECK (total_cost >= 0)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian SMS delivery logs with network and cost tracking';