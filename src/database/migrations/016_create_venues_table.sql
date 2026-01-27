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

  -- Geographic data
  `latitude` DECIMAL(10,8),
  `longitude` DECIMAL(11,8),
  `location` POINT GENERATED ALWAYS AS (
    ST_SRID(POINT(longitude, latitude), 4326)
  ) STORED,

  `google_maps_url` VARCHAR(500),

  `capacity` INT,
  `venue_type` ENUM('indoor', 'outdoor', 'both') DEFAULT 'indoor',

  `amenities` JSON,
  `contact_phone` VARCHAR(20),
  `contact_email` VARCHAR(100),
  `website` VARCHAR(255),

  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,

  `description` TEXT,
  `images` JSON,

  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` DATETIME NULL,

  FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,

  INDEX `idx_city` (`city_id`),
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_is_verified` (`is_verified`),
  INDEX `idx_deleted_at` (`deleted_at`),

  FULLTEXT INDEX `idx_search`
    (`name`, `name_amharic`, `landmark`, `full_address`),

  SPATIAL INDEX `idx_location` (`location`),

  CONSTRAINT `chk_capacity`
    CHECK (`capacity` IS NULL OR `capacity` > 0),

  CONSTRAINT `chk_coordinates`
    CHECK (
      (`latitude` IS NULL AND `longitude` IS NULL)
      OR
      (`latitude` IS NOT NULL AND `longitude` IS NOT NULL)
    )
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
