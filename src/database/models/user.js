// File: backend/src/database/models/user.js
import { BaseModel } from './BaseModel.js';

export class UserModel extends BaseModel {
  constructor() {
    super('users');
  }

  // ========== CRITICAL METHODS FOR AUTH ==========

  async findByPhone(phone) {
    try {
      const normalizedPhone = this.normalizePhone(phone);
      return await this.findOne({ phone: normalizedPhone });
    } catch (error) {
      console.error('UserModel.findByPhone error:', error);
      throw error;
    }
  }

  async createUser(userData) {
    try {
      // Normalize Ethiopian phone
      if (userData.phone) {
        userData.phone = this.normalizePhone(userData.phone);
      }
      
      // Set defaults
      const userToCreate = {
        phone: userData.phone,
        full_name: userData.full_name || '',
        role: userData.role || 'customer',
        preferred_language: userData.preferred_language || 'am',
        phone_verified: false,
        is_active: true,
        is_suspended: false,
        organizer_status: 'none',
        ...userData
      };
      
      return await this.create(userToCreate);
    } catch (error) {
      console.error('UserModel.createUser error:', error);
      throw error;
    }
  }

  async updateVerificationCode(userId, code) {
    try {
      const expiryDate = new Date();
      expiryDate.setMinutes(expiryDate.getMinutes() + 10);
      
      // Ensure code is stored as string
      const codeString = String(code).trim();
      
      return await this.update(userId, {
        verification_code: codeString,  // Store as string
        verification_expiry: expiryDate,
        phone_verified: false
      });
    } catch (error) {
      console.error('UserModel.updateVerificationCode error:', error);
      throw error;
    }
  }

  async verifyPhoneCode(userId, code) {
    try {
      const user = await this.findById(userId);
      
      if (!user) {
        return { success: false, message: 'User not found' };
      }
      
      // DEBUG LOG
      console.log('🔍 OTP Verification Debug:');
      console.log(`  User ID: ${userId}`);
      console.log(`  DB OTP: "${user.verification_code}" (type: ${typeof user.verification_code})`);
      console.log(`  Input OTP: "${code}" (type: ${typeof code})`);
      console.log(`  OTP Expiry: ${user.verification_expiry}`);
      console.log(`  Current Time: ${new Date()}`);
      
      // Check if OTP exists
      if (!user.verification_code) {
        console.log('  ❌ No OTP in database');
        return { success: false, message: 'No verification code found' };
      }
      
      // Convert both to strings and trim
      const dbCode = String(user.verification_code).trim();
      const inputCode = String(code).trim();
      
      console.log(`  DB OTP (trimmed): "${dbCode}"`);
      console.log(`  Input OTP (trimmed): "${inputCode}"`);
      console.log(`  Match: ${dbCode === inputCode}`);
      
      if (dbCode !== inputCode) {
        console.log('  ❌ OTP mismatch');
        return { success: false, message: 'Invalid verification code' };
      }
      
      // Check if OTP is expired
      const now = new Date();
      const expiryDate = new Date(user.verification_expiry);
      
      console.log(`  Now: ${now}`);
      console.log(`  Expiry: ${expiryDate}`);
      console.log(`  Is expired? ${now > expiryDate}`);
      
      if (now > expiryDate) {
        console.log('  ❌ OTP expired');
        return { success: false, message: 'Verification code expired' };
      }
      
      // Update user as verified
      await this.update(userId, {
        phone_verified: true,
        verification_code: null,
        verification_expiry: null
      });
      
      console.log('  ✅ OTP verified successfully');
      
      return { 
        success: true, 
        message: 'Phone verified successfully',
        user: { ...user, phone_verified: true }
      };
    } catch (error) {
      console.error('UserModel.verifyPhoneCode error:', error);
      throw error;
    }
  }

  // ========== ETHIOPIAN PHONE HANDLING ==========

