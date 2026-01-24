const path = require('path');
const fs = require('fs');
require('dotenv').config();

class EnvConfig {
  constructor() {
    this.loadEnvironment();
    this.validateRequired();
  }

  loadEnvironment() {
    const env = process.env.NODE_ENV || 'development';
    const envFile = `.env.${env}`;
    const envPath = path.join(__dirname, '..', '..', envFile);

    // Check if environment-specific file exists
    if (fs.existsSync(envPath)) {
      require('dotenv').config({ path: envPath });
    } else {
      // Fallback to .env file
      require('dotenv').config();
    }

    this.env = env;
  }

  validateRequired() {
    const required = [
      'DB_HOST',
      'DB_USER',
      'DB_NAME',
      'JWT_SECRET',
      'PORT'
    ];

    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
      throw new Error(
        `Missing required environment variables: ${missing.join(', ')}\n` +
        `Please check your .env.${this.env} file or .env file`
      );
    }
  }

  get(key, defaultValue = null) {
    return process.env[key] || defaultValue;
  }

  getInt(key, defaultValue = 0) {
    const value = this.get(key);
    return value ? parseInt(value, 10) : defaultValue;
  }

  getFloat(key, defaultValue = 0.0) {
    const value = this.get(key);
    return value ? parseFloat(value) : defaultValue;
  }

  getBool(key, defaultValue = false) {
    const value = this.get(key);
    if (value === 'true') return true;
    if (value === 'false') return false;
    return defaultValue;
  }

  getArray(key, defaultValue = []) {
    const value = this.get(key);
    if (!value) return defaultValue;
    return value.split(',').map(item => item.trim());
  }

  isDevelopment() {
    return this.env === 'development';
  }

  isProduction() {
    return this.env === 'production';
  }

  isTest() {
    return this.env === 'test';
  }
}

module.exports = new EnvConfig();