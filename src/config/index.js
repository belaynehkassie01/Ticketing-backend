const env = require('./env');

module.exports = {
  // Environment
  env: env.env,
  isDevelopment: env.isDevelopment(),
  isProduction: env.isProduction(),
  isTest: env.isTest(),

  // Server
  port: env.getInt('PORT', 5000),
  host: env.get('HOST', '0.0.0.0'),
  nodeEnv: env.get('NODE_ENV', 'development'),
  appName: env.get('APP_NAME', 'Ethiopian Ticketing Platform'),
  appVersion: env.get('APP_VERSION', '1.0.0'),
  apiPrefix: env.get('API_PREFIX', '/api'),

  // Database
  database: {
    host: env.get('DB_HOST', 'localhost'),
    port: env.getInt('DB_PORT', 3306),
    user: env.get('DB_USER', 'root'),
    password: env.get('DB_PASSWORD', ''),
    name: env.get('DB_NAME', 'ethio_tickets_dev'),
    testName: env.get('DB_TEST_NAME', 'ethio_tickets_test'),
    connectionLimit: env.getInt('DB_CONNECTION_LIMIT', 10),
    queueLimit: env.getInt('DB_QUEUE_LIMIT', 0),
    connectTimeout: env.getInt('DB_CONNECT_TIMEOUT', 10000),
    sslEnabled: env.getBool('DB_SSL_ENABLED', false),
  },

  // Security
  security: {
    jwtSecret: env.get('JWT_SECRET'),
    jwtAccessExpiry: env.get('JWT_ACCESS_EXPIRY', '7d'),
    jwtRefreshExpiry: env.get('JWT_REFRESH_EXPIRY', '30d'),
    sessionSecret: env.get('SESSION_SECRET'),
    bcryptSaltRounds: env.getInt('BCRYPT_SALT_ROUNDS', 10),
    encryptionKey: env.get('ENCRYPTION_KEY'),
  },

  // OTP
  otp: {
    length: env.getInt('OTP_LENGTH', 6),
    expiryMinutes: env.getInt('OTP_EXPIRY_MINUTES', 10),
    maxAttempts: env.getInt('OTP_MAX_ATTEMPTS', 3),
    cooldownSeconds: env.getInt('OTP_COOLDOWN_SECONDS', 60),
  },

  // Ethiopian Specific
  ethiopian: {
    defaultLanguage: env.get('DEFAULT_LANGUAGE', 'am'),
    defaultCurrency: env.get('DEFAULT_CURRENCY', 'ETB'),
    timezone: env.get('TIMEZONE', 'Africa/Addis_Ababa'),
    vatRate: env.getFloat('VAT_RATE', 0.15),
    platformCommissionRate: env.getFloat('PLATFORM_COMMISSION_RATE', 0.10),
    calendarEnabled: env.getBool('ETHIOPIAN_CALENDAR_ENABLED', true),
  },

  // Payment Integrations
  payments: {
    telebirr: {
      env: env.get('TELEBIRR_ENV', 'sandbox'),
      sandbox: {
        appId: env.get('TELEBIRR_SANDBOX_APP_ID'),
        appKey: env.get('TELEBIRR_SANDBOX_APP_KEY'),
        publicKey: env.get('TELEBIRR_SANDBOX_PUBLIC_KEY'),
        privateKey: env.get('TELEBIRR_SANDBOX_PRIVATE_KEY'),
        merchantId: env.get('TELEBIRR_SANDBOX_MERCHANT_ID'),
      },
      production: {
        appId: env.get('TELEBIRR_APP_ID'),
        appKey: env.get('TELEBIRR_APP_KEY'),
        publicKey: env.get('TELEBIRR_PUBLIC_KEY'),
        privateKey: env.get('TELEBIRR_PRIVATE_KEY'),
        merchantId: env.get('TELEBIRR_MERCHANT_ID'),
        webhookSecret: env.get('TELEBIRR_WEBHOOK_SECRET'),
      },
    },
    cbe: {
      env: env.get('CBE_ENV', 'development'),
      development: {
        account: env.get('CBE_DEV_ACCOUNT', '1000123456789'),
        accountName: env.get('CBE_DEV_ACCOUNT_NAME', 'Ethio Tickets Dev'),
      },
      production: {
        account: env.get('CBE_PROD_ACCOUNT'),
        accountName: env.get('CBE_PROD_ACCOUNT_NAME', 'Ethio Tickets PLC'),
        apiKey: env.get('CBE_API_KEY'),
        apiSecret: env.get('CBE_API_SECRET'),
      },
    },
  },

  // SMS & Notifications
  notifications: {
    sms: {
      provider: env.get('SMS_PROVIDER', 'mock'),
      ethioTelecom: {
        apiKey: env.get('ETHIO_TELECOM_API_KEY'),
        senderId: env.get('ETHIO_TELECOM_SENDER_ID', 'EthioTickets'),
      },
      mockEnabled: env.getBool('SMS_MOCK_ENABLED', true),
      route: env.get('SMS_ROUTE', 'transactional'),
      dryRun: env.getBool('SMS_DRY_RUN', false),
    },
    email: {
      provider: env.get('EMAIL_PROVIDER', 'smtp'),
      smtp: {
        host: env.get('SMTP_HOST', 'smtp.gmail.com'),
        port: env.getInt('SMTP_PORT', 587),
        secure: env.getBool('SMTP_SECURE', false),
        user: env.get('SMTP_USER'),
        pass: env.get('SMTP_PASS'),
      },
      sendgrid: {
        apiKey: env.get('SENDGRID_API_KEY'),
        fromEmail: env.get('SENDGRID_FROM_EMAIL', 'noreply@ethiotickets.com'),
        fromName: env.get('SENDGRID_FROM_NAME', 'Ethio Tickets'),
      },
    },
    push: {
      enabled: env.getBool('PUSH_NOTIFICATIONS_ENABLED', false),
      fcmServerKey: env.get('FCM_SERVER_KEY'),
    },
  },

  // File Upload
  upload: {
    maxFileSize: env.getInt('MAX_FILE_SIZE', 10485760),
    path: env.get('UPLOAD_PATH', 'public/uploads/'),
    tempPath: env.get('UPLOAD_TEMP_PATH', 'temp/uploads/'),
    allowedImageTypes: env.getArray('ALLOWED_IMAGE_TYPES', [
      'image/jpeg',
      'image/png',
      'image/webp',
    ]),
    allowedDocumentTypes: env.getArray('ALLOWED_DOCUMENT_TYPES', [
      'application/pdf',
      'image/jpeg',
      'image/png',
    ]),
  },

  // CORS
  cors: {
    origin: env.getArray('CORS_ORIGIN', ['http://localhost:3000']),
    credentials: env.getBool('CORS_CREDENTIALS', true),
  },

  // Frontend
  frontend: {
    url: env.get('FRONTEND_URL', 'http://localhost:3000'),
  },

  // Rate Limiting
  rateLimit: {
    max: env.getInt('RATE_LIMIT_MAX', 100),
    windowMs: env.getInt('RATE_LIMIT_WINDOW_MS', 900000),
    otpMax: env.getInt('OTP_RATE_LIMIT', 5),
    otpWindowMs: env.getInt('OTP_RATE_WINDOW_MS', 900000),
  },

  // Logging
  logging: {
    level: env.get('LOG_LEVEL', 'info'),
    format: env.get('LOG_FORMAT', 'combined'),
    toFile: env.getBool('LOG_TO_FILE', false),
    filePath: env.get('LOG_FILE_PATH', 'logs/app.log'),
    errorPath: env.get('ERROR_LOG_PATH', 'logs/error.log'),
  },

  // Merchant Information
  merchant: {
    name: env.get('MERCHANT_NAME', 'Ethio Tickets Platform'),
    nameAm: env.get('MERCHANT_NAME_AM', 'ኢትዮ ቲኬትስ ስርአት'),
    contact: env.get('MERCHANT_CONTACT', '+251911223344'),
    email: env.get('MERCHANT_EMAIL', 'payments@ethiotickets.com'),
  },

  // Debug & Development
  debug: {
    enabled: env.getBool('DEBUG', false),
    metricsEnabled: env.getBool('ENABLE_METRICS', true),
    swaggerEnabled: env.getBool('ENABLE_SWAGGER', true),
    healthCheckPath: env.get('HEALTH_CHECK_PATH', '/health'),
    metricsPath: env.get('METRICS_PATH', '/metrics'),
    swaggerPath: env.get('SWAGGER_PATH', '/api-docs'),
  },

  // Cache
  cache: {
    redisHost: env.get('REDIS_HOST', 'localhost'),
    redisPort: env.getInt('REDIS_PORT', 6379),
    redisPassword: env.get('REDIS_PASSWORD'),
    ttl: env.getInt('CACHE_TTL', 3600),
    sessionStore: env.get('SESSION_STORE', 'memory'),
  },

  // Monitoring
  monitoring: {
    sentryEnabled: env.getBool('ENABLE_SENTRY', false),
    sentryDsn: env.get('SENTRY_DSN'),
  },

  // Seed Data
  seed: {
    adminEmail: env.get('SEED_ADMIN_EMAIL', 'admin@ethiotickets.dev'),
    adminPassword: env.get('SEED_ADMIN_PASSWORD', 'Admin123!'),
    demoOrganizers: env.getBool('SEED_DEMO_ORGANIZERS', true),
    demoEvents: env.getBool('SEED_DEMO_EVENTS', true),
  },
};