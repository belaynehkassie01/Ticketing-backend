-- Converted from MySQL to SQLite
-- Original file: 041_create_webhook_logs_table.sql
-- Migration: 041_create_webhook_logs_table.sql
-- Purpose: Store webhook logs

CREATE TABLE IF NOT EXISTS webhook_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  webhook_type TEXT NOT NULL,
  endpoINTEGER_url VARCHAR(500) NOT NULL,
  request_headers JSON COMMENT 'HTTP headers sent',
  request_body TEXT,
  request_method VARCHAR(10) DEFAULT 'POST',
  response_status INTEGER,
  response_headers JSON COMMENT 'HTTP headers received',
  response_body TEXT,
  response_time_ms INTEGER,
  status TEXT DEFAULT 'pending',
  retry_count INTEGER DEFAULT 0,
  error_message TEXT,
  next_retry_at TEXT NULL,
  related_id INTEGEREGER,
  related_type VARCHAR(50),
  created_at TEXT DEFAULT CURRENT_TEXT,
  sent_at TEXT NULL,
  delivered_at TEXT NULL, -- INDEX converted separately (webhook_type), -- INDEX converted separately (status), -- INDEX converted separately (created_at), -- INDEX converted separately (related_type, related_id), -- INDEX converted separately (next_retry_at), -- INDEX converted separately (endpoINTEGER_url(100)), -- INDEX converted separately (response_status), -- INDEX converted separately (sent_at),
  
  CONSTRAINTEGER chk_response_time CHECK (response_time_ms IS NULL OR response_time_ms >= 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0),
  CONSTRAINTEGER chk_response_status CHECK (response_status IS NULL OR response_status BETWEEN 100 AND 599)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;