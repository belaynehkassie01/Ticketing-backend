// backend/src/config/integrations/email.config.js
export default {
  // Email Service Provider
  provider: process.env.EMAIL_PROVIDER || 'smtp', // smtp, sendgrid, mailgun, ses
  
  // SMTP Configuration (Default)
  smtp: {
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587', 10),
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER || 'your-email@gmail.com',
      pass: process.env.SMTP_PASS || 'your-app-password',
    },
    tls: {
      rejectUnauthorized: false,
    },
    pool: true,
    maxConnections: 5,
    maxMessages: 100,
    rateDelta: 1000, // 1 second between emails
    rateLimit: 100, // 100 emails per rateDelta
  },
  
  // SendGrid Configuration
  sendgrid: {
    apiKey: process.env.SENDGRID_API_KEY,
    fromEmail: process.env.SENDGRID_FROM_EMAIL || 'noreply@ethiotickets.com',
    fromName: process.env.SENDGRID_FROM_NAME || 'Ethio Tickets',
    trackingEnabled: true,
    clickTracking: true,
    openTracking: true,
    subscriptionTracking: true,
  },
  
  // Mailgun Configuration
  mailgun: {
    apiKey: process.env.MAILGUN_API_KEY,
    domain: process.env.MAILGUN_DOMAIN || 'mg.ethiotickets.com',
    fromEmail: process.env.MAILGUN_FROM_EMAIL || 'noreply@ethiotickets.com',
    fromName: process.env.MAILGUN_FROM_NAME || 'Ethio Tickets',
    region: process.env.MAILGUN_REGION || 'us', // us or eu
  },
  
  // AWS SES Configuration
  ses: {
    accessKeyId: process.env.AWS_SES_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SES_SECRET_ACCESS_KEY,
    region: process.env.AWS_SES_REGION || 'us-east-1',
    fromEmail: process.env.AWS_SES_FROM_EMAIL || 'noreply@ethiotickets.com',
    fromName: process.env.AWS_SES_FROM_NAME || 'Ethio Tickets',
    configurationSet: process.env.AWS_SES_CONFIGURATION_SET,
  },
  
  // Email Templates
  templates: {
    directory: './src/templates/emails',
    engine: 'handlebars', // handlebars, ejs, pug
    defaultLanguage: 'en',
    
    // Template configurations
    welcome: {
      subject: {
        en: 'Welcome to Ethio Tickets!',
        am: 'ወደ ኢትዮ ቲኬትስ እንኳን ደህና መጡ!',
      },
      template: 'welcome.html',
      requiredVariables: ['name'],
    },
    
    payment_confirmation: {
      subject: {
        en: 'Payment Confirmation - {eventName}',
        am: 'ክፍያ ማረጋገጫ - {eventNameAm}',
      },
      template: 'payment-confirmation.html',
      requiredVariables: ['eventName', 'amount', 'ticketNumber', 'qrCodeUrl'],
    },
    
    ticket_delivery: {
      subject: {
        en: 'Your Ticket is Ready - {eventName}',
        am: 'ትኬትዎ ዝግጁ ነው - {eventNameAm}',
      },
      template: 'ticket-delivery.html',
      requiredVariables: ['eventName', 'ticketNumber', 'eventDate', 'venue'],
    },
    
    event_reminder: {
      subject: {
        en: 'Reminder: {eventName} starts tomorrow!',
        am: 'አስገንዝብ: {eventNameAm} ነገ ይጀምራል!',
      },
      template: 'event-reminder.html',
      requiredVariables: ['eventName', 'eventTime', 'venue', 'ticketNumber'],
    },
    
    organizer_approved: {
      subject: {
        en: 'Organizer Application Approved!',
        am: 'የአዘጋጅነት ማመልከቻ ተጸድቋል!',
      },
      template: 'organizer-approved.html',
      requiredVariables: ['businessName'],
    },
    
    payout_processed: {
      subject: {
        en: 'Payout Processed - {amount} ETB',
        am: 'ክፍያ ተካሂዷል - {amount} ብር',
      },
      template: 'payout-processed.html',
      requiredVariables: ['amount', 'referenceNumber', 'date'],
    },
    
    password_reset: {
      subject: {
        en: 'Password Reset Request',
        am: 'የይለፍ ቃል መቀየሪያ ጥያቄ',
      },
      template: 'password-reset.html',
      requiredVariables: ['name', 'resetLink', 'expiryTime'],
    },
    
    otp_verification: {
      subject: {
        en: 'Your Verification Code',
        am: 'የማረጋገጫ ኮድዎ',
      },
      template: 'otp-verification.html',
      requiredVariables: ['otp', 'expiryMinutes'],
    },
  },
  
  // Email Queue Settings
  queue: {
    enabled: true,
    maxRetries: 3,
    retryDelay: 5000, // 5 seconds
    batchSize: 50,
    maxQueueSize: 10000,
    processingConcurrency: 3,
    cleanupAge: 30, // Days to keep sent emails in queue
  },
  
  // Delivery Settings
  delivery: {
    maxAttempts: 3,
    timeout: 10000, // 10 seconds
    bounceHandling: true,
    complaintHandling: true,
    unsubscribeHeader: true,
    listUnsubscribe: true,
  },
  
  // Tracking & Analytics
  tracking: {
    enabled: true,
    openTracking: true,
    clickTracking: true,
    googleAnalytics: false,
    utmParameters: {
      source: 'email',
      medium: 'email',
      campaign: 'transactional',
    },
  },
  
  // Bounce & Complaint Handling
  feedback: {
    bounceThreshold: 5, // Percentage of bounces to trigger alert
    complaintThreshold: 1, // Percentage of complaints to trigger alert
    suppressionList: true,
    autoUnsubscribe: true,
    notificationEmail: process.env.BOUNCE_NOTIFICATION_EMAIL,
  },
  
  // Security & Compliance
  security: {
    dkimEnabled: true,
    spfEnabled: true,
    dmarcEnabled: true,
    tlsRequired: true,
    requireTLS: true,
    priority: 'normal',
    headers: {
      'X-Priority': '3',
      'X-Mailer': 'Ethio Tickets Platform',
      'X-Auto-Response-Suppress': 'OOF, AutoReply',
    },
  },
  
  // Utility Functions
  getConfig: function() {
    const provider = this.provider;
    
    switch (provider) {
      case 'sendgrid':
        return {
          provider: 'sendgrid',
          config: this.sendgrid,
        };
      case 'mailgun':
        return {
          provider: 'mailgun',
          config: this.mailgun,
        };
      case 'ses':
        return {
          provider: 'ses',
          config: this.ses,
        };
      default:
        return {
          provider: 'smtp',
          config: this.smtp,
        };
    }
  },
  
  getFromAddress: function(language = 'en') {
    const config = this.getConfig();
    
    if (config.provider === 'smtp') {
      return {
        email: this.smtp.auth.user,
        name: 'Ethio Tickets',
      };
    }
    
    return {
      email: config.config.fromEmail,
      name: config.config.fromName,
    };
  },
  
  getTemplateConfig: function(templateName) {
    return this.templates[templateName] || null;
  },
  
  renderSubject: function(templateName, variables, language = 'en') {
    const template = this.getTemplateConfig(templateName);
    if (!template || !template.subject) return null;
    
    let subject = template.subject[language] || template.subject.en;
    
    // Replace variables in subject
    Object.keys(variables).forEach(key => {
      const placeholder = `{${key}}`;
      subject = subject.replace(new RegExp(placeholder, 'g'), variables[key]);
    });
    
    return subject;
  },
  
  validateEmail: function(email) {
    const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return regex.test(email);
  },
  
  sanitizeEmail: function(email) {
    return email.trim().toLowerCase();
  },
  
  canSendToEmail: function(email, userPreferences = {}) {
    const sanitized = this.sanitizeEmail(email);
    
    // Check if email is valid
    if (!this.validateEmail(sanitized)) {
      return { canSend: false, reason: 'invalid_email' };
    }
    
    // Check user preferences
    if (userPreferences.emailOptOut === true) {
      return { canSend: false, reason: 'user_opted_out' };
    }
    
    // Check if email is in suppression list (would check database)
    // This is a placeholder - implement based on your suppression list
    
    return { canSend: true, reason: null };
  },
  
  getBounceHandlingAction: function(bounceType, bounceCount) {
    const actions = {
      permanent: {
        1: 'add_to_suppression_list',
        2: 'disable_user_email',
        3: 'notify_admin',
      },
      transient: {
        1: 'retry_later',
        2: 'retry_with_delay',
        3: 'add_to_suppression_list_temp',
      },
    };
    
    const action = actions[bounceType]?.[bounceCount] || 'notify_admin';
    
    return {
      action,
      message: `Bounce ${bounceType} count: ${bounceCount}`,
      requiresManualReview: bounceCount >= 3,
    };
  },
  
  formatEmailHeaders: function(templateName, trackingId) {
    const headers = {
      ...this.security.headers,
      'Message-ID': `<${trackingId}@ethiotickets.com>`,
      'List-Unsubscribe': `<https://ethiotickets.com/unsubscribe/${trackingId}>`,
      'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',
    };
    
    if (this.tracking.enabled) {
      headers['X-Tracking-ID'] = trackingId;
    }
    
    return headers;
  },
  
  generateTrackingId: function() {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 15);
    return `${timestamp}-${random}`;
  },
  
  getTemplatePath: function(templateName, language = 'en') {
    const template = this.getTemplateConfig(templateName);
    if (!template) return null;
    
    const langDir = language === 'am' ? 'am' : 'en';
    return `${this.templates.directory}/${langDir}/${template.template}`;
  },
  
  // Rate limiting helper
  getRateLimitDelay: function(emailCount) {
    const rateLimit = this.smtp.rateLimit || 100;
    const rateDelta = this.smtp.rateDelta || 1000;
    
    if (emailCount >= rateLimit) {
      return rateDelta;
    }
    
    return 0;
  },
  
  // Batch processing helper
  createEmailBatch: function(emails, batchSize = this.queue.batchSize) {
    const batches = [];
    
    for (let i = 0; i < emails.length; i += batchSize) {
      batches.push(emails.slice(i, i + batchSize));
    }
    
    return batches;
  },
};