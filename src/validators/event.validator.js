// File: backend/src/validators/event.validator.js
import Joi from 'joi';
import { validateEthiopianPhone } from './ethiopian.validator.js';

// Ethiopian date regex (Gregorian format: YYYY-MM-DDTHH:mm:ss)
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/;
const ETHIOPIAN_DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/; // YYYY-MM-DD Ethiopian format

// Helper for Ethiopian calendar validation
const isValidEthiopianDate = (value, helpers) => {
  const [year, month, day] = value.split('-').map(Number);
  
  // Basic Ethiopian calendar validation
  if (month < 1 || month > 13) {
    return helpers.error('any.invalid');
  }
  
  // Meskerem (month 1) to Pagume (month 13) day validation
  if (month === 13 && day > 5) { // Pagume has 5 or 6 days
    return helpers.error('any.invalid');
  }
  
  if (day < 1 || day > 30) { // Regular months have 30 days
    return helpers.error('any.invalid');
  }
  
  return value;
};

export const eventCreationSchema = Joi.object({
  // Basic Information
  title: Joi.string().min(3).max(200).required()
    .messages({
      'string.empty': 'በአማርኛ: የዝግጅት ርዕስ ያስፈልጋል',
      'string.min': 'በአማርኛ: የዝግጅት ርዕስ ቢያንስ 3 ፊደላት ሊኖረው ይገባል',
      'any.required': 'Event title is required'
    }),
  
  title_amharic: Joi.string().max(200).optional(),
  
  description: Joi.string().min(10).max(5000).required()
    .messages({
      'string.empty': 'ዝግጅቱን የሚገልጽ ጽሁፍ ያስፈልጋል',
      'string.min': 'ዝርዝር ገላጭ ጽሁፍ ቢያንስ 10 ፊደላት ሊኖረው ይገባል',
      'any.required': 'Event description is required'
    }),
  
  short_description: Joi.string().max(500).optional(),
  
  // Categorization
  category_id: Joi.number().integer().positive().required()
    .messages({
      'number.base': 'የዝግጅት ምድብ መምረጥ አለብዎት',
      'any.required': 'Event category is required'
    }),
  
  tags: Joi.array().items(Joi.number().integer().positive()).max(10).optional(),
  
  // Location (Ethiopian Context)
  city_id: Joi.number().integer().positive().required()
    .messages({
      'number.base': 'ከተማ መምረጥ አለብዎት',
      'any.required': 'City selection is required'
    }),
  
  venue_id: Joi.number().integer().positive().optional(),
  venue_custom: Joi.string().max(200).optional(),
  
  address_details: Joi.string().max(1000).optional(),
  
  latitude: Joi.number().min(-90).max(90).optional(),
  longitude: Joi.number().min(-180).max(180).optional(),
  
  // Date & Time (Ethiopian Calendar Support)
  start_date: Joi.string().pattern(DATE_REGEX).required()
    .messages({
      'string.pattern.base': 'የመጀመሪያ ቀን ቅርጽ: አመት-ወር-ቀን ሰዓት:ደቂቃ:ሰከንድ',
      'any.required': 'የመጀመሪያ ቀን አስፈላጊ ነው'
    }),
  
  end_date: Joi.string().pattern(DATE_REGEX).required()
    .messages({
      'string.pattern.base': 'የመጨረሻ ቀን ቅርጽ: አመት-ወር-ቀን ሰዓት:ደቂቃ:ሰከንድ',
      'any.required': 'የመጨረሻ ቀን አስፈላጊ ነው'
    }),
  
  // Ethiopian Calendar Dates
  start_date_ethiopian: Joi.string().pattern(ETHIOPIAN_DATE_REGEX)
    .custom(isValidEthiopianDate)
    .optional()
    .messages({
      'string.pattern.base': 'የኢትዮጵያ ቀን ቅርጽ: አመት-ወር-ቀን',
      'any.invalid': 'የኢትዮጵያ ቀን ትክክል አይደለም'
    }),
  
  end_date_ethiopian: Joi.string().pattern(ETHIOPIAN_DATE_REGEX)
    .custom(isValidEthiopianDate)
    .optional(),
  
  timezone: Joi.string().default('Africa/Addis_Ababa'),
  
  // Event Status
  status: Joi.string().valid('draft', 'pending_review', 'published', 'cancelled').default('draft'),
  visibility: Joi.string().valid('public', 'private', 'unlisted').default('public'),
  
  // Ticket Settings
  has_tickets: Joi.boolean().default(true),
  
  // Age Restriction
  age_restriction: Joi.string().valid('all', '18+', '21+').default('all'),
  
  // Ethiopian-Specific Fields
  is_charity: Joi.boolean().default(false),
  charity_org: Joi.when('is_charity', {
    is: true,
    then: Joi.string().min(2).max(200).required()
      .messages({
        'string.empty': 'ለበጎ አድራጎት ዝግጅት የተቋሙ ስም ያስፈልጋል'
      }),
    otherwise: Joi.string().optional()
  }),
  
  vat_included: Joi.boolean().default(true),
  vat_rate: Joi.number().min(0).max(100).default(15.00),
  
  // Media
  cover_image: Joi.string().uri().max(500).optional(),
  gallery_images: Joi.array().items(Joi.string().uri().max(500)).max(10).optional(),
  video_url: Joi.string().uri().max(500).optional(),
  
  // SEO
  meta_title: Joi.string().max(200).optional(),
  meta_description: Joi.string().max(500).optional(),
  meta_keywords: Joi.string().max(500).optional(),
  
  // Contact Info (Ethiopian format)
  contact_phone: Joi.string().custom((value, helpers) => {
    return validateEthiopianPhone(value, helpers);
  }).optional(),
  
  contact_email: Joi.string().email().optional(),
}).with('start_date', 'end_date') // If start_date exists, end_date must exist
  .with('start_date_ethiopian', 'end_date_ethiopian'); // Same for Ethiopian dates

