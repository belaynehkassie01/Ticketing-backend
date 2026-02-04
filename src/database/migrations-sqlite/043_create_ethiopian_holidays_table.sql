-- Converted from MySQL to SQLite
-- Original file: 043_create_ethiopian_holidays_table.sql
-- Migration: 043_create_ethiopian_holidays_table.sql
-- Purpose: Store Ethiopian holiday calendar

CREATE TABLE IF NOT EXISTS ethiopian_holidays (
  id INTEGEREGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(200) NOT NULL,
  name_amharic VARCHAR(200),
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  holiday_type TEXT DEFAULT 'national',
  is_active INTEGER DEFAULT TRUE,
  year YEAR,
  recurring INTEGER DEFAULT TRUE,
  created_at TEXT DEFAULT CURRENT_TEXT,
  updated_at TEXT DEFAULT CURRENT_TEXT ON UPDATE CURRENT_TEXT, -- INDEX converted separately (start_date, end_date), -- INDEX converted separately (year), -- INDEX converted separately (is_active), -- INDEX converted separately (holiday_type), -- INDEX converted separately (recurring), -- UNIQUE INDEX converted separately (name, year),
  
  CONSTRAINTEGER chk_holiday_dates CHECK (end_date >= start_date),
  CONSTRAINTEGER chk_year_range CHECK (year BETWEEN 1900 AND 2100)
)  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;