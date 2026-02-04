-- Converted from MySQL to SQLite
-- Original file: 035_create_push_notifications_table.sql
-- Migration: 035_create_push_notifications_table.sql
-- Purpose: Store push notification logs for Ethiopian mobile apps

CREATE TABLE IF NOT EXISTS push_notifications (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Push identification
  push_id VARCHAR(100) UNIQUE NOT NULL COMMENT 'INTEGERernal push ID',
  provider_push_id VARCHAR(200) NULL COMMENT 'External provider ID (FCM, APNS)',
  
  -- Recipient info
  user_id INTEGEREGER NOT NULL,
  device_token VARCHAR(255) NOT NULL,
  device_type VARCHAR(20) NOT NULL COMMENT 'ios, android, web',
  app_version VARCHAR(20) NULL,
  os_version VARCHAR(20) NULL,
  
  -- Push content
  push_type VARCHAR(50) NOT NULL COMMENT 'payment, ticket, event, system, promotional, reminder',
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  body TEXT NOT NULL,
  body_amharic TEXT,
  data JSON COMMENT 'Additional data payload',
  badge_count INTEGER NULL,
  sound VARCHAR(50) DEFAULT 'default',
  
  -- Ethiopian context
  language TEXT DEFAULT 'am',
  city_id INTEGEREGER NULL,
  
  -- Provider info
  provider VARCHAR(50) DEFAULT 'fcm' COMMENT 'fcm, apns, web_push, other',
  provider_config VARCHAR(100) NULL COMMENT 'Which config/account used',
  
  -- Delivery tracking
  status VARCHAR(50) DEFAULT 'pending' COMMENT 'pending, queued, sent, delivered, failed, device_not_registered',
  delivery_report JSON COMMENT 'Provider delivery report',
  attempt_count INTEGER DEFAULT 1,
  last_attempt_at TEXT NULL,
  failure_reason TEXT,
  error_code VARCHAR(50),
  
  -- Engagement tracking
  received_at TEXT NULL,
  opened_at TEXT NULL,
  dismissed_at TEXT NULL,
  action_taken VARCHAR(50) NULL COMMENT 'opened, dismissed, custom_action',
  custom_action VARCHAR(100) NULL,
  
  -- Timing
  scheduled_for TEXT NULL,
  sent_at TEXT NULL,
  delivered_at TEXT NULL,
  failed_at TEXT NULL,
  expires_at TEXT NULL,
  
  -- Related entities
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  notification_id INTEGEREGER NULL,
  
  -- Network info (Ethiopian context)
  network_type VARCHAR(20) NULL COMMENT 'wifi, cellular_2g, cellular_3g, cellular_4g, unknown',
  battery_level INTEGEREGER NULL COMMENT 'Percentage 0-100',
  
  -- Metadata
  metadata JSON,
  audit_trail JSON,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (notification_id) REFERENCES notifications(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_push_id (push_id), -- INDEX converted separately (user_id), -- INDEX converted separately (device_token(100)), -- INDEX converted separately (device_type), -- INDEX converted separately (push_type), -- INDEX converted separately (status), -- INDEX converted separately (sent_at), -- INDEX converted separately (provider), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (created_at), -- INDEX converted separately (language), -- INDEX converted separately (app_version),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_device_type CHECK (device_type IN ('ios', 'android', 'web')),
  CONSTRAINTEGER chk_battery_level CHECK (battery_level IS NULL OR battery_level BETWEEN 0 AND 100)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Push notification logs for Ethiopian mobile applications';