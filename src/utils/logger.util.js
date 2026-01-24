// backend/src/utils/logger.util.js
import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import path from 'path';
import fs from 'fs';

// Create logs directory if it doesn't exist
const logDir = 'logs';
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

// Custom log levels for Ethiopian Ticketing Platform
const ethioTicketLevels = {
  emergency: 0,   // System unusable
  alert: 1,       // Immediate action needed
  critical: 2,    // Critical conditions
  error: 3,       // Error conditions
  warning: 4,     // Warning conditions
  notice: 5,      // Normal but significant
  info: 6,        // Informational messages
  debug: 7,       // Debug-level messages
  trace: 8        // Trace-level messages
};

const ethioTicketColors = {
  emergency: 'red',
  alert: 'red',
  critical: 'red',
  error: 'red',
  warning: 'yellow',
  notice: 'cyan',
  info: 'green',
  debug: 'blue',
  trace: 'gray'
};

winston.addColors(ethioTicketColors);

// Custom format for Ethiopian context
const ethioTicketFormat = winston.format.combine(
  winston.format.timestamp({
    format: 'YYYY-MM-DD HH:mm:ss.SSS'
  }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

// Console format (human readable)
const consoleFormat = winston.format.combine(
  winston.format.colorize({ all: true }),
  winston.format.timestamp({
    format: 'HH:mm:ss'
  }),
  winston.format.printf((info) => {
    const { timestamp, level, message, ...meta } = info;
    
    let metaString = '';
    if (Object.keys(meta).length > 0 && !meta.stack) {
      metaString = JSON.stringify(meta, null, 2);
    }
    
    return `[${timestamp}] ${level}: ${message} ${metaString}`.trim();
  })
);

// Create the logger instance
const logger = winston.createLogger({
  levels: ethioTicketLevels,
  level: process.env.LOG_LEVEL || 'info',
  format: ethioTicketFormat,
  defaultMeta: {
    service: 'ethio-tickets',
    environment: process.env.NODE_ENV || 'development',
    timezone: 'Africa/Addis_Ababa'
  },
  transports: [
    // Console transport for development
    new winston.transports.Console({
      format: consoleFormat,
      level: process.env.NODE_ENV === 'production' ? 'info' : 'debug'
    }),
    
    // Daily rotate file for application logs
    new DailyRotateFile({
      filename: path.join(logDir, 'application-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      zippedArchive: true,
      maxSize: '20m',
      maxFiles: '30d',
      level: 'info'
    }),
    
    // Error logs (separate file)
    new DailyRotateFile({
      filename: path.join(logDir, 'error-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      zippedArchive: true,
      maxSize: '20m',
      maxFiles: '30d',
      level: 'error'
    }),
    
    // Payment transaction logs
    new DailyRotateFile({
      filename: path.join(logDir, 'payment-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      zippedArchive: true,
      maxSize: '20m',
      maxFiles: '30d',
      level: 'info',
      format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.json()
      )
    }),
    
    // Audit logs (for admin actions)
    new DailyRotateFile({
      filename: path.join(logDir, 'audit-%DATE%.log'),
      datePattern: 'YYYY-MM-DD',
      zippedArchive: true,
      maxSize: '20m',
      maxFiles: '90d', // Keep audit logs longer
      level: 'notice'
    })
  ]
});

// Helper functions for different log types
export default {
  // System logs
  emergency: (message, meta = {}) => logger.emerg(message, meta),
  alert: (message, meta = {}) => logger.alert(message, meta),
  critical: (message, meta = {}) => logger.critical(message, meta),
  error: (message, meta = {}) => logger.error(message, meta),
  warning: (message, meta = {}) => logger.warning(message, meta),
  notice: (message, meta = {}) => logger.notice(message, meta),
  info: (message, meta = {}) => logger.info(message, meta),
  debug: (message, meta = {}) => logger.debug(message, meta),
  trace: (message, meta = {}) => logger.trace(message, meta),
  
  // Domain-specific logs
  user: {
    registered: (userId, phone, meta = {}) => 
      logger.info('User registered', { userId, phone, event: 'user_registered', ...meta }),
    
    login: (userId, device, meta = {}) => 
      logger.info('User login', { userId, device, event: 'user_login', ...meta }),
    
    profileUpdate: (userId, changes, meta = {}) => 
      logger.info('Profile updated', { userId, changes, event: 'profile_update', ...meta }),
    
    roleChanged: (userId, oldRole, newRole, meta = {}) => 
      logger.notice('User role changed', { userId, oldRole, newRole, event: 'role_change', ...meta })
  },
  
  organizer: {
    applicationSubmitted: (applicationId, userId, meta = {}) => 
      logger.info('Organizer application submitted', { applicationId, userId, event: 'organizer_application_submitted', ...meta }),
    
    applicationApproved: (applicationId, organizerId, adminId, meta = {}) => 
      logger.notice('Organizer application approved', { applicationId, organizerId, adminId, event: 'organizer_application_approved', ...meta }),
    
    eventCreated: (eventId, organizerId, meta = {}) => 
      logger.info('Event created', { eventId, organizerId, event: 'event_created', ...meta }),
    
    payoutRequested: (payoutId, organizerId, amount, meta = {}) => 
      logger.info('Payout requested', { payoutId, organizerId, amount, event: 'payout_requested', ...meta })
  },
  
  payment: {
    initiated: (paymentId, userId, amount, method, meta = {}) => 
      logger.info('Payment initiated', { paymentId, userId, amount, method, event: 'payment_initiated', ...meta }),
    
    completed: (paymentId, transactionId, meta = {}) => 
      logger.info('Payment completed', { paymentId, transactionId, event: 'payment_completed', ...meta }),
    
    failed: (paymentId, reason, meta = {}) => 
      logger.error('Payment failed', { paymentId, reason, event: 'payment_failed', ...meta }),
    
    refunded: (refundId, paymentId, amount, meta = {}) => 
      logger.notice('Payment refunded', { refundId, paymentId, amount, event: 'payment_refunded', ...meta })
  },
  
  ticket: {
    issued: (ticketId, userId, eventId, meta = {}) => 
      logger.info('Ticket issued', { ticketId, userId, eventId, event: 'ticket_issued', ...meta }),
    
    checkedIn: (ticketId, eventId, checkinBy, meta = {}) => 
      logger.info('Ticket checked in', { ticketId, eventId, checkinBy, event: 'ticket_checkin', ...meta }),
    
    transferred: (ticketId, fromUser, toUser, meta = {}) => 
      logger.notice('Ticket transferred', { ticketId, fromUser, toUser, event: 'ticket_transferred', ...meta })
  },
  
  admin: {
    action: (adminId, actionType, target, changes, meta = {}) => 
      logger.notice('Admin action', { adminId, actionType, target, changes, event: 'admin_action', ...meta }),
    
    verification: (adminId, paymentId, decision, meta = {}) => 
      logger.info('Payment verification', { adminId, paymentId, decision, event: 'payment_verification', ...meta }),
    
    payoutProcessed: (adminId, payoutId, amount, meta = {}) => 
      logger.info('Payout processed', { adminId, payoutId, amount, event: 'payout_processed', ...meta })
  },
  
  // Ethiopian-specific logs
  ethiopian: {
    smsSent: (phone, messageType, status, meta = {}) => 
      logger.info('SMS sent', { phone, messageType, status, country: 'ET', event: 'sms_sent', ...meta }),
    
    telebirrPayment: (paymentId, qrData, status, meta = {}) => 
      logger.info('Telebirr payment', { paymentId, qrData, status, gateway: 'telebirr', event: 'telebirr_payment', ...meta }),
    
    cbePayment: (paymentId, reference, status, meta = {}) => 
      logger.info('CBE payment', { paymentId, reference, status, bank: 'cbe', event: 'cbe_payment', ...meta })
  },
  
  // Technical logs
  database: {
    query: (query, duration, meta = {}) => 
      logger.debug('Database query', { query: query.substring(0, 200), duration, event: 'db_query', ...meta }),
    
    transaction: (action, result, meta = {}) => 
      logger.debug('Database transaction', { action, result, event: 'db_transaction', ...meta }),
    
    connection: (status, meta = {}) => 
      logger.info('Database connection', { status, event: 'db_connection', ...meta })
  },
  
  // API logs
  api: {
    request: (method, url, ip, userAgent, meta = {}) => 
      logger.debug('API request', { method, url, ip, userAgent, event: 'api_request', ...meta }),
    
    response: (method, url, statusCode, duration, meta = {}) => 
      logger.debug('API response', { method, url, statusCode, duration, event: 'api_response', ...meta }),
    
    error: (method, url, statusCode, error, meta = {}) => 
      logger.error('API error', { method, url, statusCode, error: error.message, event: 'api_error', ...meta })
  },
  
  // Get logger instance for custom use
  getLogger: () => logger,
  
  // Stream for HTTP logging middleware
  stream: {
    write: (message) => {
      logger.info('HTTP request', { message: message.trim(), event: 'http_request' });
    }
  },
  
  // Log Ethiopian calendar events
  logEthiopianDate: (gregorianDate, ethiopianDate, meta = {}) => {
    logger.info('Ethiopian date conversion', {
      gregorian: gregorianDate,
      ethiopian: ethiopianDate,
      event: 'ethiopian_date_conversion',
      ...meta
    });
  }
};