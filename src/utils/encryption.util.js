// backend/src/utils/encryption.util.js
import crypto from 'crypto';
import dotenv from 'dotenv';

dotenv.config();

export default {
  // Configuration
  algorithm: 'aes-256-gcm',
  ivLength: 16,
  saltLength: 64,
  keyLength: 32,
  iterations: 100000,
  
  // Generate encryption key from environment
  getEncryptionKey() {
    const key = process.env.ENCRYPTION_KEY;
    if (!key || key.length < 32) {
      throw new Error('ENCRYPTION_KEY must be at least 32 characters');
    }
    return crypto.scryptSync(key, 'ethio-tickets-salt', 32);
  },
  
  // Encrypt sensitive data (bank accounts, IDs, etc.)
  encryptSensitiveData(text) {
    const iv = crypto.randomBytes(this.ivLength);
    const key = this.getEncryptionKey();
    const cipher = crypto.createCipheriv(this.algorithm, key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const authTag = cipher.getAuthTag();
    
    // Return in format for database storage
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex'),
      algorithm: this.algorithm,
      timestamp: new Date().toISOString()
    };
  },
  
  // Decrypt sensitive data
  decryptSensitiveData(encryptedData) {
    const key = this.getEncryptionKey();
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      key,
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  },
  
  // Hash passwords (for users table)
  hashPassword(password) {
    const salt = crypto.randomBytes(this.saltLength).toString('hex');
    const hash = crypto.pbkdf2Sync(
      password,
      salt,
      this.iterations,
      this.keyLength,
      'sha256'
    ).toString('hex');
    
    return {
      hash,
      salt,
      iterations: this.iterations,
      algorithm: 'pbkdf2-sha256'
    };
  },
  
  // Verify password
  verifyPassword(password, hashedPassword, salt) {
    const hash = crypto.pbkdf2Sync(
      password,
      salt,
      this.iterations,
      this.keyLength,
      'sha256'
    ).toString('hex');
    
    return hash === hashedPassword;
  },
  
  // Generate secure random strings (for OTP, tokens, etc.)
  generateSecureRandom(length = 32) {
    return crypto.randomBytes(length).toString('hex');
  },
  
  // Generate UUID for entities (tickets, payments, etc.)
  generateUUID() {
    return crypto.randomUUID();
  },
  
  // Hash file for integrity check (receipts, documents)
  hashFile(buffer) {
    return crypto.createHash('sha256').update(buffer).digest('hex');
  },
  
  // Encrypt JSON data (for sensitive config in database)
  encryptJSON(data) {
    const jsonString = JSON.stringify(data);
    return this.encryptSensitiveData(jsonString);
  },
  
  // Decrypt JSON data
  decryptJSON(encryptedData) {
    const decrypted = this.decryptSensitiveData(encryptedData);
    return JSON.parse(decrypted);
  },
  
  // Generate QR secret key (for ticket validation)
  generateQRSecret() {
    return crypto.randomBytes(64).toString('base64');
  },
  
  // Validate Ethiopian ID number format (placeholder for actual validation)
  validateEthiopianID(idNumber) {
    // Ethiopian ID validation logic
    const regex = /^[0-9]{9,15}$/;
    return regex.test(idNumber);
  },
  
  // Mask sensitive data for logging (bank accounts, phone numbers)
  maskSensitiveData(data, type) {
    if (!data) return '';
    
    switch (type) {
      case 'phone':
        return data.replace(/(\d{3})\d{4}(\d{3})/, '$1****$2');
      case 'bank_account':
        return `****${data.slice(-4)}`;
      case 'email':
        const [local, domain] = data.split('@');
        return `${local.charAt(0)}***@${domain}`;
      case 'id_number':
        return `${data.slice(0, 3)}***${data.slice(-3)}`;
      default:
        return data.replace(/./g, '*');
    }
  }
};