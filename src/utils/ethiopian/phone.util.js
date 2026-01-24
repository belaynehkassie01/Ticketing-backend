// backend/src/utils/ethiopian/phone.util.js
export default {
  // Ethiopian telecom operators and their prefixes
  operators: {
    ethio_telecom: {
      name: 'Ethio Telecom',
      nameAm: 'ኢትዮ ቴሌኮም',
      prefixes: ['91', '92', '93', '94', '95', '96'],
      isMobile: true,
      supportsMobileMoney: true
    },
    safaricom: {
      name: 'Safaricom Ethiopia',
      nameAm: 'ሳፋሪኮም ኢትዮጵያ',
      prefixes: ['97'],
      isMobile: true,
      supportsMobileMoney: true
    }
  },
  
  // Landline area codes for major cities
  areaCodes: {
    'Addis Ababa': ['11'],
    'Bahir Dar': ['58'],
    'Mekelle': ['34'],
    'Adama': ['22'],
    'Hawassa': ['46'],
    'Jimma': ['47'],
    'Gondar': ['58'],
    'Dessie': ['33'],
    'Dire Dawa': ['25'],
    'Jijiga': ['25']
  },
  
  // Validate Ethiopian phone number
  validatePhone: function(phone) {
    if (!phone) return { valid: false, error: 'Phone number is required' };
    
    // Remove any whitespace, dashes, parentheses
    const cleaned = phone.toString().replace(/\s+/g, '').replace(/[\(\)\-]/g, '');
    
    // Check for international format (+251)
    if (cleaned.startsWith('+251')) {
      const number = cleaned.substring(4); // Remove +251
      return this.validateLocalNumber(number, '+251');
    }
    
    // Check for local format (09 or 9)
    if (cleaned.startsWith('09') || cleaned.startsWith('9')) {
      const number = cleaned.startsWith('09') ? cleaned.substring(2) : cleaned.substring(1);
      return this.validateLocalNumber(number, '0');
    }
    
    return { valid: false, error: 'Invalid phone number format' };
  },
  
  // Validate local number (without country code)
  validateLocalNumber: function(number, prefixType) {
    // Must be 9 digits
    if (!/^\d{9}$/.test(number)) {
      return { valid: false, error: 'Phone number must be 9 digits after country code' };
    }
    
    const operatorCode = number.substring(0, 2);
    const operator = this.getOperatorByPrefix(operatorCode);
    
    if (!operator) {
      return { valid: false, error: 'Invalid operator prefix' };
    }
    
    return {
      valid: true,
      normalized: prefixType === '+251' ? `+251${number}` : `0${number}`,
      international: `+251${number}`,
      local: `0${number}`,
      operator: operator.name,
      operatorCode,
      isMobile: operator.isMobile,
      supportsMobileMoney: operator.supportsMobileMoney
    };
  },
  
  // Get operator by prefix
  getOperatorByPrefix: function(prefix) {
    for (const [operatorName, operator] of Object.entries(this.operators)) {
      if (operator.prefixes.includes(prefix)) {
        return { ...operator, code: operatorName };
      }
    }
    return null;
  },
  
  // Normalize phone number to international format
  normalizeToInternational: function(phone) {
    const validation = this.validatePhone(phone);
    if (!validation.valid) return null;
    
    return validation.international;
  },
  
  // Normalize phone number to local format
  normalizeToLocal: function(phone) {
    const validation = this.validatePhone(phone);
    if (!validation.valid) return null;
    
    return validation.local;
  },
  
  // Format phone number for display
  formatForDisplay: function(phone, format = 'international') {
    const normalized = this.normalizeToInternational(phone);
    if (!normalized) return phone;
    
    const number = normalized.substring(4); // Remove +251
    
    switch (format) {
      case 'international':
        return `+251 ${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}`;
      case 'local':
        return `0${number.substring(0, 3)} ${number.substring(3, 6)} ${number.substring(6)}`;
      case 'compact':
        return `0${number}`;
      default:
        return normalized;
    }
  },
  
  // Mask phone number for privacy
  maskPhone: function(phone, visibleDigits = 3) {
    const normalized = this.normalizeToLocal(phone);
    if (!normalized) return '*** *** ***';
    
    const number = normalized.substring(1); // Remove leading 0
    const masked = number.substring(0, visibleDigits) + 
                   '*'.repeat(9 - visibleDigits * 2) + 
                   number.substring(9 - visibleDigits);
    
    return `0${masked.substring(0, 3)} ${masked.substring(3, 6)} ${masked.substring(6)}`;
  },
  
  // Generate random Ethiopian phone number (for testing)
  generateRandom: function(operator = 'ethio_telecom') {
    const op = this.operators[operator];
    if (!op) throw new Error('Invalid operator');
    
    const prefix = op.prefixes[Math.floor(Math.random() * op.prefixes.length)];
    const randomDigits = Math.floor(1000000 + Math.random() * 9000000).toString();
    
    return `0${prefix}${randomDigits}`;
  },
  
  // Extract area code from landline
  extractAreaCode: function(phone) {
    const normalized = this.normalizeToLocal(phone);
    if (!normalized) return null;
    
    const number = normalized.substring(1); // Remove leading 0
    
    // Check if it's a landline (starts with area code)
    for (const [city, codes] of Object.entries(this.areaCodes)) {
      for (const code of codes) {
        if (number.startsWith(code) && number.length === 7) {
          return {
            areaCode: code,
            city,
            isLandline: true,
            localNumber: number.substring(code.length)
          };
        }
      }
    }
    
    return null;
  },
  
  // Check if number supports mobile money
  supportsMobileMoney: function(phone) {
    const validation = this.validatePhone(phone);
    if (!validation.valid) return false;
    
    return validation.supportsMobileMoney || false;
  },
  
  // Validate batch of phone numbers
  validateBatch: function(phones) {
    const results = {
      valid: [],
      invalid: [],
      duplicates: new Set()
    };
    
    const seen = new Set();
    
    phones.forEach(phone => {
      const validation = this.validatePhone(phone);
      
      if (validation.valid) {
        const normalized = validation.international;
        
        if (seen.has(normalized)) {
          results.duplicates.add(normalized);
        } else {
          seen.add(normalized);
          results.valid.push({
            original: phone,
            ...validation
          });
        }
      } else {
        results.invalid.push({
          original: phone,
          error: validation.error
        });
      }
    });
    
    results.duplicates = Array.from(results.duplicates);
    
    return results;
  },
  
  // Format for SMS sending
  formatForSMS: function(phone) {
    const normalized = this.normalizeToInternational(phone);
    if (!normalized) return null;
    
    // Remove + for some SMS gateways
    return normalized.substring(1);
  },
  
  // Ethiopian phone number regex patterns
  patterns: {
    international: /^\+251[79]\d{8}$/,
    local: /^0[79]\d{8}$/,
    any: /^(\+251|0)[79]\d{8}$/
  },
  
  // Check if number matches a pattern
  matchesPattern: function(phone, pattern = 'any') {
    const regex = this.patterns[pattern];
    if (!regex) return false;
    
    return regex.test(phone.toString().replace(/\s+/g, ''));
  }
};