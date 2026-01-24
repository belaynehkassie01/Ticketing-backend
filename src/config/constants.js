module.exports = {
  // User Roles
  USER_ROLES: {
    CUSTOMER: 'customer',
    ORGANIZER: 'organizer',
    ADMIN: 'admin',
    STAFF: 'staff',
  },

  // Organizer Status
  ORGANIZER_STATUS: {
    PENDING: 'pending',
    APPROVED: 'approved',
    SUSPENDED: 'suspended',
    REJECTED: 'rejected',
    UNDER_REVIEW: 'under_review',
  },

  // Event Status
  EVENT_STATUS: {
    DRAFT: 'draft',
    PENDING_REVIEW: 'pending_review',
    PUBLISHED: 'published',
    CANCELLED: 'cancelled',
    COMPLETED: 'completed',
    SUSPENDED: 'suspended',
  },

  // Payment Status
  PAYMENT_STATUS: {
    PENDING: 'pending',
    PROCESSING: 'processing',
    COMPLETED: 'completed',
    FAILED: 'failed',
    CANCELLED: 'cancelled',
    REFUNDED: 'refunded',
  },

  // Ticket Status
  TICKET_STATUS: {
    RESERVED: 'reserved',
    PAID: 'paid',
    CHECKED_IN: 'checked_in',
    CANCELLED: 'cancelled',
    REFUNDED: 'refunded',
    TRANSFERRED: 'transferred',
  },

  // Ethiopian Banks
  ETHIOPIAN_BANKS: [
    { code: 'cbe', name: 'Commercial Bank of Ethiopia', nameAm: 'ኮሜርሻል ባንክ ኦፍ ኢትዮጵያ' },
    { code: 'awash', name: 'Awash Bank', nameAm: 'አዋሽ ባንክ' },
    { code: 'dashen', name: 'Dashen Bank', nameAm: 'ዳሽን ባንክ' },
    { code: 'abyssinia', name: 'Bank of Abyssinia', nameAm: 'ባንክ ኦፍ አቢሲኒያ' },
    { code: 'nib', name: 'Nib International Bank', nameAm: 'ኒብ ኢንተርናሽናል ባንክ' },
    { code: 'cbe_birr', name: 'CBE Birr', nameAm: 'ሲቢኢ ብር' },
    { code: 'telebirr', name: 'Telebirr', nameAm: 'ቴሌብር' },
  ],

  // Ethiopian Regions
  ETHIOPIAN_REGIONS: [
    'Addis Ababa',
    'Afar',
    'Amhara',
    'Benishangul-Gumuz',
    'Dire Dawa',
    'Gambela',
    'Harari',
    'Oromia',
    'Sidama',
    'Somali',
    'Southern Nations, Nationalities, and Peoples\' Region',
    'Tigray',
  ],

  // Major Ethiopian Cities
  MAJOR_CITIES: [
    { id: 1, name: 'Addis Ababa', nameAm: 'አዲስ አበባ', region: 'Addis Ababa' },
    { id: 2, name: 'Adama', nameAm: 'አዳማ', region: 'Oromia' },
    { id: 3, name: 'Bahir Dar', nameAm: 'ባህር ዳር', region: 'Amhara' },
    { id: 4, name: 'Mekelle', nameAm: 'ምቀላ', region: 'Tigray' },
    { id: 5, name: 'Hawassa', nameAm: 'ሀዋሳ', region: 'Sidama' },
    { id: 6, name: 'Gondar', nameAm: 'ጎንደር', region: 'Amhara' },
    { id: 7, name: 'Jimma', nameAm: 'ጅማ', region: 'Oromia' },
    { id: 8, name: 'Dire Dawa', nameAm: 'ድሬ ዳዋ', region: 'Dire Dawa' },
    { id: 9, name: 'Dessie', nameAm: 'ደሴ', region: 'Amhara' },
    { id: 10, name: 'Jijiga', nameAm: 'ጅጅጋ', region: 'Somali' },
  ],

  // Event Categories
  EVENT_CATEGORIES: [
    { id: 1, name: 'Music & Concerts', nameAm: 'ሙዚቃ እና ኮንሰርቶች' },
    { id: 2, name: 'Sports', nameAm: 'ስፖርት' },
    { id: 3, name: 'Theater & Arts', nameAm: 'ቲያትር እና ጥበብ' },
    { id: 4, name: 'Conference & Business', nameAm: 'ኮንፈረንስ እና ንግድ' },
    { id: 5, name: 'Festival & Cultural', nameAm: 'ወገን እና ባህላዊ' },
    { id: 6, name: 'Education & Workshop', nameAm: 'ትምህርት እና ስልጠና' },
    { id: 7, name: 'Charity & Fundraising', nameAm: 'በጎ አድራጎት እና ገንዘብ ማሰባሰብ' },
    { id: 8, name: 'Food & Drink', nameAm: 'ምግብ እና መጠጥ' },
    { id: 9, name: 'Comedy & Entertainment', nameAm: 'ኮሜዲ እና መዝናኛ' },
    { id: 10, name: 'Religious & Spiritual', nameAm: 'ሃይማኖታዊ እና መንፈሳዊ' },
  ],

  // Time Constants
  TIME: {
    SECOND: 1000,
    MINUTE: 60 * 1000,
    HOUR: 60 * 60 * 1000,
    DAY: 24 * 60 * 60 * 1000,
    WEEK: 7 * 24 * 60 * 60 * 1000,
  },

  // Reservation Timeout (15 minutes in milliseconds)
  RESERVATION_TIMEOUT: 15 * 60 * 1000,

  // Ethiopian VAT Rate (15%)
  VAT_RATE: 0.15,

  // Platform Commission Default (10%)
  PLATFORM_COMMISSION_RATE: 0.10,

  // Ethiopian Phone Regex
  PHONE_REGEX: /^(09[0-9]{8}|\+2519[0-9]{8})$/,

  // Ethiopian TIN Regex (Tax Identification Number)
  TIN_REGEX: /^[0-9]{10,15}$/,

  // Ethiopian Business License Regex
  BUSINESS_LICENSE_REGEX: /^[A-Z]{2}\/[0-9]{1,5}\/[0-9]{4}$/,

  // Error Messages (English & Amharic)
  ERROR_MESSAGES: {
    // Validation Errors
    INVALID_PHONE: {
      en: 'Invalid phone number. Please use Ethiopian format (09XXXXXXXX or +2519XXXXXXXX)',
      am: 'የስልክ ቁጥር ትክክል አይደለም። ኢትዮጵያዊ ፎርማት ይጠቀሙ (09XXXXXXXX ወይም +2519XXXXXXXX)',
    },
    INVALID_EMAIL: {
      en: 'Invalid email address',
      am: 'የኢሜል አድራሻ ትክክል አይደለም',
    },
    REQUIRED_FIELD: {
      en: 'This field is required',
      am: 'ይህ መስክ ያስፈልጋል',
    },
    
    // Auth Errors
    INVALID_CREDENTIALS: {
      en: 'Invalid phone number or password',
      am: 'የስልክ ቁጥር ወይም የይለፍ ቃል ትክክል አይደለም',
    },
    ACCOUNT_SUSPENDED: {
      en: 'Your account has been suspended. Please contact support',
      am: 'አካውንትዎ ተቆምቷል። እባክዎን ድጋፍ ያግኙ',
    },
    
    // Payment Errors
    PAYMENT_FAILED: {
      en: 'Payment failed. Please try again',
      am: 'ክፍያ አልተሳካም። እባክዎን እንደገና ይሞክሩ',
    },
    INSUFFICIENT_BALANCE: {
      en: 'Insufficient balance for this transaction',
      am: 'ለዚህ ግብይት በቂ ቀሪ ሒሳብ የለም',
    },
  },

  // Success Messages (English & Amharic)
  SUCCESS_MESSAGES: {
    PAYMENT_SUCCESSFUL: {
      en: 'Payment successful! Your ticket has been issued',
      am: 'ክፍያ ተሳክቷል! ትኬትዎ ተሰጥቷል',
    },
    OTP_SENT: {
      en: 'OTP has been sent to your phone',
      am: 'OTP ወደ ስልክዎ ተልኳል',
    },
    REGISTRATION_SUCCESSFUL: {
      en: 'Registration successful! Please verify your phone',
      am: 'ምዝገባ ተሳክቷል! እባክዎን ስልክዎን ያረጋግጡ',
    },
  },

  // Pagination Defaults
  PAGINATION: {
    DEFAULT_LIMIT: 20,
    MAX_LIMIT: 100,
    DEFAULT_PAGE: 1,
  },

  // File Upload Limits
  FILE_LIMITS: {
    MAX_IMAGE_SIZE: 5 * 1024 * 1024, // 5MB
    MAX_DOCUMENT_SIZE: 10 * 1024 * 1024, // 10MB
    MAX_VIDEO_SIZE: 50 * 1024 * 1024, // 50MB
  },

  // QR Code Settings
  QR: {
    SIZE: 300,
    MARGIN: 2,
    COLOR: {
      DARK: '#078930', // Ethiopian Green
      LIGHT: '#FFFFFF',
    },
  },

  // Ethiopian Holidays (Common dates)
  ETHIOPIAN_HOLIDAYS: [
    '01-07', // Ethiopian Christmas
    '01-19', // Timket
    '02-11', // Victory of Adwa
    '04-06', // Ethiopian Good Friday (varies)
    '04-08', // Ethiopian Easter (varies)
    '05-05', // Ethiopian Patriots' Victory Day
    '05-28', // Derg Downfall Day
    '08-17', // Ethiopian New Year
    '09-11', // Enkutatash
    '09-27', // Finding of True Cross
  ],
};