// Event Update Schema (less strict)
export const eventUpdateSchema = Joi.object({
  title: Joi.string().min(3).max(200).optional(),
  title_amharic: Joi.string().max(200).optional(),
  description: Joi.string().min(10).max(5000).optional(),
  short_description: Joi.string().max(500).optional(),
  category_id: Joi.number().integer().positive().optional(),
  tags: Joi.array().items(Joi.number().integer().positive()).max(10).optional(),
  city_id: Joi.number().integer().positive().optional(),
  venue_id: Joi.number().integer().positive().optional(),
  venue_custom: Joi.string().max(200).optional(),
  address_details: Joi.string().max(1000).optional(),
  start_date: Joi.string().pattern(DATE_REGEX).optional(),
  end_date: Joi.string().pattern(DATE_REGEX).optional(),
  start_date_ethiopian: Joi.string().pattern(ETHIOPIAN_DATE_REGEX).custom(isValidEthiopianDate).optional(),
  end_date_ethiopian: Joi.string().pattern(ETHIOPIAN_DATE_REGEX).custom(isValidEthiopianDate).optional(),
  status: Joi.string().valid('draft', 'pending_review', 'published', 'cancelled').optional(),
  visibility: Joi.string().valid('public', 'private', 'unlisted').optional(),
  is_charity: Joi.boolean().optional(),
  charity_org: Joi.string().min(2).max(200).optional(),
  vat_included: Joi.boolean().optional(),
  vat_rate: Joi.number().min(0).max(100).optional(),
  cover_image: Joi.string().uri().max(500).optional(),
  contact_phone: Joi.string().custom((value, helpers) => {
    return validateEthiopianPhone(value, helpers);
  }).optional(),
  contact_email: Joi.string().email().optional(),
}).min(1); // At least one field must be provided

// Publish Event Validation
export const eventPublishSchema = Joi.object({
  event_id: Joi.number().integer().positive().required(),
  publish_immediately: Joi.boolean().default(false),
  scheduled_publish: Joi.string().pattern(DATE_REGEX).optional(),
});

// Event Filter/Search Schema
export const eventFilterSchema = Joi.object({
  city_id: Joi.number().integer().positive().optional(),
  category_id: Joi.number().integer().positive().optional(),
  organizer_id: Joi.number().integer().positive().optional(),
  date_from: Joi.string().pattern(DATE_REGEX).optional(),
  date_to: Joi.string().pattern(DATE_REGEX).optional(),
  price_min: Joi.number().min(0).optional(),
  price_max: Joi.number().min(0).optional(),
  status: Joi.string().valid('published', 'draft', 'upcoming', 'past', 'cancelled').optional(),
  is_featured: Joi.boolean().optional(),
  search: Joi.string().max(100).optional(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
  sort_by: Joi.string().valid('date', 'price', 'popularity', 'name').default('date'),
  sort_order: Joi.string().valid('asc', 'desc').default('asc'),
});

// Export validation functions
export const validateEventCreation = (data) => {
  const { error, value } = eventCreationSchema.validate(data, {
    abortEarly: false,
    stripUnknown: true
  });
  
  return {
    valid: !error,
    errors: error ? error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message,
      message_amharic: detail.context?.message_amharic || detail.message
    })) : [],
    data: value
  };
};

export const validateEventUpdate = (data) => {
  const { error, value } = eventUpdateSchema.validate(data, {
    abortEarly: false,
    stripUnknown: true
  });
  
  return {
    valid: !error,
    errors: error ? error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    })) : [],
    data: value
  };
};

export const validateEventFilter = (data) => {
  const { error, value } = eventFilterSchema.validate(data, {
    abortEarly: false,
    stripUnknown: true
  });
  
  return {
    valid: !error,
    errors: error ? error.details.map(detail => ({
      field: detail.path.join('.'),
      message: detail.message
    })) : [],
    data: value
  };
};

export default {
  eventCreationSchema,
  eventUpdateSchema,
  eventPublishSchema,
  eventFilterSchema,
  validateEventCreation,
  validateEventUpdate,
  validateEventFilter
};