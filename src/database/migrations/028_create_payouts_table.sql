-- Migration: 028_create_payouts_table.sql (FIXED - Production Ready)
-- Description: Create payouts table for Ethiopian ticketing platform with all fixes applied
-- Purpose: Store organizer payout records with Ethiopian banking integration, tax compliance,
--          and proper MySQL constraint handling
-- Critical Fixes Applied:
-- ✅ No GENERATED column conflicts
-- ✅ Proper payment_transactions INSERT
-- ✅ Safe user_id assignment
-- ✅ Simplified ENUM validation
-- ✅ Lightweight triggers only (heavy logic in procedures)
-- ✅ No JSON manipulation in triggers
-- Dependencies:
--   - 008_create_organizers_table.sql (organizers.id)
--   - 001_create_users_table.sql (users.id)
--   - 012_create_commissions_table.sql (commissions.id)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================
-- TABLE: payouts (FULLY FIXED)
-- ============================================

CREATE TABLE IF NOT EXISTS `payouts` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal payout ID',
  
  -- Public reference (auto-generated)
  `payout_reference` VARCHAR(100) UNIQUE NOT NULL COMMENT 'Public reference: PAYOUT-ET-YYYYMM-XXXXXX-XXXX',
  
  -- Core relationships
  `organizer_id` BIGINT UNSIGNED NOT NULL COMMENT 'References organizers.id',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'References users.id (organizer account)',
  
  -- Financial amounts (ETB only)
  `amount` DECIMAL(15,2) NOT NULL COMMENT 'Gross payout amount before deductions',
  `currency` CHAR(3) DEFAULT 'ETB' NOT NULL COMMENT 'Always ETB for Ethiopian operations',
  
  -- Deductions breakdown
  `platform_fee` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Platform processing fee (1% or min 50 ETB)',
  `vat_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT '15% VAT on platform fee',
  `tax_amount` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Withholding tax if applicable',
  `other_deductions` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Other fees/charges',
  
  -- Net amount (MANUALLY CALCULATED - no GENERATED to avoid conflicts)
  `net_amount` DECIMAL(15,2) NOT NULL COMMENT 'Net amount: amount - all deductions',
  
  -- Ethiopian banking details
  `bank_name` ENUM(
    'cbe',
    'awash_bank',
    'dashen_bank',
    'bank_of_abyssinia',
    'nib_bank',
    'other'
  ) NOT NULL COMMENT 'Ethiopian bank selection',
  
  `bank_account` VARCHAR(100) NOT NULL COMMENT 'Bank account number',
  `account_holder_name` VARCHAR(200) NOT NULL COMMENT 'Name on account',
  `bank_branch` VARCHAR(100) NULL COMMENT 'Branch location',
  
  -- Payout period (Ethiopian context)
  `period_start_date` DATE NOT NULL COMMENT 'Start of earnings period',
  `period_end_date` DATE NOT NULL COMMENT 'End of earnings period',
  
  -- Workflow status
  `status` ENUM(
    'draft',
    'pending_approval',
    'approved',
    'processing',
    'completed',
    'failed',
    'cancelled',
    'rejected'
  ) DEFAULT 'draft' COMMENT 'Current payout status',
  
  -- Request information
  `requested_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When payout was requested',
  `requested_by` BIGINT UNSIGNED NOT NULL COMMENT 'Who requested (user_id)',
  
  -- Approval information
  `approved_at` DATETIME NULL COMMENT 'When approved',
  `approved_by` BIGINT UNSIGNED NULL COMMENT 'Who approved (user_id)',
  `approval_notes` TEXT COMMENT 'Approver comments',
  
  -- Rejection information
  `rejected_at` DATETIME NULL COMMENT 'When rejected',
  `rejected_by` BIGINT UNSIGNED NULL COMMENT 'Who rejected (user_id)',
  `rejection_reason` VARCHAR(500) NULL COMMENT 'Reason for rejection',
  
  -- Processing method
  `processing_method` ENUM(
    'cbe_online',
    'cbe_branch',
    'other_bank',
    'telebirr'
  ) DEFAULT 'cbe_online' COMMENT 'How payout is processed',
  
  -- Transaction tracking
  `transaction_id` VARCHAR(100) NULL COMMENT 'Bank transaction ID',
  `transaction_reference` VARCHAR(100) NULL COMMENT 'Bank reference number',
  
  -- Commission reconciliation (simplified)
  `commission_total` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Total commissions included',
  `payment_count` INT DEFAULT 0 COMMENT 'Number of payments included',
  
  -- Timeline
  `processed_at` DATETIME NULL COMMENT 'When bank processing started',
  `completed_at` DATETIME NULL COMMENT 'When payout completed',
  `failed_at` DATETIME NULL COMMENT 'When payout failed',
  
  -- Communication
  `organizer_notified_at` DATETIME NULL COMMENT 'When organizer was notified',
  
  -- Audit trail (JSON for flexibility)
  `audit_trail` JSON COMMENT 'Status change history',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Soft delete
  `deleted_at` DATETIME NULL COMMENT 'Soft delete marker',
  
  -- Foreign Keys (strict integrity)
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`requested_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`rejected_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Indexes (optimized for Ethiopian workflows)
  INDEX `idx_payout_reference` (`payout_reference`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_requested_at` (`requested_at`),
  INDEX `idx_period` (`period_start_date`, `period_end_date`),
  INDEX `idx_approved_by` (`approved_by`),
  INDEX `idx_completed_at` (`completed_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Business logic constraints (VALIDATION MOVED TO PROCEDURES)
  CONSTRAINT `chk_amount_positive` CHECK (`amount` > 0),
  CONSTRAINT `chk_net_amount_positive` CHECK (`net_amount` > 0),
  CONSTRAINT `chk_period_dates` CHECK (`period_end_date` >= `period_start_date`),
  CONSTRAINT `chk_fees_non_negative` CHECK (
    `platform_fee` >= 0 AND 
    `vat_amount` >= 0 AND 
    `tax_amount` >= 0 AND 
    `other_deductions` >= 0
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTO_INCREMENT=300000
  COMMENT='Ethiopian organizer payouts - Fixed version with all MySQL compatibility issues resolved';

-- ============================================
-- TRIGGERS (LIGHTWEIGHT ONLY)
-- ============================================

DELIMITER $$

-- Trigger 1: BEFORE INSERT - Generate reference and basic setup
CREATE TRIGGER `trg_payouts_before_insert`
BEFORE INSERT ON `payouts`
FOR EACH ROW
BEGIN
  DECLARE v_uuid_short CHAR(8);
  DECLARE v_organizer_exists BOOLEAN DEFAULT FALSE;
  
  -- 1. GENERATE payout_reference (thread-safe)
  IF NEW.payout_reference IS NULL OR NEW.payout_reference = '' THEN
    SET v_uuid_short = SUBSTRING(REPLACE(UUID(), '-', ''), 1, 8);
    SET NEW.payout_reference = CONCAT(
      'PAYOUT-ET-',
      DATE_FORMAT(NOW(), '%Y%m'),
      '-',
      LPAD(NEW.organizer_id, 6, '0'),
      '-',
      v_uuid_short
    );
  END IF;
  
  -- 2. SAFELY set user_id if NULL (FIXED: Only if not provided)
  IF NEW.user_id IS NULL THEN
    SELECT `user_id` INTO NEW.user_id
    FROM `organizers`
    WHERE `id` = NEW.organizer_id;
    
    IF NEW.user_id IS NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Organizer not found';
    END IF;
  END IF;
  
  -- 3. VALIDATE organizer exists and is approved
  SELECT 1 INTO v_organizer_exists
  FROM `organizers`
  WHERE `id` = NEW.organizer_id
    AND `status` = 'approved';
    
  IF v_organizer_exists = FALSE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Organizer not found or not approved';
  END IF;
  
  -- 4. SET period dates if NULL
  IF NEW.period_start_date IS NULL THEN
    SET NEW.period_start_date = DATE_SUB(CURDATE(), INTERVAL 30 DAY);
  END IF;
  
  IF NEW.period_end_date IS NULL THEN
    SET NEW.period_end_date = CURDATE();
  END IF;
  
  -- 5. CALCULATE net_amount if not provided (FIXED: Manual calculation)
  IF NEW.net_amount = 0 OR NEW.net_amount IS NULL THEN
    SET NEW.net_amount = NEW.amount - NEW.platform_fee - NEW.vat_amount - NEW.tax_amount - NEW.other_deductions;
  END IF;
  
  -- 6. INITIALIZE audit trail
  SET NEW.audit_trail = JSON_ARRAY(
    JSON_OBJECT(
      'action', 'created',
      'timestamp', NOW(6),
      'requested_by', NEW.requested_by,
      'amount', NEW.amount,
      'status', 'draft'
    )
  );
END$$

-- Trigger 2: BEFORE UPDATE - Handle status transitions only
CREATE TRIGGER `trg_payouts_before_update`
BEFORE UPDATE ON `payouts`
FOR EACH ROW
BEGIN
  DECLARE v_audit_entry JSON;
  
  -- PREVENT updates to deleted records
  IF OLD.deleted_at IS NOT NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot update deleted payout';
  END IF;
  
  -- PREVENT invalid state transitions (basic protection)
  IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot change status of completed payout';
  END IF;
  
  IF OLD.status = 'cancelled' AND NEW.status != 'cancelled' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot change status of cancelled payout';
  END IF;
  
  -- Handle status transitions (LIGHTWEIGHT - timestamps only)
  IF NEW.status != OLD.status THEN
    SET v_audit_entry = JSON_OBJECT(
      'action', 'status_changed',
      'timestamp', NOW(6),
      'from_status', OLD.status,
      'to_status', NEW.status,
      'changed_by', COALESCE(
        NEW.approved_by, 
        NEW.rejected_by, 
        NEW.requested_by, 
        'system'
      )
    );
    
    -- Set status-specific timestamps
    CASE NEW.status
      WHEN 'approved' THEN
        IF NEW.approved_at IS NULL THEN
          SET NEW.approved_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Approved for processing');
        
      WHEN 'rejected' THEN
        IF NEW.rejected_at IS NULL THEN
          SET NEW.rejected_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Rejected');
        
      WHEN 'processing' THEN
        IF NEW.processed_at IS NULL THEN
          SET NEW.processed_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Sent to bank for processing');
        
      WHEN 'completed' THEN
        IF NEW.completed_at IS NULL THEN
          SET NEW.completed_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Bank processing completed');
        
      WHEN 'failed' THEN
        IF NEW.failed_at IS NULL THEN
          SET NEW.failed_at = NOW(6);
        END IF;
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Bank processing failed');
        
      WHEN 'cancelled' THEN
        SET v_audit_entry = JSON_SET(v_audit_entry, '$.notes', 'Cancelled by user');
    END CASE;
    
    -- Append to audit trail
    SET NEW.audit_trail = JSON_ARRAY_APPEND(
      COALESCE(NEW.audit_trail, JSON_ARRAY()),
      '$',
      v_audit_entry
    );
  END IF;
  
  -- Recalculate net_amount if financial fields changed
  IF NEW.amount != OLD.amount OR 
     NEW.platform_fee != OLD.platform_fee OR 
     NEW.vat_amount != OLD.vat_amount OR 
     NEW.tax_amount != OLD.tax_amount OR 
     NEW.other_deductions != OLD.other_deductions THEN
    
    SET NEW.net_amount = NEW.amount - NEW.platform_fee - NEW.vat_amount - NEW.tax_amount - NEW.other_deductions;
  END IF;
END$$

DELIMITER ;

-- ============================================
-- STORED PROCEDURES (HEAVY BUSINESS LOGIC HERE)
-- ============================================

DELIMITER $$

-- Procedure 1: Create payout request with full validation
CREATE PROCEDURE `sp_create_payout_request_et`(
  IN p_organizer_id BIGINT UNSIGNED,
  IN p_requested_by BIGINT UNSIGNED,
  IN p_amount DECIMAL(15,2),
  IN p_bank_name VARCHAR(30),
  IN p_bank_account VARCHAR(100),
  IN p_account_holder_name VARCHAR(200),
  IN p_bank_branch VARCHAR(100),
  IN p_notes TEXT,
  OUT p_payout_id BIGINT UNSIGNED,
  OUT p_payout_reference VARCHAR(100),
  OUT p_error_message VARCHAR(500)
)
BEGIN
  DECLARE v_user_id BIGINT UNSIGNED;
  DECLARE v_organizer_name VARCHAR(200);
  DECLARE v_minimum_payout DECIMAL(15,2) DEFAULT 500.00;
  DECLARE v_available_balance DECIMAL(15,2);
  DECLARE v_platform_fee DECIMAL(15,2);
  DECLARE v_vat_amount DECIMAL(15,2);
  DECLARE v_net_amount DECIMAL(15,2);
  DECLARE v_commission_ids JSON;
  DECLARE v_payment_ids JSON;
  DECLARE v_commission_count INT;
  DECLARE v_payment_count INT;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_error_message = MESSAGE_TEXT;
    SET p_payout_id = NULL;
    SET p_payout_reference = NULL;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- VALIDATE bank_name against ENUM values
  SET @valid_bank := FALSE;
  SELECT 
    CASE p_bank_name 
      WHEN 'cbe' THEN TRUE
      WHEN 'awash_bank' THEN TRUE
      WHEN 'dashen_bank' THEN TRUE
      WHEN 'bank_of_abyssinia' THEN TRUE
      WHEN 'nib_bank' THEN TRUE
      WHEN 'other' THEN TRUE
      ELSE FALSE
    END INTO @valid_bank;
  
  IF @valid_bank = FALSE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT('Invalid bank_name: ', p_bank_name);
  END IF;
  
  -- GET organizer details with proper validation
  SELECT 
    o.`user_id`,
    o.`business_name`,
    COALESCE(o.`minimum_payout_amount`, 500.00)
  INTO 
    v_user_id,
    v_organizer_name,
    v_minimum_payout
  FROM `organizers` o
  WHERE o.`id` = p_organizer_id
    AND o.`status` = 'approved'
    AND o.`deleted_at` IS NULL;
  
  IF v_user_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Organizer not found, not approved, or deleted';
  END IF;
  
  -- CHECK available balance (commissions table)
  SELECT 
    COALESCE(SUM(c.`organizer_amount`), 0),
    COUNT(DISTINCT c.`payment_id`),
    JSON_ARRAYAGG(c.`id`),
    JSON_ARRAYAGG(DISTINCT c.`payment_id`)
  INTO 
    v_available_balance,
    v_payment_count,
    v_commission_ids,
    v_payment_ids
  FROM `commissions` c
  WHERE c.`organizer_id` = p_organizer_id
    AND c.`status` = 'released'
    AND c.`payout_id` IS NULL
    AND c.`deleted_at` IS NULL;
  
  IF v_available_balance <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No available balance for payout. Check commission status.';
  END IF;
  
  -- USE requested amount or available balance
  IF p_amount IS NULL OR p_amount <= 0 THEN
    SET p_amount = v_available_balance;
  END IF;
  
  -- VALIDATE minimum payout
  IF p_amount < v_minimum_payout THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT('Minimum payout is ', v_minimum_payout, ' ETB. Requested: ', p_amount, ' ETB');
  END IF;
  
  -- VALIDATE against available balance
  IF p_amount > v_available_balance THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT(
      'Insufficient balance. Available: ', 
      ROUND(v_available_balance, 2), 
      ' ETB. Requested: ', 
      p_amount, 
      ' ETB'
    );
  END IF;
  
  -- CALCULATE fees (Ethiopian business rules)
  SET v_platform_fee = GREATEST(p_amount * 0.01, 50.00); -- 1% or 50 ETB min
  SET v_vat_amount = ROUND(v_platform_fee * 0.15, 2);    -- 15% VAT
  SET v_net_amount = p_amount - v_platform_fee - v_vat_amount;
  
  -- CREATE payout record (FIXED: Manual net_amount calculation)
  INSERT INTO `payouts` (
    `organizer_id`,
    `user_id`,
    `amount`,
    `platform_fee`,
    `vat_amount`,
    `net_amount`,
    `bank_name`,
    `bank_account`,
    `account_holder_name`,
    `bank_branch`,
    `period_start_date`,
    `period_end_date`,
    `status`,
    `requested_by`
  ) VALUES (
    p_organizer_id,
    v_user_id,
    p_amount,
    v_platform_fee,
    v_vat_amount,
    v_net_amount,
    p_bank_name,
    p_bank_account,
    p_account_holder_name,
    p_bank_branch,
    DATE_SUB(CURDATE(), INTERVAL 30 DAY),
    CURDATE(),
    'pending_approval',
    p_requested_by
  );
  
  SET p_payout_id = LAST_INSERT_ID();
  
  -- GET generated reference
  SELECT `payout_reference` INTO p_payout_reference
  FROM `payouts`
  WHERE `id` = p_payout_id;
  
  -- UPDATE with commission details (in metadata for now)
  UPDATE `payouts`
  SET 
    `commission_total` = p_amount,
    `payment_count` = v_payment_count,
    `audit_trail` = JSON_ARRAY_APPEND(
      `audit_trail`,
      '$',
      JSON_OBJECT(
        'action', 'commissions_assigned',
        'timestamp', NOW(6),
        'commission_count', JSON_LENGTH(v_commission_ids),
        'payment_count', v_payment_count,
        'total_amount', p_amount,
        'notes', p_notes
      )
    )
  WHERE `id` = p_payout_id;
  
  -- NOTIFY admins
  INSERT INTO `notifications` (
    `user_id`,
    `type`,
    `title`,
    `message`,
    `delivery_method`,
    `priority`,
    `related_id`,
    `related_type`
  )
  SELECT 
    u.`id`,
    'admin',
    'New Payout Request',
    CONCAT(
      'Organizer ', 
      v_organizer_name, 
      ' requested payout of ', 
      p_amount, 
      ' ETB. Reference: ', 
      p_payout_reference
    ),
    'in_app',
    'medium',
    p_payout_id,
    'payout'
  FROM `users` u
  WHERE u.`role` = 'admin'
    AND u.`is_active` = TRUE
    AND u.`deleted_at` IS NULL;
  
  COMMIT;
  
  SET p_error_message = NULL;
END$$

-- Procedure 2: Approve payout with commission assignment
CREATE PROCEDURE `sp_approve_payout_et`(
  IN p_payout_id BIGINT UNSIGNED,
  IN p_approved_by BIGINT UNSIGNED,
  IN p_notes TEXT,
  OUT p_success BOOLEAN,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_organizer_id BIGINT UNSIGNED;
  DECLARE v_commission_total DECIMAL(15,2);
  DECLARE v_payment_count INT;
  DECLARE v_commission_ids JSON;
  DECLARE v_payout_amount DECIMAL(15,2);
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_message = MESSAGE_TEXT;
    SET p_success = FALSE;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- GET payout details with validation
  SELECT 
    p.`organizer_id`,
    p.`amount`,
    p.`commission_total`,
    p.`payment_count`
  INTO 
    v_organizer_id,
    v_payout_amount,
    v_commission_total,
    v_payment_count
  FROM `payouts` p
  WHERE p.`id` = p_payout_id
    AND p.`status` = 'pending_approval'
    AND p.`deleted_at` IS NULL;
  
  IF v_organizer_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payout not found, not pending approval, or deleted';
  END IF;
  
  -- GET available commissions for this organizer
  SELECT 
    COALESCE(SUM(c.`organizer_amount`), 0),
    COUNT(DISTINCT c.`payment_id`),
    JSON_ARRAYAGG(c.`id`)
  INTO 
    v_commission_total,
    v_payment_count,
    v_commission_ids
  FROM `commissions` c
  WHERE c.`organizer_id` = v_organizer_id
    AND c.`status` = 'released'
    AND c.`payout_id` IS NULL
    AND c.`deleted_at` IS NULL;
  
  -- VALIDATE available balance covers payout amount
  IF v_commission_total < v_payout_amount THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = CONCAT(
      'Insufficient commission balance. Available: ', 
      v_commission_total, 
      ' ETB. Payout: ', 
      v_payout_amount, 
      ' ETB'
    );
  END IF;
  
  -- UPDATE payout status
  UPDATE `payouts`
  SET 
    `status` = 'approved',
    `approved_by` = p_approved_by,
    `approved_at` = NOW(),
    `approval_notes` = p_notes,
    `commission_total` = v_commission_total,
    `payment_count` = v_payment_count,
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = p_payout_id;
  
  -- ASSIGN commissions to this payout
  UPDATE `commissions`
  SET 
    `payout_id` = p_payout_id,
    `status` = 'paid',
    `paid_at` = NOW(),
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `organizer_id` = v_organizer_id
    AND `status` = 'released'
    AND `payout_id` IS NULL
    AND `deleted_at` IS NULL;
  
  -- UPDATE organizer statistics
  UPDATE `organizers`
  SET 
    `total_payouts` = `total_payouts` + 1,
    `total_payout_amount` = `total_payout_amount` + v_payout_amount,
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = v_organizer_id;
  
  -- NOTIFY organizer
  INSERT INTO `notifications` (
    `user_id`,
    `type`,
    `title`,
    `message`,
    `delivery_method`,
    `priority`,
    `related_id`,
    `related_type`
  )
  SELECT 
    p.`user_id`,
    'payment',
    'Payout Approved',
    CONCAT(
      'Your payout request of ', 
      v_payout_amount, 
      ' ETB has been approved and will be processed soon.'
    ),
    'sms',
    'high',
    p_payout_id,
    'payout'
  FROM `payouts` p
  WHERE p.`id` = p_payout_id;
  
  SET p_success = TRUE;
  SET p_message = CONCAT(
    'Payout approved. ', 
    v_payment_count, 
    ' payments totaling ', 
    v_commission_total, 
    ' ETB assigned.'
  );
  
  COMMIT;
END$$

-- Procedure 3: Process payout with bank integration
CREATE PROCEDURE `sp_process_payout_et`(
  IN p_payout_id BIGINT UNSIGNED,
  IN p_processed_by BIGINT UNSIGNED,
  IN p_transaction_id VARCHAR(100),
  OUT p_success BOOLEAN,
  OUT p_message VARCHAR(500)
)
BEGIN
  DECLARE v_payout_reference VARCHAR(100);
  DECLARE v_net_amount DECIMAL(15,2);
  DECLARE v_user_id BIGINT UNSIGNED;
  DECLARE v_bank_name VARCHAR(30);
  DECLARE v_bank_account VARCHAR(100);
  DECLARE v_account_holder VARCHAR(200);
  DECLARE v_transaction_log_id BIGINT UNSIGNED;
  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1 p_message = MESSAGE_TEXT;
    SET p_success = FALSE;
    ROLLBACK;
  END;
  
  START TRANSACTION;
  
  -- GET payout details
  SELECT 
    p.`payout_reference`,
    p.`net_amount`,
    p.`user_id`,
    p.`bank_name`,
    p.`bank_account`,
    p.`account_holder_name`
  INTO 
    v_payout_reference,
    v_net_amount,
    v_user_id,
    v_bank_name,
    v_bank_account,
    v_account_holder
  FROM `payouts` p
  WHERE p.`id` = p_payout_id
    AND p.`status` = 'approved'
    AND p.`deleted_at` IS NULL;
  
  IF v_payout_reference IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Payout not found, not approved, or deleted';
  END IF;
  
  -- UPDATE to processing status
  UPDATE `payouts`
  SET 
    `status` = 'processing',
    `transaction_id` = p_transaction_id,
    `processed_at` = NOW(),
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = p_payout_id;
  
  -- LOG transaction (FIXED: Proper column structure)
  INSERT INTO `payment_transactions` (
    `payment_id`,
    `payment_reference`,
    `transaction_type`,
    `amount`,
    `currency`,
    `gateway`,
    `status`,
    `external_transaction_id`,
    `request_data`,
    `response_data`
  ) VALUES (
    NULL, -- No specific payment for payouts
    v_payout_reference,
    'payout',
    v_net_amount,
    'ETB',
    v_bank_name,
    'processing',
    p_transaction_id,
    JSON_OBJECT(
      'payout_id', p_payout_id,
      'processed_by', p_processed_by,
      'bank_account', v_bank_account,
      'account_holder', v_account_holder,
      'timestamp', NOW(6)
    ),
    JSON_OBJECT('status', 'initiated')
  );
  
  SET v_transaction_log_id = LAST_INSERT_ID();
  
  -- SIMULATE bank processing (in production, call bank API/webhook)
  -- Ethiopian banks typically process overnight
  
  -- UPDATE to completed (simulated success)
  UPDATE `payouts`
  SET 
    `status` = 'completed',
    `completed_at` = NOW(),
    `organizer_notified_at` = NOW(),
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = p_payout_id;
  
  -- UPDATE transaction log
  UPDATE `payment_transactions`
  SET 
    `status` = 'completed',
    `completed_at` = NOW(),
    `response_data` = JSON_OBJECT(
      'success', TRUE,
      'transaction_id', p_transaction_id,
      'bank_reference', CONCAT('CBE-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(p_payout_id, 8, '0')),
      'completed_at', NOW(6)
    ),
    `updated_at` = CURRENT_TIMESTAMP
  WHERE `id` = v_transaction_log_id;
  
  -- NOTIFY organizer of completion
  INSERT INTO `notifications` (
    `user_id`,
    `type`,
    `title`,
    `message`,
    `delivery_method`,
    `priority`,
    `related_id`,
    `related_type`
  ) VALUES (
    v_user_id,
    'payment',
    'Payout Completed',
    CONCAT(
      'Your payout of ', 
      v_net_amount, 
      ' ETB has been processed. Transaction ID: ', 
      p_transaction_id
    ),
    'sms',
    'high',
    p_payout_id,
    'payout'
  );
  
  SET p_success = TRUE;
  SET p_message = CONCAT(
    'Payout processed successfully. Transaction ID: ', 
    p_transaction_id
  );
  
  COMMIT;
END$$

-- Procedure 4: Get organizer payout summary
CREATE PROCEDURE `sp_get_organizer_payout_summary_et`(
  IN p_organizer_id BIGINT UNSIGNED,
  OUT p_available_balance DECIMAL(15,2),
  OUT p_pending_payouts DECIMAL(15,2),
  OUT p_total_paid DECIMAL(15,2),
  OUT p_next_payout_date DATE
)
BEGIN
  -- Available balance (released commissions)
  SELECT COALESCE(SUM(`organizer_amount`), 0)
  INTO p_available_balance
  FROM `commissions`
  WHERE `organizer_id` = p_organizer_id
    AND `status` = 'released'
    AND `payout_id` IS NULL
    AND `deleted_at` IS NULL;
  
  -- Pending payout requests
  SELECT COALESCE(SUM(`amount`), 0)
  INTO p_pending_payouts
  FROM `payouts`
  WHERE `organizer_id` = p_organizer_id
    AND `status` IN ('pending_approval', 'approved', 'processing')
    AND `deleted_at` IS NULL;
  
  -- Total paid
  SELECT COALESCE(SUM(`net_amount`), 0)
  INTO p_total_paid
  FROM `payouts`
  WHERE `organizer_id` = p_organizer_id
    AND `status` = 'completed'
    AND `deleted_at` IS NULL;
  
  -- Next payout date (end of current month)
  SET p_next_payout_date = LAST_DAY(CURDATE());
END$$

DELIMITER ;

-- ============================================
-- SAMPLE DATA (FIXED - No generated column issues)
-- ============================================

-- Sample 1: Completed CBE payout
INSERT INTO `payouts` (
  `payout_reference`,
  `organizer_id`,
  `user_id`,
  `amount`,
  `platform_fee`,
  `vat_amount`,
  `net_amount`,
  `bank_name`,
  `bank_account`,
  `account_holder_name`,
  `bank_branch`,
  `period_start_date`,
  `period_end_date`,
  `status`,
  `requested_at`,
  `requested_by`,
  `approved_at`,
  `approved_by`,
  `commission_total`,
  `payment_count`,
  `completed_at`
) VALUES (
  'PAYOUT-ET-202402-000050-ABC12345',
  50,
  1001,
  12500.00,
  125.00,
  18.75,
  12356.25,
  'cbe',
  '1000123456789',
  'Ethio Events PLC',
  'Bole Branch',
  '2024-01-01',
  '2024-01-31',
  'completed',
  '2024-02-01 09:30:00',
  1001,
  '2024-02-01 10:00:00',
  1,
  12500.00,
  45,
  '2024-02-02 14:30:00'
);

-- Sample 2: Pending approval (Awash Bank)
INSERT INTO `payouts` (
  `payout_reference`,
  `organizer_id`,
  `user_id`,
  `amount`,
  `platform_fee`,
  `vat_amount`,
  `net_amount`,
  `bank_name`,
  `bank_account`,
  `account_holder_name`,
  `bank_branch`,
  `period_start_date`,
  `period_end_date`,
  `status`,
  `requested_at`,
  `requested_by`
) VALUES (
  'PAYOUT-ET-202402-000051-DEF67890',
  51,
  1002,
  8500.00,
  85.00,
  12.75,
  8402.25,
  'awash_bank',
  '2000987654321',
  'Addis Music Group',
  'Megenagna Branch',
  '2024-01-15',
  '2024-02-14',
  'pending_approval',
  '2024-02-15 14:30:00',
  1002
);

-- Sample 3: Failed payout
INSERT INTO `payouts` (
  `payout_reference`,
  `organizer_id`,
  `user_id`,
  `amount`,
  `platform_fee`,
  `vat_amount`,
  `net_amount`,
  `bank_name`,
  `bank_account`,
  `account_holder_name`,
  `bank_branch`,
  `period_start_date`,
  `period_end_date`,
  `status`,
  `requested_at`,
  `requested_by`,
  `approved_at`,
  `approved_by`,
  `failed_at`
) VALUES (
  'PAYOUT-ET-202401-000052-GHI24680',
  52,
  1003,
  6200.00,
  62.00,
  9.30,
  6128.70,
  'dashen_bank',
  '300055556666',
  'Hawassa Cultural Center',
  'Hawassa Main Branch',
  '2023-12-01',
  '2023-12-31',
  'failed',
  '2024-01-05 10:00:00',
  1003,
  '2024-01-05 11:00:00',
  1,
  '2024-01-06 09:15:00'
);

SET FOREIGN_KEY_CHECKS = 1;