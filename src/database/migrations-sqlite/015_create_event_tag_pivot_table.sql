-- Converted from MySQL to SQLite
-- Original file: 015_create_event_tag_pivot_table.sql
-- Migration: 015_create_event_tag_pivot_table.sql
-- Description: Many-to-many relationship between events and tags
-- Dependencies: Requires events and event_tags tables

CREATE TABLE IF NOT EXISTS event_tag_pivot (
  event_id INTEGEREGER NOT NULL,
  tag_id INTEGEREGER NOT NULL,

  -- Metadata
  source TEXT DEFAULT 'manual',
  created_at TEXT DEFAULT CURRENT_TEXT,
  deleted_at TEXT NULL,

  -- Composite Primary Key
  PRIMARY KEY (event_id, tag_id),

  -- Foreign Keys
  FOREIGN KEY (event_id) REFERENCES events(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  FOREIGN KEY (tag_id) REFERENCES event_tags(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,

  -- Indexes
  INDEX idx_event_id (event_id), -- INDEX converted separately (tag_id), -- INDEX converted separately (deleted_at)

) 
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Pivot table linking events and tags (many-to-many)';
