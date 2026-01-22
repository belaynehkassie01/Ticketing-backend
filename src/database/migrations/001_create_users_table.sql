-- ============================================
-- TABLE: users
-- Purpose: Store all platform users (customers, organizers, admins)
-- ============================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `phone` VARCHAR(20) UNIQUE NOT NULL,
  `email` VARCHAR(100) UNIQUE,
  `password_hash` VARCHAR(255),
  `full_name` VARCHAR(100),
  `role` ENUM('customer', 'organizer', 'admin', 'staff') DEFAULT 'customer',
  `preferred_language` ENUM('am', 'en') DEFAULT 'am',
  `city_id` BIGINT UNSIGNED NULL,
  `phone_verified` BOOLEAN DEFAULT FALSE,
  `verification_code` VARCHAR(6),
  `verification_expiry` DATETIME,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_suspended` BOOLEAN DEFAULT FALSE,
  `failed_login_attempts` INT DEFAULT 0,
  `locked_until` DATETIME NULL,
  `last_login` DATETIME NULL,
  `device_id` VARCHAR(255),
  `organizer_status` ENUM('none', 'pending', 'approved', 'rejected') DEFAULT 'none',
  `organizer_id` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,
  
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  INDEX `idx_phone` (`phone`),
  INDEX `idx_role` (`role`),
  INDEX `idx_phone_verified` (`phone_verified`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_city_id` (`city_id`),
  INDEX `idx_organizer_status` (`organizer_status`),
  INDEX `idx_deleted_at` (`deleted_at`),
  INDEX `idx_created_at` (`created_at`),
  
  CONSTRAINT `chk_failed_attempts` CHECK (`failed_login_attempts` >= 0),
  CONSTRAINT `chk_phone_format` CHECK (`phone` REGEXP '^[0-9+][0-9]{5,}$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;