  normalizePhone(phone) {
    if (!phone) return '';
    
    let normalized = phone.trim();
    
    // Remove all non-digits except +
    normalized = normalized.replace(/[^\d+]/g, '');
    
    // Ethiopian phone normalization
    if (normalized.startsWith('09') && normalized.length === 10) {
      // 0912345678 → +251912345678
      normalized = '+2519' + normalized.substring(2);
    } else if (normalized.startsWith('9') && normalized.length === 9) {
      // 912345678 → +251912345678
      normalized = '+251' + normalized;
    } else if (normalized.startsWith('251') && normalized.length === 12) {
      // 251912345678 → +251912345678
      normalized = '+' + normalized;
    } else if (!normalized.startsWith('+251') && normalized.length === 12) {
      // 251912345678 → +251912345678
      normalized = '+' + normalized;
    }
    
    return normalized;
  }

  // ========== ORGANIZER MANAGEMENT ==========

  async applyForOrganizer(userId) {
    try {
      return await this.update(userId, {
        organizer_status: 'pending'
      });
    } catch (error) {
      console.error('UserModel.applyForOrganizer error:', error);
      throw error;
    }
  }

  async approveOrganizer(userId, organizerId) {
    try {
      return await this.update(userId, {
        organizer_status: 'approved',
        organizer_id: organizerId,
        role: 'organizer'
      });
    } catch (error) {
      console.error('UserModel.approveOrganizer error:', error);
      throw error;
    }
  }

  async rejectOrganizer(userId) {
    try {
      return await this.update(userId, {
        organizer_status: 'rejected',
        organizer_id: null
      });
    } catch (error) {
      console.error('UserModel.rejectOrganizer error:', error);
      throw error;
    }
  }

  // ========== UTILITY METHODS ==========

  async getUsersByRole(role, options = {}) {
    try {
      return await this.findAll({ role }, options);
    } catch (error) {
      console.error('UserModel.getUsersByRole error:', error);
      throw error;
    }
  }

  async getPendingOrganizerApplications() {
    try {
      const [rows] = await this.db.execute(`
        SELECT u.* 
        FROM users u
        WHERE u.organizer_status = 'pending'
        ORDER BY u.created_at DESC
      `);
      return rows;
    } catch (error) {
      console.error('UserModel.getPendingOrganizerApplications error:', error);
      throw error;
    }
  }

  async updateLastLogin(userId) {
    try {
      return await this.update(userId, {
        last_login: new Date()
      });
    } catch (error) {
      console.error('UserModel.updateLastLogin error:', error);
      throw error;
    }
  }

  async incrementFailedAttempts(userId) {
    try {
      const user = await this.findById(userId);
      const newAttempts = (user.failed_login_attempts || 0) + 1;
      
      let updateData = { failed_login_attempts: newAttempts };
      
      // Lock account after 5 failed attempts for 30 minutes
      if (newAttempts >= 5) {
        const lockUntil = new Date();
        lockUntil.setMinutes(lockUntil.getMinutes() + 30);
        updateData.locked_until = lockUntil;
      }
      
      return await this.update(userId, updateData);
    } catch (error) {
      console.error('UserModel.incrementFailedAttempts error:', error);
      throw error;
    }
  }

  async resetFailedAttempts(userId) {
    try {
      return await this.update(userId, {
        failed_login_attempts: 0,
        locked_until: null
      });
    } catch (error) {
      console.error('UserModel.resetFailedAttempts error:', error);
      throw error;
    }
  }

  async isAccountLocked(userId) {
    try {
      const user = await this.findById(userId);
      
      if (!user || !user.locked_until) {
        return false;
      }
      
      const now = new Date();
      const lockedUntil = new Date(user.locked_until);
      
      return now < lockedUntil;
    } catch (error) {
      console.error('UserModel.isAccountLocked error:', error);
      throw error;
    }
  }
}

// Export singleton instance
export default new UserModel();