-- Converted from MySQL to SQLite
-- Original file: 010_create_admin_actions_table.sql
-- Migration: 010_create_admin_actions_table.sql
-- Description: Store administrative action logs for audit trail and compliance
-- Dependencies: Requires users table (admin_id FK)
-- Best Practices: Ethiopian timezone handled in app, no dangerous defaults, clear JSON structure

-- ============================================
-- TABLE: admin_actions
-- Purpose: Audit trail of all administrative actions for compliance, security, and accountability
-- Ethiopian Context: Local timezone tracking via application logic
-- ============================================

CREATE TABLE IF NOT EXISTS admin_actions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Admin Information (historical snapshot - application must provide)
  admin_id INTEGEREGER NOT NULL COMMENT 'User who performed the action',
  admin_role_at_time TEXT NOT NULL COMMENT 'Role at time of action (application must provide)',
  
  -- Action Details
  action_type TEXT NOT NULL,
  
  action_name VARCHAR(100) NOT NULL,
  action_description TEXT,
  
  -- Target Information (application rule: if target_id exists, target_type must be set)
  target_type TEXT DEFAULT NULL COMMENT 'Must be set if target_id is provided',
  
  target_id INTEGEREGER DEFAULT NULL,
  target_name VARCHAR(200),
  
  -- Change Tracking (Before/After) - Clear JSON structure
  previous_values JSON COMMENT '{"field_name": "old_value", ...} - Snapshot before change',
  new_values JSON COMMENT '{"field_name": "new_value", ...} - Snapshot after change',
  changed_fields JSON COMMENT '["field1", "field2", ...] - Array of modified field names',
  
  -- Action Metadata
  requires_approval INTEGER DEFAULT FALSE COMMENT 'Sensitive actions requiring supervisor approval',
  approved_by INTEGEREGER NULL COMMENT 'Supervisor who approved the action',
  approved_at TEXT NULL,
  approval_notes TEXT,
  
  requires_review INTEGER DEFAULT FALSE COMMENT 'Actions that need periodic review',
  reviewed_by INTEGEREGER NULL,
  reviewed_at TEXT NULL,
  review_notes TEXT,
  
  -- Ethiopian Context (Application sets local time)
  performed_at_local TEXT NULL COMMENT 'Local time in Africa/Addis_Ababa (set by application)',
  performed_in_city_id INTEGEREGER NULL COMMENT 'City where action was performed',
  performed_from_ip VARCHAR(45),
  
  -- Device & Session Information
  device_id VARCHAR(255),
  device_type TEXT DEFAULT 'desktop',
  session_id VARCHAR(100),
  user_agent TEXT,
  browser_fingerprINTEGER TEXT,
  
  -- Status & Impact
  status TEXT DEFAULT 'completed',
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  
  impact_level TEXT DEFAULT 'medium',
  affected_users_count INTEGER DEFAULT 1,
  financial_impact_etb REAL DEFAULT 0.00,
  
  -- Related Entities
  related_actions JSON COMMENT 'Array of related action IDs: [123, 456, ...]',
  batch_id VARCHAR(100) COMMENT 'For bulk operations',
  
  -- Compliance & Auditing
  compliance_reference VARCHAR(100),
  audit_trail_id VARCHAR(100),
  gdpr_impact INTEGER DEFAULT FALSE,
  requires_notification INTEGER DEFAULT FALSE,
  
  -- Metadata
  meta_data JSON DEFAULT NULL,
  tags JSON DEFAULT NULL COMMENT 'Tags for categorization and search: ["financial", "urgent", ...]',
  
  -- TEXTs (Server UTC)
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  archived_at TEXT NULL COMMENT 'For GDPR compliance archiving',
  
  -- Foreign Keys (Application will enforce consistency rules)
  FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (reviewed_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (performed_in_city_id) REFERENCES cities(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Core Indexes (Optimized for common queries)
  INDEX idx_admin_id (admin_id), -- INDEX converted separately (action_type), -- INDEX converted separately (target_type, target_id), -- INDEX converted separately (created_at), -- INDEX converted separately (requires_approval), -- INDEX converted separately (approved_by), -- INDEX converted separately (status), -- INDEX converted separately (batch_id), -- INDEX converted separately (performed_at_local), -- INDEX converted separately (deleted_at), -- INDEX converted separately (impact_level),
  
  -- Composite Indexes for Performance (Carefully selected)
  INDEX idx_admin_action_time (admin_id, action_type, created_at), -- INDEX converted separately (target_type, target_id, created_at), -- INDEX converted separately (requires_approval, approved_at, status), -- INDEX converted separately (admin_id, created_at), -- INDEX converted separately (action_type, status, created_at)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Audit trail of administrative actions. Ethiopian timezone handled in app. Target consistency: if target_id exists, target_type must be set.';

-- ============================================
-- VIEWS FOR REPORTING
-- ============================================

-- View for admin dashboard (optimized)
CREATE OR REPLACE VIEW vw_admin_action_summary AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.target_name,
    aa.status,
    aa.impact_level,
    aa.financial_impact_etb,
    aa.requires_approval,
    aa.approved_by,
    aa.performed_at_local,
    aa.created_at,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    -- Calculate action duration if available
    TEXTDIFF(SECOND, aa.created_at, aa.updated_at) as duration_seconds,
    -- Count affected users
    aa.affected_users_count,
    -- Format for display
    DATE_FORMAT(aa.created_at, '%Y-%m-%d %H:%i:%s') as formatted_time,
    DATE_FORMAT(aa.performed_at_local, '%Y-%m-%d %H:%i:%s') as formatted_local_time
FROM admin_actions aa
LEFT JOIN users u ON aa.admin_id = u.id
LEFT JOIN cities c ON aa.performed_in_city_id = c.id
WHERE aa.deleted_at IS NULL
ORDER BY aa.created_at DESC;

-- View for compliance reporting
CREATE OR REPLACE VIEW vw_compliance_audit_log AS
SELECT 
    aa.id,
    aa.admin_id,
    u.full_name as admin_name,
    u.phone as admin_phone,
    aa.admin_role_at_time,
    aa.action_type,
    aa.action_name,
    aa.target_type,
    aa.target_id,
    aa.previous_values,
    aa.new_values,
    aa.changed_fields,
    aa.requires_approval,
    aa.approved_by,
    ab.full_name as approved_by_name,
    aa.approved_at,
    aa.approval_notes,
    aa.performed_at_local,
    aa.performed_from_ip,
    aa.device_type,
    aa.session_id,
    aa.gdpr_impact,
    aa.compliance_reference,
    aa.created_at,
    -- Data privacy flags (application-level logic)
    CASE 
        WHEN aa.gdpr_impact = TRUE THEN 'GDPR_RELEVANT'
        WHEN aa.target_type IN ('user', 'organizer') THEN 'PERSONAL_DATA'
        ELSE 'GENERAL_ACTION'
    END as data_privacy_level
FROM admin_actions aa
LEFT JOIN users u ON aa.admin_id = u.id
LEFT JOIN users ab ON aa.approved_by = ab.id
WHERE aa.deleted_at IS NULL
  AND (aa.gdpr_impact = TRUE OR aa.target_type IN ('user', 'organizer', 'payment'))
ORDER BY aa.created_at DESC;
