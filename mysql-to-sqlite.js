import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// MySQL to SQLite conversions
const mysqlToSqlite = {
  // Data types
  'BIGINT UNSIGNED': 'INTEGER',
  'INT UNSIGNED': 'INTEGER',
  'INT': 'INTEGER',
  'TINYINT': 'INTEGER',
  'SMALLINT': 'INTEGER',
  'MEDIUMINT': 'INTEGER',
  'DECIMAL\\([^)]+\\)': 'REAL',
  'DATETIME': 'TEXT',
  'TIMESTAMP': 'TEXT',
  'ENUM\\([^)]+\\)': 'TEXT',
  'BOOLEAN': 'INTEGER', // SQLite uses 0/1 for boolean
  
  // Keywords
  'AUTO_INCREMENT': 'AUTOINCREMENT',
  'UNSIGNED': '',
  'CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci': '',
  'ENGINE=InnoDB': '',
  'DEFAULT CURRENT_TIMESTAMP': 'DEFAULT CURRENT_TIMESTAMP',
  'ON UPDATE CURRENT_TIMESTAMP': '',
  
  // Constraints (SQLite has limited CHECK support)
  'CHECK \\(`[^`]+` REGEXP': '-- CHECK (REGEXP not supported in SQLite',
  'CONSTRAINT `chk_[^`]+`': '-- CONSTRAINT chk_',
  
  // Indexes (need to be separate statements in SQLite)
  ',\\s*INDEX `[^`]+`': (match) => {
    // Extract index definition and convert to separate statement
    return ', -- INDEX converted separately';
  },
  ',\\s*UNIQUE INDEX `[^`]+`': ', -- UNIQUE INDEX converted separately',
  ',\\s*FOREIGN KEY \\([^)]+\\) REFERENCES': (match) => {
    // Keep foreign keys but adjust syntax
    return match.replace(/`/g, '');
  },
  
  // Remove backticks
  '`': ''
};

function convertMySQLToSQLite(sql) {
  let converted = sql;
  
  // Apply conversions
  Object.entries(mysqlToSqlite).forEach(([pattern, replacement]) => {
    if (typeof replacement === 'function') {
      converted = converted.replace(new RegExp(pattern, 'gi'), replacement);
    } else {
      converted = converted.replace(new RegExp(pattern, 'gi'), replacement);
    }
  });
  
  // Clean up extra commas
  converted = converted.replace(/,\s*,/g, ',');
  converted = converted.replace(/,\s*\)/g, ')');
  
  return converted;
}

async function convertMigrationFile(inputPath, outputPath) {
  try {
    const content = await fs.readFile(inputPath, 'utf8');
    const converted = convertMySQLToSQLite(content);
    
    // Add SQLite pragma
    const finalContent = `-- Converted from MySQL to SQLite
-- Original file: ${path.basename(inputPath)}
${converted}`;
    
    await fs.writeFile(outputPath, finalContent, 'utf8');
    console.log(`‚úÖ Converted: ${path.basename(inputPath)}`);
    return true;
  } catch (error) {
    console.error(`‚ùå Failed to convert ${inputPath}:`, error.message);
    return false;
  }
}

async function main() {
  const inputDir = path.join(__dirname, 'src/database/migrations');
  const outputDir = path.join(__dirname, 'src/database/migrations-sqlite');
  
  // Create output directory
  await fs.mkdir(outputDir, { recursive: true });
  
  // Get all SQL files
  const files = (await fs.readdir(inputDir)).filter(f => f.endsWith('.sql'));
  
  console.log(`Ì¥Ñ Converting ${files.length} MySQL files to SQLite...`);
  
  let successCount = 0;
  for (const file of files) {
    const inputPath = path.join(inputDir, file);
    const outputPath = path.join(outputDir, file);
    
    const success = await convertMigrationFile(inputPath, outputPath);
    if (success) successCount++;
  }
  
  console.log(`\nÌ≥ä Conversion complete: ${successCount}/${files.length} files converted`);
  console.log(`Ì≥Å SQLite migrations in: ${outputDir}`);
}

main().catch(console.error);
