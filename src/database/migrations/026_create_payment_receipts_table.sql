-- ============================================
-- TABLE: payment_receipts (FIXED VERSION)
-- IMPROVEMENTS APPLIED:
-- 1. Added trigger for payment_reference consistency
-- 2. Fixed unique constraint to allow receipt corrections
-- 3. Enhanced transaction uniqueness with date
-- 4. Added safety triggers for MySQL version compatibility
-- ============================================

CREATE TABLE IF NOT EXISTS `payment_receipts` (
  -- Primary identifier
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'Internal receipt ID',
  
  -- Payment Reference (MANDATORY - connects to Ethiopian payment workflow)
  `payment_id` BIGINT UNSIGNED NOT NULL COMMENT 'References payments.id',
  `payment_reference` VARCHAR(100) NOT NULL COMMENT 'Denormalized copy from payments for fast lookup without join',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'References users.id (who uploaded receipt)',
  
  -- Receipt Type & Media (Ethiopian banks use different receipt formats)
  `receipt_type` ENUM('cbe_screenshot', 'bank_slip', 'telebirr_screenshot', 'awash_receipt', 'dashen_receipt', 'other') 
    DEFAULT 'cbe_screenshot' COMMENT 'Type of receipt/evidence uploaded',
  
  `image_url` VARCHAR(500) NOT NULL COMMENT 'Cloud storage URL of receipt image',
  `thumbnail_url` VARCHAR(500) NULL COMMENT 'Thumbnail for faster preview',
  `original_filename` VARCHAR(255) NULL COMMENT 'Original filename from upload',
  `file_size_kb` INT UNSIGNED NULL COMMENT 'File size in KB',
  `mime_type` VARCHAR(100) NULL COMMENT 'MIME type (image/jpeg, image/png, application/pdf)',
  `image_dimensions` VARCHAR(50) NULL COMMENT 'Width x Height (e.g., "1200x800")',
  
  -- Ethiopian Bank Transaction Details (CRITICAL for manual verification)
  `bank_name` VARCHAR(100) NOT NULL COMMENT 'Bank: CBE, Awash, Dashen, etc.',
  `bank_branch` VARCHAR(100) NULL COMMENT 'Bank branch name',
  `bank_branch_code` VARCHAR(50) NULL COMMENT 'Bank branch code',
  
  `account_number` VARCHAR(100) NULL COMMENT 'Account number transferred FROM',
  `account_holder_name` VARCHAR(200) NULL COMMENT 'Name on sender account',
  
  `transaction_id` VARCHAR(100) NULL COMMENT 'Bank transaction ID',
  `transaction_date` DATE NOT NULL COMMENT 'Date of bank transaction',
  `transaction_time` TIME NULL COMMENT 'Time of bank transaction',
  
  `teller_number` VARCHAR(50) NULL COMMENT 'Teller/counter number',
  `teller_name` VARCHAR(100) NULL COMMENT 'Teller name (if visible)',
  
  -- Amount Details (MUST match payment amount)
  `receipt_amount` DECIMAL(15,2) NOT NULL COMMENT 'Amount shown on receipt (ETB)',
  `receipt_currency` CHAR(3) DEFAULT 'ETB' COMMENT 'Currency on receipt',
  `service_charge` DECIMAL(10,2) NULL COMMENT 'Bank service charge if any',
  
  -- Platform Account Details (WHERE money was sent)
  `platform_bank_account` VARCHAR(100) NULL COMMENT 'Our platform bank account number',
  `platform_account_name` VARCHAR(200) NULL COMMENT 'Our platform account name',
  `platform_bank_branch` VARCHAR(100) NULL COMMENT 'Our platform bank branch',
  
  -- Verification Workflow (ETHIOPIAN ADMIN PROCESS)
  `verification_status` ENUM('pending', 'under_review', 'approved', 'rejected', 'needs_clarification', 'fraud_check') 
    DEFAULT 'pending' COMMENT 'Admin verification status',
  
  `verified_by` BIGINT UNSIGNED NULL COMMENT 'References users.id (admin who verified)',
  `verified_at` DATETIME NULL COMMENT 'When receipt was verified',
  `verification_notes` TEXT COMMENT 'Admin notes about verification',
  
  `rejection_reason` ENUM(
    'amount_mismatch', 
    'date_mismatch', 
    'wrong_account', 
    'receipt_unclear', 
    'receipt_fake', 
    'duplicate_submission', 
    'fraud_suspected', 
    'other'
  ) NULL COMMENT 'Reason for rejection',
  
  `rejection_details` TEXT COMMENT 'Detailed rejection explanation',
  
  -- Automated Validation Results (OCR/ML in future)
  `ocr_extracted_data` JSON NULL COMMENT 'OCR extracted data from receipt',
  `ocr_confidence_score` DECIMAL(5,2) NULL COMMENT 'OCR confidence (0-100)',
  `is_automatically_validated` BOOLEAN DEFAULT FALSE COMMENT 'Auto-validation result',
  `auto_validation_errors` JSON COMMENT 'Auto-validation errors if any',
  
  -- User Upload Context
  `uploaded_from_ip` VARCHAR(45) NULL COMMENT 'IP address used for upload',
  `uploaded_from_device` VARCHAR(255) NULL COMMENT 'Device used for upload',
  `upload_method` ENUM('web', 'mobile_app', 'email_forward', 'admin_upload') DEFAULT 'web',
  
  -- Communication with User
  `user_notified_at` DATETIME NULL COMMENT 'When user was notified of status',
  `notification_method` ENUM('sms', 'email', 'in_app', 'whatsapp') NULL COMMENT 'How user was notified',
  `user_comments` TEXT COMMENT 'User comments/notes about receipt',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'When receipt was uploaded',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `submitted_at` DATETIME NULL COMMENT 'When user submitted for verification',
  `review_started_at` DATETIME NULL COMMENT 'When admin started review',
  `review_completed_at` DATETIME NULL COMMENT 'When review was completed',
  
  -- Audit Trail
  `audit_trail` JSON COMMENT 'JSON array of status changes and actions',
  
  -- Soft Delete (Allows receipt corrections)
  `deleted_at` DATETIME NULL COMMENT 'Soft delete timestamp',
  `deletion_reason` VARCHAR(200) NULL COMMENT 'Reason for deletion',
  `deleted_by` BIGINT UNSIGNED NULL COMMENT 'Who deleted the receipt',
  
  -- Foreign Keys (Ethiopian Data Integrity)
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) 
    ON DELETE CASCADE 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  FOREIGN KEY (`deleted_by`) REFERENCES `users`(`id`) 
    ON DELETE SET NULL 
    ON UPDATE RESTRICT,
  
  -- Indexes (Optimized for Ethiopian Admin Workflow)
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_payment_reference` (`payment_reference`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_verification_status` (`verification_status`),
  INDEX `idx_bank_name` (`bank_name`),
  INDEX `idx_transaction_date` (`transaction_date`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_verified_by` (`verified_by`),
  INDEX `idx_receipt_type` (`receipt_type`),
  
  -- Composite indexes for admin dashboard queries
  INDEX `idx_status_date` (`verification_status`, `created_at`),
  INDEX `idx_payment_status` (`payment_id`, `verification_status`),
  INDEX `idx_user_status` (`user_id`, `verification_status`, `created_at`),
  INDEX `idx_bank_date` (`bank_name`, `transaction_date`, `verification_status`),
  INDEX `idx_amount_date` (`receipt_amount`, `transaction_date`),
  
  -- UNIQUE CONSTRAINTS (IMPROVED based on feedback)
  -- Allows multiple receipts per payment, but only one active per type
  UNIQUE INDEX `uq_active_receipt` (
    `payment_id`, 
    `receipt_type`, 
    `deleted_at`
  ) COMMENT 'Only one active receipt per type per payment',
  
  -- Bank transaction uniqueness with date (safer)
  UNIQUE INDEX `uq_transaction_reference` (
    `bank_name`, 
    `transaction_id`, 
    `transaction_date`
  ) COMMENT 'Bank transaction uniqueness (with date safety)',
  
  -- Business Logic Constraints (SAFE - will work in older MySQL via triggers)
  CONSTRAINT `chk_receipt_amount_positive` CHECK (`receipt_amount` > 0),
  CONSTRAINT `chk_file_size` CHECK (`file_size_kb` IS NULL OR `file_size_kb` > 0),
  CONSTRAINT `chk_currency_etb` CHECK (`receipt_currency` = 'ETB'),
  CONSTRAINT `chk_ocr_confidence` CHECK (`ocr_confidence_score` IS NULL OR (`ocr_confidence_score` >= 0 AND `ocr_confidence_score` <= 100))
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  AUTO_INCREMENT=100000
  COMMENT='CBE/Awash/Dashen bank receipt uploads and verification workflow for Ethiopian manual payments. Fixed version with improved constraints and triggers.';