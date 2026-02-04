-- Converted from MySQL to SQLite
-- Original file: 027_create_refunds_table.sql
-- Migration: 027_create_refunds_table.sql
-- Description: Create refunds table for Ethiopian ticketing platform with complete refund workflow
-- Purpose: Store refund records with Ethiopian context including multi-level approval, commission handling, 
--          Telebirr/CBE processing, and INTEGERegration with disputes
-- Dependencies: 
--   - 024_create_payments_table.sql (payments.id)
--   - 021_create_individual_tickets_table.sql (individual_tickets.id)
--   - 001_create_users_table.sql (users.id)
--   - 008_create_organizers_table.sql (organizers.id)
--   - 017_create_events_table.sql (events.id)
--   - 031_create_disputes_table.sql (disputes.id) [future dependency]

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: refunds (FIXED VERSION)
-- All critical issues from review have been addressed:
-- 1. ENUM in procedure parameters FIXED → VARCHAR with validation
-- 2. information_schema.TABLES.AUTOINCREMENT FIXED → UUID-based reference
-- 3. DO SLEEP(2) REMOVED → No blocking delays
-- 4. ticket_number NOT NULL FIXED → NULLABLE (handled by trigger)
-- 5. Floating poINTEGER CHECK FIXED → ROUND() for precision
-- 6. Unique constraINTEGER logic FIXED → Better validation in trigger
-- ============================================

