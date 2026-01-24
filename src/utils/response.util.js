// backend/src/utils/response.util.js
export default {
  // Success responses
  success: (data = null, message = 'Success', meta = {}) => ({
    success: true,
    message,
    messageAm: this.translateToAmharic(message),
    data,
    meta: {
      timestamp: new Date().toISOString(),
      timezone: 'Africa/Addis_Ababa',
      ...meta
    }
  }),
  
  // Paginated response
  paginated: (data, pagination, message = 'Data retrieved successfully') => ({
    success: true,
    message,
    messageAm: this.translateToAmharic(message),
    data,
    pagination: {
      total: pagination.total,
      page: pagination.page,
      limit: pagination.limit,
      pages: Math.ceil(pagination.total / pagination.limit),
      hasNext: pagination.page < Math.ceil(pagination.total / pagination.limit),
      hasPrev: pagination.page > 1,
      ...pagination
    },
    meta: {
      timestamp: new Date().toISOString(),
      timezone: 'Africa/Addis_Ababa'
    }
  }),
  
  // Error responses
  error: (message = 'An error occurred', code = 'INTERNAL_ERROR', details = null) => ({
    success: false,
    error: {
      code,
      message,
      messageAm: this.translateToAmharic(message),
      details,
      timestamp: new Date().toISOString()
    }
  }),
  
  // Validation error
  validationError: (errors, message = 'Validation failed') => ({
    success: false,
    error: {
      code: 'VALIDATION_ERROR',
      message,
      messageAm: 'ማረጋገጫ አልተሳካም',
      errors,
      timestamp: new Date().toISOString()
    }
  }),
  
  // Authentication error
  authError: (message = 'Authentication required') => ({
    success: false,
    error: {
      code: 'AUTH_ERROR',
      message,
      messageAm: 'ማረጋገጫ ያስፈልጋል',
      timestamp: new Date().toISOString()
    }
  }),
  
  // Permission error
  permissionError: (message = 'Permission denied') => ({
    success: false,
    error: {
      code: 'PERMISSION_DENIED',
      message,
      messageAm: 'ፈቃድ አልተሰጠም',
      timestamp: new Date().toISOString()
    }
  }),
  
  // Not found error
  notFound: (resource = 'Resource') => ({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: `${resource} not found`,
      messageAm: `${resource} አልተገኘም`,
      timestamp: new Date().toISOString()
    }
  }),
  
  // Conflict error (duplicate, already exists)
  conflict: (message = 'Resource already exists') => ({
    success: false,
    error: {
      code: 'CONFLICT',
      message,
      messageAm: 'መረጃው አስቀድሞ አለ',
      timestamp: new Date().toISOString()
    }
  }),
  
  // Rate limit error
  rateLimit: (message = 'Too many requests') => ({
    success: false,
    error: {
      code: 'RATE_LIMIT_EXCEEDED',
      message,
      messageAm: 'በጣም ብዙ ጥያቄዎች',
      retryAfter: 900, // 15 minutes in seconds
      timestamp: new Date().toISOString()
    }
  }),
  
  // Payment error
  paymentError: (message = 'Payment failed', gateway = null) => ({
    success: false,
    error: {
      code: 'PAYMENT_FAILED',
      message,
      messageAm: 'ክፍያ አልተሳካም',
      gateway,
      timestamp: new Date().toISOString()
    }
  }),
  
  // OTP error
  otpError: (message = 'OTP verification failed') => ({
    success: false,
    error: {
      code: 'OTP_ERROR',
      message,
      messageAm: 'የማረጋገጫ ኮድ አልተሳካም',
      timestamp: new Date().toISOString()
    }
  }),
  
  // Ethiopian-specific errors
  ethiopian: {
    invalidPhone: () => ({
      success: false,
      error: {
        code: 'INVALID_ETHIOPIAN_PHONE',
        message: 'Invalid Ethiopian phone number',
        messageAm: 'ልክ ያልሆነ የኢትዮጵያ ስልክ ቁጥር',
        timestamp: new Date().toISOString()
      }
    }),
    
    invalidBankAccount: (bank) => ({
      success: false,
      error: {
        code: 'INVALID_BANK_ACCOUNT',
        message: `Invalid ${bank} account number`,
        messageAm: `ልክ ያልሆነ ${bank} አካውንት ቁጥር`,
        bank,
        timestamp: new Date().toISOString()
      }
    }),
    
    holidayConflict: (holiday) => ({
      success: false,
      error: {
        code: 'HOLIDAY_CONFLICT',
        message: `Event conflicts with Ethiopian holiday: ${holiday}`,
        messageAm: `ዝግጅቱ ከኢትዮጵያ በዓል ጋር ይጋጫል: ${holiday}`,
        holiday,
        timestamp: new Date().toISOString()
      }
    })
  },
  
  // Helper function to translate common messages to Amharic
  translateToAmharic: (message) => {
    const translations = {
      'Success': 'ተሳክቷል',
      'Data retrieved successfully': 'መረጃ በተሳካ ሁኔታ ተገኝቷል',
      'An error occurred': 'ስህተት ተከስቷል',
      'Validation failed': 'ማረጋገጫ አልተሳካም',
      'Authentication required': 'ማረጋገጫ ያስፈልጋል',
      'Permission denied': 'ፈቃድ አልተሰጠም',
      'Resource not found': 'መረጃ አልተገኘም',
      'Resource already exists': 'መረጃው አስቀድሞ አለ',
      'Too many requests': 'በጣም ብዙ ጥያቄዎች',
      'Payment failed': 'ክፍያ አልተሳካም',
      'OTP verification failed': 'የማረጋገጫ ኮድ አልተሳካም',
      'Invalid Ethiopian phone number': 'ልክ ያልሆነ የኢትዮጵያ ስልክ ቁጥር',
      'Event created successfully': 'ዝግጅቱ በተሳካ ሁኔታ ተፈጥሯል',
      'Ticket purchased successfully': 'ትኬቱ በተሳካ ሁኔታ ተገዝቷል',
      'Organizer application submitted': 'የአዘጋጅነት ማመልከቻ ቀርቧል',
      'Payment verification required': 'የክፍያ ማረጋገጫ ያስፈልጋል',
      'Ticket checked in successfully': 'ትኬቱ በተሳካ ሁኔታ ተመዝግቧል'
    };
    
    return translations[message] || message;
  },
  
  // Format currency for Ethiopian context
  formatCurrency: (amount, currency = 'ETB', language = 'en') => {
    const formatter = new Intl.NumberFormat(language === 'am' ? 'am-ET' : 'en-ET', {
      style: 'currency',
      currency: currency,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    });
    
    return formatter.format(amount);
  },
  
  // Format date for Ethiopian context
  formatDate: (date, format = 'medium', language = 'en') => {
    const dateObj = new Date(date);
    
    if (language === 'am') {
      // Ethiopian date formatting would go here
      // This is a placeholder - you'd implement actual Ethiopian calendar conversion
      return dateObj.toLocaleDateString('am-ET');
    }
    
    const options = {
      short: { year: 'numeric', month: 'numeric', day: 'numeric' },
      medium: { year: 'numeric', month: 'short', day: 'numeric' },
      long: { year: 'numeric', month: 'long', day: 'numeric' },
      full: { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
    };
    
    return dateObj.toLocaleDateString('en-ET', options[format] || options.medium);
  },
  
  // Create response metadata
  createMeta: (additionalMeta = {}) => ({
    timestamp: new Date().toISOString(),
    timezone: 'Africa/Addis_Ababa',
    apiVersion: '1.0.0',
    ...additionalMeta
  }),
  
  // Format validation errors from express-validator
  formatValidationErrors: (errors) => {
    return errors.array().map(err => ({
      field: err.path,
      message: err.msg,
      messageAm: this.translateToAmharic(err.msg),
      value: err.value
    }));
  },
  
  // Success responses for common operations
  created: (data, message = 'Resource created successfully') => 
    this.success(data, message, { statusCode: 201 }),
  
  updated: (data, message = 'Resource updated successfully') => 
    this.success(data, message, { statusCode: 200 }),
  
  deleted: (message = 'Resource deleted successfully') => 
    this.success(null, message, { statusCode: 200 }),
  
  // Response for file uploads
  fileUploaded: (fileInfo, message = 'File uploaded successfully') => ({
    success: true,
    message,
    messageAm: this.translateToAmharic(message),
    data: {
      filename: fileInfo.filename,
      url: fileInfo.url,
      size: fileInfo.size,
      mimetype: fileInfo.mimetype
    },
    meta: this.createMeta()
  }),
  
  // Response for SMS/email notifications
  notificationSent: (type, recipient, message = 'Notification sent successfully') => ({
    success: true,
    message,
    messageAm: this.translateToAmharic(message),
    data: {
      type,
      recipient,
      sentAt: new Date().toISOString()
    },
    meta: this.createMeta()
  })
};