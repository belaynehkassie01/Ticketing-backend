// File: backend/src/database/models/event.js
import { BaseModel } from './BaseModel.js';
import { convertToEthiopianDate } from '../../utils/ethiopian/calendar.util.js';

export class EventModel extends BaseModel {
  constructor() {
    super('events');
  }

  async createEvent(organizerId, eventData) {
    try {
      // Calculate Ethiopian dates if not provided
      if (eventData.start_date && !eventData.start_date_ethiopian) {
        eventData.start_date_ethiopian = convertToEthiopianDate(eventData.start_date);
      }
      
      if (eventData.end_date && !eventData.end_date_ethiopian) {
        eventData.end_date_ethiopian = convertToEthiopianDate(eventData.end_date);
      }

      // Generate slug from title
      if (eventData.title && !eventData.slug) {
        eventData.slug = this.generateSlug(eventData.title);
      }

      // Calculate duration
      if (eventData.start_date && eventData.end_date) {
        const start = new Date(eventData.start_date);
        const end = new Date(eventData.end_date);
        eventData.duration_minutes = Math.round((end - start) / (1000 * 60));
      }

      const event = {
        organizer_id: organizerId,
        status: 'draft',
        visibility: 'public',
        timezone: 'Africa/Addis_Ababa',
        vat_included: true,
        vat_rate: 15.00,
        is_charity: false,
        age_restriction: 'all',
        ...eventData
      };

      return await this.create(event);
    } catch (error) {
      console.error('EventModel.createEvent error:', error);
      throw error;
    }
  }

  async publishEvent(eventId) {
    try {
      return await this.update(eventId, {
        status: 'published',
        published_at: new Date()
      });
    } catch (error) {
      console.error('EventModel.publishEvent error:', error);
      throw error;
    }
  }

  async getPublishedEvents(filters = {}, options = {}) {
    try {
      let query = `
        SELECT e.*, 
          c.name as city_name,
          c.name_amharic as city_name_amharic,
          cat.name as category_name,
          cat.name_amharic as category_name_amharic,
          org.business_name as organizer_name,
          org.business_name_amharic as organizer_name_amharic,
          v.name as venue_name,
          v.name_amharic as venue_name_amharic,
          (SELECT COUNT(*) FROM individual_tickets it 
           WHERE it.event_id = e.id AND it.status = 'paid') as tickets_sold,
          (SELECT MIN(price) FROM ticket_types tt 
           WHERE tt.event_id = e.id AND tt.is_active = TRUE) as min_price,
          (SELECT MAX(price) FROM ticket_types tt 
           WHERE tt.event_id = e.id AND tt.is_active = TRUE) as max_price
        FROM events e
        LEFT JOIN cities c ON e.city_id = c.id
        LEFT JOIN event_categories cat ON e.category_id = cat.id
        LEFT JOIN organizers org ON e.organizer_id = org.id
        LEFT JOIN venues v ON e.venue_id = v.id
        WHERE e.status = 'published' 
        AND e.visibility = 'public'
        AND e.start_date > NOW()
      `;

      const values = [];
      let paramCount = 0;

      // Apply filters
      if (filters.city_id) {
        query += ` AND e.city_id = ?`;
        values.push(filters.city_id);
      }

      if (filters.category_id) {
        query += ` AND e.category_id = ?`;
        values.push(filters.category_id);
      }

      if (filters.organizer_id) {
        query += ` AND e.organizer_id = ?`;
        values.push(filters.organizer_id);
      }

      if (filters.start_date_from) {
        query += ` AND e.start_date >= ?`;
        values.push(filters.start_date_from);
      }

      if (filters.start_date_to) {
        query += ` AND e.start_date <= ?`;
        values.push(filters.start_date_to);
      }

      if (filters.search) {
        query += ` AND (e.title LIKE ? OR e.title_amharic LIKE ? OR e.description LIKE ?)`;
        const searchTerm = `%${filters.search}%`;
        values.push(searchTerm, searchTerm, searchTerm);
      }

      // Ordering
      if (filters.sort_by) {
        const sortMap = {
          'date_asc': 'e.start_date ASC',
          'date_desc': 'e.start_date DESC',
          'price_asc': 'min_price ASC',
          'price_desc': 'min_price DESC',
          'popular': 'tickets_sold DESC'
        };
        query += ` ORDER BY ${sortMap[filters.sort_by] || 'e.start_date ASC'}`;
      } else {
        query += ` ORDER BY e.start_date ASC`;
      }

      // Pagination
      if (options.limit) {
        query += ` LIMIT ?`;
        values.push(options.limit);
      }

      if (options.offset) {
        query += ` OFFSET ?`;
        values.push(options.offset);
      }

      const [rows] = await this.db.execute(query, values);
      return rows;
    } catch (error) {
      console.error('EventModel.getPublishedEvents error:', error);
      throw error;
    }
  }

