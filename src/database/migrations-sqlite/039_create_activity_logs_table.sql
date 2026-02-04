-- Converted from MySQL to SQLite
-- Original file: 039_create_activity_logs_table.sql
-- Migration: 039_create_activity_logs_table.sql
-- Purpose: Store user activity logs for analytics and Ethiopian user behavior analysis

CREATE TABLE IF NOT EXISTS activity_logs (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- User identification
  user_id INTEGEREGER NOT NULL,
  session_id VARCHAR(100) NOT NULL,
  device_fingerprINTEGER VARCHAR(255) NULL COMMENT 'Browser/device fingerprINTEGER',
  
  -- Activity details
  activity_type VARCHAR(50) NOT NULL COMMENT 'page_view, button_click, form_submit, search, login, logout, ticket_purchase, event_view',
  activity_subtype VARCHAR(50) NULL COMMENT 'homepage_view, event_details_view, ticket_selection, payment_initiated',
  activity_description VARCHAR(500) NOT NULL,
  
  -- Page/Route information
  page_url VARCHAR(500) NOT NULL,
  page_title VARCHAR(200) NULL,
  route_name VARCHAR(100) NULL COMMENT 'Frontend route name',
  referrer_url VARCHAR(500),
  utm_source VARCHAR(100) NULL,
  utm_medium VARCHAR(100) NULL,
  utm_campaign VARCHAR(100) NULL,
  
  -- Device and browser info
  device_type VARCHAR(30) DEFAULT 'mobile' COMMENT 'mobile, tablet, desktop',
  device_model VARCHAR(100) NULL,
  browser VARCHAR(100),
  browser_version VARCHAR(50),
  os VARCHAR(100),
  os_version VARCHAR(50),
  screen_resolution VARCHAR(20) NULL COMMENT '1920x1080',
  
  -- Network information (Ethiopian context)
  city_id INTEGEREGER NULL,
  region VARCHAR(100) NULL,
  estimated_location VARCHAR(255),
  network_type VARCHAR(30) NULL COMMENT 'wifi, cellular_2g, cellular_3g, cellular_4g, unknown',
  network_speed_kbps INTEGER NULL,
  carrier VARCHAR(100) NULL COMMENT 'Ethio Telecom, Safaricom Ethiopia',
  
  -- Performance metrics
  page_load_time_ms INTEGER,
  time_on_page_ms INTEGER,
  scroll_depth_percentage INTEGEREGER NULL COMMENT '0-100',
  INTEGEReraction_count INTEGER DEFAULT 1,
  
  -- Application context
  app_version VARCHAR(20) NULL,
  platform VARCHAR(20) DEFAULT 'web' COMMENT 'web, android_app, ios_app',
  language TEXT DEFAULT 'am',
  
  -- Related entities
  related_event_id INTEGEREGER NULL,
  related_ticket_id INTEGEREGER NULL,
  related_payment_id INTEGEREGER NULL,
  related_organizer_id INTEGEREGER NULL,
  
  -- User journey
  funnel_step VARCHAR(50) NULL COMMENT 'awareness, consideration, conversion, retention',
  conversion_goal VARCHAR(100) NULL COMMENT 'ticket_purchase, organizer_signup, event_creation',
  is_conversion INTEGER DEFAULT FALSE,
  
  -- Error tracking
  error_occurred INTEGER DEFAULT FALSE,
  error_message TEXT,
  error_stack TEXT,
  
  -- Ethiopian market research
  user_segment VARCHAR(50) NULL COMMENT 'student, professional, tourist, organizer, business',
  price_sensitivity VARCHAR(20) NULL COMMENT 'low, medium, high',
  event_preference JSON NULL COMMENT 'Preferred event categories',
  
  -- Metadata
  metadata JSON,
  custom_attributes JSON,
  
  -- TEXTs
  activity_TEXT TEXT(6) NOT NULL DEFAULT CURRENT_TEXT(6),
  created_at TEXT DEFAULT CURRENT_TEXT,
  
  -- Foreign Keys
  FOREIGN KEY (user_id) REFERENCES users(id)
    ON DELETE CASCADE ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_event_id) REFERENCES events(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_ticket_id) REFERENCES individual_tickets(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_payment_id) REFERENCES payments(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_organizer_id) REFERENCES organizers(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes (optimized for Ethiopian user analytics)
  INDEX idx_user_id (user_id), -- INDEX converted separately (activity_type), -- INDEX converted separately (activity_TEXT), -- INDEX converted separately (page_url(100)), -- INDEX converted separately (city_id), -- INDEX converted separately (device_type), -- INDEX converted separately (network_type), -- INDEX converted separately (language), -- INDEX converted separately (session_id), -- INDEX converted separately (conversion_goal), -- INDEX converted separately (is_conversion), -- INDEX converted separately (related_event_id), -- INDEX converted separately (utm_source), -- INDEX converted separately (created_at),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_scroll_depth CHECK (scroll_depth_percentage IS NULL OR scroll_depth_percentage BETWEEN 0 AND 100),
  CONSTRAINTEGER chk_page_load_time CHECK (page_load_time_ms IS NULL OR page_load_time_ms >= 0)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='User activity logs for Ethiopian market analytics and user behavior tracking';