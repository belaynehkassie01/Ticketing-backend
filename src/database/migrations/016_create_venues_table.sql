-- ============================================
-- TABLE: venues
-- Purpose: Store event venue information
-- ============================================
CREATE TABLE IF NOT EXISTS `venues` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `name_amharic` VARCHAR(200),
  `city_id` BIGINT UNSIGNED NOT NULL,
  `sub_city` VARCHAR(100),
  `woreda` VARCHAR(100),
  `kebele` VARCHAR(100),
  `house_number` VARCHAR(50),
  `landmark` TEXT,
  `full_address` TEXT,
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `google_maps_url` VARCHAR(500),
  `capacity` INT,
  `venue_type` ENUM('indoor', 'outdoor', 'both') DEFAULT 'indoor',
  `amenities` JSON COMMENT 'Array of amenities: ["parking", "wifi", "restrooms", "food", "bar", "ac", "stage"]',
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(100),
  `website` VARCHAR(255),
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `description` TEXT,
  `images` JSON COMMENT 'Array of image URLs with metadata',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  
  INDEX `idx_city` (`city_id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_is_verified` (`is_verified`),
  FULLTEXT `idx_search` (`name`, `name_amharic`, `landmark`, `full_address`),
  SPATIAL INDEX `idx_location` (`latitude`, `longitude`),
  
  CONSTRAINT `chk_capacity` CHECK (`capacity` IS NULL OR `capacity` > 0),
  CONSTRAINT `chk_coordinates` CHECK (
    (`latitude` IS NULL AND `longitude` IS NULL) OR 
    (`latitude` IS NOT NULL AND `longitude` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;