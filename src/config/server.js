// backend/src/config/server.js
import dotenv from 'dotenv';

dotenv.config();

export default {
  // Server settings
  port: parseInt(process.env.PORT || '5000', 10),
  host: process.env.HOST || '0.0.0.0',
  environment: process.env.NODE_ENV || 'development',
  
  // Application settings
  appName: process.env.APP_NAME || 'Ethiopian Ticketing Platform',
  appVersion: process.env.APP_VERSION || '1.0.0',
  apiPrefix: process.env.API_PREFIX || '/api',
  
  // Session & Cookie settings
  sessionSecret: process.env.SESSION_SECRET || 'ethio-tickets-secret-key-change-in-production',
  sessionMaxAge: parseInt(process.env.SESSION_MAX_AGE || '86400000', 10), // 24 hours
  
  // CORS settings
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000', 'http://localhost:5173'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Accept', 'Origin'],
    maxAge: 86400, // 24 hours
  },
  
  // Rate limiting
  rateLimit: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: process.env.RATE_LIMIT_MAX ? parseInt(process.env.RATE_LIMIT_MAX, 10) : 100,
    message: 'Too many requests from this IP, please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
  },
  
  // Upload limits
  upload: {
    maxFileSize: process.env.MAX_FILE_SIZE ? parseInt(process.env.MAX_FILE_SIZE, 10) : 10 * 1024 * 1024, // 10MB
    allowedImageTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    allowedDocumentTypes: ['application/pdf', 'image/jpeg', 'image/png'],
    uploadPath: process.env.UPLOAD_PATH || 'public/uploads/',
  },
  
  // Ethiopian timezone
  timezone: 'Africa/Addis_Ababa',
  defaultCurrency: 'ETB',
  defaultLanguage: 'am', // Amharic default
  
  // Logging
  logLevel: process.env.LOG_LEVEL || 'info',
  logFormat: process.env.LOG_FORMAT || 'combined',
  
  // Monitoring
  enableMetrics: process.env.ENABLE_METRICS === 'true',
  metricsPath: process.env.METRICS_PATH || '/metrics',
  
  // Health check
  healthCheckPath: process.env.HEALTH_CHECK_PATH || '/health',
  
  // Server timeouts
  requestTimeout: parseInt(process.env.REQUEST_TIMEOUT || '30000', 10),
  keepAliveTimeout: parseInt(process.env.KEEP_ALIVE_TIMEOUT || '5000', 10),
  
  // SSL/TLS (for production)
  ssl: {
    enabled: process.env.SSL_ENABLED === 'true',
    keyPath: process.env.SSL_KEY_PATH,
    certPath: process.env.SSL_CERT_PATH,
    caPath: process.env.SSL_CA_PATH,
  },
};