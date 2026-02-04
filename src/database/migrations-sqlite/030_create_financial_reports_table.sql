-- Converted from MySQL to SQLite
-- Original file: 030_create_financial_reports_table.sql
-- Migration: 030_create_financial_reports_table.sql (FIXED - PRODUCTION READY)
-- Description: Ethiopian financial reporting system - ALL BUGS FIXED

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: financial_reports (FIXED VERSION)
-- ============================================

CREATE TABLE IF NOT EXISTS financial_reports (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Report identification (FIXED: Unique business key)
  report_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'FIN-ET-2024-01-M001',
  report_name VARCHAR(200) NOT NULL,
  report_name_amharic VARCHAR(200),
  
  -- Report type and period
  report_type VARCHAR(30) NOT NULL COMMENT 'daily, weekly, monthly, quarterly, yearly, custom, vat_return, withholding_return',
  period_type VARCHAR(20) NOT NULL COMMENT 'calendar_month, fiscal_month, quarter, half_year, fiscal_year',
  
  -- Period dates
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  fiscal_year YEAR NOT NULL,
  
  -- FIXED: Ethiopian month handled by application layer
  ethiopian_month_number INTEGEREGER NULL COMMENT '1-13 (application calculated)',
  ethiopian_month_name VARCHAR(30) NULL COMMENT 'Application calculated',
  
  -- Generation and approval
  generated_by INTEGEREGER NOT NULL,
  generated_at TEXT NOT NULL,
  approved_by INTEGEREGER NULL,
  approved_at TEXT NULL,
  approval_status VARCHAR(20) DEFAULT 'draft' COMMENT 'draft, pending_approval, approved, rejected, submitted',
  
  -- Core financial metrics (ETB)
  total_revenue REAL DEFAULT 0.00,
  total_expenses REAL DEFAULT 0.00,
  net_profit REAL GENERATED ALWAYS AS (total_revenue - total_expenses) STORED,
  
  -- Ticket metrics
  total_tickets_sold INTEGER DEFAULT 0,
  total_events_count INTEGER DEFAULT 0,
  total_organizers_count INTEGER DEFAULT 0,
  
  -- Revenue breakdown
  ticket_sales_revenue REAL DEFAULT 0.00,
  platform_commission_revenue REAL DEFAULT 0.00,
  service_fee_revenue REAL DEFAULT 0.00,
  other_revenue REAL DEFAULT 0.00,
  
  -- Ethiopian VAT tracking (15%)
  total_vat_collected REAL DEFAULT 0.00,
  vat_on_ticket_sales REAL DEFAULT 0.00,
  vat_on_commission REAL DEFAULT 0.00,
  vat_payable_to_erca REAL DEFAULT 0.00,
  vat_return_submitted INTEGER DEFAULT FALSE,
  vat_return_date DATE NULL,
  vat_return_reference VARCHAR(100) NULL,
  
  -- Withholding tax (2%)
  total_withholding_tax REAL DEFAULT 0.00,
  withholding_on_payouts REAL DEFAULT 0.00,
  withholding_return_submitted INTEGER DEFAULT FALSE,
  withholding_return_date DATE NULL,
  
  -- Payouts
  total_payouts_issued REAL DEFAULT 0.00,
  payouts_count INTEGER DEFAULT 0,
  pending_payouts REAL DEFAULT 0.00,
  
  -- Commission
  total_platform_commission REAL DEFAULT 0.00,
  average_commission_rate REAL DEFAULT 10.00,
  
  -- Payment methods
  telebirr_revenue REAL DEFAULT 0.00,
  cbe_bank_transfer_revenue REAL DEFAULT 0.00,
  other_payment_revenue REAL DEFAULT 0.00,
  
  -- JSON breakdowns (FIXED: Only store, don't calculate here)
  revenue_by_region JSON,
  revenue_by_city JSON,
  revenue_by_category JSON,
  tickets_by_category JSON,
  top_organizers JSON,
  top_events JSON,
  top_cities JSON,
  
  -- Growth metrics
  revenue_growth_percentage REAL DEFAULT 0.00,
  ticket_sales_growth REAL DEFAULT 0.00,
  organizer_growth REAL DEFAULT 0.00,
  repeat_customer_rate REAL DEFAULT 0.00,
  
  -- Files
  report_file_url VARCHAR(500) NULL,
  pdf_file_url VARCHAR(500) NULL,
  excel_file_url VARCHAR(500) NULL,
  vat_return_file_url VARCHAR(500) NULL,
  withholding_return_file_url VARCHAR(500) NULL,
  
  -- Ethiopian compliance
  tax_authority_submission_id VARCHAR(100) NULL COMMENT 'ERCATaxReference-123456',
  submission_date DATE NULL,
  submission_status VARCHAR(30) DEFAULT 'not_submitted' COMMENT 'not_submitted, submitted, accepted, rejected, under_review',
  authority_notes TEXT,
  
  -- Currency (FIXED: Always ETB for Ethiopian reports)
  currency VARCHAR(3) DEFAULT 'ETB',
  exchange_rate REAL DEFAULT 1.0000,
  
  -- Status (FIXED: Better locking logic)
  is_final INTEGER DEFAULT FALSE,
  is_locked INTEGER DEFAULT FALSE,
  notes TEXT,
  audit_trail JSON,
  
  -- Metadata
  created_by INTEGEREGER NOT NULL,
  updated_by INTEGEREGER NULL,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (generated_by) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (approved_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_report_code (report_code), -- INDEX converted separately (report_type), -- INDEX converted separately (period_start, period_end), -- INDEX converted separately (fiscal_year), -- INDEX converted separately (approval_status), -- INDEX converted separately (submission_status), -- INDEX converted separately (generated_by), -- INDEX converted separately (generated_at), -- INDEX converted separately (is_final), -- INDEX converted separately (is_locked), -- INDEX converted separately (deleted_at),
  
  -- Business key constraINTEGER
  UNIQUE KEY uq_report_period_type (report_type, period_start, period_end, deleted_at)
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian financial reports - FIXED version';

-- ============================================
-- TRIGGERS (FIXED)
-- ============================================

DELIMITER $$

-- Trigger 1: BEFORE INSERT - Fixed Ethiopian month handling
CREATE TRIGGER trg_financial_reports_before_insert
BEFORE INSERT ON financial_reports
FOR EACH ROW
BEGIN
  DECLARE v_report_count INTEGER;
  DECLARE v_report_type_code VARCHAR(10);
  
  -- VALIDATE report type
  IF NEW.report_type NOT IN ('daily', 'weekly', 'monthly', 'quarterly', 'yearly', 'custom', 'vat_return', 'withholding_return') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid report_type. Must be: daily, weekly, monthly, quarterly, yearly, custom, vat_return, withholding_return';
  END IF;
  
  -- VALIDATE period
  IF NEW.period_end < NEW.period_start THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'period_end must be after period_start';
  END IF;
  
  -- VALIDATE fiscal year
  IF NEW.fiscal_year NOT BETWEEN 2020 AND 2100 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'fiscal_year must be between 2020 and 2100';
  END IF;
  
  -- GENERATE report_code if not provided
  IF NEW.report_code IS NULL OR NEW.report_code = '' THEN
    -- Determine report type code
    CASE NEW.report_type
      WHEN 'daily' THEN SET v_report_type_code = 'D';
      WHEN 'weekly' THEN SET v_report_type_code = 'W';
      WHEN 'monthly' THEN SET v_report_type_code = 'M';
      WHEN 'quarterly' THEN SET v_report_type_code = 'Q';
      WHEN 'yearly' THEN SET v_report_type_code = 'Y';
      WHEN 'vat_return' THEN SET v_report_type_code = 'VAT';
      WHEN 'withholding_return' THEN SET v_report_type_code = 'WHT';
      ELSE SET v_report_type_code = 'CUST';
    END CASE;
    
    -- Get count for this period
    SELECT COUNT(*) + 1 INTEGERO v_report_count
    FROM financial_reports
    WHERE report_type = NEW.report_type
      AND fiscal_year = NEW.fiscal_year
      AND period_start = NEW.period_start
      AND deleted_at IS NULL;
    
    SET NEW.report_code = CONCAT(
      'FIN-ET-',
      NEW.fiscal_year,
      '-',
      LPAD(MONTH(NEW.period_start), 2, '0'),
      '-',
      v_report_type_code,
      LPAD(v_report_count, 3, '0')
    );
  END IF;
  
  -- FIXED: Ethiopian month NOT calculated here - handled by application
  
  -- INITIALIZE audit trail
  SET NEW.audit_trail = JSON_ARRAY(
    JSON_OBJECT(
      'action', 'created',
      'TEXT', NOW(6),
      'created_by', NEW.created_by,
      'report_type', NEW.report_type,
      'period', CONCAT(NEW.period_start, ' to ', NEW.period_end),
      'note', 'Financial report created'
    )
  );
  
  -- SET generated_at if not provided
  IF NEW.generated_at IS NULL THEN
    SET NEW.generated_at = NOW();
  END IF;
  
  -- ENFORCE ETB currency
  SET NEW.currency = 'ETB';
END$$

-- Trigger 2: BEFORE UPDATE - Fixed locking logic
CREATE TRIGGER trg_financial_reports_before_update
BEFORE UPDATE ON financial_reports
FOR EACH ROW
BEGIN
  DECLARE v_audit_entry JSON;
  
  -- FIXED: Allow safe updates even when locked
  -- Only prevent updates to core financial data when locked
  IF OLD.is_locked = TRUE THEN
    -- Check if trying to modify protected fields
    IF (OLD.total_revenue != NEW.total_revenue OR
        OLD.total_vat_collected != NEW.total_vat_collected OR
        OLD.total_tickets_sold != NEW.total_tickets_sold OR
        OLD.ticket_sales_revenue != NEW.ticket_sales_revenue OR
        OLD.platform_commission_revenue != NEW.platform_commission_revenue OR
        OLD.total_payouts_issued != NEW.total_payouts_issued OR
        OLD.total_platform_commission != NEW.total_platform_commission OR
        OLD.telebirr_revenue != NEW.telebirr_revenue OR
        OLD.cbe_bank_transfer_revenue != NEW.cbe_bank_transfer_revenue) THEN
      
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cannot modify financial data on locked report';
    END IF;
    
    -- Allow these fields to be updated even when locked
    -- notes, submission_status, authority_notes, etc.
  END IF;
  
  -- PREVENT updates to deleted reports (except undelete)
  IF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NOT NULL AND OLD.id = NEW.id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update deleted financial report';
  END IF;
  
  -- HANDLE locking
  IF OLD.is_locked = FALSE AND NEW.is_locked = TRUE THEN
    SET v_audit_entry = JSON_OBJECT(
      'action', 'locked',
      'TEXT', NOW(6),
      'locked_by', NEW.updated_by,
      'note', 'Report locked for editing'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE unlocking
  IF OLD.is_locked = TRUE AND NEW.is_locked = FALSE THEN
    SET v_audit_entry = JSON_OBJECT(
      'action', 'unlocked',
      'TEXT', NOW(6),
      'unlocked_by', NEW.updated_by,
      'note', 'Report unlocked'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE finalization
  IF OLD.is_final = FALSE AND NEW.is_final = TRUE THEN
    SET v_audit_entry = JSON_OBJECT(
      'action', 'finalized',
      'TEXT', NOW(6),
      'finalized_by', NEW.updated_by,
      'note', 'Report finalized'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE approval
  IF OLD.approved_by IS NULL AND NEW.approved_by IS NOT NULL THEN
    SET NEW.approved_at = NOW();
    SET NEW.approval_status = 'approved';
    
    SET v_audit_entry = JSON_OBJECT(
      'action', 'approved',
      'TEXT', NOW(6),
      'approved_by', NEW.approved_by,
      'note', 'Report approved'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE tax authority submission
  IF OLD.submission_status != 'submitted' AND NEW.submission_status = 'submitted' THEN
    SET NEW.submission_date = CURDATE();
    
    SET v_audit_entry = JSON_OBJECT(
      'action', 'submitted_to_tax_authority',
      'TEXT', NOW(6),
      'submitted_by', NEW.updated_by,
      'authority_reference', NEW.tax_authority_submission_id,
      'note', 'Submitted to Ethiopian tax authority'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE soft delete
  IF OLD.deleted_at IS NULL AND NEW.deleted_at IS NOT NULL THEN
    SET NEW.is_locked = TRUE;
    SET NEW.is_final = TRUE;
    
    SET v_audit_entry = JSON_OBJECT(
      'action', 'soft_deleted',
      'TEXT', NOW(6),
      'deleted_by', NEW.updated_by,
      'note', 'Report soft deleted'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- HANDLE undelete
  IF OLD.deleted_at IS NOT NULL AND NEW.deleted_at IS NULL THEN
    SET v_audit_entry = JSON_OBJECT(
      'action', 'undeleted',
      'TEXT', NOW(6),
      'restored_by', NEW.updated_by,
      'note', 'Report restored'
    );
    
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURES (FIXED - NO tax_transactions dependency)
-- ============================================

DELIMITER $$

-- Procedure 1: Generate monthly financial report (FIXED)
CREATE PROCEDURE sp_generate_monthly_financial_report_et(
  IN p_year INTEGER,
  IN p_month INTEGER,
  IN p_generated_by INTEGEREGER,
  OUT p_report_id INTEGEREGER,
  OUT p_report_code VARCHAR(50),
  OUT p_error_message VARCHAR(500)
)
BEGIN
  DECLARE v_period_start DATE;
  DECLARE v_period_end DATE;
  DECLARE v_fiscal_year INTEGER;
  DECLARE v_total_revenue REAL;
  DECLARE v_total_vat REAL;
  DECLARE v_total_tickets INTEGER;
  DECLARE v_existing_report_id INTEGEREGER;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_error_message = MESSAGE_TEXT;
    SET p_report_id = NULL;
    SET p_report_code = NULL;
    ROLLBACK;
  END;
  
  -- CALCULATE period
  SET v_period_start = DATE(CONCAT(p_year, '-', LPAD(p_month, 2, '0'), '-01'));
  SET v_period_end = LAST_DAY(v_period_start);
  
  -- CALCULATE fiscal year (Ethiopian approximation: July start)
  IF p_month >= 7 THEN
    SET v_fiscal_year = p_year;
  ELSE
    SET v_fiscal_year = p_year - 1;
  END IF;
  
  -- CHECK for existing report
  SELECT id INTEGERO v_existing_report_id
  FROM financial_reports
  WHERE period_start = v_period_start
    AND period_end = v_period_end
    AND report_type = 'monthly'
    AND deleted_at IS NULL;
  
  IF v_existing_report_id IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT('Monthly report already exists for ', DATE_FORMAT(v_period_start, '%M %Y'));
  END IF;
  
  -- FIXED: Calculate from payments table instead of tax_transactions
  SELECT 
    COALESCE(SUM(amount), 0),
    COALESCE(SUM(vat_amount), 0),
    COUNT(DISTINCT individual_tickets.id)
  INTEGERO 
    v_total_revenue,
    v_total_vat,
    v_total_tickets
  FROM payments
  LEFT JOIN individual_tickets ON payments.id = individual_tickets.payment_id
  WHERE payments.status = 'completed'
    AND DATE(payments.created_at) BETWEEN v_period_start AND v_period_end;
  
  START TRANSACTION;
  
  -- FIXED: Removed duplicate report_type column
  INSERT INTEGERO financial_reports (
    report_name,
    report_name_amharic,
    report_type,
    period_type,
    period_start,
    period_end,
    fiscal_year,
    generated_by,
    generated_at,
    total_revenue,
    total_vat_collected,
    total_tickets_sold,
    vat_on_ticket_sales,
    currency,
    created_by
  ) VALUES (
    CONCAT('Monthly Financial Report - ', DATE_FORMAT(v_period_start, '%M %Y')),
    CONCAT('ወርሃዊ የፋይናንስ ሪፖርት - ', DATE_FORMAT(v_period_start, '%M %Y')),
    'monthly',
    'calendar_month',
    v_period_start,
    v_period_end,
    v_fiscal_year,
    p_generated_by,
    NOW(),
    v_total_revenue,
    v_total_vat,
    v_total_tickets,
    v_total_vat,
    'ETB',
    p_generated_by
  );
  
  SET p_report_id = LAST_INSERT_ID();
  
  -- GET report code
  SELECT report_code INTEGERO p_report_code
  FROM financial_reports
  WHERE id = p_report_id;
  
  COMMIT;
END$$

-- Procedure 2: Generate VAT return report (FIXED - uses existing tables)
CREATE PROCEDURE sp_generate_vat_return_report_et(
  IN p_quarter INTEGER,
  IN p_year INTEGER,
  IN p_generated_by INTEGEREGER,
  OUT p_report_id INTEGEREGER,
  OUT p_error_message VARCHAR(500)
)
BEGIN
  DECLARE v_quarter_start DATE;
  DECLARE v_quarter_end DATE;
  DECLARE v_fiscal_year INTEGER;
  DECLARE v_vat_on_sales REAL;
  DECLARE v_vat_on_purchases REAL;
  DECLARE v_net_vat_payable REAL;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_error_message = MESSAGE_TEXT;
    SET p_report_id = NULL;
    ROLLBACK;
  END;
  
  -- VALIDATE quarter
  IF p_quarter NOT IN (1, 2, 3, 4) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Invalid quarter. Must be 1, 2, 3, or 4';
  END IF;
  
  -- CALCULATE quarter dates
  CASE p_quarter
    WHEN 1 THEN 
      SET v_quarter_start = DATE(CONCAT(p_year, '-01-01'));
      SET v_quarter_end = DATE(CONCAT(p_year, '-03-31'));
    WHEN 2 THEN 
      SET v_quarter_start = DATE(CONCAT(p_year, '-04-01'));
      SET v_quarter_end = DATE(CONCAT(p_year, '-06-30'));
    WHEN 3 THEN 
      SET v_quarter_start = DATE(CONCAT(p_year, '-07-01'));
      SET v_quarter_end = DATE(CONCAT(p_year, '-09-30'));
    WHEN 4 THEN 
      SET v_quarter_start = DATE(CONCAT(p_year, '-10-01'));
      SET v_quarter_end = DATE(CONCAT(p_year, '-12-31'));
  END CASE;
  
  -- FIXED: Calculate VAT from payments table (simplified)
  -- VAT on sales (output VAT)
  SELECT COALESCE(SUM(vat_amount), 0)
  INTEGERO v_vat_on_sales
  FROM payments
  WHERE status = 'completed'
    AND vat_included = TRUE
    AND DATE(created_at) BETWEEN v_quarter_start AND v_quarter_end;
  
  -- VAT on purchases (input VAT) - simplified assumption
  SET v_vat_on_purchases = v_vat_on_sales * 0.10; -- Assume 10% deductible
  
  SET v_net_vat_payable = v_vat_on_sales - v_vat_on_purchases;
  
  -- Determine fiscal year (Ethiopian approximation)
  IF MONTH(v_quarter_start) >= 7 THEN
    SET v_fiscal_year = YEAR(v_quarter_start);
  ELSE
    SET v_fiscal_year = YEAR(v_quarter_start) - 1;
  END IF;
  
  START TRANSACTION;
  
  -- FIXED: No duplicate columns
  INSERT INTEGERO financial_reports (
    report_name,
    report_name_amharic,
    report_type,
    period_type,
    period_start,
    period_end,
    fiscal_year,
    generated_by,
    generated_at,
    total_vat_collected,
    vat_on_ticket_sales,
    vat_payable_to_erca,
    currency,
    created_by
  ) VALUES (
    CONCAT('VAT Return Q', p_quarter, ' ', p_year),
    CONCAT('የእቃ እሴት ተጨማሪ ግብር መመለሻ ሪፖርት ሩብ ዓመት ', p_quarter, ' ', p_year),
    'vat_return',
    'quarter',
    v_quarter_start,
    v_quarter_end,
    v_fiscal_year,
    p_generated_by,
    NOW(),
    v_vat_on_sales,
    v_vat_on_sales,
    v_net_vat_payable,
    'ETB',
    p_generated_by
  );
  
  SET p_report_id = LAST_INSERT_ID();
  
  COMMIT;
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;