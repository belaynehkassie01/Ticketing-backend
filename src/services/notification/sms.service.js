// File: backend/src/services/notification/sms.service.js
export const sendOTPSMS = async (phone, otp, language = 'am') => {
  try {
    // For now, just log. Integrate with Ethio Telecom API later
    console.log(`📱 [SMS] Sending OTP to ${phone}: ${otp} (Language: ${language})`);
    
    // Ethiopian SMS templates
    const templates = {
      am: `የእርስዎ ማረጋገጫ ኮድ: ${otp}. በ10 ደቂቃ ውስጥ ይጠፋል።`,
      en: `Your verification code: ${otp}. Expires in 10 minutes.`
    };
    
    const message = templates[language] || templates.en;
    console.log(`Message: ${message}`);
    
    // TODO: Integrate with Ethio Telecom API
    // const result = await ethioTelecomAPI.sendSMS(phone, message);
    
    return {
      success: true,
      message: 'SMS sent (simulated)',
      otp: otp // Remove this in production!
    };
    
  } catch (error) {
    console.error('SMS service error:', error);
    return {
      success: false,
      message: 'Failed to send SMS'
    };
  }
};