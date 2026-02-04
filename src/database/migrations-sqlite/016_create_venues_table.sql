-- Converted from MySQL to SQLite
-- Original file: 016_create_venues_table.sql
CREATE TABLE IF NOT EXISTS venues (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(200) NOT NULL,
  name_amharic VARCHAR(200),

  city_id INTEGEREGER NOT NULL,
  sub_city VARCHAR(100),
  woreda VARCHAR(100),
  kebele VARCHAR(100),
  house_number VARCHAR(50),
  landmark TEXT,
  full_address TEXT,

  -- Geographic data
  latitude REAL,
  longitude REAL,
  location POINTEGER GENERATED ALWAYS AS (
    ST_SRID(POINTEGER(longitude, latitude), 4326)
  ) STORED,

  google_maps_url VARCHAR(500),

  capacity INTEGER,
  venue_type TEXT DEFAULT 'indoor',

  amenities JSON,
  contact_phone VARCHAR(20),
  contact_email VARCHAR(100),
  website VARCHAR(255),

  is_verified INTEGER DEFAULT FALSE,
  is_active INTEGER DEFAULT TRUE,

  description TEXT,
  images JSON,

  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  deleted_at TEXT NULL,

  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT, -- INDEX converted separately (city_id), -- INDEX converted separately (name), -- INDEX converted separately (is_active), -- INDEX converted separately (is_verified), -- INDEX converted separately (deleted_at),

  FULLTEXT INDEX idx_search
    (name, name_amharic, landmark, full_address),

  SPATIAL INDEX idx_location (location),

  CONSTRAINTEGER chk_capacity
    CHECK (capacity IS NULL OR capacity > 0),

  CONSTRAINTEGER chk_coordinates
    CHECK (
      (latitude IS NULL AND longitude IS NULL)
      OR
      (latitude IS NOT NULL AND longitude IS NOT NULL)
    )
) 
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;
