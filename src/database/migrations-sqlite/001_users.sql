-- Converted from MySQL to SQLite
-- Original file: 001_users.sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  phone VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(100),
  created_at TEXT DEFAULT CURRENT_TEXT
);