  async getEventWithDetails(eventId) {
    try {
      const [rows] = await this.db.execute(`
        SELECT e.*,
          c.name as city_name,
          c.name_amharic as city_name_amharic,
          cat.name as category_name,
          cat.name_amharic as category_name_amharic,
          org.business_name as organizer_name,
          org.business_name_amharic as organizer_name_amharic,
          org.business_phone as organizer_phone,
          org.business_email as organizer_email,
          v.name as venue_name,
          v.name_amharic as venue_name_amharic,
          v.full_address as venue_address,
          v.latitude as venue_latitude,
          v.longitude as venue_longitude,
          (SELECT COUNT(*) FROM individual_tickets it 
           WHERE it.event_id = e.id AND it.status = 'paid') as tickets_sold,
          (SELECT SUM(p.amount) FROM payments p 
           WHERE p.event_id = e.id AND p.status = 'completed') as total_revenue
        FROM events e
        LEFT JOIN cities c ON e.city_id = c.id
        LEFT JOIN event_categories cat ON e.category_id = cat.id
        LEFT JOIN organizers org ON e.organizer_id = org.id
        LEFT JOIN venues v ON e.venue_id = v.id
        WHERE e.id = ?
      `, [eventId]);

      return rows[0] || null;
    } catch (error) {
      console.error('EventModel.getEventWithDetails error:', error);
      throw error;
    }
  }

  async getEventsByOrganizer(organizerId, options = {}) {
    try {
      let query = `
        SELECT e.*,
          (SELECT COUNT(*) FROM individual_tickets it 
           WHERE it.event_id = e.id AND it.status = 'paid') as tickets_sold,
          (SELECT SUM(p.amount) FROM payments p 
           WHERE p.event_id = e.id AND p.status = 'completed') as total_revenue
        FROM events e
        WHERE e.organizer_id = ?
      `;

      const values = [organizerId];

      if (options.status) {
        query += ` AND e.status = ?`;
        values.push(options.status);
      }

      query += ` ORDER BY e.created_at DESC`;

      if (options.limit) {
        query += ` LIMIT ?`;
        values.push(options.limit);
      }

      const [rows] = await this.db.execute(query, values);
      return rows;
    } catch (error) {
      console.error('EventModel.getEventsByOrganizer error:', error);
      throw error;
    }
  }

  async checkHolidayConflict(eventDate) {
    try {
      // Check if event falls on Ethiopian holiday
      const [rows] = await this.db.execute(`
        SELECT * FROM ethiopian_holidays 
        WHERE DATE(?) BETWEEN start_date AND end_date
        AND is_active = TRUE
      `, [eventDate]);

      return rows.length > 0 ? rows[0] : null;
    } catch (error) {
      console.error('EventModel.checkHolidayConflict error:', error);
      throw error;
    }
  }

  async updateEventStats(eventId, stats) {
    try {
      const updates = {};
      
      if (stats.tickets_sold !== undefined) {
        updates.tickets_sold = stats.tickets_sold;
      }
      
      if (stats.views !== undefined) {
        updates.views = stats.views;
      }
      
      if (stats.shares !== undefined) {
        updates.shares = stats.shares;
      }
      
      if (stats.saves !== undefined) {
        updates.saves = stats.saves;
      }

      if (Object.keys(updates).length > 0) {
        return await this.update(eventId, updates);
      }
      
      return 0;
    } catch (error) {
      console.error('EventModel.updateEventStats error:', error);
      throw error;
    }
  }

  generateSlug(title) {
    return title
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/\s+/g, '-')
      .replace(/--+/g, '-')
      .trim();
  }
}

export default new EventModel();