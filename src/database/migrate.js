const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const path = require('path');
const { dbConfig } = require('../config/database');

class MigrationRunner {
  constructor() {
    this.connection = null;
    this.migrationsTable = 'migrations';
    this.migrationsPath = path.join(__dirname, 'migrations');
  }

  async init() {
    console.log('🔧 Initializing migration runner...');
    this.connection = await mysql.createConnection(dbConfig);
    
    // Create migrations table if it doesn't exist
    await this.createMigrationsTable();
    
    console.log('✅ Migration runner initialized');
  }

  async createMigrationsTable() {
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS ${this.migrationsTable} (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL UNIQUE,
        batch INT NOT NULL,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status ENUM('pending', 'applied', 'failed') DEFAULT 'pending',
        error_message TEXT NULL,
        INDEX idx_batch (batch),
        INDEX idx_status (status)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `;
    
    await this.connection.execute(createTableSQL);
  }

  async getAppliedMigrations() {
    const [rows] = await this.connection.execute(
      `SELECT name FROM ${this.migrationsTable} WHERE status = 'applied' ORDER BY id ASC`
    );
    return rows.map(row => row.name);
  }

  async getPendingMigrations() {
    try {
      const files = await fs.readdir(this.migrationsPath);
      const sqlFiles = files
        .filter(file => file.endsWith('.sql'))
        .sort(); // Sort alphabetically for order

      const applied = await this.getAppliedMigrations();
      const pending = sqlFiles.filter(file => !applied.includes(file));

      return pending;
    } catch (error) {
      console.error('❌ Error reading migrations directory:', error.message);
      return [];
    }
  }

  async executeMigration(fileName, direction = 'up') {
    const filePath = path.join(this.migrationsPath, fileName);
    
    try {
      const sqlContent = await fs.readFile(filePath, 'utf8');
      const statements = sqlContent
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0);

      // Begin transaction
      await this.connection.beginTransaction();

      for (const statement of statements) {
        if (statement) {
          console.log(`   Executing: ${statement.substring(0, 100)}...`);
          await this.connection.execute(statement);
        }
      }

      if (direction === 'up') {
        // Get current batch number
        const [batchRows] = await this.connection.execute(
          `SELECT COALESCE(MAX(batch), 0) + 1 as next_batch FROM ${this.migrationsTable}`
        );
        const nextBatch = batchRows[0].next_batch;

        // Record migration
        await this.connection.execute(
          `INSERT INTO ${this.migrationsTable} (name, batch, status) VALUES (?, ?, 'applied')`,
          [fileName, nextBatch]
        );
      } else if (direction === 'down') {
        // Remove migration record
        await this.connection.execute(
          `DELETE FROM ${this.migrationsTable} WHERE name = ?`,
          [fileName]
        );
      }

      await this.connection.commit();
      console.log(`✅ Migration ${fileName} ${direction} completed successfully`);
      return true;

    } catch (error) {
      await this.connection.rollback();
      
      if (direction === 'up') {
        // Record failed migration
        await this.connection.execute(
          `INSERT INTO ${this.migrationsTable} (name, batch, status, error_message) VALUES (?, 0, 'failed', ?)`,
          [fileName, error.message]
        );
      }
      
      console.error(`❌ Migration ${fileName} failed:`, error.message);
      return false;
    }
  }

  async migrate() {
    await this.init();
    
    const pending = await this.getPendingMigrations();
    
    if (pending.length === 0) {
      console.log('🎉 No pending migrations. Database is up to date!');
      return;
    }

    console.log(`📦 Found ${pending.length} pending migration(s):`);
    pending.forEach((file, index) => {
      console.log(`  ${index + 1}. ${file}`);
    });

    console.log('\n🚀 Starting migrations...');
    
    for (const file of pending) {
      console.log(`\n📄 Processing: ${file}`);
      const success = await this.executeMigration(file, 'up');
      
      if (!success) {
        console.error(`💥 Migration stopped due to failure in ${file}`);
        process.exit(1);
      }
    }

    console.log('\n✨ All migrations completed successfully!');
    await this.connection.end();
  }

  async rollback(batch = null) {
    await this.init();

    let query = `SELECT name, batch FROM ${this.migrationsTable} WHERE status = 'applied'`;
    const params = [];

    if (batch) {
      query += ` AND batch = ?`;
      params.push(batch);
    }

    query += ` ORDER BY id DESC`;

    const [migrations] = await this.connection.execute(query, params);

    if (migrations.length === 0) {
      console.log('📭 No migrations to rollback');
      return;
    }

    console.log(`🔄 Rolling back ${migrations.length} migration(s):`);
    
    for (const migration of migrations) {
      console.log(`\n📄 Rolling back: ${migration.name} (Batch: ${migration.batch})`);
      
      // For rollback, we need to read the migration file to execute down statements
      // For now, we'll just remove the record. You can implement full down migration later.
      await this.executeMigration(migration.name, 'down');
    }

    console.log('\n✅ Rollback completed');
    await this.connection.end();
  }

  async status() {
    await this.init();

    const [applied] = await this.connection.execute(
      `SELECT name, batch, applied_at, status FROM ${this.migrationsTable} ORDER BY id ASC`
    );

    const pending = await this.getPendingMigrations();

    console.log('📊 Migration Status:');
    console.log('===================');
    
    console.log('\n✅ Applied Migrations:');
    if (applied.length === 0) {
      console.log('   No migrations applied yet');
    } else {
      applied.forEach(mig => {
        const statusIcon = mig.status === 'applied' ? '✅' : '❌';
        console.log(`   ${statusIcon} ${mig.name} (Batch: ${mig.batch}, Applied: ${mig.applied_at})`);
      });
    }

    console.log('\n⏳ Pending Migrations:');
    if (pending.length === 0) {
      console.log('   No pending migrations');
    } else {
      pending.forEach(file => {
        console.log(`   ⏳ ${file}`);
      });
    }

    console.log(`\n📈 Summary: ${applied.length} applied, ${pending.length} pending`);
    await this.connection.end();
  }
}

// Command line interface
async function main() {
  const command = process.argv[2];
  const runner = new MigrationRunner();

  try {
    switch (command) {
      case 'migrate':
        await runner.migrate();
        break;
      case 'rollback':
        const batch = process.argv[3] || null;
        await runner.rollback(batch);
        break;
      case 'status':
        await runner.status();
        break;
      case 'fresh':
        // Drop and recreate all tables
        await runner.fresh();
        break;
      default:
        console.log(`
Usage: node migrate.js <command>
        
Commands:
  migrate     Run all pending migrations
  rollback    Rollback the last batch of migrations
  rollback <batch> Rollback specific batch
  status      Show migration status
  fresh       Drop all tables and run migrations fresh (DANGEROUS)
        
Examples:
  node migrate.js migrate
  node migrate.js rollback
  node migrate.js rollback 2
  node migrate.js status
        `);
    }
  } catch (error) {
    console.error('💥 Migration error:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = MigrationRunner;