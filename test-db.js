import { db } from './src/config/database.js';

async function testDB() {
  try {
    const [rows] = await db.query('SELECT 1 + 1 AS result');
    console.log('DB connected! Test query result:', rows[0].result);
  } catch (err) {
    console.error('DB connection failed:', err);
  } finally {
    db.end();
  }
}

testDB();
