-- Converted from MySQL to SQLite
-- Original file: 034_create_email_logs_table.sql
-- Migration: 034_create_email_logs_table.sql
-- Purpose: Store email delivery logs with Ethiopian localization support

CREATE TABLE IF NOT EXISTS email_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Email identification
  email_id VARCHAR(200) UNIQUE NOT NULL COMMENT 'INTEGERernal email ID',
  provider_message_id VARCHAR(200) NULL COMMENT 'External provider message ID',
  
  -- Recipient info
  recipient_email VARCHAR(100) NOT NULL,
  recipient_name VARCHAR(100),
  recipient_user_id INTEGEREGER NULL,
  
  -- Email content
  email_type VARCHAR(50) NOT NULL COMMENT 'payment_confirmation, ticket_delivery, event_reminder, promotional, system, otp, welcome, password_reset',
  template_id VARCHAR(100) NULL,
  template_version VARCHAR(20) NULL,
  subject VARCHAR(200) NOT NULL,
  subject_amharic VARCHAR(200),
  language TEXT DEFAULT 'en',
  variables JSON COMMENT 'Template variables replaced',
  
  -- Email provider
  provider VARCHAR(50) DEFAULT 'smtp' COMMENT 'smtp, sendgrid, mailgun, aws_ses, ethio_telecom_email',
  sender_email VARCHAR(100) NOT NULL,
  sender_name VARCHAR(100) NOT NULL,
  reply_to VARCHAR(100) NULL,
  
  -- Delivery tracking
  status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, opened, clicked, bounced, failed, spam_reported',
  delivery_report JSON COMMENT 'Full delivery report from provider',
  attempt_count INTEGER DEFAULT 1,
  last_attempt_at TEXT NULL,
  error_code VARCHAR(50),
  error_message TEXT,
  
  -- Engagement tracking
  open_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  first_opened_at TEXT NULL,
  last_opened_at TEXT NULL,
  first_clicked_at TEXT NULL,
  last_clicked_at TEXT NULL,
  unsubscribe_clicked INTEGER DEFAULT FALSE,
  spam_reported INTEGER DEFAULT FALSE,
  
  -- Timing
  scheduled_for TEXT NULL,
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  bounced_at TEXT NULL,
  failed_at TEXT NULL,
  
  -- Related entities
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  notification_id INTEGEREGER NULL,
  
  -- Ethiopian context
  city_id INTEGEREGER NULL,
  recipient_timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  
  -- Cost tracking
  email_cost REAL DEFAULT 0.00 COMMENT 'Cost in ETB',
  is_billed INTEGER DEFAULT FALSE,
  
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
  
  -- Indexes
  INDEX idx_email_id (email_id), -- INDEX converted separately (recipient_email), -- INDEX converted separately (recipient_user_id), -- INDEX converted separately (email_type), -- INDEX converted separately (status), -- INDEX converted separately (sent_at), -- INDEX converted separately (provider), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (created_at), -- INDEX converted separately (language), -- INDEX converted separately (template_id),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_email_format -- CHECK (REGEXP not supported in SQLite '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
  CONSTRAINTEGER chk_cost_non_negative CHECK (email_cost >= 0)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Email delivery logs with Ethiopian localization and engagement tracking';