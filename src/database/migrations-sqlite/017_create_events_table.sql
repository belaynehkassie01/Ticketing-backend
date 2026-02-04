-- Converted from MySQL to SQLite
-- Original file: 017_create_events_table.sql
-- Migration: 017_create_events_table.sql (IMPROVED VERSION)
-- Description: Store event information with enhanced features
-- Dependencies: Requires organizers, event_categories, cities, venues tables

-- ============================================
-- TABLE: events (IMPROVED)
-- Purpose: Store event information
-- Improvements: Added recurring events support, online events, age INTEGEReger, removed redundant tags
-- ============================================

CREATE TABLE IF NOT EXISTS events (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  organizer_id INTEGEREGER NOT NULL,
  
  -- Event Information
  title VARCHAR(200) NOT NULL,
  title_amharic VARCHAR(200),
  slug VARCHAR(255) UNIQUE NOT NULL,
  seo_slug VARCHAR(255) UNIQUE NULL COMMENT 'Optional separate slug for SEO flexibility',
  
  -- Descriptions
  description TEXT,
  description_amharic TEXT,
  short_description VARCHAR(500),
  
  -- Classification
  category_id INTEGEREGER NOT NULL,
  city_id INTEGEREGER NOT NULL,
  
  -- Location & Venue
  venue_id INTEGEREGER NULL,
  venue_custom VARCHAR(200),
  address_details TEXT,
  latitude REAL,
  longitude REAL,
  is_online INTEGER DEFAULT FALSE COMMENT 'Virtual/online events',
  online_event_url VARCHAR(500) COMMENT 'URL for virtual events',
  
  -- Event Timing
  start_date TEXT NOT NULL,
  end_date TEXT NOT NULL,
  start_date_ethiopian VARCHAR(50),
  end_date_ethiopian VARCHAR(50),
  timezone VARCHAR(50) DEFAULT 'Africa/Addis_Ababa',
  duration_minutes INTEGER,
  
  -- Recurring Events (Enhanced)
  is_recurring INTEGER DEFAULT FALSE,
  recurrence_pattern JSON COMMENT 'Recurrence configuration',
  recurrence_end_date TEXT NULL COMMENT 'When recurring events stop',
  
  -- Status & Visibility
  status TEXT DEFAULT 'draft',
  status_reason TEXT COMMENT 'Reason for status change',
  visibility TEXT DEFAULT 'public',
  is_featured INTEGER DEFAULT FALSE,
  featured_until TEXT NULL,
  
  -- Ticketing
  has_tickets INTEGER DEFAULT TRUE,
  external_ticket_url VARCHAR(500) COMMENT 'For events using external ticketing',
  total_tickets INTEGER DEFAULT 0,
  tickets_sold INTEGER DEFAULT 0,
  min_price REAL NULL,
  max_price REAL NULL,
  
  -- Media
  cover_image VARCHAR(255),
  gallery_images JSON COMMENT 'Array of image URLs',
  video_url VARCHAR(500),
  
  -- Audience & Restrictions
  min_age INTEGER DEFAULT 0 COMMENT 'Minimum age requirement (0 = all ages)',
  age_restriction TEXT DEFAULT 'all' COMMENT 'Display category',
  is_charity INTEGER DEFAULT FALSE,
  charity_org VARCHAR(200),
  
  -- Ethiopian Tax
  vat_included INTEGER DEFAULT TRUE,
  vat_rate REAL DEFAULT 15.00,
  
  -- Engagement Metrics
  views INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  saves INTEGER DEFAULT 0,
  attendee_count INTEGER DEFAULT 0 COMMENT 'Actual attendees (not ticket sales)',
  
  -- SEO
  meta_title VARCHAR(200),
  meta_description TEXT,
  meta_keywords VARCHAR(500),
  
  -- TEXTs
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT,
  published_at TEXT NULL,
  cancelled_at TEXT NULL,
  cancellation_reason TEXT,
  cancelled_by INTEGEREGER NULL,
  
  -- Foreign Keys
  FOREIGN KEY (organizer_id) REFERENCES organizers(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (category_id) REFERENCES event_categories(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (city_id) REFERENCES cities(id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (venue_id) REFERENCES venues(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
    
  FOREIGN KEY (cancelled_by) REFERENCES users(id)
    ON DELETE SET NULL
    ON UPDATE RESTRICT,
  
  -- Core Indexes
  INDEX idx_organizer (organizer_id), -- INDEX converted separately (status), -- INDEX converted separately (city_id), -- INDEX converted separately (start_date), -- INDEX converted separately (is_featured, featured_until), -- INDEX converted separately (published_at), -- INDEX converted separately (category_id), -- INDEX converted separately (venue_id), -- INDEX converted separately (cancelled_by),
  
  -- Enhanced Composite Indexes (for common queries)
  INDEX idx_organizer_status_date (organizer_id, status, start_date), -- INDEX converted separately (city_id, status, start_date), -- INDEX converted separately (category_id, status, start_date), -- INDEX converted separately (is_featured, status, start_date), -- INDEX converted separately (is_online, status, start_date),
  
  -- Spatial and Full-Text Search
  SPATIAL INDEX idx_location (latitude, longitude),
  FULLTEXT idx_event_search (title, title_amharic, description, description_amharic),
  
  -- Application-enforced constraINTEGERs (documented here)
  -- Note: CHECK constraINTEGERs are for documentation only in older MySQL
  CONSTRAINTEGER chk_event_dates CHECK (end_date > start_date),
  CONSTRAINTEGER chk_tickets_sold CHECK (tickets_sold <= total_tickets),
  CONSTRAINTEGER chk_vat_rate CHECK (vat_rate >= 0 AND vat_rate <= 100),
  CONSTRAINTEGER chk_slug_format -- CHECK (REGEXP not supported in SQLite '^[a-z0-9-]+$'),
  CONSTRAINTEGER chk_min_age CHECK (min_age >= 0 AND min_age <= 100),
  CONSTRAINTEGER chk_duration CHECK (duration_minutes IS NULL OR duration_minutes > 0),
  CONSTRAINTEGER chk_venue_or_online CHECK (
    (venue_id IS NOT NULL AND is_online = FALSE) OR
    (venue_id IS NULL AND is_online = TRUE) OR
    (venue_id IS NULL AND venue_custom IS NOT NULL AND is_online = FALSE)
  )
  
)  
  DEFAULT CHARSET=utf8mb4 
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Core events table with enhanced features. Business rules enforced in application.';

-- ============================================
-- VIEWS FOR COMMON EVENT QUERIES
-- ============================================

-- View for public event listings
CREATE OR REPLACE VIEW vw_public_events AS
SELECT 
    e.id,
    e.organizer_id,
    o.business_name as organizer_name,
    e.title,
    e.title_amharic,
    e.slug,
    e.short_description,
    e.category_id,
    ec.name as category_name,
    ec.name_amharic as category_name_amharic,
    e.city_id,
    c.name as city_name,
    c.name_amharic as city_name_amharic,
    e.venue_id,
    v.name as venue_name,
    v.name_amharic as venue_name_amharic,
    e.start_date,
    e.end_date,
    e.start_date_ethiopian,
    e.end_date_ethiopian,
    e.is_online,
    e.online_event_url,
    e.cover_image,
    e.min_price,
    e.max_price,
    e.has_tickets,
    e.total_tickets,
    e.tickets_sold,
    e.min_age,
    e.age_restriction,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    -- Availability indicator
    CASE 
        WHEN e.total_tickets > 0 AND e.tickets_sold >= e.total_tickets THEN 'SOLD_OUT'
        WHEN e.total_tickets > 0 AND (e.total_tickets - e.tickets_sold) < 10 THEN 'FEW_LEFT'
        WHEN e.total_tickets > 0 THEN 'AVAILABLE'
        ELSE 'NO_TICKETS'
    END as ticket_availability,
    -- Date status
    CASE 
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 30 DAY) THEN 'UPCOMING'
        ELSE 'FUTURE'
    END as date_status
FROM events e
LEFT JOIN organizers o ON e.organizer_id = o.id
LEFT JOIN event_categories ec ON e.category_id = ec.id
LEFT JOIN cities c ON e.city_id = c.id
LEFT JOIN venues v ON e.venue_id = v.id
WHERE e.status = 'published'
  AND e.visibility = 'public'
  AND (e.featured_until IS NULL OR e.featured_until > NOW())
ORDER BY 
    e.is_featured DESC,
    e.start_date ASC;

-- View for organizer dashboard
CREATE OR REPLACE VIEW vw_organizer_events AS
SELECT 
    e.id,
    e.title,
    e.title_amharic,
    e.status,
    e.start_date,
    e.end_date,
    e.total_tickets,
    e.tickets_sold,
    e.min_price,
    e.max_price,
    e.views,
    e.saves,
    e.created_at,
    e.published_at,
    e.cancelled_at,
    -- Financial metrics
    CASE 
        WHEN e.min_price IS NOT NULL AND e.max_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' - ', FORMAT(e.max_price, 2), ' ETB')
        WHEN e.min_price IS NOT NULL THEN 
            CONCAT(FORMAT(e.min_price, 2), ' ETB')
        ELSE 'FREE'
    END as price_range,
    -- Sales percentage
    CASE 
        WHEN e.total_tickets > 0 THEN 
            CONCAT(ROUND((e.tickets_sold / e.total_tickets) * 100, 1), '%')
        ELSE '0%'
    END as sales_percentage,
    -- Time status
    CASE 
        WHEN e.cancelled_at IS NOT NULL THEN 'CANCELLED'
        WHEN e.start_date < NOW() THEN 'PAST'
        WHEN e.start_date <= DATE_ADD(NOW(), INTEGERERVAL 7 DAY) THEN 'UPCOMING_SOON'
        WHEN e.status = 'published' THEN 'ACTIVE'
        WHEN e.status = 'draft' THEN 'DRAFT'
        ELSE e.status
    END as event_status
FROM events e
ORDER BY 
    CASE 
        WHEN e.start_date < NOW() THEN 3
        WHEN e.status = 'published' THEN 1
        ELSE 2
    END,
    e.start_date ASC;
-- End of Migration: 017_create_events_table.sql