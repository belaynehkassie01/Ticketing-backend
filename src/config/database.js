// backend/src/config/database.js
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import logger from '../utils/logger.util.js';

dotenv.config();

// Enhanced configuration with environment-specific settings
const databaseConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'ethio_tickets_dev',
  
  // Connection pool settings
  waitForConnections: true,
  connectionLimit: parseInt(process.env.DB_CONNECTION_LIMIT || '10'),
  queueLimit: parseInt(process.env.DB_QUEUE_LIMIT || '0'),
  
  // Timezone for Ethiopian context
  timezone: '+03:00', // Ethiopian timezone (EAT)
  charset: 'utf8mb4',
  
  // Connection timeout settings
  connectTimeout: parseInt(process.env.DB_CONNECT_TIMEOUT || '10000'),
  acquireTimeout: parseInt(process.env.DB_ACQUIRE_TIMEOUT || '10000'),
  
  // Enable keep-alive
  enableKeepAlive: true,
  keepAliveInitialDelay: 0,
  
  // Enable prepared statements
  namedPlaceholders: true,
  
  // SSL configuration (for production)
  ssl: process.env.DB_SSL === 'true' ? {
    rejectUnauthorized: false,
    ca: process.env.DB_SSL_CA,
    cert: process.env.DB_SSL_CERT,
    key: process.env.DB_SSL_KEY
  } : undefined
};

// Create connection pool
export const pool = mysql.createPool(databaseConfig);

// Enhanced database utility functions
export const db = {
  // Raw query execution
  query: async (sql, params = []) => {
    try {
      const [rows] = await pool.execute(sql, params);
      return rows;
    } catch (error) {
      logger.error('Database query error:', {
        error: error.message,
        sql: sql.substring(0, 200), // Log first 200 chars
        params
      });
      throw error;
    }
  },
  
  // Transaction support
  transaction: async (callback) => {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      const result = await callback(connection);
      await connection.commit();
      return result;
    } catch (error) {
      await connection.rollback();
      logger.error('Database transaction error:', error);
      throw error;
    } finally {
      connection.release();
    }
  },
  
  // Single query with transaction (auto-commit/rollback)
  executeInTransaction: async (sql, params = []) => {
    const connection = await pool.getConnection();
    try {
      await connection.beginTransaction();
      const [result] = await connection.execute(sql, params);
      await connection.commit();
      return result;
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  },
  
  // Safe parameter formatting
  escape: (value) => pool.escape(value),
  escapeId: (value) => pool.escapeId(value),
  
  // Format SQL with parameters
  format: (sql, params) => mysql.format(sql, params),
  
  // Get connection from pool (for manual control)
  getConnection: () => pool.getConnection(),
  
  // Release connection back to pool
  releaseConnection: (connection) => connection.release(),
  
  // Check if connection is alive
  ping: async () => {
    try {
      const connection = await pool.getConnection();
      await connection.ping();
      connection.release();
      return true;
    } catch (error) {
      return false;
    }
  },
  
  // Get pool statistics
  getPoolStats: () => {
    return {
      totalConnections: pool._allConnections.length,
      freeConnections: pool._freeConnections.length,
      connectionLimit: pool.config.connectionLimit,
      queueSize: pool._connectionQueue.length
    };
  }
};

// Database connection test function
export const testDatabaseConnection = async () => {
  try {
    const connection = await pool.getConnection();
    await connection.ping();
    connection.release();
    
    logger.info('✅ Database connected successfully', {
      host: databaseConfig.host,
      database: databaseConfig.database,
      timezone: databaseConfig.timezone
    });
    
    return {
      success: true,
      message: 'Database connected successfully',
      details: {
        host: databaseConfig.host,
        database: databaseConfig.database,
        timezone: databaseConfig.timezone
      }
    };
  } catch (error) {
    logger.error('❌ Database connection failed:', {
      error: error.message,
      host: databaseConfig.host,
      database: databaseConfig.database
    });
    
    return {
      success: false,
      message: 'Database connection failed',
      error: error.message,
      details: {
        host: databaseConfig.host,
        database: databaseConfig.database
      }
    };
  }
};

// Connection health check (for monitoring)
export const healthCheck = async () => {
  try {
    const connection = await pool.getConnection();
    
    // Test basic query
    const [result] = await connection.execute('SELECT 1 as test');
    
    // Check database time
    const [timeResult] = await connection.execute('SELECT NOW() as db_time, @@time_zone as timezone');
    
    connection.release();
    
    const stats = db.getPoolStats();
    
    return {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      database: {
        connected: true,
        host: databaseConfig.host,
        name: databaseConfig.database,
        timezone: timeResult[0].timezone,
        databaseTime: timeResult[0].db_time
      },
      pool: stats,
      responseTime: Date.now() // Would need to calculate actual response time
    };
  } catch (error) {
    return {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message,
      database: {
        connected: false,
        host: databaseConfig.host,
        name: databaseConfig.database
      }
    };
  }
};

// Graceful shutdown handler
export const closeDatabaseConnections = async () => {
  try {
    await pool.end();
    logger.info('Database connections closed gracefully');
    return true;
  } catch (error) {
    logger.error('Error closing database connections:', error);
    return false;
  }
};

// Auto-test connection on startup (in development)
if (process.env.NODE_ENV === 'development') {
  testDatabaseConnection().catch(console.error);
}

// Handle process termination
process.on('SIGINT', async () => {
  await closeDatabaseConnections();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await closeDatabaseConnections();
  process.exit(0);
});

export default db;