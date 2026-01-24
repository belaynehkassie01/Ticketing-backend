// backend/src/config/ethiopian/banks.config.js
export default {
  // Ethiopian banks
  banks: [
    {
      code: 'cbe',
      name: 'Commercial Bank of Ethiopia',
      nameAm: 'ንግድ ባንክ ኢትዮጵያ',
      swiftCode: 'CBETETAA',
      isActive: true,
      supportsTransfer: true,
      supportsQR: false,
      website: 'https://www.combanketh.et',
      hotline: '+251115170000',
      logo: '/banks/cbe.png',
      accountNumberRegex: /^\d{10,16}$/, // 10-16 digit account numbers
      branches: [
        {
          code: 'CBE-AA-001',
          name: 'Head Office',
          city: 'Addis Ababa',
          address: 'Mexico Square, Addis Ababa',
          phone: '+251115170000',
        },
        // Add more branches as needed
      ],
    },
    {
      code: 'awash',
      name: 'Awash Bank',
      nameAm: 'አዋሽ ባንክ',
      swiftCode: 'AWINETAA',
      isActive: true,
      supportsTransfer: true,
      supportsQR: false,
      website: 'https://www.awashbank.com',
      hotline: '+251116670000',
      logo: '/banks/awash.png',
      accountNumberRegex: /^\d{10,15}$/,
    },
    {
      code: 'dashen',
      name: 'Dashen Bank',
      nameAm: 'ዳሽን ባንክ',
      swiftCode: 'DASHETAA',
      isActive: true,
      supportsTransfer: true,
      supportsQR: false,
      website: 'https://www.dashenbanksc.com',
      hotline: '+251115180000',
      logo: '/banks/dashen.png',
      accountNumberRegex: /^\d{10,15}$/,
    },
    {
      code: 'abyssinia',
      name: 'Abyssinia Bank',
      nameAm: 'አቢሲኒያ ባንክ',
      swiftCode: 'ABYSETAA',
      isActive: true,
      supportsTransfer: true,
      supportsQR: false,
      website: 'https://www.abyssiniabank.com',
      hotline: '+251116890000',
      logo: '/banks/abyssinia.png',
      accountNumberRegex: /^\d{10,15}$/,
    },
    {
      code: 'nib',
      name: 'NIB International Bank',
      nameAm: 'ኒብ ኢንተርናሽናል ባንክ',
      swiftCode: 'NIBIETAA',
      isActive: true,
      supportsTransfer: true,
      supportsQR: false,
      website: 'https://www.nibbank.com.et',
      hotline: '+251115503000',
      logo: '/banks/nib.png',
      accountNumberRegex: /^\d{10,15}$/,
    },
  ],
  
  // Payment methods supported
  paymentMethods: [
    {
      code: 'telebirr',
      name: 'Telebirr',
      nameAm: 'ቴሊብር',
      type: 'mobile_money',
      isActive: true,
      isDefault: true,
      icon: '/payments/telebirr.png',
      instructions: 'Scan QR code with Telebirr app',
      instructionsAm: 'ቴሊብር አፕ በመጠቀም QR ኮድ ይቃኙ',
      minAmount: 1,
      maxAmount: 50000,
      processingTime: 'instant',
      fee: {
        type: 'percentage',
        value: 0.5, // 0.5%
        minFee: 1,
        maxFee: 25,
      },
    },
    {
      code: 'cbe_transfer',
      name: 'CBE Bank Transfer',
      nameAm: 'CBE ባንክ ማስተላለፍ',
      type: 'bank_transfer',
      isActive: true,
      isDefault: false,
      icon: '/payments/cbe.png',
      instructions: 'Transfer to CBE account shown below',
      instructionsAm: 'ከታች የተመለከተውን CBE አካውንት ይለውጡ',
      minAmount: 10,
      maxAmount: 100000,
      processingTime: '1-2 hours',
      fee: {
        type: 'percentage',
        value: 0, // No fee for CBE transfers
        minFee: 0,
        maxFee: 0,
      },
    },
    {
      code: 'cbe_birr',
      name: 'CBE Birr',
      nameAm: 'CBE ብር',
      type: 'mobile_money',
      isActive: true,
      isDefault: false,
      icon: '/payments/cbe-birr.png',
      instructions: 'Use CBE Birr app for payment',
      instructionsAm: 'CBE ብር አፕ በመጠቀም ይክፈሉ',
      minAmount: 1,
      maxAmount: 50000,
      processingTime: 'instant',
      fee: {
        type: 'percentage',
        value: 0.5,
        minFee: 1,
        maxFee: 25,
      },
    },
  ],
  
  // Utility functions
  getBankByCode: function(code) {
    return this.banks.find(bank => bank.code === code && bank.isActive);
  },
  
  getActiveBanks: function() {
    return this.banks.filter(bank => bank.isActive);
  },
  
  getPaymentMethodByCode: function(code) {
    return this.paymentMethods.find(method => method.code === code && method.isActive);
  },
  
  getActivePaymentMethods: function() {
    return this.paymentMethods.filter(method => method.isActive);
  },
  
  validateAccountNumber: function(bankCode, accountNumber) {
    const bank = this.getBankByCode(bankCode);
    if (!bank) return false;
    
    if (bank.accountNumberRegex) {
      return bank.accountNumberRegex.test(accountNumber);
    }
    
    // Default validation for banks without regex
    return /^\d{10,20}$/.test(accountNumber);
  },
  
  getBankOptions: function() {
    return this.getActiveBanks().map(bank => ({
      value: bank.code,
      label: bank.name,
      labelAm: bank.nameAm,
      icon: bank.logo,
    }));
  },
  
  getPaymentMethodOptions: function() {
    return this.getActivePaymentMethods().map(method => ({
      value: method.code,
      label: method.name,
      labelAm: method.nameAm,
      icon: method.icon,
      type: method.type,
    }));
  },
};