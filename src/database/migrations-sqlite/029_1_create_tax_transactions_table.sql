-- Converted from MySQL to SQLite
-- Original file: 029_1_create_tax_transactions_table.sql
-- Migration: 029_1_create_tax_transactions_table.sql
-- Purpose: Track all tax transactions for Ethiopian compliance

CREATE TABLE IF NOT EXISTS tax_transactions (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  
  -- Transaction identification
  transaction_code VARCHAR(50) UNIQUE NOT NULL COMMENT 'TAX-ET-2024-001',
  tax_id INTEGEREGER NOT NULL COMMENT 'Reference to taxes table',
  
  -- Transaction details
  transaction_type VARCHAR(30) NOT NULL COMMENT 'vat_collection, vat_payment, withholding_collection, withholding_payment, penalty, adjustment',
  entity_type VARCHAR(50) NOT NULL COMMENT 'ticket_sale, commission_fee, payout, expense, adjustment',
  entity_id INTEGEREGER NOT NULL,
  
  -- Financial details (ETB)
  base_amount REAL NOT NULL COMMENT 'Amount before tax',
  tax_rate REAL NOT NULL,
  tax_amount REAL NOT NULL,
  total_amount REAL NOT NULL COMMENT 'base_amount + tax_amount',
  currency VARCHAR(3) DEFAULT 'ETB',
  
  -- Ethiopian compliance
  tax_authority VARCHAR(30) DEFAULT 'erca' COMMENT 'erca, regional_revenue, city_administration',
  tax_period VARCHAR(20) COMMENT 'YYYY-MM for reporting',
  is_deductible INTEGER DEFAULT TRUE COMMENT 'For input VAT',
  
  -- Status
  status VARCHAR(30) DEFAULT 'pending' COMMENT 'pending, calculated, due, paid, overdue, waived',
  payment_status VARCHAR(30) DEFAULT 'unpaid' COMMENT 'unpaid, partially_paid, paid, refunded',
  
  -- Dates
  transaction_date DATE NOT NULL,
  due_date DATE NULL,
  paid_date DATE NULL,
  reported_date DATE NULL,
  
  -- Payment reference
  payment_reference VARCHAR(100) NULL,
  bank_transaction_id VARCHAR(100) NULL,
  
  -- Related entities
  related_payment_id INTEGEREGER NULL,
  related_payout_id INTEGEREGER NULL,
  related_refund_id INTEGEREGER NULL,
  
  -- Audit
  created_by INTEGEREGER NOT NULL,
  updated_by INTEGEREGER NULL,
  audit_trail JSON,
  
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,
  
  -- Foreign Keys
  FOREIGN KEY (tax_id) REFERENCES taxes(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_payment_id) REFERENCES payments(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_payout_id) REFERENCES payouts(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (related_refund_id) REFERENCES refunds(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
    
  FOREIGN KEY (created_by) REFERENCES users(id)
    ON DELETE RESTRICT ON UPDATE RESTRICT,
    
  FOREIGN KEY (updated_by) REFERENCES users(id)
    ON DELETE SET NULL ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX idx_transaction_code (transaction_code), -- INDEX converted separately (tax_id), -- INDEX converted separately (transaction_type), -- INDEX converted separately (entity_type, entity_id), -- INDEX converted separately (status), -- INDEX converted separately (payment_status), -- INDEX converted separately (transaction_date), -- INDEX converted separately (due_date), -- INDEX converted separately (tax_period), -- INDEX converted separately (tax_authority), -- INDEX converted separately (deleted_at),
  
  -- Business key
  UNIQUE KEY uq_tax_entity (entity_type, entity_id, transaction_type, deleted_at)
  
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;