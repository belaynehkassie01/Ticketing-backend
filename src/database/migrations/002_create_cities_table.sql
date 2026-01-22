-- ============================================
-- TABLE: cities
-- Purpose: Store Ethiopian cities and regions
-- ============================================
CREATE TABLE IF NOT EXISTS `cities` (
  `id` BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  `name_en` VARCHAR(100) NOT NULL,
  `name_am` VARCHAR(100) NOT NULL,
  `region` ENUM(
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Dire Dawa',
    'Gambela',
    'Harari',
    'Oromia',
    'Sidama',
    'Somali',
    'South West Ethiopia Peoples',
    'Southern Nations, Nationalities, and Peoples',
    'Tigray'
  ) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_region` (`region`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_name_en` (`name_en`),
  INDEX `idx_name_am` (`name_am`),
  UNIQUE INDEX `uq_city_region` (`name_en`, `region`),
  
  CONSTRAINT `chk_city_names` CHECK (`name_en` != '' AND `name_am` != '')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;