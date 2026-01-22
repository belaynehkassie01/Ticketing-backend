-- ============================================
-- TABLE: ticket_types
-- Purpose: Store different ticket types for events
-- ============================================
CREATE TABLE IF NOT EXISTS `ticket_types` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `event_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `name_amharic` VARCHAR(100),
  `description` TEXT,
  `description_amharic` TEXT,
  `price` DECIMAL(10,2) NOT NULL,
  `vat_included` BOOLEAN DEFAULT TRUE,
  `vat_amount` DECIMAL(10,2) GENERATED ALWAYS AS (CASE WHEN `vat_included` THEN `price` * 0.15 ELSE 0 END) STORED,
  `net_price` DECIMAL(10,2) GENERATED ALWAYS AS (CASE WHEN `vat_included` THEN `price` / 1.15 ELSE `price` END) STORED,
  `quantity` INT NOT NULL,
  `sold_count` INT DEFAULT 0,
  `reserved_count` INT DEFAULT 0,
  `available_count` INT GENERATED ALWAYS AS (`quantity` - `sold_count` - `reserved_count`) STORED,
  `max_per_user` INT DEFAULT 5,
  `min_per_user` INT DEFAULT 1,
  `sales_start` DATETIME,
  `sales_end` DATETIME,
  `is_early_bird` BOOLEAN DEFAULT FALSE,
  `early_bird_end` DATETIME NULL,
  `access_level` ENUM('general', 'vip', 'backstage', 'premium') DEFAULT 'general',
  `seating_info` TEXT,
  `benefits` JSON COMMENT 'Array of benefits for this ticket type',
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_hidden` BOOLEAN DEFAULT FALSE,
  `is_student_ticket` BOOLEAN DEFAULT FALSE,
  `requires_student_id` BOOLEAN DEFAULT FALSE,
  `is_group_ticket` BOOLEAN DEFAULT FALSE,
  `group_size` INT NULL,
  `revenue` DECIMAL(15,2) DEFAULT 0.00,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`event_id`) REFERENCES `events`(`id`)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  
  INDEX `idx_event` (`event_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_sales_dates` (`sales_start`, `sales_end`),
  INDEX `idx_price` (`price`),
  INDEX `idx_access_level` (`access_level`),
  INDEX `idx_deleted_at` (`deleted_at`),
  
  CONSTRAINT `chk_quantity` CHECK (`quantity` >= 0),
  CONSTRAINT `chk_sold_count` CHECK (`sold_count` >= 0),
  CONSTRAINT `chk_reserved_count` CHECK (`reserved_count` >= 0),
  CONSTRAINT `chk_price` CHECK (`price` >= 0),
  CONSTRAINT `chk_sales_dates` CHECK (`sales_end` IS NULL OR `sales_start` IS NULL OR `sales_end` > `sales_start`),
  CONSTRAINT `chk_max_min_per_user` CHECK (`max_per_user` >= `min_per_user` AND `min_per_user` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;