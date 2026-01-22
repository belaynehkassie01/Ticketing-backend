import Joi from 'joi';

// Ethiopian phone validation
const ethiopianPhoneRegex = /^(09[0-9]{8}|\+2519[0-9]{8}|2519[0-9]{8})$/;

// Register validation
export const registerSchema = Joi.object({
  phone: Joi.string()
    .pattern(ethiopianPhoneRegex)
    .required()
    .messages({
      'string.pattern.base': 'Invalid Ethiopian phone number. Format: 0912345678',
      'any.required': 'Phone number is required'
    }),
    
  password: Joi.string()
    .min(6)
    .max(100)
    .required()
    .messages({
      'string.min': 'Password must be at least 6 characters',
      'any.required': 'Password is required'
    }),
    
  email: Joi.string()
    .email()
    .optional(),
    
  full_name: Joi.string()
    .max(100)
    .optional()
});

// Login validation
export const loginSchema = Joi.object({
  phone: Joi.string()
    .pattern(ethiopianPhoneRegex)
    .required()
    .messages({
      'string.pattern.base': 'Invalid Ethiopian phone number',
      'any.required': 'Phone number is required'
    }),
    
  password: Joi.string()
    .required()
    .messages({
      'any.required': 'Password is required'
    })
});

// OTP validation
export const otpSchema = Joi.object({
  phone: Joi.string()
    .pattern(ethiopianPhoneRegex)
    .required(),
    
  otp: Joi.string()
    .length(6)
    .pattern(/^[0-9]+$/)
    .required()
});