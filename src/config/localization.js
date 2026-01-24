// backend/src/config/localization.js
export default {
  // Supported languages
  languages: [
    {
      code: 'am',
      name: 'አማርኛ',
      nameEn: 'Amharic',
      isRTL: false,
      isDefault: true,
    },
    {
      code: 'en',
      name: 'English',
      nameEn: 'English',
      isRTL: false,
      isDefault: false,
    },
  ],
  
  // Language detection
  detection: {
    order: ['header', 'cookie', 'query', 'session'],
    lookupHeader: 'accept-language',
    lookupCookie: 'i18n',
    lookupQuery: 'lang',
    lookupSession: 'lang',
    caches: ['cookie'],
    cookieSecure: true,
    cookieSameSite: 'strict',
    cookieMaxAge: 365 * 24 * 60 * 60 * 1000, // 1 year
  },
  
  // Date & Time formats
  dateFormats: {
    gregorian: {
      short: 'dd/MM/yyyy',
      medium: 'dd MMM yyyy',
      long: 'dd MMMM yyyy',
      full: 'EEEE, dd MMMM yyyy',
    },
    ethiopian: {
      short: 'dd/MM/yyyy',
      medium: 'dd መድህን yyyy',
      long: 'dd መድህን yyyy ዓ/ም',
      full: 'EEEE, dd መድህን yyyy ዓ/ም',
    },
  },
  
  timeFormats: {
    short: 'HH:mm',
    medium: 'HH:mm:ss',
    long: 'HH:mm:ss z',
  },
  
  // Number formats
  numberFormats: {
    currency: {
      style: 'currency',
      currency: 'ETB',
      currencyDisplay: 'symbol',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    },
    decimal: {
      style: 'decimal',
      minimumFractionDigits: 0,
      maximumFractionDigits: 2,
    },
    percent: {
      style: 'percent',
      minimumFractionDigits: 0,
      maximumFractionDigits: 2,
    },
  },
  
  // Ethiopian-specific
  ethiopian: {
    firstDayOfWeek: 0, // Sunday (0 = Sunday, 1 = Monday)
    months: [
      'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታህሳስ', 'ጥር', 'የካቲት',
      'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ'
    ],
    weekdays: [
      'እሑድ', 'ሰኞ', 'ማክሰኞ', 'ረቡዕ', 'ሐሙስ', 'አርብ', 'ቅዳሜ'
    ],
    weekdaysShort: ['እሑድ', 'ሰኞ', 'ማክ', 'ረቡ', 'ሐሙ', 'አር', 'ቅዳ'],
    weekdaysMin: ['እ', 'ሰ', 'ማ', 'ረ', 'ሐ', 'አ', 'ቅ'],
  },
  
  // Translation fallbacks
  fallbackLanguage: 'am',
  
  // Auto-detect settings
  autoDetect: true,
  
  // Cookie settings
  cookieName: 'ethio_tickets_lang',
  
  // Directory for translation files
  directory: './src/i18n',
};