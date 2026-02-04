-- Converted from MySQL to SQLite
-- Original file: 037_create_message_threads_table.sql
-- Migration: 037_create_message_threads_table.sql (ENHANCED)
-- Purpose: Store message threads with improved foreign key constraINTEGERs and status tracking

CREATE TABLE IF NOT EXISTS message_threads (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Thread identification
  thread_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'THREAD-ET-2024-001',
  subject VARCHAR(200) NOT NULL,
  subject_amharic VARCHAR(200),
  
  -- Participants
  customer_id INTEGEREGER NOT NULL COMMENT 'User who started the thread',
  organizer_id INTEGEREGER NULL COMMENT 'Organizer involved (if applicable)',
  admin_id INTEGEREGER NULL COMMENT 'Admin assigned to thread',
  
  -- Thread type and context
  thread_type VARCHAR(50) NOT NULL COMMENT 'customer_support, dispute, event_inquiry, payment_issue, general, partnership',
  priority VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  
  -- Related entities
  related_event_id INTEGEREGER NULL,
  related_ticket_id INTEGEREGER NULL,
  related_payment_id INTEGEREGER NULL,
  related_dispute_id INTEGEREGER NULL,
  
  -- Ethiopian context
  city_id INTEGEREGER NULL,
  preferred_language TEXT DEFAULT 'am',
  
  -- Status tracking
  status VARCHAR(30) DEFAULT 'open' COMMENT 'open, waiting_reply, resolved, closed, archived',
  is_locked INTEGER DEFAULT FALSE COMMENT 'Prevent new messages',
  is_pinned INTEGER DEFAULT FALSE COMMENT 'Pinned by admin',
  
  -- Message statistics
  message_count INTEGEREGER DEFAULT 0,
  unread_count_customer INTEGEREGER DEFAULT 0,
  unread_count_organizer INTEGEREGER DEFAULT 0,
  unread_count_admin INTEGEREGER DEFAULT 0,
  
  -- Last message info (IMPROVED: Can be from any user type)
  last_message_at TEXT NULL,
  last_message_by_user_id INTEGEREGER NULL COMMENT 'Can be customer, organizer, or admin',
  last_message_by_type VARCHAR(20) NULL COMMENT 'customer, organizer, admin, system',
  last_message_preview VARCHAR(500) NULL,
  last_message_preview_amharic VARCHAR(500),
  
  -- Resolution
  resolved_at TEXT NULL,
  resolved_by INTEGEREGER NULL,
  resolution_notes TEXT,
  customer_satisfaction INTEGEREGER NULL COMMENT '1-5 rating',
  
  -- Closing
  closed_at TEXT NULL,
  closed_by INTEGEREGER NULL,
  closure_reason VARCHAR(100) NULL COMMENT 'resolved, duplicate, spam, no_response',
  
  -- Labels and categorization
  labels JSON COMMENT '["urgent", "technical", "payment", "refund"]',
  category VARCHAR(50) NULL COMMENT 'technical, billing, event, account, other',
  
  -- SLA tracking (Ethiopian business hours)
  sla_target_hours INTEGER DEFAULT 24 COMMENT 'Hours to first response',
  first_response_at TEXT NULL,
  sla_breached INTEGER DEFAULT FALSE,
  response_time_minutes INTEGER NULL COMMENT 'Actual response time in minutes',
  
  -- NEW: Status history tracking
  status_history JSON COMMENT 'Array of status changes: [{status: "open", changed_at: "...", changed_by: 1}]',
  
  -- Metadata
  metadata JSON,
  audit_trail JSON,
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  archived_at TEXT NULL,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (customer_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (admin_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_event_id) REFERENCES events(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_ticket_id) REFERENCES individual_tickets(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_payment_id) REFERENCES payments(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_dispute_id) REFERENCES disputes(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  -- IMPROVED: Last message can be from users or organizers
  FOREIGN KEY (last_message_by_user_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (resolved_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (closed_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_thread_code (thread_code), -- INDEX converted separately (customer_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (admin_id), -- INDEX converted separately (status), -- INDEX converted separately (thread_type), -- INDEX converted separately (priority), -- INDEX converted separately (last_message_at), -- INDEX converted separately (created_at), -- INDEX converted separately (preferred_language), -- INDEX converted separately (city_id), -- INDEX converted separately (related_event_id), -- INDEX converted separately (related_dispute_id), -- INDEX converted separately (last_message_by_user_id), -- INDEX converted separately (last_message_by_type), -- INDEX converted separately (deleted_at),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_satisfaction_rating CHECK (customer_satisfaction IS NULL OR customer_satisfaction BETWEEN 1 AND 5),
  CONSTRAINTEGER chk_message_counts CHECK (message_count >= 0 AND unread_count_customer >= 0 AND unread_count_organizer >= 0 AND unread_count_admin >= 0),
  CONSTRAINTEGER chk_last_message_type CHECK (last_message_by_type IS NULL OR last_message_by_type IN ('customer', 'organizer', 'admin', 'system'))
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Enhanced message threads for Ethiopian customer support with improved status tracking';