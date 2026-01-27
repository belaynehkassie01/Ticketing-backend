-- Migration: 019_create_ticket_types_table.sql (CORRECTED VERSION)
-- Description: Store different ticket types for events with proper VAT calculations
-- Dependencies: Requires events table
-- Important: Ethiopian VAT fixed at 15%, calculations rounded to 2 decimals

-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- VAT Note: Ethiopian VAT is fixed at 15%, calculations use ROUND() for precision
-- ============================================

CREATE TABLE IF NOT EXISTS `ticket_types` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  
  -- Ticket Information (Bilingual)
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `description` TEXT,
  `description_amharic` TEXT,
  
  -- Pricing (ETH - Ethiopian Birr)
  `price` DECIMAL(10,2) NOT NULL COMMENT 'Display price in ETB',
  `vat_included` BOOLEAN DEFAULT TRUE COMMENT 'Whether 15% VAT is included in price',
  
  -- Generated VAT Columns (Ethiopian 15% VAT with rounding)
  `vat_amount` DECIMAL(10,2) GENERATED ALWAYS AS (
    CASE WHEN `vat_included` THEN ROUND(`price` * 0.15, 2) ELSE 0.00 END
  ) STORED COMMENT '15% VAT amount (rounded to 2 decimals)',
  
  `net_price` DECIMAL(10,2) GENERATED ALWAYS AS (
    CASE WHEN `vat_included` THEN ROUND(`price` / 1.15, 2) ELSE `price` END
  ) STORED COMMENT 'Price without VAT (rounded to 2 decimals)',
  
  -- Inventory Management
  `quantity` INT NOT NULL COMMENT 'Total tickets available',
  `sold_count` INT DEFAULT 0 COMMENT 'Tickets sold (confirmed payments)',
  `reserved_count` INT DEFAULT 0 COMMENT 'Tickets reserved (pending payment)',
  
  `available_count` INT GENERATED ALWAYS AS (
    `quantity` - `sold_count` - `reserved_count`
  ) STORED COMMENT 'Available tickets (calculated)',
  
  -- Purchase Limits
  `max_per_user` INT DEFAULT 5 COMMENT 'Maximum tickets per user',
  `min_per_user` INT DEFAULT 1 COMMENT 'Minimum tickets per user',
  
  -- Sales Window
  `sales_start` DATETIME COMMENT 'When ticket sales begin',
  `sales_end` DATETIME COMMENT 'When ticket sales end',
  
  -- Special Ticket Types
  `is_early_bird` BOOLEAN DEFAULT FALSE,
  `early_bird_end` DATETIME NULL COMMENT 'End of early bird pricing',
  
  `access_level` ENUM('general', 'vip', 'backstage', 'premium') DEFAULT 'general',
  `seating_info` TEXT COMMENT 'Seat numbers, sections, etc.',
  
  `benefits` JSON COMMENT 'Array of benefits: ["early_entry", "free_drink", "meet_greet"]',
  
  -- Status Flags
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_hidden` BOOLEAN DEFAULT FALSE COMMENT 'Hidden from public view',
  
  -- Special Ticket Categories
  `is_student_ticket` BOOLEAN DEFAULT FALSE,
  `requires_student_id` BOOLEAN DEFAULT FALSE,
  `is_group_ticket` BOOLEAN DEFAULT FALSE,
  `group_size` INT NULL COMMENT 'Required group size for group tickets',
  
  -- Cached Revenue (Application must keep in sync)
  `revenue` DECIMAL(15,2) DEFAULT 0.00 COMMENT 'Cached revenue (sold_count * price) - app must update',
  
  -- Timestamps
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  -- Foreign Key
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  -- Indexes
  INDEX `idx_event` (`event_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sales_dates` (`sales_start`, `sales_end`),
  INDEX `idx_price` (`price`),
  INDEX `idx_access_level` (`access_level`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_event_active` (`event_id`, `is_active`),
  INDEX `idx_event_sales` (`event_id`, `sales_start`, `sales_end`),
  
  -- Unique constraint: Prevent duplicate ticket names per event
  UNIQUE KEY `uq_event_ticket_name` (`event_id`, `name`),
  
  -- Constraints (Application-enforced, documented here)
  CONSTRAINT `chk_quantity` CHECK (`quantity` >= 0),
  CONSTRAINT `chk_sold_count` CHECK (`sold_count` >= 0),
  CONSTRAINT `chk_reserved_count` CHECK (`reserved_count` >= 0),
  CONSTRAINT `chk_price` CHECK (`price` >= 0),
  CONSTRAINT `chk_sales_dates` CHECK (
    `sales_end` IS NULL OR 
    `sales_start` IS NULL OR 
    `sales_end` > `sales_start`
  ),
  CONSTRAINT `chk_max_min_per_user` CHECK (
    `max_per_user` >= `min_per_user` AND 
    `min_per_user` > 0
  ),
  CONSTRAINT `chk_group_size` CHECK (
    `group_size` IS NULL OR 
    `group_size` > 1
  )
  
) ENGINE=InnoDB 
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Event ticket types with Ethiopian 15% VAT calculations. Revenue field is cached - app must maintain.';

