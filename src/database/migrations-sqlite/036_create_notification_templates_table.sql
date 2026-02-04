-- Converted from MySQL to SQLite
-- Original file: 036_create_notification_templates_table.sql
-- Migration: 036_create_notification_templates_table.sql
-- Purpose: Store notification templates for Ethiopian localized messaging

CREATE TABLE IF NOT EXISTS notification_templates (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Template identification
  template_code VARCHAR(100) UNIQUE NOT NULL COMMENT 'SMS_OTP_VERIFICATION, EMAIL_TICKET_CONFIRMATION',
  template_name VARCHAR(200) NOT NULL,
  template_name_amharic VARCHAR(200),
  
  -- Template type
  template_type VARCHAR(20) NOT NULL COMMENT 'sms, email, push, in_app',
  category VARCHAR(50) NOT NULL COMMENT 'authentication, transactional, marketing, reminder, alert',
  channel VARCHAR(20) NOT NULL COMMENT 'sms, email, push, in_app, all',
  
  -- Content in English
  subject_en VARCHAR(200) NULL COMMENT 'For email templates',
  body_en TEXT NOT NULL,
  short_body_en VARCHAR(500) NULL COMMENT 'For SMS/push preview',
  action_label_en VARCHAR(100) NULL,
  footer_en TEXT NULL COMMENT 'Email footer',
  
  -- Content in Amharic
  subject_am VARCHAR(200) NULL,
  body_am TEXT NOT NULL,
  short_body_am VARCHAR(500) NULL,
  action_label_am VARCHAR(100) NULL,
  footer_am TEXT NULL,
  
  -- Other Ethiopian languages (optional)
  subject_or VARCHAR(200) NULL,
  body_or TEXT NULL,
  subject_ti VARCHAR(200) NULL,
  body_ti TEXT NULL,
  subject_so VARCHAR(200) NULL,
  body_so TEXT NULL,
  
  -- Template variables
  variables JSON COMMENT 'Array of variable names: {{user_name}}, {{event_title}}',
  variable_descriptions JSON COMMENT 'Descriptions of each variable',
  default_values JSON COMMENT 'Default values for variables',
  
  -- Ethiopian context
  default_language TEXT DEFAULT 'am',
  city_specific INTEGER DEFAULT FALSE,
  region_specific INTEGER DEFAULT FALSE,
  applicable_cities JSON NULL COMMENT 'Array of city_ids if city_specific',
  applicable_regions JSON NULL COMMENT 'Array of regions if region_specific',
  
  -- SMS specific
  sms_unicode_required INTEGER DEFAULT FALSE,
  sms_max_length INTEGER DEFAULT 160,
  sms_sender_id VARCHAR(20) NULL,
  
  -- Email specific
  email_layout VARCHAR(50) NULL COMMENT 'basic, receipt, newsletter, alert',
  email_preheader VARCHAR(200) NULL,
  email_cc JSON NULL COMMENT 'Array of CC emails',
  email_bcc JSON NULL COMMENT 'Array of BCC emails',
  
  -- Push specific
  push_icon VARCHAR(100) NULL,
  push_color VARCHAR(7) NULL COMMENT '#RRGGBB',
  push_priority VARCHAR(20) DEFAULT 'normal' COMMENT 'normal, high',
  
  -- In-App specific
  in_app_icon VARCHAR(100) NULL,
  in_app_duration INTEGER NULL COMMENT 'Seconds to display',
  in_app_position VARCHAR(20) DEFAULT 'top' COMMENT 'top, bottom, center',
  
  -- Status and versioning
  version VARCHAR(20) DEFAULT '1.0.0',
  is_active INTEGER DEFAULT TRUE,
  is_system INTEGER DEFAULT FALSE COMMENT 'System templates cannot be deleted',
  requires_approval INTEGER DEFAULT TRUE,
  approved_by INTEGEREGER NULL,
  approved_at TEXT NULL,
  
  -- Usage tracking
  usage_count INTEGER DEFAULT 0,
  last_used_at TEXT NULL,
  success_rate REAL DEFAULT 0.00 COMMENT 'Delivery success percentage',
  
  -- Audit
  created_by INTEGEREGER NOT NULL,
  updated_by INTEGEREGER NULL,
  audit_trail JSON,
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_template_code (template_code), -- INDEX converted separately (template_type), -- INDEX converted separately (category), -- INDEX converted separately (is_active), -- INDEX converted separately (is_system), -- INDEX converted separately (default_language), -- INDEX converted separately (created_by), -- INDEX converted separately (deleted_at), -- INDEX converted separately (version),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_template_type CHECK (template_type IN ('sms', 'email', 'push', 'in_app')),
  CONSTRAINTEGER chk_success_rate CHECK (success_rate >= 0 AND success_rate <= 100)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Notification templates for Ethiopian localized messaging across all channels';