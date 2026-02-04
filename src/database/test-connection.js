const mysql = require('mysql2/promise');
const { dbConfig } = require('../config/database');

(async () => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.query('SELECT 1 + 1 AS result');
    console.log('✅ DB connected. Result:', rows[0].result);
    await conn.end();
  } catch (err) {
    console.error('❌ DB connection failed:', err.message);
  }
})();
