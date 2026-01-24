// backend/src/config/security.js
import dotenv from 'dotenv';

dotenv.config();

export default {
  // JWT Configuration
  jwt: {
    secret: process.env.JWT_SECRET || 'ethio-tickets-jwt-secret-change-in-production',
    accessTokenExpiry: process.env.JWT_ACCESS_EXPIRY || '7d', // 7 days
    refreshTokenExpiry: process.env.JWT_REFRESH_EXPIRY || '30d', // 30 days
    issuer: process.env.JWT_ISSUER || 'ethio-tickets-api',
    audience: process.env.JWT_AUDIENCE || 'ethio-tickets-app',
    algorithm: 'HS256',
  },
  
  // Password hashing
  bcrypt: {
    saltRounds: parseInt(process.env.BCRYPT_SALT_ROUNDS || '10', 10),
  },
  
  // OTP Configuration
  otp: {
    length: parseInt(process.env.OTP_LENGTH || '6', 10),
    expiryMinutes: parseInt(process.env.OTP_EXPIRY_MINUTES || '10', 10),
    maxAttempts: parseInt(process.env.OTP_MAX_ATTEMPTS || '3', 10),
    cooldownSeconds: parseInt(process.env.OTP_COOLDOWN_SECONDS || '60', 10),
  },
  
  // Account lockout
  accountLockout: {
    maxFailedAttempts: parseInt(process.env.MAX_FAILED_ATTEMPTS || '5', 10),
    lockoutDurationMinutes: parseInt(process.env.LOCKOUT_DURATION_MINUTES || '30', 10),
  },
  
  // API Key security
  apiKeys: {
    minLength: 32,
    maxLength: 128,
    rotationDays: parseInt(process.env.API_KEY_ROTATION_DAYS || '90', 10),
  },
  
  // CORS security headers
  headers: {
    hsts: {
      maxAge: 31536000, // 1 year in seconds
      includeSubDomains: true,
      preload: true,
    },
    contentSecurityPolicy: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.telebirr.com", "https://cbe-api.example.com"],
      fontSrc: ["'self'", "https:", "data:"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
    xFrameOptions: 'DENY',
    xContentTypeOptions: 'nosniff',
    xXSSProtection: '1; mode=block',
    referrerPolicy: 'strict-origin-when-cross-origin',
  },
  
  // Rate limiting per endpoint
  endpointRateLimits: {
    auth: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 5, // 5 attempts per window
    },
    otp: {
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 3, // 3 OTP requests per hour
    },
    payment: {
      windowMs: 5 * 60 * 1000, // 5 minutes
      max: 10, // 10 payment attempts per 5 minutes
    },
    default: {
      windowMs: 15 * 60 * 1000,
      max: 100,
    },
  },
  
  // Fraud detection
  fraudDetection: {
    maxSameDevicePurchases: parseInt(process.env.MAX_SAME_DEVICE_PURCHASES || '10', 10),
    maxSameIpPurchases: parseInt(process.env.MAX_SAME_IP_PURCHASES || '5', 10),
    suspiciousAmountThreshold: parseInt(process.env.SUSPICIOUS_AMOUNT_THRESHOLD || '50000', 10), // 50,000 ETB
  },
  
  // Encryption
  encryption: {
    algorithm: 'aes-256-gcm',
    key: process.env.ENCRYPTION_KEY || '32-char-encryption-key-change-me!',
    ivLength: 16,
  },
};