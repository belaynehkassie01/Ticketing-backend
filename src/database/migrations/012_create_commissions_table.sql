-- Migration: 012_create_commissions_table.sql
-- Description: Store commission calculations for Ethiopian platform revenue sharing
-- Dependencies: Requires payments, organizers, events tables
-- Ethiopian Context: 15% VAT calculations, Ethiopian tax compliance
-- MySQL Compatibility: Fixed string concatenation, proper DECIMAL precision, explicit FK handling

-- ============================================
-- TABLE: commissions
-- Purpose: Track platform commission calculations with Ethiopian VAT compliance
-- Important: All financial consistency rules enforced at application level
-- ============================================

CREATE TABLE IF NOT EXISTS `commissions` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  
  -- Core References
  `payment_id` BIGINT UNSIGNED NOT NULL COMMENT 'Reference to the original payment',
  `organizer_id` BIGINT UNSIGNED NOT NULL,
  `event_id` BIGINT UNSIGNED NOT NULL,
  
  -- Ethiopian Financial Calculations (ETH larger for platform scale)
  `ticket_amount` DECIMAL(15,2) NOT NULL COMMENT 'Gross ticket amount in ETB',
  `commission_rate` DECIMAL(5,2) NOT NULL COMMENT 'Platform commission percentage (5-15%)',
  `commission_amount` DECIMAL(15,2) NOT NULL COMMENT 'commission_rate * ticket_amount',
  
  -- Ethiopian VAT (15%) Calculations
  `vat_rate` DECIMAL(5,2) DEFAULT 15.00 COMMENT 'Ethiopian VAT rate (15%)',
  `vat_amount` DECIMAL(15,2) NOT NULL COMMENT 'VAT on ticket_amount (payable to ERA)',
  `vat_included` BOOLEAN DEFAULT TRUE COMMENT 'Whether VAT is included in ticket price',
  `vat_liability` ENUM('organizer', 'platform', 'shared') DEFAULT 'organizer' COMMENT 'Who is liable for VAT payment',
  
  -- Net Amounts (VAT-adjusted)
  `net_ticket_amount` DECIMAL(15,2) NOT NULL COMMENT 'ticket_amount - vat_amount (if vat_included)',
  `organizer_amount` DECIMAL(15,2) NOT NULL COMMENT 'Net amount to organizer after commission and VAT',
  `platform_amount` DECIMAL(15,2) NOT NULL COMMENT 'Platform earnings (commission only, VAT separate)',
  
  -- Commission Status & Release
  `status` ENUM('pending', 'held', 'released', 'paid', 'refunded', 'cancelled') DEFAULT 'pending',
  `held_until` DATETIME NULL COMMENT 'Date when commission can be released',
  `released_at` DATETIME NULL COMMENT 'When commission was made available for payout',
  `paid_at` DATETIME NULL COMMENT 'When commission was actually paid to platform',
  
  -- Payout Linkage (Soft references - may not exist yet)
  `payout_id` BIGINT UNSIGNED NULL COMMENT 'Link to platform payout record (soft reference)',
  `organizer_payout_id` BIGINT UNSIGNED NULL COMMENT 'Link to organizer payout record (soft reference)',
  
  -- Ethiopian Tax Compliance
  `tax_withheld` BOOLEAN DEFAULT FALSE COMMENT 'Whether tax was withheld at source',
  `tax_withheld_amount` DECIMAL(15,2) DEFAULT 0.00,
  `tax_reference` VARCHAR(100),
  `tax_authority` ENUM('era', 'tir', 'customs') DEFAULT 'era' COMMENT 'Ethiopian tax authority',
  
  -- Audit & Verification
  `calculated_by_system` BOOLEAN DEFAULT TRUE,
  `calculation_notes` TEXT,
  `verified_by` BIGINT UNSIGNED NULL COMMENT 'Admin who verified calculation',
  `verified_at` DATETIME NULL,
  
  -- Reversal Tracking (for refunds/cancellations)
  `is_reversed` BOOLEAN DEFAULT FALSE,
  `reversed_at` DATETIME NULL,
  `reversal_reason` ENUM('refund', 'cancellation', 'adjustment', 'fraud') NULL,
  `reversal_reference_id` BIGINT UNSIGNED NULL COMMENT 'Link to reversal commission record',
  
  -- Metadata
  `meta_data` JSON DEFAULT NULL COMMENT 'Calculation details, audit trail',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Keys (Core references only, payout references are soft)
  FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`organizer_id`) REFERENCES `organizers`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (`verified_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Note: payout_id and organizer_payout_id are soft references
  -- They will reference payouts table (to be created later)
  -- Application logic handles consistency
  
  -- Indexes
  INDEX `idx_payment` (`payment_id`),
  INDEX `idx_organizer` (`organizer_id`),
  INDEX `idx_event` (`event_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_held_until` (`held_until`),
  INDEX `idx_released_at` (`released_at`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  -- Composite Indexes for Performance
  INDEX `idx_organizer_status` (`organizer_id`, `status`),
  INDEX `idx_event_status` (`event_id`, `status`),
  INDEX `idx_payment_organizer` (`payment_id`, `organizer_id`),
  INDEX `idx_status_time` (`status`, `created_at`),
  INDEX `idx_organizer_period` (`organizer_id`, `created_at`),
  
  -- Unique constraint to prevent duplicate commissions per payment
  UNIQUE KEY `uq_payment_commission` (`payment_id`)
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Ethiopian commission calculations with 15% VAT compliance. Amounts in ETB. Payout references are soft. All financial consistency enforced in application.';

-- ============================================
-- VIEWS FOR FINANCIAL REPORTING (FIXED STRING CONCATENATION)
-- ============================================

-- View for organizer commission dashboard
CREATE OR REPLACE VIEW `vw_organizer_commissions` AS
SELECT 
    c.id,
    c.organizer_id,
    o.business_name,
    c.event_id,
    e.title as event_title,
    c.ticket_amount,
    c.commission_rate,
    c.commission_amount,
    c.vat_amount,
    c.organizer_amount,
    c.status,
    c.created_at,
    c.released_at,
    c.paid_at,
    -- Financial summary
    CASE 
        WHEN c.status = 'paid' THEN c.organizer_amount
        WHEN c.status = 'released' THEN c.organizer_amount
        ELSE 0.00
    END as available_amount,
    -- Status display (FIXED: Using CONCAT instead of ||)
    CASE c.status
        WHEN 'pending' THEN 'Pending Release'
        WHEN 'held' THEN CONCAT('Held Until ', DATE_FORMAT(c.held_until, '%Y-%m-%d'))
        WHEN 'released' THEN 'Available for Payout'
        WHEN 'paid' THEN 'Paid to Organizer'
        WHEN 'refunded' THEN 'Refunded'
        ELSE c.status
    END as status_display,
    -- Ethiopian VAT information
    CONCAT(c.vat_rate, '%') as vat_rate_display,
    CASE c.vat_included
        WHEN TRUE THEN 'VAT Included'
        ELSE 'VAT Excluded'
    END as vat_status,
    -- VAT liability clarity
    CASE c.vat_liability
        WHEN 'organizer' THEN 'Organizer liable for VAT'
        WHEN 'platform' THEN 'Platform liable for VAT'
        WHEN 'shared' THEN 'VAT liability shared'
        ELSE 'VAT status pending'
    END as vat_liability_display
FROM `commissions` c
LEFT JOIN `organizers` o ON c.organizer_id = o.id
LEFT JOIN `events` e ON c.event_id = e.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
ORDER BY c.created_at DESC;

-- View for platform revenue dashboard (Admin) - Clarified VAT ownership
CREATE OR REPLACE VIEW `vw_platform_revenue` AS
SELECT 
    DATE(c.created_at) as revenue_date,
    COUNT(c.id) as transaction_count,
    SUM(c.ticket_amount) as gross_revenue,
    SUM(c.commission_amount) as total_commission,
    SUM(c.vat_amount) as total_vat_collected,
    SUM(c.platform_amount) as net_platform_revenue,
    -- VAT liability summary
    SUM(CASE WHEN c.vat_liability = 'platform' THEN c.vat_amount ELSE 0 END) as vat_payable_by_platform,
    SUM(CASE WHEN c.vat_liability = 'organizer' THEN c.vat_amount ELSE 0 END) as vat_payable_by_organizer,
    -- Average metrics
    AVG(c.commission_rate) as avg_commission_rate,
    AVG(c.ticket_amount) as avg_ticket_price,
    -- Status breakdown
    SUM(CASE WHEN c.status = 'paid' THEN 1 ELSE 0 END) as paid_count,
    SUM(CASE WHEN c.status = 'released' THEN c.platform_amount ELSE 0 END) as released_amount,
    SUM(CASE WHEN c.status = 'paid' THEN c.platform_amount ELSE 0 END) as paid_amount,
    -- Ethiopian tax summary
    SUM(CASE WHEN c.tax_withheld = TRUE THEN c.tax_withheld_amount ELSE 0 END) as total_tax_withheld
FROM `commissions` c
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
GROUP BY DATE(c.created_at)
ORDER BY revenue_date DESC;

-- View for Ethiopian tax compliance reporting
CREATE OR REPLACE VIEW `vw_vat_compliance_report` AS
SELECT 
    c.id,
    c.payment_id,
    c.organizer_id,
    o.business_name,
    o.tin_number,
    o.vat_number,
    c.event_id,
    e.title as event_title,
    c.ticket_amount,
    c.vat_rate,
    c.vat_amount,
    c.vat_included,
    c.vat_liability,
    c.created_at,
    -- Ethiopian VAT compliance status
    CASE 
        WHEN o.vat_registered = TRUE AND o.vat_number IS NOT NULL THEN 'REGISTERED_VAT'
        WHEN o.vat_registered = FALSE AND c.ticket_amount >= 1000000 THEN 'THRESHOLD_VAT'
        ELSE 'STANDARD_VAT'
    END as vat_compliance_status,
    -- VAT invoice requirements
    CASE 
        WHEN o.vat_registered = TRUE AND c.ticket_amount >= 2000 THEN 'VAT_INVOICE_REQUIRED'
        ELSE 'STANDARD_RECEIPT'
    END as invoice_requirement,
    -- VAT payment responsibility
    CASE c.vat_liability
        WHEN 'platform' THEN 'Platform to pay ERA'
        WHEN 'organizer' THEN 'Organizer to pay ERA'
        ELSE 'Shared responsibility'
    END as vat_payment_responsibility
FROM `commissions` c
JOIN `organizers` o ON c.organizer_id = o.id
LEFT JOIN `events` e ON c.event_id = e.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
  AND c.status IN ('pending', 'released', 'paid')
ORDER BY c.created_at DESC;

-- ============================================
-- HELPER VIEW FOR FINANCIAL RECONCILIATION
-- ============================================

CREATE OR REPLACE VIEW `vw_commission_reconciliation` AS
SELECT 
    -- Date range
    MIN(DATE(c.created_at)) as period_start,
    MAX(DATE(c.created_at)) as period_end,
    -- Organizer summary
    c.organizer_id,
    o.business_name,
    COUNT(c.id) as total_transactions,
    SUM(c.ticket_amount) as total_gross_sales,
    SUM(c.organizer_amount) as total_organizer_share,
    SUM(c.platform_amount) as total_platform_share,
    SUM(c.vat_amount) as total_vat_collected,
    -- VAT liability breakdown
    SUM(CASE WHEN c.vat_liability = 'platform' THEN c.vat_amount ELSE 0 END) as platform_vat_liability,
    SUM(CASE WHEN c.vat_liability = 'organizer' THEN c.vat_amount ELSE 0 END) as organizer_vat_liability,
    -- Payment status summary
    SUM(CASE WHEN c.status = 'paid' THEN 1 ELSE 0 END) as paid_count,
    SUM(CASE WHEN c.status = 'released' THEN c.organizer_amount ELSE 0 END) as released_amount,
    SUM(CASE WHEN c.status = 'paid' THEN c.organizer_amount ELSE 0 END) as paid_amount,
    -- Commission rate analysis
    AVG(c.commission_rate) as avg_commission_rate,
    MIN(c.commission_rate) as min_commission_rate,
    MAX(c.commission_rate) as max_commission_rate
FROM `commissions` c
JOIN `organizers` o ON c.organizer_id = o.id
WHERE c.deleted_at IS NULL
  AND c.is_reversed = FALSE
  AND c.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) -- Last 30 days
GROUP BY c.organizer_id, o.business_name
ORDER BY total_gross_sales DESC;