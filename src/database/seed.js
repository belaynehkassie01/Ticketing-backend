const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const path = require('path');
const { dbConfig } = require('../config/database');

class Seeder {
  constructor() {
    this.connection = null;
    this.seedsPath = path.join(__dirname, 'seeds');
    this.seedsTable = 'seed_history';
  }

  async init() {
    console.log('🌱 Initializing seeder...');
    this.connection = await mysql.createConnection(dbConfig);
    
    // Create seed history table
    await this.createSeedHistoryTable();
    
    console.log('✅ Seeder initialized');
  }

  async createSeedHistoryTable() {
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS ${this.seedsTable} (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL UNIQUE,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        execution_time_ms INT,
        rows_affected INT DEFAULT 0,
        INDEX idx_name (name)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    `;
    
    await this.connection.execute(createTableSQL);
  }

  async getExecutedSeeds() {
    const [rows] = await this.connection.execute(
      `SELECT name FROM ${this.seedsTable} ORDER BY id ASC`
    );
    return rows.map(row => row.name);
  }

  async getPendingSeeds() {
    try {
      const files = await fs.readdir(this.seedsPath);
      const sqlFiles = files
        .filter(file => file.endsWith('.sql'))
        .sort();

      const executed = await this.getExecutedSeeds();
      const pending = sqlFiles.filter(file => !executed.includes(file));

      return pending;
    } catch (error) {
      console.error('❌ Error reading seeds directory:', error.message);
      return [];
    }
  }

  async executeSeed(fileName) {
    const filePath = path.join(this.seedsPath, fileName);
    
    try {
      console.log(`📦 Executing seed: ${fileName}`);
      const startTime = Date.now();
      
      const sqlContent = await fs.readFile(filePath, 'utf8');
      const statements = sqlContent
        .split(';')
        .map(stmt => stmt.trim())
        .filter(stmt => stmt.length > 0);

      let totalRowsAffected = 0;

      // Begin transaction for seed
      await this.connection.beginTransaction();

      for (const statement of statements) {
        if (statement) {
          console.log(`   Executing: ${statement.substring(0, 100)}...`);
          
          try {
            const [result] = await this.connection.execute(statement);
            
            // Calculate rows affected
            if (result.affectedRows !== undefined) {
              totalRowsAffected += result.affectedRows;
            } else if (result.insertId !== undefined) {
              totalRowsAffected += 1;
            }
          } catch (error) {
            // If it's a duplicate key error, it's okay for seeds
            if (error.code === 'ER_DUP_ENTRY') {
              console.log(`   ⚠️  Duplicate entry skipped: ${error.message.substring(0, 100)}`);
              continue;
            }
            throw error;
          }
        }
      }

      const executionTime = Date.now() - startTime;

      // Record seed execution
      await this.connection.execute(
        `INSERT INTO ${this.seedsTable} (name, execution_time_ms, rows_affected) VALUES (?, ?, ?)`,
        [fileName, executionTime, totalRowsAffected]
      );

      await this.connection.commit();
      
      console.log(`✅ Seed ${fileName} completed in ${executionTime}ms (${totalRowsAffected} rows affected)`);
      return true;

    } catch (error) {
      await this.connection.rollback();
      console.error(`❌ Seed ${fileName} failed:`, error.message);
      return false;
    }
  }

  async seed() {
    await this.init();
    
    const pending = await this.getPendingSeeds();
    
    if (pending.length === 0) {
      console.log('🎉 No pending seeds. Database is already seeded!');
      return;
    }

    console.log(`🌱 Found ${pending.length} pending seed(s):`);
    pending.forEach((file, index) => {
      console.log(`  ${index + 1}. ${file}`);
    });

    console.log('\n🚀 Starting seed execution...');
    
    for (const file of pending) {
      const success = await this.executeSeed(file);
      
      if (!success) {
        console.error(`💥 Seed execution stopped due to failure in ${file}`);
        process.exit(1);
      }
    }

    console.log('\n✨ All seeds executed successfully!');
    await this.connection.end();
  }

  async refresh() {
    await this.init();
    
    console.log('🔄 Refreshing seeds...');
    
    // Clear seed history
    await this.connection.execute(`DELETE FROM ${this.seedsTable}`);
    console.log('✅ Cleared seed history');
    
    // Run all seeds again
    await this.seed();
  }

  async status() {
    await this.init();

    const [executed] = await this.connection.execute(
      `SELECT name, executed_at, execution_time_ms, rows_affected FROM ${this.seedsTable} ORDER BY id ASC`
    );

    const pending = await this.getPendingSeeds();

    console.log('📊 Seed Status:');
    console.log('===============');
    
    console.log('\n✅ Executed Seeds:');
    if (executed.length === 0) {
      console.log('   No seeds executed yet');
    } else {
      executed.forEach(seed => {
        console.log(`   ✅ ${seed} (Executed: ${seed.executed_at}, Time: ${seed.execution_time_ms}ms, Rows: ${seed.rows_affected})`);
      });
    }

    console.log('\n⏳ Pending Seeds:');
    if (pending.length === 0) {
      console.log('   No pending seeds');
    } else {
      pending.forEach(file => {
        console.log(`   ⏳ ${file}`);
      });
    }

    console.log(`\n📈 Summary: ${executed.length} executed, ${pending.length} pending`);
    await this.connection.end();
  }

  async seedSpecific(fileName) {
    await this.init();
    
    const filePath = path.join(this.seedsPath, fileName);
    
    try {
      await fs.access(filePath);
      await this.executeSeed(fileName);
    } catch (error) {
      console.error(`❌ Seed file ${fileName} not found or error:`, error.message);
    }
    
    await this.connection.end();
  }
}

// Command line interface
async function main() {
  const command = process.argv[2];
  const seeder = new Seeder();

  try {
    switch (command) {
      case 'run':
        await seeder.seed();
        break;
      case 'refresh':
        await seeder.refresh();
        break;
      case 'status':
        await seeder.status();
        break;
      case 'run:single':
        const fileName = process.argv[3];
        if (!fileName) {
          console.log('Please specify seed file name');
          process.exit(1);
        }
        await seeder.seedSpecific(fileName);
        break;
      default:
        console.log(`
Usage: node seed.js <command>
        
Commands:
  run                     Run all pending seeds
  refresh                 Clear history and run all seeds
  status                  Show seed status
  run:single <filename>   Run specific seed file
        
Examples:
  node seed.js run
  node seed.js refresh
  node seed.js status
  node seed.js run:single 001_system_admin.sql
        `);
    }
  } catch (error) {
    console.error('💥 Seed error:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = Seeder;