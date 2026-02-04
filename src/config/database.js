import Database from 'better-sqlite3';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import fs from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Database file in project root
const dbPath = join(__dirname, '../../ticketing.db');

console.log('í´§ Initializing SQLite database at:', dbPath);

// Create database connection
const db = new Database(dbPath);

// Enable WAL mode for better performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');
db.pragma('busy_timeout = 5000');

console.log('âœ… SQLite database initialized');

export default db;
