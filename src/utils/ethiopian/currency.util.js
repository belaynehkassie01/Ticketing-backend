// backend/src/utils/ethiopian/currency.util.js
export default {
  // Ethiopian currency information
  currency: {
    code: 'ETB',
    symbol: 'ብር',
    symbolEn: 'Br',
    name: 'Ethiopian Birr',
    nameAm: 'ኢትዮጵያዊ ብር',
    subunit: 'Santim',
    subunitAm: 'ሳንቲም',
    decimals: 2,
    format: {
      en: '{{amount}} ETB',
      am: '{{amount}} ብር'
    }
  },
  
  // Format currency amount
  format: function(amount, options = {}) {
    const {
      language = 'en',
      showSymbol = true,
      showCode = false,
      decimals = this.currency.decimals,
      locale = language === 'am' ? 'am-ET' : 'en-ET'
    } = options;
    
    // Handle null/undefined
    if (amount === null || amount === undefined) {
      return language === 'am' ? '-- ብር' : '-- ETB';
    }
    
    // Convert to number
    const numericAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
    
    if (isNaN(numericAmount)) {
      return language === 'am' ? 'ልክ ያልሆነ መጠን' : 'Invalid amount';
    }
    
    // Format the number
    const formatter = new Intl.NumberFormat(locale, {
      minimumFractionDigits: decimals,
      maximumFractionDigits: decimals,
      useGrouping: true
    });
    
    const formattedAmount = formatter.format(numericAmount);
    
    // Apply format template
    if (language === 'am') {
      return showSymbol ? `${formattedAmount} ብር` : formattedAmount;
    } else {
      if (showCode && showSymbol) {
        return `${formattedAmount} ETB (Br ${formattedAmount})`;
      } else if (showCode) {
        return `${formattedAmount} ETB`;
      } else if (showSymbol) {
        return `Br ${formattedAmount}`;
      } else {
        return formattedAmount;
      }
    }
  },
  
  // Format for display in UI
  formatForDisplay: function(amount, context = 'general') {
    const contexts = {
      ticket: { language: 'en', showSymbol: true, showCode: false },
      receipt: { language: 'en', showSymbol: true, showCode: true },
      sms: { language: 'am', showSymbol: true, showCode: false, decimals: 0 },
      email: { language: 'en', showSymbol: true, showCode: false },
      admin: { language: 'en', showSymbol: false, showCode: true }
    };
    
    const config = contexts[context] || contexts.general;
    return this.format(amount, config);
  },
  
  // Convert amount to words (for checks, receipts)
  toWords: function(amount, language = 'en') {
    const numericAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
    
    if (isNaN(numericAmount)) {
      return language === 'am' ? 'ልክ ያልሆነ መጠን' : 'Invalid amount';
    }
    
    // Round to 2 decimals
    const roundedAmount = Math.round(numericAmount * 100) / 100;
    const birr = Math.floor(roundedAmount);
    const santim = Math.round((roundedAmount - birr) * 100);
    
    if (language === 'am') {
      return this._toAmharicWords(birr, santim);
    } else {
      return this._toEnglishWords(birr, santim);
    }
  },
  
  // Private: Convert to English words
  _toEnglishWords: function(birr, santim) {
    const ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
    const teens = ['Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
    const tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
    const thousands = ['', 'Thousand', 'Million', 'Billion'];
    
    const convertLessThanThousand = (num) => {
      if (num === 0) return '';
      
      let result = '';
      
      if (num >= 100) {
        result += ones[Math.floor(num / 100)] + ' Hundred ';
        num %= 100;
      }
      
      if (num >= 20) {
        result += tens[Math.floor(num / 10)] + ' ';
        num %= 10;
      }
      
      if (num >= 10) {
        result += teens[num - 10] + ' ';
        num = 0;
      }
      
      if (num > 0) {
        result += ones[num] + ' ';
      }
      
      return result.trim();
    };
    
    if (birr === 0 && santim === 0) {
      return 'Zero Birr Only';
    }
    
    let result = '';
    let birrPart = birr;
    let thousandIndex = 0;
    
    while (birrPart > 0) {
      if (birrPart % 1000 !== 0) {
        result = convertLessThanThousand(birrPart % 1000) + ' ' + thousands[thousandIndex] + ' ' + result;
      }
      birrPart = Math.floor(birrPart / 1000);
      thousandIndex++;
    }
    
    result = result.trim();
    
    if (result) {
      result += ' Birr';
    }
    
    if (santim > 0) {
      if (result) result += ' and ';
      result += convertLessThanThousand(santim) + ' Santim';
    }
    
    return result + ' Only';
  },
  
  // Private: Convert to Amharic words
  _toAmharicWords: function(birr, santim) {
    const ones = ['', 'አንድ', 'ሁለት', 'ሶስት', 'አራት', 'አምስት', 'ስድስት', 'ሰባት', 'ስምንት', 'ዘጠኝ'];
    const tens = ['', 'አስር', 'ሃያ', 'ሰላሳ', 'አርባ', 'ሃምሳ', 'ስልሳ', 'ሰባ', 'ሰማንያ', 'ዘጠና'];
    const hundreds = 'መቶ';
    const thousands = 'ሺህ';
    const millions = 'ሚሊዮን';
    const billions = 'ቢሊዮን';
    
    const convertLessThanThousand = (num) => {
      if (num === 0) return '';
      
      let result = '';
      
      if (num >= 100) {
        const hundred = Math.floor(num / 100);
        result += (hundred === 1 ? '' : ones[hundred] + ' ') + hundreds + ' ';
        num %= 100;
      }
      
      if (num >= 10) {
        const ten = Math.floor(num / 10);
        result += tens[ten] + ' ';
        num %= 10;
      }
      
      if (num > 0) {
        result += ones[num] + ' ';
      }
      
      return result.trim();
    };
    
    if (birr === 0 && santim === 0) {
      return 'ዜሮ ብር ብቻ';
    }
    
    let result = '';
    let birrPart = birr;
    
    // Handle billions
    if (birrPart >= 1000000000) {
      const billion = Math.floor(birrPart / 1000000000);
      result += (billion === 1 ? '' : convertLessThanThousand(billion) + ' ') + billions + ' ';
      birrPart %= 1000000000;
    }
    
    // Handle millions
    if (birrPart >= 1000000) {
      const million = Math.floor(birrPart / 1000000);
      result += (million === 1 ? '' : convertLessThanThousand(million) + ' ') + millions + ' ';
      birrPart %= 1000000;
    }
    
    // Handle thousands
    if (birrPart >= 1000) {
      const thousand = Math.floor(birrPart / 1000);
      result += (thousand === 1 ? '' : convertLessThanThousand(thousand) + ' ') + thousands + ' ';
      birrPart %= 1000;
    }
    
    // Handle remaining birr
    if (birrPart > 0) {
      result += convertLessThanThousand(birrPart) + ' ';
    }
    
    if (result) {
      result += 'ብር';
    }
    
    // Handle santim
    if (santim > 0) {
      if (result) result += ' እና ';
      result += convertLessThanThousand(santim) + ' ሳንቲም';
    }
    
    return result.trim() + ' ብቻ';
  },
  
  // Validate currency amount
  validateAmount: function(amount, options = {}) {
    const {
      min = 0,
      max = 1000000, // 1 million ETB default max
      allowZero = false,
      allowNegative = false
    } = options;
    
    const numericAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
    
    if (isNaN(numericAmount)) {
      return { valid: false, error: 'Invalid amount format' };
    }
    
    if (!allowNegative && numericAmount < 0) {
      return { valid: false, error: 'Amount cannot be negative' };
    }
    
    if (!allowZero && numericAmount === 0) {
      return { valid: false, error: 'Amount cannot be zero' };
    }
    
    if (numericAmount < min) {
      return { valid: false, error: `Amount must be at least ${this.format(min)}` };
    }
    
    if (numericAmount > max) {
      return { valid: false, error: `Amount cannot exceed ${this.format(max)}` };
    }
    
    // Check decimal places
    const decimalPlaces = (numericAmount.toString().split('.')[1] || '').length;
    if (decimalPlaces > this.currency.decimals) {
      return { 
        valid: false, 
        error: `Amount can only have up to ${this.currency.decimals} decimal places` 
      };
    }
    
    return {
      valid: true,
      amount: numericAmount,
      formatted: this.format(numericAmount),
      inWords: this.toWords(numericAmount, 'en')
    };
  },
  
  // Calculate VAT (15% Ethiopian VAT)
  calculateVAT: function(amount, isInclusive = false) {
    const vatRate = 0.15; // 15%
    
    if (isInclusive) {
      // Amount includes VAT
      const vatAmount = amount * (vatRate / (1 + vatRate));
      const netAmount = amount - vatAmount;
      
      return {
        netAmount: this.round(netAmount),
        vatAmount: this.round(vatAmount),
        grossAmount: amount,
        vatRate,
        isInclusive
      };
    } else {
      // Amount excludes VAT
      const vatAmount = amount * vatRate;
      const grossAmount = amount + vatAmount;
      
      return {
        netAmount: amount,
        vatAmount: this.round(vatAmount),
        grossAmount: this.round(grossAmount),
        vatRate,
        isInclusive
      };
    }
  },
  
  // Calculate platform commission (10% default)
  calculateCommission: function(amount, commissionRate = 0.10, vatIncluded = true) {
    const commissionAmount = amount * commissionRate;
    const vatDetails = this.calculateVAT(commissionAmount, vatIncluded);
    
    return {
      ticketAmount: amount,
      commissionRate,
      commissionBeforeVAT: vatDetails.netAmount,
      commissionVAT: vatDetails.vatAmount,
      totalCommission: vatDetails.grossAmount,
      organizerAmount: amount - vatDetails.grossAmount,
      vatIncluded
    };
  },
  
  // Round to currency decimals
  round: function(amount, decimals = this.currency.decimals) {
    const factor = Math.pow(10, decimals);
    return Math.round(amount * factor) / factor;
  },
  
  // Convert between currencies (simplified)
  convert: function(amount, fromCurrency = 'ETB', toCurrency = 'USD') {
    // This would use actual exchange rates in production
    const rates = {
      'USD': 55, // 1 USD = 55 ETB (example)
      'EUR': 60, // 1 EUR = 60 ETB (example)
      'GBP': 70  // 1 GBP = 70 ETB (example)
    };
    
    if (fromCurrency === toCurrency) {
      return amount;
    }
    
    if (fromCurrency === 'ETB' && rates[toCurrency]) {
      return this.round(amount / rates[toCurrency], 2);
    }
    
    if (toCurrency === 'ETB' && rates[fromCurrency]) {
      return this.round(amount * rates[fromCurrency], 2);
    }
    
    // For other conversions, would need cross rates
    throw new Error(`Conversion from ${fromCurrency} to ${toCurrency} not supported`);
  },
  
  // Parse currency string input
  parse: function(input) {
    if (typeof input !== 'string') return input;
    
    // Remove currency symbols and thousands separators
    let cleaned = input
      .replace(/[ብርBrETB\s,]/g, '')
      .replace(/[\u1361\u1362]/g, '.'); // Ethiopian comma and period
    
    // Handle Ethiopian number format (1,234.56 vs 1.234,56)
    const hasEthiopianComma = cleaned.includes('.') && cleaned.includes(',');
    if (hasEthiopianComma) {
      // Ethiopian format: 1.234,56
      cleaned = cleaned.replace(/\./g, '').replace(',', '.');
    } else {
      // International format: 1,234.56
      cleaned = cleaned.replace(/,/g, '');
    }
    
    const amount = parseFloat(cleaned);
    return isNaN(amount) ? null : amount;
  },
  
  // Generate payment breakdown for receipts
  generatePaymentBreakdown: function(subtotal, commissionRate = 0.10, vatIncluded = true) {
    const vatDetails = this.calculateVAT(subtotal, vatIncluded);
    const commissionDetails = this.calculateCommission(subtotal, commissionRate, true);
    
    return {
      subtotal: this.format(subtotal),
      vat: {
        rate: '15%',
        amount: this.format(vatDetails.vatAmount),
        isIncluded: vatIncluded
      },
      commission: {
        rate: `${(commissionRate * 100)}%`,
        amount: this.format(commissionDetails.totalCommission),
        beforeVAT: this.format(commissionDetails.commissionBeforeVAT),
        vat: this.format(commissionDetails.commissionVAT)
      },
      organizerAmount: this.format(commissionDetails.organizerAmount),
      total: this.format(vatDetails.grossAmount),
      breakdown: [
        { item: 'Ticket Amount', amount: this.format(subtotal) },
        { item: 'VAT (15%)', amount: this.format(vatDetails.vatAmount) },
        { item: 'Platform Commission', amount: this.format(commissionDetails.totalCommission) },
        { item: 'Organizer Payout', amount: this.format(commissionDetails.organizerAmount) }
      ]
    };
  },
  
  // Format for SMS (short format)
  formatForSMS: function(amount) {
    const numericAmount = typeof amount === 'string' ? parseFloat(amount) : amount;
    
    if (isNaN(numericAmount)) {
      return '0 ETB';
    }
    
    if (numericAmount >= 1000) {
      const inThousands = numericAmount / 1000;
      return `${inThousands.toFixed(inThousands >= 10 ? 0 : 1)}K ETB`;
    }
    
    return `${Math.round(numericAmount)} ETB`;
  },
  
  // Validate Ethiopian bank account number format
  validateBankAccount: function(accountNumber, bankCode) {
    // Basic validation - would be bank-specific in production
    const banks = {
      'cbe': /^\d{10,16}$/, // Commercial Bank of Ethiopia
      'awash': /^\d{10,15}$/, // Awash Bank
      'dashen': /^\d{10,15}$/, // Dashen Bank
      'nib': /^\d{10,15}$/   // NIB International Bank
    };
    
    const regex = banks[bankCode] || /^\d{10,20}$/;
    
    if (!regex.test(accountNumber)) {
      return {
        valid: false,
        error: `Invalid ${bankCode.toUpperCase()} account number format`
      };
    }
    
    // Add Luhn check or other validation if available
    return {
      valid: true,
      formatted: this.maskBankAccount(accountNumber),
      bank: bankCode.toUpperCase()
    };
  },
  
  // Mask bank account for display
  maskBankAccount: function(accountNumber) {
    if (!accountNumber || accountNumber.length < 4) {
      return '****';
    }
    
    return `****${accountNumber.slice(-4)}`;
  },
  
  // Calculate installment payments
  calculateInstallments: function(totalAmount, numberOfInstallments, downPaymentPercent = 0) {
    if (numberOfInstallments < 1) {
      throw new Error('Number of installments must be at least 1');
    }
    
    const downPayment = totalAmount * (downPaymentPercent / 100);
    const remainingAmount = totalAmount - downPayment;
    const installmentAmount = this.round(remainingAmount / numberOfInstallments);
    
    // Adjust last installment for rounding differences
    const totalInstallments = installmentAmount * numberOfInstallments;
    const lastInstallment = installmentAmount + (remainingAmount - totalInstallments);
    
    const installments = [];
    for (let i = 0; i < numberOfInstallments; i++) {
      const amount = i === numberOfInstallments - 1 ? lastInstallment : installmentAmount;
      const dueDate = new Date();
      dueDate.setDate(dueDate.getDate() + (i + 1) * 30); // Monthly installments
      
      installments.push({
        number: i + 1,
        amount: this.round(amount),
        dueDate: dueDate.toISOString().split('T')[0],
        status: 'pending'
      });
    }
    
    return {
      totalAmount: this.round(totalAmount),
      downPayment: this.round(downPayment),
      downPaymentPercent,
      numberOfInstallments,
      installmentAmount: this.round(installmentAmount),
      installments,
      summary: {
        total: this.format(totalAmount),
        downPayment: this.format(downPayment),
        perInstallment: this.format(installmentAmount)
      }
    };
  }
};