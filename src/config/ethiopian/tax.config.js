// backend/src/config/ethiopian/tax.config.js
export default {
  // Ethiopian VAT (Value Added Tax)
  vat: {
    rate: 0.15, // 15% standard VAT rate
    effectiveDate: new Date('2022-01-01'),
    appliesTo: [
      'ticket_sales',
      'event_fees',
      'service_fees',
    ],
    exemptCategories: [
      'charity_events',
      'educational_events',
      'religious_events',
    ],
    registrationThreshold: 500000, // 500,000 ETB annual turnover
    filingFrequency: 'monthly', // monthly VAT filing
    dueDate: 15, // 15th of following month
  },
  
  // Withholding Tax (WHT)
  withholdingTax: {
    rates: {
      goods: 0.02, // 2% for goods
      services: 0.02, // 2% for services
      rent: 0.02, // 2% for rent
      interest: 0.05, // 5% for interest
      dividends: 0.10, // 10% for dividends
    },
    threshold: 1000, // 1,000 ETB threshold
    appliesToOrganizers: true,
    monthlyFiling: true,
  },
  
  // Income Tax (for organizers/companies)
  incomeTax: {
    individualRates: [
      { from: 0, to: 600, rate: 0.00 }, // 0%
      { from: 601, to: 1650, rate: 0.10 }, // 10%
      { from: 1651, to: 3200, rate: 0.15 }, // 15%
      { from: 3201, to: 5250, rate: 0.20 }, // 20%
      { from: 5251, to: 7800, rate: 0.25 }, // 25%
      { from: 7801, to: 10900, rate: 0.30 }, // 30%
      { above: 10900, rate: 0.35 }, // 35%
    ],
    
    businessRates: {
      micro: 0.00, // 0% for micro enterprises
      small: 0.00, // 0% for small enterprises
      medium: 0.30, // 30% for medium enterprises
      large: 0.30, // 30% for large enterprises
    },
    
    businessCategories: {
      micro: { annualTurnover: 0, employees: 5 },
      small: { annualTurnover: 500000, employees: 10 },
      medium: { annualTurnover: 5000000, employees: 30 },
      large: { annualTurnover: 50000000, employees: 30 },
    },
  },
  
  // Turnover Tax (for small businesses)
  turnoverTax: {
    rate: 0.02, // 2%
    threshold: 500000, // 500,000 ETB annual turnover
    appliesTo: ['micro', 'small'],
    filingFrequency: 'monthly',
  },
  
  // Platform-specific tax settings
  platform: {
    // Commission is subject to VAT
    commissionVatIncluded: true,
    
    // Platform fee structure
    fees: {
      ticketSales: {
        commissionRate: 0.10, // 10% commission
        vatIncluded: true,
        minimumFee: 5, // 5 ETB minimum
      },
      payoutProcessing: {
        fee: 0, // No fee for payouts
        vatIncluded: false,
      },
      paymentProcessing: {
        telebirr: 0.005, // 0.5%
        cbe: 0,
        cash: 0,
      },
    },
    
    // Tax reporting
    reporting: {
      generateMonthlyReports: true,
      annualTaxCertificate: true,
      taxClearanceRequired: false,
      taxAuthority: 'Ethiopian Revenue and Customs Authority (ERCA)',
      authorityWebsite: 'https://www.erca.gov.et',
      contactEmail: 'info@erca.gov.et',
      contactPhone: '+251115504040',
    },
  },
  
  // Tax calculation utilities
  calculateVAT: function(amount, isInclusive = true) {
    if (isInclusive) {
      // Amount includes VAT
      const vatAmount = amount * (this.vat.rate / (1 + this.vat.rate));
      const netAmount = amount - vatAmount;
      return {
        netAmount: Math.round(netAmount * 100) / 100,
        vatAmount: Math.round(vatAmount * 100) / 100,
        grossAmount: amount,
      };
    } else {
      // Amount excludes VAT
      const vatAmount = amount * this.vat.rate;
      const grossAmount = amount + vatAmount;
      return {
        netAmount: amount,
        vatAmount: Math.round(vatAmount * 100) / 100,
        grossAmount: Math.round(grossAmount * 100) / 100,
      };
    }
  },
  
  calculateWithholdingTax: function(amount, type = 'services') {
    const rate = this.withholdingTax.rates[type] || 0.02;
    if (amount < this.withholdingTax.threshold) {
      return { taxAmount: 0, netAmount: amount };
    }
    const taxAmount = amount * rate;
    return {
      taxAmount: Math.round(taxAmount * 100) / 100,
      netAmount: Math.round((amount - taxAmount) * 100) / 100,
      rate: rate,
    };
  },
  
  calculatePlatformCommission: function(ticketAmount, quantity = 1) {
    const totalAmount = ticketAmount * quantity;
    const commissionRate = this.platform.fees.ticketSales.commissionRate;
    const minimumFee = this.platform.fees.ticketSales.minimumFee;
    
    let commission = totalAmount * commissionRate;
    if (commission < minimumFee) {
      commission = minimumFee;
    }
    
    const vatDetails = this.calculateVAT(commission, this.platform.fees.ticketSales.vatIncluded);
    
    return {
      ticketAmount: totalAmount,
      commissionRate: commissionRate,
      commissionBeforeVat: vatDetails.netAmount,
      commissionVat: vatDetails.vatAmount,
      totalCommission: vatDetails.grossAmount,
      organizerAmount: totalAmount - vatDetails.grossAmount,
    };
  },
  
  // Tax exemption check
  isEventTaxExempt: function(eventCategory, isCharity = false) {
    if (isCharity) return true;
    return this.vat.exemptCategories.includes(eventCategory);
  },
  
  // Business category determination
  getBusinessCategory: function(annualTurnover, employeeCount) {
    if (annualTurnover <= this.incomeTax.businessCategories.micro.annualTurnover && 
        employeeCount <= this.incomeTax.businessCategories.micro.employees) {
      return 'micro';
    } else if (annualTurnover <= this.incomeTax.businessCategories.small.annualTurnover && 
               employeeCount <= this.incomeTax.businessCategories.small.employees) {
      return 'small';
    } else if (annualTurnover <= this.incomeTax.businessCategories.medium.annualTurnover && 
               employeeCount <= this.incomeTax.businessCategories.medium.employees) {
      return 'medium';
    } else {
      return 'large';
    }
  },
  
  // Format tax amounts for display
  formatTaxAmount: function(amount, currency = 'ETB') {
    return new Intl.NumberFormat('en-ET', {
      style: 'currency',
      currency: currency,
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount);
  },
  
  // Get tax summary for invoice
  getTaxSummary: function(subtotal, isVatIncluded = true) {
    const vatDetails = this.calculateVAT(subtotal, isVatIncluded);
    
    return {
      subtotal: subtotal,
      vatRate: this.vat.rate * 100, // 15%
      vatAmount: vatDetails.vatAmount,
      total: vatDetails.grossAmount,
      breakdown: [
        {
          name: 'Subtotal',
          amount: vatDetails.netAmount,
          rate: null,
        },
        {
          name: 'VAT (15%)',
          amount: vatDetails.vatAmount,
          rate: '15%',
        },
      ],
    };
  },
};