-- ============================================
-- VIEWS FOR TICKET MANAGEMENT
-- ============================================

-- View for public ticket display
CREATE OR REPLACE VIEW `vw_public_tickets` AS
SELECT 
    tt.id,
    tt.event_id,
    e.title as event_title,
    e.title_amharic as event_title_amharic,
    tt.name,
    tt.name_amharic,
    tt.description,
    tt.description_amharic,
    tt.price,
    tt.vat_included,
    tt.vat_amount,
    tt.net_price,
    tt.quantity,
    tt.sold_count,
    tt.reserved_count,
    tt.available_count,
    tt.max_per_user,
    tt.min_per_user,
    tt.sales_start,
    tt.sales_end,
    tt.is_early_bird,
    tt.early_bird_end,
    tt.access_level,
    tt.seating_info,
    tt.benefits,
    tt.is_student_ticket,
    tt.requires_student_id,
    tt.is_group_ticket,
    tt.group_size,
    tt.created_at,
    -- Availability status
    CASE 
        WHEN tt.available_count <= 0 THEN 'SOLD_OUT'
        WHEN tt.available_count < 10 THEN 'FEW_LEFT'
        WHEN tt.sales_end IS NOT NULL AND tt.sales_end < NOW() THEN 'SALES_ENDED'
        WHEN tt.sales_start IS NOT NULL AND tt.sales_start > NOW() THEN 'SALES_NOT_STARTED'
        ELSE 'AVAILABLE'
    END as availability_status,
    -- Price display
    CASE 
        WHEN tt.vat_included = TRUE THEN CONCAT(FORMAT(tt.price, 2), ' ETB (VAT included)')
        ELSE CONCAT(FORMAT(tt.price, 2), ' ETB + VAT')
    END as price_display,
    -- Early bird status
    CASE 
        WHEN tt.is_early_bird = TRUE AND tt.early_bird_end > NOW() THEN 'EARLY_BIRD_ACTIVE'
        WHEN tt.is_early_bird = TRUE AND tt.early_bird_end <= NOW() THEN 'EARLY_BIRD_EXPIRED'
        ELSE 'REGULAR_PRICE'
    END as pricing_status
FROM `ticket_types` tt
JOIN `events` e ON tt.event_id = e.id
WHERE tt.is_active = TRUE
  AND tt.is_hidden = FALSE
  AND tt.deleted_at IS NULL
  AND e.status = 'published'
ORDER BY 
    tt.price ASC,
    tt.access_level,
    tt.created_at;

-- View for organizer ticket management
CREATE OR REPLACE VIEW `vw_organizer_ticket_types` AS
SELECT 
    tt.id,
    tt.event_id,
    e.title as event_title,
    tt.name,
    tt.price,
    tt.quantity,
    tt.sold_count,
    tt.reserved_count,
    tt.available_count,
    tt.revenue,
    tt.is_active,
    tt.sales_start,
    tt.sales_end,
    tt.created_at,
    tt.updated_at,
    -- Sales percentage
    CASE 
        WHEN tt.quantity > 0 THEN ROUND((tt.sold_count / tt.quantity) * 100, 1)
        ELSE 0
    END as sold_percentage,
    -- Revenue per ticket
    CASE 
        WHEN tt.sold_count > 0 THEN ROUND(tt.revenue / tt.sold_count, 2)
        ELSE 0
    END as avg_revenue_per_ticket,
    -- Status indicator
    CASE 
        WHEN tt.available_count <= 0 THEN 'SOLD_OUT'
        WHEN tt.sales_end IS NOT NULL AND tt.sales_end < NOW() THEN 'SALES_ENDED'
        WHEN tt.sales_start IS NOT NULL AND tt.sales_start > NOW() THEN 'UPCOMING_SALES'
        WHEN tt.is_active = FALSE THEN 'INACTIVE'
        ELSE 'ACTIVE'
    END as ticket_status
FROM `ticket_types` tt
JOIN `events` e ON tt.event_id = e.id
WHERE tt.deleted_at IS NULL
ORDER BY tt.event_id, tt.price;