// File: backend/src/database/models/organizer_application.js
import { BaseModel } from './BaseModel.js';

export class OrganizerApplicationModel extends BaseModel {
  constructor() {
    super('organizer_applications');
  }

  async createApplication(userId, applicationData) {
    try {
      const application = {
        user_id: userId,
        business_name: applicationData.business_name,
        business_type: applicationData.business_type,
        business_description: applicationData.business_description || '',
        contact_person: applicationData.contact_person || '',
        contact_phone: this.normalizePhone(applicationData.contact_phone || ''),
        contact_email: applicationData.contact_email || '',
        id_document_front: applicationData.id_document_front || '',
        id_document_back: applicationData.id_document_back || '',
        business_license_doc: applicationData.business_license_doc || '',
        tax_certificate: applicationData.tax_certificate || '',
        bank_name: applicationData.bank_name || '',
        bank_account: applicationData.bank_account || '',
        account_holder_name: applicationData.account_holder_name || '',
        status: 'pending',
        submitted_at: new Date(),
        expected_monthly_events: applicationData.expected_monthly_events || 1,
        primary_event_type: applicationData.primary_event_type || ''
      };

      return await this.create(application);
    } catch (error) {
      console.error('OrganizerApplicationModel.createApplication error:', error);
      throw error;
    }
  }

  async getApplicationsByStatus(status, options = {}) {
    try {
      return await this.findAll({ status }, {
        orderBy: 'submitted_at DESC',
        ...options
      });
    } catch (error) {
      console.error('OrganizerApplicationModel.getApplicationsByStatus error:', error);
      throw error;
    }
  }

  async getApplicationWithUser(applicationId) {
    try {
      const [rows] = await this.db.execute(`
        SELECT 
          oa.*,
          u.phone as user_phone,
          u.full_name as user_full_name,
          u.email as user_email,
          u.created_at as user_created_at
        FROM organizer_applications oa
        LEFT JOIN users u ON oa.user_id = u.id
        WHERE oa.id = ?
      `, [applicationId]);

      return rows[0] || null;
    } catch (error) {
      console.error('OrganizerApplicationModel.getApplicationWithUser error:', error);
      throw error;
    }
  }

  async updateApplicationStatus(applicationId, status, reviewNotes = '', reviewedBy = null) {
    try {
      const updates = {
        status,
        reviewed_at: new Date(),
        review_notes: reviewNotes
      };

      if (reviewedBy) {
        updates.reviewed_by = reviewedBy;
      }

      return await this.update(applicationId, updates);
    } catch (error) {
      console.error('OrganizerApplicationModel.updateApplicationStatus error:', error);
      throw error;
    }
  }

  async getApplicationsByUserId(userId) {
    try {
      return await this.findAll({ user_id: userId }, {
        orderBy: 'submitted_at DESC'
      });
    } catch (error) {
      console.error('OrganizerApplicationModel.getApplicationsByUserId error:', error);
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

export default new OrganizerApplicationModel();