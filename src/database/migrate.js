import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { db } from '../config/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function runMigrations() {
  try {
    console.log('🚀 Starting database migrations...');
    
    // First, ensure database exists
    await db.query(`
      CREATE DATABASE IF NOT EXISTS ethio_tickets 
      CHARACTER SET utf8mb4 
      COLLATE utf8mb4_unicode_ci
    `);
    
    console.log('✅ Database created/verified');
    
    // Use the database
    await db.query('USE ethio_tickets');
    
    // Get all migration files
    const migrationDir = path.join(__dirname, 'migrations');
    const migrationFiles = fs.readdirSync(migrationDir)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Sort to run in order
    
    console.log(`📦 Found ${migrationFiles.length} migration files`);
    
    // Run each migration
    for (const file of migrationFiles) {
      console.log(`\n📋 Running: ${file}`);
      const filePath = path.join(migrationDir, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      // Split by semicolons and execute each statement
      const statements = sql.split(';').filter(stmt => stmt.trim());
      
      for (const statement of statements) {
        if (statement.trim()) {
          await db.query(statement);
        }
      }
      
      console.log(`✅ Completed: ${file}`);
    }
    
    console.log('\n🎉 All migrations completed successfully!');
    console.log('📊 Database: ethio_tickets');
    console.log('🔤 Collation: utf8mb4_unicode_ci');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run migrations if this file is executed directly
if (process.argv[1] === fileURLToPath(import.meta.url)) {
  runMigrations();
}

export default runMigrations;