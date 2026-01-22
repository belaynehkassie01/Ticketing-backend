// File: backend/src/controllers/auth/auth.controller.js
import userModel from '../../database/models/user.js';
import { generateToken } from '../../utils/jwt.util.js';
import { sendOTPSMS } from '../../services/notification/sms.service.js';

export const authController = {
  // Send OTP to phone
  async sendOTP(req, res) {
    try {
      const { phone } = req.body;
      
      if (!phone) {
        return res.status(400).json({
          success: false,
          message: 'Phone number is required'
        });
      }
      
      // Check if user exists or create new
      let user = await userModel.findByPhone(phone);
      
      if (!user) {
        // Create new user
        const userId = await userModel.createUser({
          phone,
          full_name: '',
          role: 'customer'
        });
        user = await userModel.findById(userId);
      }
      
      // Check if account is locked
      const isLocked = await userModel.isAccountLocked(user.id);
      if (isLocked) {
        return res.status(423).json({
          success: false,
          message: 'Account is temporarily locked. Try again later.'
        });
      }
      
      // Generate 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      
      // Save OTP to user
      await userModel.updateVerificationCode(user.id, otp);
      
      // Send OTP via SMS (Ethio Telecom)
      const smsResult = await sendOTPSMS(phone, otp, user.preferred_language || 'am');
      
      res.json({
        success: true,
        message: 'OTP sent successfully',
        data: {
          userId: user.id,
          phone: user.phone,
          smsSent: smsResult.success,
          expiresIn: '10 minutes'
        }
      });
      
    } catch (error) {
      console.error('Send OTP error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to send OTP',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Verify OTP and login
  async verifyOTP(req, res) {
    try {
      const { userId, otp } = req.body;
      
      if (!userId || !otp) {
        return res.status(400).json({
          success: false,
          message: 'User ID and OTP are required'
        });
      }
      
      // Verify OTP
      const verifyResult = await userModel.verifyPhoneCode(userId, otp);
      
      if (!verifyResult.success) {
        // Increment failed attempts
        await userModel.incrementFailedAttempts(userId);
        
        return res.status(400).json({
          success: false,
          message: verifyResult.message
        });
      }
      
      // Reset failed attempts on success
      await userModel.resetFailedAttempts(userId);
      
      // Update last login
      await userModel.updateLastLogin(userId);
      
      // Generate JWT token
      const token = generateToken({
        id: verifyResult.user.id,
        phone: verifyResult.user.phone,
        role: verifyResult.user.role,
        organizer_status: verifyResult.user.organizer_status
      });
      
      res.json({
        success: true,
        message: 'Login successful',
        data: {
          token,
          user: {
            id: verifyResult.user.id,
            phone: verifyResult.user.phone,
            full_name: verifyResult.user.full_name,
            role: verifyResult.user.role,
            organizer_status: verifyResult.user.organizer_status,
            phone_verified: verifyResult.user.phone_verified
          }
        }
      });
      
    } catch (error) {
      console.error('Verify OTP error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to verify OTP',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get current user profile
  async getProfile(req, res) {
    try {
      // User is attached by auth middleware
      const user = req.user;
      
      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            phone: user.phone,
            full_name: user.full_name,
            role: user.role,
            organizer_status: user.organizer_status,
            phone_verified: user.phone_verified,
            preferred_language: user.preferred_language,
            city_id: user.city_id,
            created_at: user.created_at
          }
        }
      });
      
    } catch (error) {
      console.error('Get profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get profile'
      });
    }
  },

  // Update profile
  async updateProfile(req, res) {
    try {
      const userId = req.user.id;
      const updates = req.body;
      
      // Remove fields that shouldn't be updated
      const allowedUpdates = ['full_name', 'preferred_language', 'city_id'];
      const filteredUpdates = {};
      
      for (const key in updates) {
        if (allowedUpdates.includes(key)) {
          filteredUpdates[key] = updates[key];
        }
      }
      
      if (Object.keys(filteredUpdates).length === 0) {
        return res.status(400).json({
          success: false,
          message: 'No valid fields to update'
        });
      }
      
      await userModel.update(userId, filteredUpdates);
      
      // Get updated user
      const updatedUser = await userModel.findById(userId);
      
      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          user: {
            id: updatedUser.id,
            full_name: updatedUser.full_name,
            preferred_language: updatedUser.preferred_language,
            city_id: updatedUser.city_id
          }
        }
      });
      
    } catch (error) {
      console.error('Update profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update profile'
      });
    }
  }
};