// backend/src/config/integrations/cbe.config.js
export default {
  // Environment settings
  environment: process.env.CBE_ENV || 'development', // development, production
  
  // Bank Account Information
  accounts: {
    development: {
      accountNumber: process.env.CBE_DEV_ACCOUNT || '1000123456789',
      accountName: process.env.CBE_DEV_ACCOUNT_NAME || 'Ethio Tickets Dev',
      bankName: 'Commercial Bank of Ethiopia',
      branch: 'Head Office',
      branchCode: '001',
      swiftCode: 'CBETETAA',
      currency: 'ETB',
    },
    production: {
      accountNumber: process.env.CBE_PROD_ACCOUNT,
      accountName: process.env.CBE_PROD_ACCOUNT_NAME || 'Ethio Tickets PLC',
      bankName: 'Commercial Bank of Ethiopia',
      branch: 'Head Office',
      branchCode: '001',
      swiftCode: 'CBETETAA',
      currency: 'ETB',
    },
  },
  
  // API Integration (if available)
  api: {
    development: {
      baseUrl: 'https://cbe-testapi.example.com',
      apiKey: process.env.CBE_TEST_API_KEY || 'test_key',
      apiSecret: process.env.CBE_TEST_API_SECRET || 'test_secret',
      verifyEndpoint: '/api/v1/verify',
      statementEndpoint: '/api/v1/statement',
      webhookEndpoint: '/api/v1/webhook',
    },
    production: {
      baseUrl: 'https://api.cbe.com.et',
      apiKey: process.env.CBE_API_KEY,
      apiSecret: process.env.CBE_API_SECRET,
      verifyEndpoint: '/api/v1/verify',
      statementEndpoint: '/api/v1/statement',
      webhookEndpoint: '/api/v1/webhook',
    },
  },
  
  // Manual Verification Settings
  verification: {
    referencePrefix: 'ETKT',
    referenceLength: 12,
    expiryHours: 24, // References valid for 24 hours
    minimumAmount: 10, // 10 ETB minimum
    maximumAmount: 100000, // 100,000 ETB maximum
    allowedBranches: [
      'Head Office',
      'Bole Branch',
      'Mexico Square',
      'Megenagna',
      'Piassa',
      'Merkato',
    ],
  },
  
  // Statement Processing
  statement: {
    allowedFormats: ['pdf', 'jpg', 'png', 'jpeg'],
    maxFileSize: 5 * 1024 * 1024, // 5MB
    ocrEnabled: true, // Optical Character Recognition for statement parsing
    ocrConfidenceThreshold: 0.8, // 80% confidence required
    autoVerificationThreshold: 5000, // Auto-verify payments below 5,000 ETB
  },
  
  // Reference Number Generation
  referenceFormat: {
    pattern: '{prefix}-{date}-{sequence}',
    dateFormat: 'YYYYMMDD',
    sequenceLength: 6,
    checksum: true,
  },
  
  // Payment Information Display
  paymentInstructions: {
    en: [
      'Transfer to: Commercial Bank of Ethiopia',
      'Account Number: {accountNumber}',
      'Account Name: {accountName}',
      'Reference Number: {referenceNumber}',
      'Amount: {amount} ETB',
      'Branch: {branch}',
      'Note: Include reference number in transaction description',
    ],
    am: [
      'ወደ: ንግድ ባንክ ኢትዮጵያ ያስተላልፉ',
      'አካውንት ቁጥር: {accountNumber}',
      'የአካውንት ስም: {accountName}',
      'ማጣቀሻ ቁጥር: {referenceNumber}',
      'መጠን: {amount} ብር',
      'ቅርንጫፍ: {branch}',
      'ማስታወሻ: በግብይት መግለጫ ውስጥ ማጣቀሻ ቁጥሩን ያካትቱ',
    ],
  },
  
  // Receipt Requirements
  receipt: {
    requiredFields: [
      'transactionId',
      'amount',
      'date',
      'senderName',
      'senderAccount',
      'referenceNumber',
    ],
    validationRules: {
      amountTolerance: 0.01, // 1% tolerance for amount matching
      dateToleranceDays: 1, // Allow 1 day difference
      minimumImageQuality: 0.7, // Minimum OCR confidence
    },
  },
  
  // Processing Time
  processing: {
    verificationTime: '1-2 hours', // Manual verification takes 1-2 hours
    businessHours: {
      start: 8, // 8 AM
      end: 17, // 5 PM
      timezone: 'Africa/Addis_Ababa',
      days: [1, 2, 3, 4, 5], // Monday to Friday
    },
    batchProcessing: {
      enabled: true,
      interval: 30, // Process every 30 minutes
      batchSize: 50,
    },
  },
  
  // Fee Structure
  fees: {
    transferFee: 0, // CBE internal transfers usually free
    minimumFee: 0,
    maximumFee: 0,
    ourFees: {
      processingFee: 0, // We don't charge extra for CBE
      vatOnFees: 0,
    },
  },
  
  // Utility Functions
  getConfig: function() {
    const env = this.environment;
    return {
      account: this.accounts[env],
      api: this.api[env],
      environment: env,
    };
  },
  
  getAccountInfo: function() {
    return this.accounts[this.environment];
  },
  
  generateReferenceNumber: function(paymentId) {
    const prefix = this.verification.referencePrefix;
    const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const sequence = String(paymentId).padStart(
      this.referenceFormat.sequenceLength, 
      '0'
    ).slice(-this.referenceFormat.sequenceLength);
    
    return `${prefix}-${date}-${sequence}`;
  },
  
  parseReferenceNumber: function(reference) {
    const pattern = /^([A-Z]+)-(\d{8})-(\d+)$/;
    const match = reference.match(pattern);
    
    if (!match) return null;
    
    return {
      prefix: match[1],
      date: match[2],
      sequence: match[3],
      valid: this.validateReference(reference),
    };
  },
  
  validateReference: function(reference) {
    const parsed = this.parseReferenceNumber(reference);
    if (!parsed) return false;
    
    // Check if reference is expired
    const refDate = new Date(
      parseInt(parsed.date.slice(0, 4)),
      parseInt(parsed.date.slice(4, 6)) - 1,
      parseInt(parsed.date.slice(6, 8))
    );
    
    const now = new Date();
    const hoursDiff = Math.abs(now - refDate) / 36e5; // hours
    
    return hoursDiff <= this.verification.expiryHours;
  },
  
  formatPaymentInstructions: function(paymentDetails, language = 'en') {
    const account = this.getAccountInfo();
    const instructions = this.paymentInstructions[language] || this.paymentInstructions.en;
    
    return instructions.map(line => {
      return line
        .replace('{accountNumber}', account.accountNumber)
        .replace('{accountName}', account.accountName)
        .replace('{referenceNumber}', paymentDetails.referenceNumber)
        .replace('{amount}', paymentDetails.amount)
        .replace('{branch}', account.branch);
    }).join('\n');
  },
  
  validatePaymentAmount: function(amount) {
    if (amount < this.verification.minimumAmount) {
      return {
        valid: false,
        error: `Amount must be at least ${this.verification.minimumAmount} ETB`,
      };
    }
    
    if (amount > this.verification.maximumAmount) {
      return {
        valid: false,
        error: `Amount cannot exceed ${this.verification.maximumAmount} ETB`,
      };
    }
    
    return { valid: true, error: null };
  },
  
  isWithinBusinessHours: function(timestamp) {
    const date = new Date(timestamp);
    const hour = date.getHours();
    const day = date.getDay(); // 0 = Sunday, 6 = Saturday
    
    const businessHours = this.processing.businessHours;
    
    // Check if weekend
    if (!businessHours.days.includes(day)) {
      return false;
    }
    
    // Check if within business hours
    return hour >= businessHours.start && hour < businessHours.end;
  },
  
  getNextProcessingTime: function() {
    const now = new Date();
    const businessHours = this.processing.businessHours;
    
    // If within business hours, process immediately
    if (this.isWithinBusinessHours(now)) {
      return now;
    }
    
    // Otherwise, schedule for next business day
    const nextDay = new Date(now);
    let dayAdded = 0;
    
    do {
      nextDay.setDate(nextDay.getDate() + 1);
      dayAdded++;
    } while (!businessHours.days.includes(nextDay.getDay()));
    
    // Set to start of business hours
    nextDay.setHours(businessHours.start, 0, 0, 0);
    
    return nextDay;
  },
  
  validateReceipt: function(receiptData) {
    const missingFields = [];
    const errors = [];
    
    // Check required fields
    this.receipt.requiredFields.forEach(field => {
      if (!receiptData[field]) {
        missingFields.push(field);
      }
    });
    
    if (missingFields.length > 0) {
      errors.push(`Missing required fields: ${missingFields.join(', ')}`);
    }
    
    // Validate amount tolerance
    if (receiptData.expectedAmount && receiptData.receivedAmount) {
      const tolerance = Math.abs(
        (receiptData.receivedAmount - receiptData.expectedAmount) / receiptData.expectedAmount
      );
      
      if (tolerance > this.receipt.validationRules.amountTolerance) {
        errors.push(`Amount mismatch: Expected ${receiptData.expectedAmount}, got ${receiptData.receivedAmount}`);
      }
    }
    
    // Validate date
    if (receiptData.transactionDate) {
      const transactionDate = new Date(receiptData.transactionDate);
      const now = new Date();
      const daysDiff = Math.abs(now - transactionDate) / (1000 * 60 * 60 * 24);
      
      if (daysDiff > this.receipt.validationRules.dateToleranceDays) {
        errors.push(`Transaction date is too old: ${receiptData.transactionDate}`);
      }
    }
    
    return {
      valid: errors.length === 0,
      errors,
      missingFields,
    };
  },
  
  // Statement parsing utilities
  extractTransactionFromStatement: function(statementText) {
    // This is a simplified version - actual implementation would use OCR
    const patterns = [
      // Pattern for transaction lines
      /(\d{2}\/\d{2}\/\d{4})\s+([A-Z0-9]+)\s+([\d,]+\.\d{2})\s+(.+?)(?=\s+\d{2}\/\d{2}\/\d{4}|$)/g,
      // Pattern with reference numbers
      /REF:\s*([A-Z]+-\d{8}-\d+)/gi,
    ];
    
    const transactions = [];
    
    patterns.forEach(pattern => {
      let match;
      while ((match = pattern.exec(statementText)) !== null) {
        if (pattern.source.includes('REF:')) {
          transactions.push({
            type: 'reference',
            value: match[1],
          });
        } else {
          transactions.push({
            date: match[1],
            transactionId: match[2],
            amount: parseFloat(match[3].replace(/,/g, '')),
            description: match[4].trim(),
          });
        }
      }
    });
    
    return transactions;
  },
  
  matchPaymentWithStatement: function(payment, statementTransactions) {
    const reference = payment.referenceNumber;
    const expectedAmount = payment.amount;
    
    // First, try to match by reference number
    const refMatch = statementTransactions.find(t => 
      t.type === 'reference' && t.value === reference
    );
    
    if (refMatch) {
      // Find the transaction associated with this reference
      const transactionIndex = statementTransactions.findIndex(t => t === refMatch);
      if (transactionIndex > 0) {
        const transaction = statementTransactions[transactionIndex - 1];
        if (Math.abs(transaction.amount - expectedAmount) <= (expectedAmount * 0.01)) {
          return {
            matched: true,
            transaction,
            matchType: 'reference',
            confidence: 0.95,
          };
        }
      }
    }
    
    // Try to match by amount and date
    const amountMatches = statementTransactions.filter(t => 
      !t.type && 
      Math.abs(t.amount - expectedAmount) <= (expectedAmount * 0.01)
    );
    
    if (amountMatches.length === 1) {
      return {
        matched: true,
        transaction: amountMatches[0],
        matchType: 'amount',
        confidence: 0.80,
      };
    }
    
    return {
      matched: false,
      matches: amountMatches.length,
      confidence: 0,
    };
  },
};