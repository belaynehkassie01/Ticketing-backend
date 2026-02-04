-- Converted from MySQL to SQLite
-- Original file: 032_create_notifications_table.sql
-- Migration: 032_create_notifications_table.sql
-- Purpose: Store user notifications with Ethiopian SMS/Email/Push support

CREATE TABLE IF NOT EXISTS notifications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Notification identification
  notification_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'NOTIF-ET-2024-001',
  user_id INTEGEREGER NOT NULL,
  
  -- Notification metadata
  notification_type VARCHAR(50) NOT NULL COMMENT 'payment, ticket, event, system, promotional, admin, otp, reminder, security, dispute',
  category VARCHAR(50) NULL COMMENT 'transactional, marketing, security, reminder, alert',
  channel VARCHAR(20) NOT NULL COMMENT 'in_app, sms, email, push, all',
  
  -- Content (Ethiopian bilingual support)
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  message TEXT NOT NULL,
  message_amharic TEXT,
  short_message VARCHAR(500) NULL COMMENT 'For SMS/push preview',
  short_message_amharic VARCHAR(500),
  
  -- Action and navigation
  action_url VARCHAR(500),
  action_label VARCHAR(100),
  action_label_amharic VARCHAR(100),
  action_data JSON,
  deep_link VARCHAR(500) NULL COMMENT 'app://ticket/123',
  
  -- Template reference
  template_id VARCHAR(100) NULL,
  template_version VARCHAR(20) NULL,
  variables JSON COMMENT 'Template variables replaced',
  
  -- Ethiopian context
  preferred_language TEXT DEFAULT 'am',
  city_id INTEGEREGER NULL,
  
  -- Delivery status per channel
  in_app_status VARCHAR(30) DEFAULT 'pending' COMMENT 'pending, sent, delivered, read, failed',
  sms_status VARCHAR(30) DEFAULT 'pending',
  email_status VARCHAR(30) DEFAULT 'pending',
  push_status VARCHAR(30) DEFAULT 'pending',
  
  -- Ethiopian SMS specific
  sms_provider VARCHAR(50) DEFAULT 'ethio_telecom' COMMENT 'ethio_telecom, awash_sms, cbe_sms',
  sms_message_id VARCHAR(100) NULL,
  sms_unicode INTEGER DEFAULT FALSE,
  sms_retry_count INTEGER DEFAULT 0,
  
  -- Email specific
  email_subject VARCHAR(200) NULL,
  email_message_id VARCHAR(200) NULL,
  email_retry_count INTEGER DEFAULT 0,
  
  -- Push specific
  device_token VARCHAR(255) NULL,
  device_type VARCHAR(20) NULL COMMENT 'ios, android, web',
  push_retry_count INTEGER DEFAULT 0,
  
  -- Status tracking
  is_read INTEGER DEFAULT FALSE,
  is_delivered INTEGER DEFAULT FALSE,
  is_archived INTEGER DEFAULT FALSE,
  delivery_status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, bounced, opened, clicked',
  failure_reason TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  
  -- Priority and scheduling
  priority VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  scheduled_for TEXT NULL,
  expires_at TEXT NULL,
  read_at TEXT NULL,
  delivered_at TEXT NULL,
  opened_at TEXT NULL,
  clicked_at TEXT NULL,
  failed_at TEXT NULL,
  
  -- Related entities
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  metadata JSON,
  
  -- Performance tracking
  open_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  last_opened_at TEXT NULL,
  last_clicked_at TEXT NULL,
  
  -- Cost tracking (Ethiopian SMS/Email costs)
  sms_cost REAL DEFAULT 0.10 COMMENT 'Cost in ETB per SMS',
  email_cost REAL DEFAULT 0.00,
  total_cost REAL DEFAULT 0.00,
  
  -- Audit
  audit_trail JSON,
  created_by INTEGEREGER NULL COMMENT 'System or admin who triggered',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_notification_code (notification_code), -- INDEX converted separately (user_id), -- INDEX converted separately (notification_type), -- INDEX converted separately (channel), -- INDEX converted separately (is_read), -- INDEX converted separately (delivery_status), -- INDEX converted separately (scheduled_for), -- INDEX converted separately (expires_at), -- INDEX converted separately (created_at), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (template_id), -- INDEX converted separately (preferred_language), -- INDEX converted separately (sms_provider), -- INDEX converted separately (deleted_at),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_channel_values CHECK (channel IN ('in_app', 'sms', 'email', 'push', 'all')),
  CONSTRAINTEGER chk_priority_values CHECK (priority IN ('low', 'medium', 'high', 'urgent'))
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian notifications system with SMS, Email, and Push support';