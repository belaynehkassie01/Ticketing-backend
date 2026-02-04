-- Converted from MySQL to SQLite
-- Original file: 040_create_offline_sync_logs_table.sql
-- Migration: 040_create_offline_sync_logs_table.sql
-- Purpose: Store offline sync logs

CREATE TABLE IF NOT EXISTS offline_sync_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  device_id VARCHAR(255) NOT NULL,
  user_id INTEGEREGER NOT NULL,
  device_type TEXT NOT NULL,
  app_version VARCHAR(20),
  sync_type TEXT NOT NULL,
  records_count INTEGER DEFAULT 0,
  data_size_kb INTEGER,
  status TEXT DEFAULT 'pending',
  started_at TEXT NOT NULL,
  completed_at TEXT NULL,
  duration_ms INTEGER,
  connection_type TEXT DEFAULT 'unknown',
  network_speed_kbps INTEGER,
  city_id INTEGEREGER NULL,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT, -- INDEX converted separately (device_id), -- INDEX converted separately (user_id), -- INDEX converted separately (status), -- INDEX converted separately (started_at), -- INDEX converted separately (sync_type), -- INDEX converted separately (city_id), -- INDEX converted separately (connection_type), -- INDEX converted separately (completed_at),
  
  CONSTRAINTEGER chk_records_count CHECK (records_count >= 0),
  CONSTRAINTEGER chk_data_size CHECK (data_size_kb IS NULL OR data_size_kb >= 0),
  CONSTRAINTEGER chk_duration CHECK (duration_ms IS NULL OR duration_ms >= 0),
  CONSTRAINTEGER chk_network_speed CHECK (network_speed_kbps IS NULL OR network_speed_kbps >= 0),
  CONSTRAINTEGER chk_retry_count CHECK (retry_count >= 0)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;