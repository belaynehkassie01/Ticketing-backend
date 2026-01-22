// File: backend/src/database/models/organizer.js
import { BaseModel } from './BaseModel.js';

export class OrganizerModel extends BaseModel {
  constructor() {
    super('organizers');
  }

  async createOrganizer(userId, organizerData) {
    try {
      const organizer = {
        user_id: userId,
        business_name: organizerData.business_name,
        business_name_amharic: organizerData.business_name_amharic || '',
        business_type: organizerData.business_type,
        tax_id: organizerData.tax_id || '',
        business_license: organizerData.business_license || '',
        vat_registered: organizerData.vat_registered || false,
        vat_number: organizerData.vat_number || '',
        business_phone: this.normalizePhone(organizerData.business_phone || ''),
        business_email: organizerData.business_email || '',
        website: organizerData.website || '',
        region: organizerData.region || '',
        sub_city: organizerData.sub_city || '',
        woreda: organizerData.woreda || '',
        house_number: organizerData.house_number || '',
        bank_name: organizerData.bank_name || 'cbe',
        bank_account: organizerData.bank_account || '',
        account_holder_name: organizerData.account_holder_name || '',
        bank_branch: organizerData.bank_branch || '',
        status: 'approved',
        verification_level: 'basic',
        verified_at: new Date(),
        commission_rate: organizerData.commission_rate || 10.00
      };

      return await this.create(organizer);
    } catch (error) {
      console.error('OrganizerModel.createOrganizer error:', error);
      throw error;
    }
  }

  async getOrganizerByUserId(userId) {
    try {
      return await this.findOne({ user_id: userId });
    } catch (error) {
      console.error('OrganizerModel.getOrganizerByUserId error:', error);
      throw error;
    }
  }

  async getOrganizerWithUser(organizerId) {
    try {
      const [rows] = await this.db.execute(`
        SELECT 
          o.*,
          u.phone as user_phone,
          u.full_name as user_full_name,
          u.email as user_email,
          u.preferred_language as user_preferred_language
        FROM organizers o
        LEFT JOIN users u ON o.user_id = u.id
        WHERE o.id = ?
      `, [organizerId]);

      return rows[0] || null;
    } catch (error) {
      console.error('OrganizerModel.getOrganizerWithUser error:', error);
      throw error;
    }
  }

  async updateOrganizerStats(organizerId, stats) {
    try {
      const updates = {};
      
      if (stats.total_events !== undefined) {
        updates.total_events = stats.total_events;
      }
      if (stats.total_tickets_sold !== undefined) {
        updates.total_tickets_sold = stats.total_tickets_sold;
      }
      if (stats.total_revenue !== undefined) {
        updates.total_revenue = stats.total_revenue;
      }
      if (stats.rating !== undefined) {
        updates.rating = stats.rating;
      }
      if (stats.rating_count !== undefined) {
        updates.rating_count = stats.rating_count;
      }

      if (Object.keys(updates).length > 0) {
        return await this.update(organizerId, updates);
      }
      
      return 0;
    } catch (error) {
      console.error('OrganizerModel.updateOrganizerStats error:', error);
      throw error;
    }
  }

  async getActiveOrganizers(options = {}) {
    try {
      return await this.findAll({ 
        status: 'approved',
        is_active: true 
      }, {
        orderBy: 'business_name ASC',
        ...options
      });
    } catch (error) {
      console.error('OrganizerModel.getActiveOrganizers error:', error);
      throw error;
    }
  }

  normalizePhone(phone) {
    if (!phone) return '';
    
    let normalized = phone.trim();
    normalized = normalized.replace(/[^\d+]/g, '');
    
    if (normalized.startsWith('09') && normalized.length === 10) {
      normalized = '+2519' + normalized.substring(2);
    } else if (normalized.startsWith('9') && normalized.length === 9) {
      normalized = '+251' + normalized;
    } else if (normalized.startsWith('251') && normalized.length === 12) {
      normalized = '+' + normalized;
    } else if (!normalized.startsWith('+251') && normalized.length === 12) {
      normalized = '+' + normalized;
    }
    
    return normalized;
  }
}

export default new OrganizerModel();