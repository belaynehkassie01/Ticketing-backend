import mysql from 'mysql2/promise';

const config = {
  host: 'localhost',
  user: 'root',
  password: '',  // Empty if no password
  database: 'test_db'
};

async function test() {
  try {
    console.log('Trying to connect to MySQL...');
    const conn = await mysql.createConnection({
      host: config.host,
      user: config.user,
      password: config.password
    });
    
    console.log('✅ MySQL is running!');
    
    // List databases
    const [dbs] = await conn.query('SHOW DATABASES');
    console.log('Available databases:');
    dbs.forEach(db => console.log('  -', db.Database));
    
    await conn.end();
    
  } catch (err) {
    console.error('❌ Failed:', err.message);
    console.log('\nPossible solutions:');
    console.log('1. Install MySQL: sudo apt install mysql-server');
    console.log('2. Start MySQL: sudo service mysql start');
    console.log('3. Check if MySQL is running:');
    console.log('   ps aux | grep mysql');
  }
}

test();
