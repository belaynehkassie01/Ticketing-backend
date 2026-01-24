// backend/src/config/ethiopian/sms.config.js
export default {
  // SMS Gateway Providers
  providers: [
    {
      name: 'Ethio Telecom',
      code: 'ethio_telecom',
      isDefault: true,
      isActive: true,
      priority: 1,
      apiUrl: 'https://sms.ethiotelecom.et/api/v1',
      supportsAmharic: true,
      maxMessageLength: 459, // For Amharic/Unicode
      asciiMaxLength: 160,
      deliveryReport: true,
      senderId: 'EthioTickets',
      senderIdAm: 'ኢትዮቲኬት',
    },
    {
      name: 'Infobip',
      code: 'infobip',
      isDefault: false,
      isActive: true,
      priority: 2,
      apiUrl: 'https://api.infobip.com/sms/2/text/advanced',
      supportsAmharic: true,
      maxMessageLength: 70, // For Unicode
      asciiMaxLength: 160,
      deliveryReport: true,
      senderId: 'EthioTickets',
    },
    {
      name: 'Twilio',
      code: 'twilio',
      isDefault: false,
      isActive: true,
      priority: 3,
      apiUrl: 'https://api.twilio.com/2010-04-01',
      supportsAmharic: true,
      maxMessageLength: 70,
      asciiMaxLength: 160,
      deliveryReport: true,
      senderId: '+251XXXXXXXXX', // Ethiopian virtual number
    },
  ],
  
  // SMS Templates (Bilingual)
  templates: {
    otp: {
      code: 'OTP_VERIFICATION',
      en: 'Your verification code is {otp}. Valid for {minutes} minutes.',
      am: 'የማረጋገጫ ኮድዎ {otp} ነው። ለ{minutes} ደቂቃዎች የሚሰራ ነው።',
      variables: ['otp', 'minutes'],
      type: 'otp',
      priority: 'high',
    },
    payment_confirmation: {
      code: 'PAYMENT_CONFIRMED',
      en: 'Payment of {amount} ETB for {event} confirmed. Ticket: {ticketNumber}. Show QR at venue.',
      am: 'ለ{event} {amount} ብር ክፍያዎ ተረጋግጧል። ትኬት: {ticketNumber}። QR በዝግጅት ቦታ ያሳዩ።',
      variables: ['amount', 'event', 'ticketNumber'],
      type: 'transaction',
      priority: 'high',
    },
    ticket_delivery: {
      code: 'TICKET_DELIVERY',
      en: 'Your ticket for {event} is ready! Ticket No: {ticketNumber}. View: {link}',
      am: 'ለ{event} ያለዎት ትኬት ዝግጁ ነው! ትኬት ቁጥር: {ticketNumber}። ይመልከቱ: {link}',
      variables: ['event', 'ticketNumber', 'link'],
      type: 'ticket',
      priority: 'medium',
    },
    event_reminder: {
      code: 'EVENT_REMINDER',
      en: 'Reminder: {event} starts {time}. Venue: {venue}. Bring your ticket QR code.',
      am: 'አስገንዝብ: {event} {time} ይጀምራል። ቦታ: {venue}። የትኬትዎን QR ኮድ ይዘው ይምጡ።',
      variables: ['event', 'time', 'venue'],
      type: 'reminder',
      priority: 'medium',
    },
    payout_processed: {
      code: 'PAYOUT_PROCESSED',
      en: 'Your payout of {amount} ETB has been processed. Transaction: {reference}',
      am: 'የ{amount} ብር ክፍያዎ ተካሂዷል። ግብይት: {reference}',
      variables: ['amount', 'reference'],
      type: 'financial',
      priority: 'high',
    },
    organizer_approved: {
      code: 'ORGANIZER_APPROVED',
      en: 'Congratulations! Your organizer application has been approved. You can now create events.',
      am: 'እንኳን ደስ ያለዎት! የአዘጋጅነት ማመልከቻዎ ተጽዕኖ ተረጋግጧል። አሁን ዝግጅቶችን መፍጠር ይችላሉ።',
      variables: [],
      type: 'account',
      priority: 'high',
    },
  },
  
  // SMS Scheduling
  scheduling: {
    otpExpiryMinutes: 10,
    eventReminderHours: [24, 2], // 24 hours and 2 hours before
    businessHours: {
      start: 8, // 8 AM
      end: 20, // 8 PM
      timezone: 'Africa/Addis_Ababa',
    },
    noSmsAfter: 21, // No SMS after 9 PM
    noSmsBefore: 7, // No SMS before 7 AM
  },
  
  // SMS Cost & Billing
  pricing: {
    ethio_telecom: {
      local: 0.10, // 0.10 ETB per SMS
      international: 1.50,
      unicodeMultiplier: 3, // Unicode messages cost 3x
      deliveryReportCost: 0.02,
    },
    infobip: {
      local: 0.15,
      international: 1.00,
      unicodeMultiplier: 2,
    },
    twilio: {
      local: 0.20,
      international: 1.20,
      unicodeMultiplier: 2,
    },
  },
  
  // SMS Queue & Retry
  queue: {
    maxRetries: 3,
    retryDelay: 5000, // 5 seconds
    batchSize: 100,
    maxQueueSize: 10000,
    processingConcurrency: 5,
  },
  
  // Utility Functions
  getProviderByCode: function(code) {
    return this.providers.find(provider => provider.code === code && provider.isActive);
  },
  
  getDefaultProvider: function() {
    return this.providers.find(provider => provider.isDefault && provider.isActive);
  },
  
  getTemplateByCode: function(code, language = 'en') {
    const template = this.templates[code];
    if (!template) return null;
    
    return {
      ...template,
      message: template[language] || template.en,
    };
  },
  
  validatePhoneNumber: function(phone) {
    // Ethiopian phone number validation
    const regex = /^(?:\+251|0)(9\d{8})$/;
    const match = phone.match(regex);
    
    if (!match) return null;
    
    // Normalize to +251 format
    const normalized = '+251' + match[1];
    
    return {
      original: phone,
      normalized: normalized,
      isValid: true,
      countryCode: 'ET',
      carrier: this.detectCarrier(normalized),
    };
  },
  
  detectCarrier: function(phone) {
    const prefix = phone.substring(4, 6); // Get the prefix after +251
    
    // Ethio Telecom prefixes
    if (['91', '92', '93', '94', '95', '96'].includes(prefix)) {
      return 'ethio_telecom';
    }
    
    // Safaricom Ethiopia (M-Pesa)
    if (['97'].includes(prefix)) {
      return 'safaricom';
    }
    
    return 'unknown';
  },
  
  calculateMessageSegments: function(message, language = 'en') {
    const isUnicode = /[^\u0000-\u00FF]/.test(message); // Check for non-ASCII
    const maxLength = isUnicode ? 70 : 160;
    
    const segments = Math.ceil(message.length / maxLength);
    const characters = message.length;
    
    return {
      segments,
      characters,
      isUnicode,
      maxLength,
      costMultiplier: isUnicode ? (this.pricing[this.getDefaultProvider().code]?.unicodeMultiplier || 1) : 1,
    };
  },
  
  formatMessage: function(templateCode, variables, language = 'en') {
    const template = this.getTemplateByCode(templateCode, language);
    if (!template) return null;
    
    let message = template.message;
    
    // Replace variables
    template.variables.forEach(variable => {
      const value = variables[variable] || '';
      message = message.replace(new RegExp(`{${variable}}`, 'g'), value);
    });
    
    return {
      message,
      templateCode,
      language,
      variables,
      segments: this.calculateMessageSegments(message, language),
    };
  },
  
  canSendAtTime: function(timestamp) {
    const date = new Date(timestamp);
    const hour = date.getHours();
    const day = date.getDay(); // 0 = Sunday, 6 = Saturday
    
    // Check if within business hours
    if (hour < this.scheduling.noSmsBefore || hour > this.scheduling.noSmsAfter) {
      return false;
    }
    
    // Allow emergency messages anytime
    return true;
  },
  
  getSmsCost: function(providerCode, segments, isUnicode = false) {
    const provider = this.getProviderByCode(providerCode);
    if (!provider) return 0;
    
    const basePrice = this.pricing[providerCode]?.local || 0.10;
    const multiplier = isUnicode ? (this.pricing[providerCode]?.unicodeMultiplier || 1) : 1;
    
    return basePrice * multiplier * segments;
  },
};