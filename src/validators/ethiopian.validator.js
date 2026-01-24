// File: backend/src/validators/ethiopian.validator.js
import Joi from 'joi';

// Ethiopian phone validation (0912345678 or +251912345678)
export const validateEthiopianPhone = (value, helpers) => {
  const phoneRegex = /^(?:\+251|0)?9\d{8}$/;
  
  if (!phoneRegex.test(value)) {
    return helpers.error('any.invalid', {
      message: 'Invalid Ethiopian phone number',
      message_amharic: 'የኢትዮጵያ ስልክ ቁጥር ትክክል አይደለም'
    });
  }
  
  // Normalize to +251 format
  if (value.startsWith('0')) {
    return '+251' + value.substring(1);
  }
  
  if (!value.startsWith('+251')) {
    return '+251' + value;
  }
  
  return value;
};

// Ethiopian TIN (Tax Identification Number) validation
export const validateEthiopianTIN = (value, helpers) => {
  const tinRegex = /^\d{10}$/; // Ethiopian TIN is 10 digits
  
  if (!tinRegex.test(value)) {
    return helpers.error('any.invalid', {
      message: 'Invalid Ethiopian TIN (must be 10 digits)',
      message_amharic: 'የኢትዮጵያ ግብር መለያ ቁጥር ትክክል አይደለም (10 አሃዝ መሆን አለበት)'
    });
  }
  
  return value;
};

// Ethiopian business license validation
export const validateBusinessLicense = (value, helpers) => {
  // Common Ethiopian business license patterns
  const patterns = [
    /^[A-Z]{2}\/\d+\/\d{4}$/, // Example: AA/12345/2024
    /^\d+[A-Z]?\/\d{4}$/,     // Example: 12345A/2024
    /^[A-Z]+\-\d+\-\d{4}$/    // Example: ADD-123-2024
  ];
  
  const isValid = patterns.some(pattern => pattern.test(value));
  
  if (!isValid) {
    return helpers.error('any.invalid', {
      message: 'Invalid Ethiopian business license format',
      message_amharic: 'የንግድ ፈቃድ ቅርጽ ትክክል አይደለም'
    });
  }
  
  return value;
};

// Ethiopian bank account validation
export const validateEthiopianBankAccount = (value, helpers) => {
  // Ethiopian bank accounts are typically 13-16 digits
  const accountRegex = /^\d{10,16}$/;
  
  if (!accountRegex.test(value)) {
    return helpers.error('any.invalid', {
      message: 'Invalid Ethiopian bank account number',
      message_amharic: 'የባንክ መለያ ቁጥር ትክክል አይደለም'
    });
  }
  
  return value;
};

// Ethiopian city validation
export const validateEthiopianCity = (value, helpers) => {
  const ethiopianCities = [
    'Addis Ababa', 'Adama', 'Bahir Dar', 'Mekelle', 'Hawassa', 
    'Gondar', 'Dessie', 'Jimma', 'Dire Dawa', 'Jijiga',
    // Amharic names
    'አዲስ አበባ', 'አዳማ', 'ባሕር ዳር', 'መቀሌ', 'ሀዋሳ',
    'ጎንደር', 'ደሴ', 'ጅማ', 'ድሬዳዋ', 'ጅጅጋ'
  ];
  
  if (!ethiopianCities.includes(value)) {
    return helpers.error('any.invalid', {
      message: 'City must be a valid Ethiopian city',
      message_amharic: 'ትክክለኛ የኢትዮጵያ ከተማ መሆን አለበት'
    });
  }
  
  return value;
};

// Export Joi extensions for use in other validators
export const ethiopianPhoneSchema = Joi.string().custom(validateEthiopianPhone, 'Ethiopian phone validation');
export const ethiopianTINSchema = Joi.string().custom(validateEthiopianTIN, 'Ethiopian TIN validation');
export const ethiopianBusinessLicenseSchema = Joi.string().custom(validateBusinessLicense, 'Ethiopian business license validation');
export const ethiopianBankAccountSchema = Joi.string().custom(validateEthiopianBankAccount, 'Ethiopian bank account validation');
export const ethiopianCitySchema = Joi.string().custom(validateEthiopianCity, 'Ethiopian city validation');

// Export all validators
export default {
  validateEthiopianPhone,
  validateEthiopianTIN,
  validateBusinessLicense,
  validateEthiopianBankAccount,
  validateEthiopianCity,
  ethiopianPhoneSchema,
  ethiopianTINSchema,
  ethiopianBusinessLicenseSchema,
  ethiopianBankAccountSchema,
  ethiopianCitySchema
};