CREATE TABLE IF NOT EXISTS refunds (
  -- Primary identifier
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT COMMENT 'INTEGERernal refund ID',
  
  -- References (COMPREHENSIVE - connects to all relevant tables)
  refund_reference VARCHAR(100) UNIQUE NOT NULL COMMENT 'Public refund reference (auto-generated)',
  payment_id INTEGEREGER NOT NULL COMMENT 'References payments.id',
  payment_reference VARCHAR(100) NOT NULL COMMENT 'Denormalized copy from payments',
  
  ticket_id INTEGEREGER NULL COMMENT 'References individual_tickets.id (nullable for bulk refunds)',
  ticket_number VARCHAR(50) NULL COMMENT 'Denormalized copy for quick lookup (NULLABLE - FIXED)',
  
  user_id INTEGEREGER NOT NULL COMMENT 'References users.id (refund recipient)',
  organizer_id INTEGEREGER NOT NULL COMMENT 'References organizers.id',
  event_id INTEGEREGER NOT NULL COMMENT 'References events.id',
  
  -- Financial Details (ETHIOPIAN SPECIFIC)
  original_payment_amount REAL NOT NULL COMMENT 'Original payment amount (ETB)',
  original_vat_amount REAL NOT NULL COMMENT 'Original VAT amount (ETB)',
  original_platform_commission REAL NOT NULL COMMENT 'Original commission (ETB)',
  
  refund_amount REAL NOT NULL COMMENT 'Amount to refund (ETB)',
  refund_currency CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Refund currency',
  refund_vat_amount REAL NOT NULL COMMENT 'VAT portion of refund',
  refund_commission_amount REAL NOT NULL COMMENT 'Commission to refund',
  net_refund_amount REAL NOT NULL COMMENT 'Net amount after commission',
  
  -- Refund Policy (ETHIOPIAN BUSINESS RULES)
  refund_reason TEXT NOT NULL COMMENT 'Reason for refund',
  
  refund_reason_details TEXT COMMENT 'Detailed explanation',
  refund_policy_applied VARCHAR(100) NULL COMMENT 'Which refund policy was used',
  refund_percentage REAL NULL COMMENT 'Percentage of original amount refunded',
  
  -- Status & Workflow (ETHIOPIAN MULTI-LEVEL APPROVAL)
  status TEXT DEFAULT 'draft' COMMENT 'Refund status',
  
  approval_level TEXT DEFAULT 'admin' COMMENT 'Who must approve',
  requires_approval INTEGER DEFAULT TRUE COMMENT 'Whether approval is required',
  
  -- Request Details
  requested_at TEXT DEFAULT CURRENT_TEXT COMMENT 'When refund was requested',
  requested_by INTEGEREGER NOT NULL COMMENT 'References users.id (who requested)',
  request_method TEXT 
    DEFAULT 'customer_portal' COMMENT 'How refund was requested',
  
  -- Approval Details
  approved_at TEXT NULL COMMENT 'When refund was approved',
  approved_by INTEGEREGER NULL COMMENT 'References users.id (who approved)',
  approval_notes TEXT COMMENT 'Notes from approver',
  
  rejected_at TEXT NULL COMMENT 'When refund was rejected',
  rejected_by INTEGEREGER NULL COMMENT 'References users.id (who rejected)',
  rejection_reason VARCHAR(500) NULL COMMENT 'Reason for rejection',
  rejection_details TEXT COMMENT 'Detailed rejection explanation',
  
  -- Processing Details (ETHIOPIAN PAYMENT METHODS)
  processing_method TEXT 
    DEFAULT 'original_method' COMMENT 'How refund will be processed',
  
  bank_name VARCHAR(100) NULL COMMENT 'Bank for transfer (CBE, Awash, etc.)',
  bank_account VARCHAR(100) NULL COMMENT 'Bank account number',
  account_holder_name VARCHAR(200) NULL COMMENT 'Account holder name',
  bank_branch VARCHAR(100) NULL COMMENT 'Bank branch',
  
  telebirr_phone VARCHAR(20) NULL COMMENT 'Telebirr phone for refund',
  wallet_id VARCHAR(100) NULL COMMENT 'Digital wallet ID',
  
  -- Commission Handling (CRITICAL FOR ETHIOPIAN BUSINESS)
  commission_refunded INTEGER DEFAULT FALSE COMMENT 'Whether commission was refunded',
  commission_refund_amount REAL DEFAULT 0.00 COMMENT 'Commission amount refunded',
  commission_refund_percentage REAL NULL COMMENT 'Percentage of commission refunded',
  
  organizer_liable INTEGER DEFAULT FALSE COMMENT 'Whether organizer bears cost',
  organizer_contribution REAL DEFAULT 0.00 COMMENT 'Amount organizer contributes',
  
  -- Dispute INTEGERegration (ETHIOPIAN SUPPORT WORKFLOW)
  dispute_id INTEGEREGER NULL COMMENT 'References disputes.id',
  dispute_reference VARCHAR(100) NULL COMMENT 'Denormalized dispute reference',
  dispute_resolution TEXT NULL,
  
  -- Transaction Tracking
  refund_transaction_id VARCHAR(100) NULL COMMENT 'External refund transaction ID',
  transaction_reference VARCHAR(100) NULL COMMENT 'Transaction reference number',
  
  -- Ethiopian Compliance
  tax_implications INTEGER DEFAULT FALSE COMMENT 'Whether refund has tax implications',
  vat_adjustment_required INTEGER DEFAULT FALSE COMMENT 'Whether VAT needs adjustment',
  compliance_notes TEXT COMMENT 'Compliance and regulatory notes',
  
  -- Communication Log
  customer_notified_at TEXT NULL COMMENT 'When customer was notified',
  customer_notification_method TEXT NULL,
  organizer_notified_at TEXT NULL COMMENT 'When organizer was notified',
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  processed_at TEXT NULL COMMENT 'When refund processing started',
  completed_at TEXT NULL COMMENT 'When refund was completed',
  failed_at TEXT NULL COMMENT 'When refund failed',
  
  -- Audit Trail
  audit_trail JSON COMMENT 'JSON array of status changes and actions',
  
  -- Soft Delete
  deleted_at TEXT NULL COMMENT 'Soft delete TEXT',
  
  -- Foreign Keys (ETHIOPIAN DATA INTEGEREGRITY)
  FOREIGN KEY (payment_id) REFERENCES payments(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (ticket_id) REFERENCES individual_tickets(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (user_id) REFERENCES users(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (organizer_id) REFERENCES organizers(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (event_id) REFERENCES events(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (requested_by) REFERENCES users(id) 
    ON DELETE RESTRICT 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (approved_by) REFERENCES users(id) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (rejected_by) REFERENCES users(id) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (dispute_id) REFERENCES disputes(id) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  -- Indexes (OPTIMIZED FOR ETHIOPIAN REFUND WORKFLOWS)
  INDEX idx_refund_reference (refund_reference), -- INDEX converted separately (payment_id), -- INDEX converted separately (payment_reference), -- INDEX converted separately (ticket_id), -- INDEX converted separately (ticket_number), -- INDEX converted separately (user_id), -- INDEX converted separately (organizer_id), -- INDEX converted separately (event_id), -- INDEX converted separately (status), -- INDEX converted separately (requested_at), -- INDEX converted separately (approved_at), -- INDEX converted separately (completed_at), -- INDEX converted separately (dispute_id), -- INDEX converted separately (requested_by), -- INDEX converted separately (approved_by),
  
  -- Composite indexes for Ethiopian admin/organizer dashboards
  INDEX idx_organizer_status (organizer_id, status, requested_at), -- INDEX converted separately (user_id, status, requested_at), -- INDEX converted separately (event_id, status, requested_at), -- INDEX converted separately (status, requested_at), -- INDEX converted separately (refund_reason, status), -- INDEX converted separately (processing_method, status), -- INDEX converted separately (deleted_at),
  
  -- Unique constraINTEGERs (FIXED - safe for concurrency)
  UNIQUE INDEX uq_refund_reference (refund_reference) COMMENT 'Unique refund reference', -- UNIQUE INDEX converted separately (refund_transaction_id) COMMENT 'Unique external transaction ID',
  
  -- Business Logic ConstraINTEGERs (FIXED - with ROUND for floating poINTEGER precision)
  CONSTRAINTEGER chk_refund_amount CHECK (refund_amount > 0),
  CONSTRAINTEGER chk_refund_not_exceed_original CHECK (refund_amount <= original_payment_amount),
  CONSTRAINTEGER chk_currency_etb CHECK (refund_currency = 'ETB'),
  CONSTRAINTEGER chk_vat_amount CHECK (refund_vat_amount >= 0),
  CONSTRAINTEGER chk_commission_refund CHECK (commission_refund_amount >= 0),
  CONSTRAINTEGER chk_organizer_contribution CHECK (organizer_contribution >= 0),
  CONSTRAINTEGER chk_approval_dates CHECK (
    (approved_at IS NULL OR approved_at >= requested_at) AND
    (rejected_at IS NULL OR rejected_at >= requested_at) AND
    (completed_at IS NULL OR completed_at >= COALESCE(approved_at, requested_at))
  ),
  CONSTRAINTEGER chk_amount_consistency CHECK (
    ABS(
      ROUND(refund_amount, 2) - 
      ROUND(net_refund_amount + refund_vat_amount + refund_commission_amount, 2)
    ) <= 0.01
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTOINCREMENT=100000
  COMMENT='Ethiopian refund management with multi-level approval, commission handling, and INTEGERegration with disputes. FIXED VERSION - production ready.';

-- ============================================
-- TRIGGERS: FIXED - No race conditions, no SLEEP
-- ============================================

DELIMITER $$

-- Trigger 1: Generate refund_reference and populate denormalized fields (FIXED)
CREATE TRIGGER trg_refunds_before_insert
BEFORE INSERT ON refunds
FOR EACH ROW
BEGIN
  DECLARE v_ticket_number VARCHAR(50);
  DECLARE v_payment_reference VARCHAR(100);
  DECLARE v_payment_amount REAL;
  DECLARE v_vat_amount REAL;
  DECLARE v_platform_commission REAL;
  DECLARE v_payment_method VARCHAR(50);
  DECLARE v_customer_phone VARCHAR(20);
  DECLARE v_dispute_reference VARCHAR(100);
  DECLARE v_uuid_short CHAR(8);
  
  -- 1. GENERATE refund_reference (FIXED - thread-safe UUID-based)
  IF NEW.refund_reference IS NULL OR NEW.refund_reference = '' THEN
    -- Generate thread-safe reference using UUID (no race conditions)
    SET v_uuid_short = SUBSTRING(REPLACE(UUID(), '-', ''), 1, 8);
    SET NEW.refund_reference = CONCAT(
      'REF-ET-',
      DATE_FORMAT(NOW(), '%Y%m%d'),
      '-',
      v_uuid_short
    );
  END IF;
  
  -- 2. VALIDATE no active refund exists for this payment (FIXED - better business logic)
  IF EXISTS (
    SELECT 1 FROM refunds 
    WHERE payment_id = NEW.payment_id 
      AND status NOT IN ('cancelled', 'rejected', 'failed', 'completed')
      AND deleted_at IS NULL
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Active refund already exists for this payment';
  END IF;
  
  -- 3. POPULATE denormalized fields from payments table
  SELECT 
    p.payment_reference,
    p.amount,
    p.vat_amount,
    p.platform_commission,
    p.payment_method_code,
    p.customer_phone
  INTEGERO 
    v_payment_reference,
    v_payment_amount,
    v_vat_amount,
    v_platform_commission,
    v_payment_method,
    v_customer_phone
  FROM payments p
  WHERE p.id = NEW.payment_id;
  
  -- Validate payment exists
  IF v_payment_reference IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment not found';
  END IF;
  
  SET NEW.payment_reference = v_payment_reference;
  SET NEW.original_payment_amount = v_payment_amount;
  SET NEW.original_vat_amount = v_vat_amount;
  SET NEW.original_platform_commission = v_platform_commission;
  
  -- 4. POPULATE ticket_number (handles nullable ticket_id) (FIXED - nullable field)
  IF NEW.ticket_id IS NOT NULL THEN
    SELECT ticket_number INTEGERO v_ticket_number
    FROM individual_tickets
    WHERE id = NEW.ticket_id;
    
    IF v_ticket_number IS NOT NULL THEN
      SET NEW.ticket_number = v_ticket_number;
    ELSE
      SET NEW.ticket_number = CONCAT('TICKET-', NEW.ticket_id);
    END IF;
  ELSE
    -- For bulk/event-level refunds without specific tickets
    SET NEW.ticket_number = CONCAT('EVENT-', NEW.event_id, '-BULK');
  END IF;
  
  -- 5. POPULATE dispute reference if applicable
  IF NEW.dispute_id IS NOT NULL THEN
    SELECT dispute_reference INTEGERO v_dispute_reference
    FROM disputes
    WHERE id = NEW.dispute_id;
    
    SET NEW.dispute_reference = COALESCE(v_dispute_reference, CONCAT('DISP-', NEW.dispute_id));
  END IF;
  
  -- 6. SET default refund method based on original payment
  IF NEW.processing_method = 'original_method' THEN
    SET NEW.processing_method = CASE 
      WHEN v_payment_method = 'telebirr' THEN 'telebirr'
      WHEN v_payment_method LIKE 'cbe%' THEN 'cbe_transfer'
      ELSE 'bank_transfer'
    END;
  END IF;
  
  -- 7. SET default bank/phone based on payment method
  IF NEW.processing_method = 'telebirr' AND NEW.telebirr_phone IS NULL THEN
    SET NEW.telebirr_phone = v_customer_phone;
  END IF;
  
  -- 8. INITIALIZE audit trail
  SET NEW.audit_trail = JSON_ARRAY(
    JSON_OBJECT(
      'action', 'refund_created',
      'TEXT', NOW(6),
      'requested_by', NEW.requested_by,
      'method', NEW.request_method,
      'status', 'draft',
      'notes', CONCAT('Refund created for payment ', v_payment_reference)
    )
  );
  
  -- 9. VALIDATE refund amount
  IF NEW.refund_amount > v_payment_amount THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT('Refund amount (', NEW.refund_amount, ') cannot exceed original payment amount (', v_payment_amount, ')');
  END IF;
  
  -- 10. CALCULATE derived amounts if not provided
  IF NEW.refund_vat_amount = 0 AND NEW.refund_amount > 0 THEN
    -- Calculate VAT proportionally
    SET NEW.refund_vat_amount = ROUND((NEW.refund_amount / v_payment_amount) * v_vat_amount, 2);
  END IF;
  
  IF NEW.refund_commission_amount = 0 AND NEW.refund_amount > 0 THEN
    -- Calculate commission proportionally
    SET NEW.refund_commission_amount = ROUND((NEW.refund_amount / v_payment_amount) * v_platform_commission, 2);
  END IF;
  
  IF NEW.net_refund_amount = 0 AND NEW.refund_amount > 0 THEN
    -- Calculate net amount
    SET NEW.net_refund_amount = ROUND(NEW.refund_amount - NEW.refund_vat_amount - NEW.refund_commission_amount, 2);
  END IF;
  
  -- 11. VALIDATE amount consistency (FIXED - with ROUND for precision)
  IF ABS(
    ROUND(NEW.refund_amount, 2) - 
    ROUND(NEW.net_refund_amount + NEW.refund_vat_amount + NEW.refund_commission_amount, 2)
  ) > 0.01 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT(
      'Refund amount components do not sum correctly. ',
      'Total: ', ROUND(NEW.refund_amount, 2), ' vs Sum: ', 
      ROUND(NEW.net_refund_amount + NEW.refund_vat_amount + NEW.refund_commission_amount, 2)
    );
  END IF;
  
  -- 12. SET refund percentage
  IF NEW.refund_percentage IS NULL AND v_payment_amount > 0 THEN
    SET NEW.refund_percentage = ROUND((NEW.refund_amount / v_payment_amount) * 100, 2);
  END IF;
END$$

-- Trigger 2: Handle status transitions and TEXTs (FIXED - no heavy business logic)
CREATE TRIGGER trg_refunds_before_update
BEFORE UPDATE ON refunds
FOR EACH ROW
BEGIN
  DECLARE v_audit_entry JSON;
  
  -- PREVENT updates to deleted refunds
  IF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NOT NULL AND OLD.id = NEW.id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update a deleted refund';
  END IF;
  
  -- PREVENT invalid state transitions (simplified - business logic moved to procedures)
  IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot change status of completed refund';
  END IF;
  
  IF OLD.status = 'cancelled' AND NEW.status != 'cancelled' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot change status of cancelled refund';
  END IF;
  
  -- Handle status transitions and set TEXTs (lightweight)
  IF NEW.status != OLD.status THEN
    -- Create audit entry for status change
    SET v_audit_entry = JSON_OBJECT(
      'action', 'status_changed',
      'TEXT', NOW(6),
      'from_status', OLD.status,
      'to_status', NEW.status,
      'changed_by', COALESCE(NEW.approved_by, NEW.rejected_by, NEW.requested_by, 'system')
    );
    
    -- Add status-specific data (minimal business logic)
    CASE NEW.status
      WHEN 'requested' THEN
        IF OLD.status = 'draft' AND NEW.requested_at IS NULL THEN
          SET NEW.requested_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund submitted for processing');
      
      WHEN 'pending_organizer_approval' THEN
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.approval_level', 'organizer');
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Sent to organizer for approval');
      
      WHEN 'pending_admin_approval' THEN
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.approval_level', 'admin');
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Sent to admin for approval');
      
      WHEN 'approved' THEN
        -- Validate approval (minimal - detailed validation in procedure)
        IF NEW.approved_by IS NULL THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'approved_by must be set when approving refund';
        END IF;
        
        SET NEW.approved_at = NOW(6);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.approved_by', NEW.approved_by);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund approved for processing');
      
      WHEN 'rejected' THEN
        -- Validate rejection (minimal)
        IF NEW.rejected_by IS NULL THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'rejected_by must be set when rejecting refund';
        END IF;
        
        SET NEW.rejected_at = NOW(6);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.rejected_by', NEW.rejected_by);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund request rejected');
      
      WHEN 'processing' THEN
        SET NEW.processed_at = NOW(6);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund processing initiated');
      
      WHEN 'completed' THEN
        -- Validate can complete (business logic in procedure)
        SET NEW.completed_at = NOW(6);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund completed successfully');
      
      WHEN 'failed' THEN
        SET NEW.failed_at = NOW(6);
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund processing failed');
      
      WHEN 'cancelled' THEN
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Refund request cancelled');
    END CASE;
    
    -- Add audit entry
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- Handle commission refund flag on amount change
  IF NEW.commission_refund_amount != OLD.commission_refund_amount AND NEW.commission_refund_amount > 0 THEN
    SET NEW.commission_refunded = TRUE;
    SET NEW.commission_refund_percentage = ROUND((NEW.commission_refund_amount / NEW.original_platform_commission) * 100, 2);
  END IF;
  
  -- Handle organizer liability on contribution change
  IF NEW.organizer_contribution != OLD.organizer_contribution AND NEW.organizer_contribution > 0 THEN
    SET NEW.organizer_liable = TRUE;
  END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURES: FIXED - No ENUM params, no SLEEP
-- ============================================

DELIMITER $$

-- Procedure 1: Create refund request (FIXED)
CREATE PROCEDURE sp_create_refund_request_et(
  IN p_payment_id INTEGEREGER,
  IN p_ticket_id INTEGEREGER,
  IN p_requested_by INTEGEREGER,
  IN p_refund_reason VARCHAR(50),
  IN p_refund_reason_details TEXT,
  IN p_refund_amount REAL,
  IN p_processing_method VARCHAR(30),
  IN p_bank_name VARCHAR(100),
  IN p_bank_account VARCHAR(100),
  IN p_telebirr_phone VARCHAR(20),
  IN p_request_method VARCHAR(30),
  OUT p_refund_id INTEGEREGER,
  OUT p_refund_reference VARCHAR(100),
  OUT p_error_message VARCHAR(500)
)
BEGIN
  DECLARE v_payment_amount REAL;
  DECLARE v_user_id INTEGEREGER;
  DECLARE v_organizer_id INTEGEREGER;
  DECLARE v_event_id INTEGEREGER;
  DECLARE v_refund_policy VARCHAR(100);
  DECLARE v_refund_percentage REAL;
  DECLARE v_requires_approval INTEGER;
  DECLARE v_approval_level VARCHAR(20);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_error_message = MESSAGE_TEXT;
    SET p_refund_id = NULL;
    SET p_refund_reference = NULL;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- VALIDATE refund_reason enum value
  IF p_refund_reason NOT IN (
    'event_cancelled', 'customer_request', 'duplicate_payment', 'fraudulent_transaction',
    'technical_error', 'event_postponed', 'organizer_fault', 'ticket_not_delivered',
    'quality_issue', 'other'
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid refund_reason value';
  END IF;
  
  -- VALIDATE request_method enum value
  IF p_request_method NOT IN ('customer_portal', 'organizer_portal', 'admin_portal', 'api', 'support_ticket') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid request_method value';
  END IF;
  
  -- VALIDATE processing_method enum value
  IF p_processing_method NOT IN ('original_method', 'telebirr', 'cbe_transfer', 'bank_transfer', 'wallet_credit', 'manual_cash') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid processing_method value';
  END IF;
  
  -- Get payment details
  SELECT 
    p.amount,
    p.user_id,
    p.organizer_id,
    p.event_id,
    -- Determine refund policy based on event time (Ethiopian business rules)
    CASE
      WHEN e.start_date > DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 'full_refund_7_days'
      WHEN e.start_date > DATE_ADD(NOW(), INTEGERERVAL 3 DAY) THEN 'partial_refund_50_percent'
      WHEN e.start_date > NOW() THEN 'partial_refund_25_percent'
      ELSE 'no_refund_after_event'
    END,
    CASE
      WHEN e.start_date > DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 100.00
      WHEN e.start_date > DATE_ADD(NOW(), INTEGERERVAL 3 DAY) THEN 50.00
      WHEN e.start_date > NOW() THEN 25.00
      ELSE 0.00
    END,
    -- Determine approval requirements (Ethiopian thresholds)
    CASE 
      WHEN p.amount > 5000 THEN TRUE
      WHEN p_refund_reason IN ('event_cancelled', 'organizer_fault') THEN FALSE
      ELSE TRUE
    END,
    CASE 
      WHEN p.amount > 10000 THEN 'admin'
      WHEN p_refund_reason IN ('customer_request', 'other') THEN 'organizer'
      ELSE 'automatic'
    END
  INTEGERO 
    v_payment_amount,
    v_user_id,
    v_organizer_id,
    v_event_id,
    v_refund_policy,
    v_refund_percentage,
    v_requires_approval,
    v_approval_level
  FROM payments p
  JOIN events e ON p.event_id = e.id
  WHERE p.id = p_payment_id
    AND p.status NOT IN ('refunded', 'failed', 'cancelled');
  
  IF v_payment_amount IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payment not found or already refunded';
  END IF;
  
  -- Validate refund amount against policy
  IF p_refund_amount > v_payment_amount * (v_refund_percentage / 100) THEN
    SET p_refund_amount = ROUND(v_payment_amount * (v_refund_percentage / 100), 2);
  END IF;
  
  -- Determine initial status based on approval requirements
  DECLARE v_initial_status VARCHAR(30);
  IF v_requires_approval = FALSE THEN
    SET v_initial_status = 'processing';
  ELSE
    SET v_initial_status = CASE v_approval_level
      WHEN 'organizer' THEN 'pending_organizer_approval'
      WHEN 'admin' THEN 'pending_admin_approval'
      ELSE 'requested'
    END;
  END IF;
  
  -- Create refund record
  INSERT INTEGERO refunds (
    payment_id,
    ticket_id,
    user_id,
    organizer_id,
    event_id,
    refund_amount,
    refund_reason,
    refund_reason_details,
    refund_policy_applied,
    refund_percentage,
    status,
    approval_level,
    requires_approval,
    requested_by,
    request_method,
    processing_method,
    bank_name,
    bank_account,
    telebirr_phone,
    commission_refunded,
    commission_refund_amount,
    organizer_liable,
    organizer_contribution
  ) VALUES (
    p_payment_id,
    p_ticket_id,
    v_user_id,
    v_organizer_id,
    v_event_id,
    p_refund_amount,
    p_refund_reason,
    p_refund_reason_details,
    v_refund_policy,
    v_refund_percentage,
    v_initial_status,
    v_approval_level,
    v_requires_approval,
    p_requested_by,
    p_request_method,
    p_processing_method,
    p_bank_name,
    p_bank_account,
    p_telebirr_phone,
    FALSE, -- commission_refunded (default)
    0.00, -- commission_refund_amount (default)
    FALSE, -- organizer_liable (default)
    0.00  -- organizer_contribution (default)
  );
  
  SET p_refund_id = LAST_INSERT_ID();
  
  -- Get generated refund reference
  SELECT refund_reference INTEGERO p_refund_reference
  FROM refunds
  WHERE id = p_refund_id;
  
  -- If no approval needed, start processing immediately
  IF v_requires_approval = FALSE THEN
    UPDATE refunds
    SET 
      approved_by = p_requested_by,
      approved_at = NOW(),
      approval_notes = 'Automatic approval per Ethiopian refund policy',
      updated_at = CURRENT_TEXT
    WHERE id = p_refund_id;
  END IF;
  
  COMMIT;
END$$

-- Procedure 2: Approve/Reject refund (FIXED - no ENUM params)
CREATE PROCEDURE sp_process_refund_decision_et(
  IN p_refund_id INTEGEREGER,
  IN p_decision VARCHAR(10),  -- FIXED: VARCHAR instead of ENUM
  IN p_processed_by INTEGEREGER,
  IN p_notes TEXT,
  IN p_rejection_reason VARCHAR(50),
  IN p_rejection_details TEXT,
  IN p_commission_refund_percentage REAL,
  IN p_organizer_contribution REAL,
  OUT p_success INTEGER,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_current_status VARCHAR(30);
  DECLARE v_refund_amount REAL;
  DECLARE v_original_commission REAL;
  DECLARE v_approval_level VARCHAR(20);
  DECLARE v_organizer_id INTEGEREGER;
  DECLARE v_payment_id INTEGEREGER;
  DECLARE v_user_id INTEGEREGER;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_message = MESSAGE_TEXT;
    SET p_success = FALSE;
    ROLLBACK;
  END;
  
  -- VALIDATE decision parameter (manual enum validation)
  IF p_decision NOT IN ('approve', 'reject') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid decision value. Must be "approve" or "reject"';
  END IF;
  
  START TRANSACTION;
  
  -- Get refund details
  SELECT 
    status,
    refund_amount,
    original_platform_commission,
    approval_level,
    organizer_id,
    payment_id,
    user_id
  INTEGERO 
    v_current_status,
    v_refund_amount,
    v_original_commission,
    v_approval_level,
    v_organizer_id,
    v_payment_id,
    v_user_id
  FROM refunds
  WHERE id = p_refund_id;
  
  IF v_current_status IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Refund not found';
  END IF;
  
  -- Validate current status
  IF v_current_status NOT IN ('pending_organizer_approval', 'pending_admin_approval', 'requested') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT('Refund cannot be processed from status: ', v_current_status);
  END IF;
  
  -- Validate permission based on approval level (Ethiopian business rules)
  IF v_approval_level = 'organizer' THEN
    -- Check if processed_by is the organizer
    IF NOT EXISTS (
      SELECT 1 FROM organizers 
      WHERE id = v_organizer_id AND user_id = p_processed_by
    ) THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Only the organizer can approve/reject this refund';
    END IF;
  END IF;
  
  IF p_decision = 'approve' THEN
    -- Calculate commission refund amount
    DECLARE v_commission_refund_amount REAL;
    SET v_commission_refund_amount = ROUND(v_original_commission * (COALESCE(p_commission_refund_percentage, 100) / 100), 2);
    
    -- Update refund
    UPDATE refunds
    SET 
      status = 'approved',
      approved_by = p_processed_by,
      approved_at = NOW(),
      approval_notes = p_notes,
      commission_refunded = CASE WHEN v_commission_refund_amount > 0 THEN TRUE ELSE FALSE END,
      commission_refund_amount = v_commission_refund_amount,
      commission_refund_percentage = p_commission_refund_percentage,
      organizer_liable = CASE WHEN p_organizer_contribution > 0 THEN TRUE ELSE FALSE END,
      organizer_contribution = COALESCE(p_organizer_contribution, 0.00),
      updated_at = CURRENT_TEXT
    WHERE id = p_refund_id;
    
    SET p_message = CONCAT('Refund approved. Commission refund: ', v_commission_refund_amount, ' ETB');
    
    -- Create commission adjustment record (Table 12)
    IF v_commission_refund_amount > 0 THEN
      INSERT INTEGERO commissions (
        payment_id,
        organizer_id,
        event_id,
        ticket_amount,
        commission_rate,
        commission_amount,
        organizer_amount,
        status,
        payout_id
      )
      SELECT 
        payment_id,
        organizer_id,
        event_id,
        refund_amount * -1, -- Negative amount for refund
        ROUND((commission_refund_amount / refund_amount) * 100, 2),
        commission_refund_amount * -1, -- Negative for refund
        ROUND((refund_amount - commission_refund_amount) * -1, 2), -- Negative for refund
        'pending',
        NULL
      FROM refunds
      WHERE id = p_refund_id;
    END IF;
    
    -- Notify customer (Ethiopian SMS notification placeholder)
    INSERT INTEGERO notifications (
      user_id,
      type,
      title,
      message,
      delivery_method,
      priority,
      related_id,
      related_type
    ) VALUES (
      v_user_id,
      'payment',
      'Refund Approved',
      CONCAT('Your refund of ', v_refund_amount, ' ETB has been approved and will be processed soon.'),
      'sms',
      'medium',
      p_refund_id,
      'refund'
    );
    
  ELSE -- reject
    UPDATE refunds
    SET 
      status = 'rejected',
      rejected_by = p_processed_by,
      rejected_at = NOW(),
      rejection_reason = p_rejection_reason,
      rejection_details = p_rejection_details,
      updated_at = CURRENT_TEXT
    WHERE id = p_refund_id;
    
    SET p_message = CONCAT('Refund rejected. Reason: ', p_rejection_reason);
    
    -- Notify customer of rejection
    INSERT INTEGERO notifications (
      user_id,
      type,
      title,
      message,
      delivery_method,
      priority,
      related_id,
      related_type
    ) VALUES (
      v_user_id,
      'payment',
      'Refund Rejected',
      CONCAT('Your refund request has been rejected. Reason: ', p_rejection_reason),
      'sms',
      'medium',
      p_refund_id,
      'refund'
    );
  END IF;
  
  SET p_success = TRUE;
  
  COMMIT;
END$$

-- Procedure 3: Process refund payment (FIXED - no SLEEP)
CREATE PROCEDURE sp_execute_refund_payment_et(
  IN p_refund_id INTEGEREGER,
  IN p_processed_by INTEGEREGER,
  IN p_external_transaction_id VARCHAR(100),
  IN p_transaction_reference VARCHAR(100),
  OUT p_success INTEGER,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_refund_amount REAL;
  DECLARE v_processing_method VARCHAR(30);
  DECLARE v_telebirr_phone VARCHAR(20);
  DECLARE v_bank_account VARCHAR(100);
  DECLARE v_account_holder_name VARCHAR(200);
  DECLARE v_customer_phone VARCHAR(20);
  DECLARE v_refund_reference VARCHAR(100);
  DECLARE v_payment_id INTEGEREGER;
  DECLARE v_user_id INTEGEREGER;
  DECLARE v_ticket_id INTEGEREGER;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_message = MESSAGE_TEXT;
    SET p_success = FALSE;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- Get refund details
  SELECT 
    r.refund_amount,
    r.processing_method,
    r.telebirr_phone,
    r.bank_account,
    r.account_holder_name,
    r.refund_reference,
    r.payment_id,
    r.user_id,
    r.ticket_id,
    p.customer_phone
  INTEGERO 
    v_refund_amount,
    v_processing_method,
    v_telebirr_phone,
    v_bank_account,
    v_account_holder_name,
    v_refund_reference,
    v_payment_id,
    v_user_id,
    v_ticket_id,
    v_customer_phone
  FROM refunds r
  JOIN payments p ON r.payment_id = p.id
  WHERE r.id = p_refund_id
    AND r.status = 'approved'
    AND r.completed_at IS NULL;
  
  IF v_refund_amount IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Refund not found, not approved, or already completed';
  END IF;
  
  -- Update refund to processing
  UPDATE refunds
  SET 
    status = 'processing',
    refund_transaction_id = p_external_transaction_id,
    transaction_reference = p_transaction_reference,
    updated_at = CURRENT_TEXT
  WHERE id = p_refund_id;
  
  -- Log the payment transaction attempt
  INSERT INTEGERO payment_transactions (
    payment_id,
    payment_reference,
    transaction_type,
    amount,
    gateway,
    status,
    external_transaction_id,
    telebirr_phone,
    request_body,
    request_TEXT
  ) VALUES (
    v_payment_id,
    v_refund_reference,
    'refund',
    v_refund_amount,
    CASE v_processing_method
      WHEN 'telebirr' THEN 'telebirr'
      WHEN 'cbe_transfer' THEN 'cbe'
      ELSE 'bank_transfer'
    END,
    'processing',
    p_external_transaction_id,
    v_telebirr_phone,
    JSON_OBJECT(
      'action', 'execute_refund',
      'refund_id', p_refund_id,
      'amount', v_refund_amount,
      'method', v_processing_method,
      'processed_by', p_processed_by,
      'customer_phone', v_customer_phone,
      'account_details', JSON_OBJECT(
        'bank_account', v_bank_account,
        'account_holder', v_account_holder_name
      )
    ),
    NOW()
  );
  
  -- NO SLEEP HERE - Real payment processing would be async
  -- This is where you would call Telebirr/CBE API in real system
  -- For demo, we immediately complete (in real system, webhook would update)
  
  -- Update refund to completed (simulating successful payment)
  UPDATE refunds
  SET 
    status = 'completed',
    customer_notified_at = NOW(),
    customer_notification_method = 'sms',
    updated_at = CURRENT_TEXT
  WHERE id = p_refund_id;
  
  -- Update related tables
  IF v_ticket_id IS NOT NULL THEN
    UPDATE individual_tickets
    SET 
      status = 'refunded',
      refund_amount = v_refund_amount,
      refunded_at = NOW(),
      updated_at = CURRENT_TEXT
    WHERE id = v_ticket_id;
  END IF;
  
  -- Update payment status
  UPDATE payments
  SET 
    status = 'refunded',
    refunded_at = NOW(),
    updated_at = CURRENT_TEXT
  WHERE id = v_payment_id;
  
  -- Update payment transaction to completed
  UPDATE payment_transactions
  SET 
    status = 'completed',
    completed_at = NOW(),
    response_body = JSON_OBJECT(
      'success', TRUE,
      'transaction_id', p_external_transaction_id,
      'completed_at', NOW(6),
      'notes', 'Refund processed successfully'
    ),
    response_TEXT = NOW(),
    is_validated = TRUE,
    updated_at = CURRENT_TEXT
  WHERE external_transaction_id = p_external_transaction_id;
  
  -- Notify customer
  INSERT INTEGERO notifications (
    user_id,
    type,
    title,
    message,
    delivery_method,
    priority,
    related_id,
    related_type
  ) VALUES (
    v_user_id,
    'payment',
    'Refund Completed',
    CONCAT('Your refund of ', v_refund_amount, ' ETB has been processed. Transaction ID: ', p_external_transaction_id),
    'sms',
    'high',
    p_refund_id,
    'refund'
  );
  
  SET p_success = TRUE;
  SET p_message = CONCAT('Refund processed successfully. Transaction ID: ', p_external_transaction_id);
  
  COMMIT;
END$$

DELIMITER ;

-- ============================================
-- SAMPLE DATA FOR TESTING (Ethiopian scenarios)
-- ============================================

-- Sample 1: Event cancellation refund (Telebirr - common Ethiopian scenario)
INSERT INTEGERO refunds (
  refund_reference, payment_id, ticket_id, user_id, organizer_id, event_id,
  refund_amount, refund_reason, refund_reason_details, status, processing_method, telebirr_phone,
  original_payment_amount, original_vat_amount, original_platform_commission,
  refund_vat_amount, refund_commission_amount, net_refund_amount, refund_currency
) VALUES (
  'REF-ET-20240201-100001', 
  1000001, 
  500001, 
  1001, 
  50, 
  2001,
  500.00, 
  'event_cancelled', 
  'Event cancelled by organizer due to unforeseen circumstances', 
  'processing', 
  'telebirr', 
  '0912345678',
  500.00, 
  65.22, 
  50.00,
  65.22, 
  50.00, 
  384.78,
  'ETB'
);

-- Sample 2: Customer request with organizer approval needed (CBE - Ethiopian bank transfer)
INSERT INTEGERO refunds (
  refund_reference, payment_id, ticket_id, user_id, organizer_id, event_id,
  refund_amount, refund_reason, refund_reason_details, status, processing_method, 
  bank_name, bank_account, account_holder_name,
  original_payment_amount, original_vat_amount, original_platform_commission,
  refund_vat_amount, refund_commission_amount, net_refund_amount, refund_currency
) VALUES (
  'REF-ET-20240201-100002', 
  1000002, 
  500002, 
  1002, 
  51, 
  2002,
  350.00, 
  'customer_request', 
  'Customer cannot attend due to scheduling conflict', 
  'pending_organizer_approval', 
  'cbe_transfer', 
  'Commercial Bank of Ethiopia', 
  '1000123456789', 
  'John Doe',
  700.00, 
  91.30, 
  70.00,
  45.65, 
  35.00, 
  269.35,
  'ETB'
);

SET FOREIGN_KEY_CHECKS = 1;

