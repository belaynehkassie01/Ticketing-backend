-- Converted from MySQL to SQLite
-- Original file: 031_create_disputes_table.sql
-- Migration: 031_create_disputes_table.sql (ENHANCED)
-- Purpose: Store dispute records with Ethiopian mediation - IMPROVED VERSION

CREATE TABLE IF NOT EXISTS disputes (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Dispute identification
  dispute_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'DSP-ET-2024-001',
  
  -- IMPROVEMENT #1: Added dispute source
  dispute_source VARCHAR(20) DEFAULT 'customer' COMMENT 'customer, organizer, system, payment_gateway, admin, automated_monitoring',
  
  -- Parties involved (Ethiopian context)
  customer_id INTEGEREGER NOT NULL,
  organizer_id INTEGEREGER NOT NULL,
  event_id INTEGEREGER NOT NULL,
  
  -- Related entities
  ticket_id INTEGEREGER NULL,
  payment_id INTEGEREGER NULL,
  refund_id INTEGEREGER NULL,
  
  -- IMPROVEMENT #2: Link to tax transactions (optional)
  related_tax_transaction_id INTEGEREGER NULL,
  
  -- Dispute classification
  dispute_type VARCHAR(50) NOT NULL COMMENT 'refund_request, event_cancelled, ticket_not_valid, organizer_no_show, event_different, fraud, technical_issue, quality_issue, other',
  dispute_subtype VARCHAR(50) NULL COMMENT 'late_start, wrong_venue, misrepresentation, safety_issue, service_quality',
  
  -- Ethiopian mediation context
  city_id INTEGEREGER NULL,
  region VARCHAR(100) NULL,
  preferred_language TEXT DEFAULT 'am',
  
  -- Dispute details
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  description TEXT NOT NULL,
  description_amharic TEXT,
  
  -- Customer demands
  desired_outcome VARCHAR(50) NOT NULL COMMENT 'full_refund, partial_refund, ticket_replacement, rescheduled_event, apology, compensation, organizer_penalty, other',
  desired_amount REAL NULL,
  desired_notes TEXT,
  
  -- Evidence
  evidence_files JSON COMMENT 'Array of URLs: photos, videos, receipts',
  supporting_documents JSON,
  witness_contacts JSON COMMENT 'Array of witness phone/email',
  
  -- Status tracking
  status VARCHAR(30) DEFAULT 'open' COMMENT 'open, under_review, awaiting_customer_response, awaiting_organizer_response, mediation_in_progress, resolved, closed, escalated',
  priority VARCHAR(20) DEFAULT 'medium' COMMENT 'low, medium, high, urgent',
  severity VARCHAR(20) DEFAULT 'normal' COMMENT 'minor, normal, major, critical',
  
  -- Assignment and workflow
  assigned_to INTEGEREGER NULL COMMENT 'Admin/staff handling',
  assigned_at TEXT NULL,
  assigned_by INTEGEREGER NULL,
  last_reassigned_at TEXT NULL,
  
  -- Resolution
  resolution_type VARCHAR(50) NULL COMMENT 'full_refund, partial_refund, ticket_replacement, organizer_penalty, customer_compensation, rejected, withdrawn, other',
  resolution_amount REAL NULL,
  resolution_details TEXT,
  resolution_details_amharic TEXT,
  
  -- Ethiopian mediation process
  requires_mediation INTEGER DEFAULT FALSE,
  mediation_attempts INTEGER DEFAULT 0,
  mediation_successful INTEGER DEFAULT FALSE,
  mediation_notes TEXT,
  mediation_date TEXT NULL,
  mediator_id INTEGEREGER NULL COMMENT 'Third-party mediator if needed',
  
  -- Communication tracking
  last_customer_response_at TEXT NULL,
  last_organizer_response_at TEXT NULL,
  response_deadline TEXT NULL,
  response_reminders_sent INTEGER DEFAULT 0,
  escalation_level INTEGER DEFAULT 1 COMMENT '1=Customer Support, 2=Senior Support, 3=Management',
  
  -- Timeline
  acknowledged_at TEXT NULL,
  investigation_started_at TEXT NULL,
  mediation_started_at TEXT NULL,
  resolved_at TEXT NULL,
  resolved_by INTEGEREGER NULL,
  closed_at TEXT NULL,
  closed_by INTEGEREGER NULL,
  escalated_at TEXT NULL,
  
  -- Financial impact
  refund_issued INTEGER DEFAULT FALSE,
  refund_amount REAL DEFAULT 0.00,
  penalty_applied INTEGER DEFAULT FALSE,
  penalty_amount REAL DEFAULT 0.00,
  compensation_awarded INTEGER DEFAULT FALSE,
  compensation_amount REAL DEFAULT 0.00,
  
  -- Customer satisfaction
  customer_satisfaction INTEGEREGER NULL COMMENT '1-5 rating',
  customer_feedback TEXT,
  organizer_feedback TEXT,
  platform_learnings TEXT COMMENT 'What we learned to prevent future disputes',
  
  -- Audit and compliance
  audit_trail JSON,
  compliance_notes TEXT,
  legal_notes TEXT,
  
  -- TEXTs with soft delete
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (customer_id) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (payment_id) REFERENCES payments(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (refund_id) REFERENCES refunds(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  -- IMPROVEMENT #2: Tax transaction link
  FOREIGN KEY (related_tax_transaction_id) REFERENCES tax_transactions(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (assigned_to) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (assigned_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (resolved_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (closed_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (mediator_id) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_dispute_code (dispute_code), -- INDEX converted separately (customer_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (event_id), -- INDEX converted separately (status), -- INDEX converted separately (dispute_type),
  
  -- IMPROVEMENT #3: Added resolution_type index
  INDEX idx_resolution_type (resolution_type), -- INDEX converted separately (dispute_source), -- INDEX converted separately (assigned_to), -- INDEX converted separately (priority), -- INDEX converted separately (created_at), -- INDEX converted separately (resolved_at), -- INDEX converted separately (closed_at), -- INDEX converted separately (city_id), -- INDEX converted separately (preferred_language), -- INDEX converted separately (deleted_at),
  
  -- Business constraINTEGERs
  CONSTRAINTEGER chk_resolution_amount CHECK (resolution_amount IS NULL OR resolution_amount >= 0),
  CONSTRAINTEGER chk_customer_satisfaction CHECK (customer_satisfaction IS NULL OR customer_satisfaction BETWEEN 1 AND 5),
  CONSTRAINTEGER chk_dispute_source CHECK (dispute_source IN ('customer', 'organizer', 'system', 'payment_gateway', 'admin', 'automated_monitoring'))
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian dispute resolution system - ENHANCED with source tracking and tax links';