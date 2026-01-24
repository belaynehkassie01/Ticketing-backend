// backend/src/config/integrations/telebirr.config.js
export default {
  // Environment settings
  environment: process.env.TELEBIRR_ENV || 'sandbox', // sandbox, production
  
  // API Credentials
  credentials: {
    sandbox: {
      appId: process.env.TELEBIRR_SANDBOX_APP_ID || 'your_sandbox_app_id',
      appKey: process.env.TELEBIRR_SANDBOX_APP_KEY || 'your_sandbox_app_key',
      publicKey: process.env.TELEBIRR_SANDBOX_PUBLIC_KEY || 'sandbox_public_key',
      privateKey: process.env.TELEBIRR_SANDBOX_PRIVATE_KEY || 'sandbox_private_key',
      merchantId: process.env.TELEBIRR_SANDBOX_MERCHANT_ID || 'sandbox_merchant_id',
    },
    production: {
      appId: process.env.TELEBIRR_APP_ID,
      appKey: process.env.TELEBIRR_APP_KEY,
      publicKey: process.env.TELEBIRR_PUBLIC_KEY,
      privateKey: process.env.TELEBIRR_PRIVATE_KEY,
      merchantId: process.env.TELEBIRR_MERCHANT_ID,
    },
  },
  
  // API Endpoints
  endpoints: {
    sandbox: {
      baseUrl: 'https://testapi.telebirr.com',
      qrGenerate: '/api/v2/generateQR',
      paymentQuery: '/api/v2/queryPayment',
      refund: '/api/v2/refund',
      webhookTest: '/api/v2/webhook/test',
    },
    production: {
      baseUrl: 'https://api.telebirr.com',
      qrGenerate: '/api/v2/generateQR',
      paymentQuery: '/api/v2/queryPayment',
      refund: '/api/v2/refund',
      webhookUrl: process.env.TELEBIRR_WEBHOOK_URL || 'https://yourdomain.com/api/webhooks/telebirr',
    },
  },
  
  // Payment Settings
  payment: {
    currency: 'ETB',
    timeoutSeconds: 900, // 15 minutes
    maxAmount: 50000, // 50,000 ETB
    minAmount: 1, // 1 ETB
    feePercentage: 0.005, // 0.5%
    feeMinimum: 1, // 1 ETB minimum fee
    feeMaximum: 25, // 25 ETB maximum fee
    descriptionTemplate: 'Ticket purchase: {eventName}',
    descriptionAmTemplate: 'ትኬት ግዛት: {eventNameAm}',
  },
  
  // QR Code Settings
  qrCode: {
    size: 300, // pixels
    format: 'png',
    logo: '/logos/telebirr-logo.png',
    color: '#0066CC', // Telebirr blue
    margin: 1,
    errorCorrection: 'M', // L, M, Q, H
  },
  
  // Webhook Configuration
  webhook: {
    secret: process.env.TELEBIRR_WEBHOOK_SECRET || 'your_webhook_secret',
    signatureHeader: 'X-Telebirr-Signature',
    events: [
      'payment.success',
      'payment.failed',
      'payment.pending',
      'refund.success',
    ],
    retryAttempts: 3,
    retryDelay: 5000, // 5 seconds
    timeout: 10000, // 10 seconds
  },
  
  // Security Settings
  security: {
    encryptionAlgorithm: 'RSA',
    hashAlgorithm: 'SHA256',
    timestampTolerance: 300, // 5 minutes in seconds
    nonceLength: 16,
    requestExpiry: 300, // 5 minutes
  },
  
  // Merchant Information
  merchant: {
    name: process.env.MERCHANT_NAME || 'Ethio Tickets Platform',
    nameAm: process.env.MERCHANT_NAME_AM || 'ኢትዮ ቲኬትስ ስርአት',
    category: '6540', // MCC code for Ticketing Services
    city: 'Addis Ababa',
    country: 'ET',
    contact: process.env.MERCHANT_CONTACT || '+251911223344',
    email: process.env.MERCHANT_EMAIL || 'payments@ethiotickets.com',
  },
  
  // Callback URLs
  callbacks: {
    success: process.env.TELEBIRR_SUCCESS_URL || 'https://yourdomain.com/payment/success',
    failure: process.env.TELEBIRR_FAILURE_URL || 'https://yourdomain.com/payment/failed',
    cancel: process.env.TELEBIRR_CANCEL_URL || 'https://yourdomain.com/payment/cancelled',
    notification: process.env.TELEBIRR_NOTIFICATION_URL || 'https://yourdomain.com/api/payments/telebirr/notify',
  },
  
  // Utility Functions
  getConfig: function() {
    const env = this.environment;
    return {
      credentials: this.credentials[env],
      endpoints: this.endpoints[env],
      environment: env,
    };
  },
  
  getBaseUrl: function() {
    return this.endpoints[this.environment].baseUrl;
  },
  
  getCredentials: function() {
    return this.credentials[this.environment];
  },
  
  generateOrderId: function(prefix = 'TKT') {
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 10000);
    return `${prefix}-${timestamp}-${random}`;
  },
  
  calculateFee: function(amount) {
    const fee = amount * this.payment.feePercentage;
    
    if (fee < this.payment.feeMinimum) {
      return this.payment.feeMinimum;
    }
    
    if (fee > this.payment.feeMaximum) {
      return this.payment.feeMaximum;
    }
    
    return Math.ceil(fee);
  },
  
  validatePaymentAmount: function(amount) {
    if (amount < this.payment.minAmount) {
      return {
        valid: false,
        error: `Amount must be at least ${this.payment.minAmount} ETB`,
      };
    }
    
    if (amount > this.payment.maxAmount) {
      return {
        valid: false,
        error: `Amount cannot exceed ${this.payment.maxAmount} ETB`,
      };
    }
    
    return { valid: true, error: null };
  },
  
  formatDescription: function(eventName, eventNameAm = '', language = 'en') {
    if (language === 'am' && eventNameAm) {
      return this.payment.descriptionAmTemplate.replace('{eventNameAm}', eventNameAm);
    }
    return this.payment.descriptionTemplate.replace('{eventName}', eventName);
  },
  
  getWebhookUrl: function() {
    if (this.environment === 'sandbox') {
      return this.endpoints.sandbox.webhookTest;
    }
    return this.endpoints.production.webhookUrl;
  },
  
  // Response code mappings
  responseCodes: {
    '0000': { status: 'success', message: 'Transaction successful' },
    '1001': { status: 'failed', message: 'Insufficient balance' },
    '1002': { status: 'failed', message: 'Transaction timeout' },
    '1003': { status: 'failed', message: 'Invalid QR code' },
    '1004': { status: 'failed', message: 'Payment cancelled by user' },
    '1005': { status: 'failed', message: 'System error' },
    '1006': { status: 'pending', message: 'Payment processing' },
    '1007': { status: 'failed', message: 'Invalid merchant' },
    '1008': { status: 'failed', message: 'Duplicate transaction' },
    '1009': { status: 'failed', message: 'Amount mismatch' },
  },
  
  getStatusFromCode: function(code) {
    return this.responseCodes[code] || { status: 'unknown', message: 'Unknown response code' };
  },
  
  // Signature verification helper
  verifyWebhookSignature: function(payload, signature, timestamp) {
    // Implementation depends on Telebirr's signature algorithm
    // This is a placeholder - implement based on Telebirr's documentation
    const currentTime = Math.floor(Date.now() / 1000);
    const timeDiff = Math.abs(currentTime - parseInt(timestamp));
    
    if (timeDiff > this.security.timestampTolerance) {
      return { valid: false, error: 'Timestamp expired' };
    }
    
    // Add actual signature verification logic here
    return { valid: true, error: null };
  },
};