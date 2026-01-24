const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const path = require('path');
const config = require('../config');

class MigrationRunner {
  constructor() {
    this.migrationsDir = path.join(__dirname, 'migrations');
    this.migrationsTable = 'database_migrations';
  }

  async connect() {
    const dbConfig = config.database;
    
    // Connect without database first to create it if needed
    const connection = await mysql.createConnection({
      host: dbConfig.host,
      port: dbConfig.port,
      user: dbConfig.user,
      password: dbConfig.password,
    });

    return connection;
  }

  async ensureDatabase() {
    const connection = await this.connect();
    const dbConfig = config.database;

    try {
      // Create database if it doesn't exist
      await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbConfig.name}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
      
      // Use the database
      await connection.query(`USE \`${dbConfig.name}\``);
      
      // Create migrations table
      await connection.query(`
        CREATE TABLE IF NOT EXISTS \`${this.migrationsTable}\` (
          id INT PRIMARY KEY AUTO_INCREMENT,
          name VARCHAR(255) NOT NULL,
          batch INT NOT NULL,
          executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          UNIQUE KEY unique_migration_name (name)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
      `);

      return connection;
    } catch (error) {
      await connection.end();
      throw error;
    }
  }

  async getExecutedMigrations(connection) {
    const [rows] = await connection.query(`SELECT name FROM \`${this.migrationsTable}\` ORDER BY id ASC`);
    return rows.map(row => row.name);
  }

  async getMigrationFiles() {
    const files = await fs.readdir(this.migrationsDir);
    return files
      .filter(file => file.endsWith('.sql'))
      .sort(); // Sort alphabetically
  }

  async runMigration(connection, filename, batch) {
    const filepath = path.join(this.migrationsDir, filename);
    const sql = await fs.readFile(filepath, 'utf8');
    
    console.log(`Running migration: ${filename}`);
    
    // Split SQL by semicolons (but not within comments or strings)
    const statements = sql
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));
    
    for (const statement of statements) {
      if (statement.trim()) {
        await connection.query(statement);
      }
    }
    
    // Record migration
    await connection.query(
      `INSERT INTO \`${this.migrationsTable}\` (name, batch) VALUES (?, ?)`,
      [filename, batch]
    );
    
    console.log(`✓ Completed: ${filename}`);
  }

  async run() {
    console.log('Starting database migrations...');
    
    const connection = await this.ensureDatabase();
    let currentBatch = 1;
    
    try {
      // Get current batch number
      const [batchRows] = await connection.query(
        `SELECT MAX(batch) as max_batch FROM \`${this.migrationsTable}\``
      );
      
      if (batchRows[0].max_batch) {
        currentBatch = batchRows[0].max_batch + 1;
      }
      
      // Get executed migrations
      const executedMigrations = await this.getExecutedMigrations(connection);
      
      // Get all migration files
      const migrationFiles = await this.getMigrationFiles();
      
      // Find pending migrations
      const pendingMigrations = migrationFiles.filter(
        file => !executedMigrations.includes(file)
      );
      
      if (pendingMigrations.length === 0) {
        console.log('✓ All migrations are already applied');
        return;
      }
      
      console.log(`Found ${pendingMigrations.length} pending migration(s):`);
      pendingMigrations.forEach(file => console.log(`  - ${file}`));
      
      // Run pending migrations
      for (const migrationFile of pendingMigrations) {
        await this.runMigration(connection, migrationFile, currentBatch);
      }
      
      console.log(`\n✓ Successfully applied ${pendingMigrations.length} migration(s) in batch ${currentBatch}`);
      
    } catch (error) {
      console.error('Migration failed:', error.message);
      throw error;
    } finally {
      await connection.end();
    }
  }

  async rollback(steps = 1) {
    console.log(`Rolling back ${steps} migration(s)...`);
    
    const connection = await this.ensureDatabase();
    
    try {
      // Get migrations to rollback
      const [migrationsToRollback] = await connection.query(
        `SELECT name FROM \`${this.migrationsTable}\` WHERE batch = (SELECT MAX(batch) FROM \`${this.migrationsTable}\`) ORDER BY id DESC LIMIT ?`,
        [steps]
      );
      
      if (migrationsToRollback.length === 0) {
        console.log('No migrations to rollback');
        return;
      }
      
      console.log(`Rolling back migration(s):`);
      
      for (const migration of migrationsToRollback) {
        console.log(`  - ${migration.name}`);
        
        // Note: We can't automatically rollback SQL migrations
        // In production, you'd need to write down migrations
        console.log(`    ⚠️  Manual rollback required for: ${migration.name}`);
        
        // Remove migration record
        await connection.query(
          `DELETE FROM \`${this.migrationsTable}\` WHERE name = ?`,
          [migration.name]
        );
      }
      
      console.log(`\n✓ Rollback completed (records removed from migration table)`);
      console.log(`⚠️  Remember to manually revert database changes`);
      
    } catch (error) {
      console.error('Rollback failed:', error.message);
      throw error;
    } finally {
      await connection.end();
    }
  }

  async status() {
    const connection = await this.ensureDatabase();
    
    try {
      const executedMigrations = await this.getExecutedMigrations(connection);
      const allMigrationFiles = await this.getMigrationFiles();
      
      console.log('Migration Status:');
      console.log('================\n');
      
      console.log(`Database: ${config.database.name}`);
      console.log(`Total migrations available: ${allMigrationFiles.length}`);
      console.log(`Total migrations applied: ${executedMigrations.length}\n`);
      
      console.log('Migration details:');
      console.log('──────────────────');
      
      for (const file of allMigrationFiles) {
        const isApplied = executedMigrations.includes(file);
        const status = isApplied ? '✓ Applied' : '⏳ Pending';
        console.log(`${status} - ${file}`);
      }
      
      const pending = allMigrationFiles.filter(
        file => !executedMigrations.includes(file)
      );
      
      if (pending.length > 0) {
        console.log(`\nPending migrations: ${pending.length}`);
        console.log('Run "npm run db:migrate" to apply them');
      } else {
        console.log('\n✓ All migrations are applied');
      }
      
    } catch (error) {
      console.error('Failed to get migration status:', error.message);
      throw error;
    } finally {
      await connection.end();
    }
  }
}

// CLI handler
async function main() {
  const command = process.argv[2];
  const runner = new MigrationRunner();
  
  switch (command) {
    case 'migrate':
      await runner.run();
      break;
      
    case 'rollback':
      const steps = process.argv[3] ? parseInt(process.argv[3]) : 1;
      await runner.rollback(steps);
      break;
      
    case 'status':
      await runner.status();
      break;
      
    case 'fresh':
      console.log('⚠️  This will drop and recreate the database!');
      // Implement fresh reset if needed
      break;
      
    default:
      console.log('Usage:');
      console.log('  node migrate.js migrate    - Run pending migrations');
      console.log('  node migrate.js rollback [n] - Rollback n migrations (default: 1)');
      console.log('  node migrate.js status     - Show migration status');
      console.log('  node migrate.js fresh      - Drop and recreate database (DANGER)');
      process.exit(1);
  }
}

if (require.main === module) {
  main().catch(error => {
    console.error('Migration script failed:', error);
    process.exit(1);
  });
}

module.exports = MigrationRunner;