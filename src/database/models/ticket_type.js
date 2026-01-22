// File: backend/src/database/models/ticket_type.js
import { BaseModel } from './BaseModel.js';

export class TicketTypeModel extends BaseModel {
  constructor() {
    super('ticket_types');
  }

  async createTicketType(eventId, ticketData) {
    try {
      // Calculate VAT
      const vatRate = 0.15; // 15% Ethiopian VAT
      const vatIncluded = ticketData.vat_included !== false;
      
      let netPrice, vatAmount;
      
      if (vatIncluded) {
        // Price includes VAT
        netPrice = ticketData.price / (1 + vatRate);
        vatAmount = ticketData.price - netPrice;
      } else {
        // Price excludes VAT
        netPrice = ticketData.price;
        vatAmount = ticketData.price * vatRate;
      }

      const ticketType = {
        event_id: eventId,
        price: ticketData.price,
        vat_included: vatIncluded,
        vat_amount: vatAmount,
        net_price: netPrice,
        quantity: ticketData.quantity,
        sold_count: 0,
        reserved_count: 0,
        max_per_user: ticketData.max_per_user || 5,
        min_per_user: ticketData.min_per_user || 1,
        sales_start: ticketData.sales_start || new Date(),
        sales_end: ticketData.sales_end,
        is_early_bird: ticketData.is_early_bird || false,
        early_bird_end: ticketData.early_bird_end,
        access_level: ticketData.access_level || 'general',
        seating_info: ticketData.seating_info,
        benefits: JSON.stringify(ticketData.benefits || []),
        is_active: true,
        is_hidden: false,
        ...ticketData
      };

      // Remove undefined fields
      Object.keys(ticketType).forEach(key => {
        if (ticketType[key] === undefined) {
          delete ticketType[key];
        }
      });

      const ticketTypeId = await this.create(ticketType);

      // Update event min/max prices
      await this.updateEventPrices(eventId);

      return ticketTypeId;
    } catch (error) {
      console.error('TicketTypeModel.createTicketType error:', error);
      throw error;
    }
  }

  async updateEventPrices(eventId) {
    try {
      const [rows] = await this.db.execute(`
        SELECT 
          MIN(price) as min_price,
          MAX(price) as max_price
        FROM ticket_types 
        WHERE event_id = ? 
        AND is_active = TRUE
        AND is_hidden = FALSE
      `, [eventId]);

      if (rows[0]) {
        await this.db.execute(`
          UPDATE events 
          SET min_price = ?, max_price = ? 
          WHERE id = ?
        `, [rows[0].min_price, rows[0].max_price, eventId]);
      }
    } catch (error) {
      console.error('TicketTypeModel.updateEventPrices error:', error);
      throw error;
    }
  }

  async getTicketTypesForEvent(eventId, includeHidden = false) {
    try {
      let query = `
        SELECT tt.*,
          (tt.quantity - tt.sold_count - tt.reserved_count) as available_count
        FROM ticket_types tt
        WHERE tt.event_id = ?
        AND tt.is_active = TRUE
      `;

      const values = [eventId];

      if (!includeHidden) {
        query += ` AND tt.is_hidden = FALSE`;
      }

      query += ` ORDER BY tt.price ASC, tt.access_level`;

      const [rows] = await this.db.execute(query, values);
      return rows;
    } catch (error) {
      console.error('TicketTypeModel.getTicketTypesForEvent error:', error);
      throw error;
    }
  }

  async reserveTickets(ticketTypeId, quantity) {
    try {
      return await this.withTransaction(async (connection) => {
        // Check availability with row lock
        const [rows] = await connection.execute(`
          SELECT * FROM ticket_types 
          WHERE id = ? 
          FOR UPDATE
        `, [ticketTypeId]);

        const ticketType = rows[0];
        
        if (!ticketType) {
          throw new Error('Ticket type not found');
        }

        const available = ticketType.quantity - ticketType.sold_count - ticketType.reserved_count;
        
        if (available < quantity) {
          throw new Error(`Only ${available} tickets available`);
        }

        // Update reserved count
        await connection.execute(`
          UPDATE ticket_types 
          SET reserved_count = reserved_count + ? 
          WHERE id = ?
        `, [quantity, ticketTypeId]);

        return ticketType;
      });
    } catch (error) {
      console.error('TicketTypeModel.reserveTickets error:', error);
      throw error;
    }
  }

  async releaseReservation(ticketTypeId, quantity) {
    try {
      const [result] = await this.db.execute(`
        UPDATE ticket_types 
        SET reserved_count = GREATEST(0, reserved_count - ?) 
        WHERE id = ?
      `, [quantity, ticketTypeId]);

      return result.affectedRows;
    } catch (error) {
      console.error('TicketTypeModel.releaseReservation error:', error);
      throw error;
    }
  }

  async markAsSold(ticketTypeId, quantity) {
    try {
      return await this.withTransaction(async (connection) => {
        // Reduce reserved count and increase sold count
        const [result] = await connection.execute(`
          UPDATE ticket_types 
          SET 
            reserved_count = GREATEST(0, reserved_count - ?),
            sold_count = sold_count + ?
          WHERE id = ?
        `, [quantity, quantity, ticketTypeId]);

        // Update revenue
        const [ticketType] = await connection.execute(
          'SELECT price FROM ticket_types WHERE id = ?',
          [ticketTypeId]
        );

        if (ticketType[0]) {
          const revenueIncrease = ticketType[0].price * quantity;
          await connection.execute(`
            UPDATE ticket_types 
            SET revenue = revenue + ? 
            WHERE id = ?
          `, [revenueIncrease, ticketTypeId]);
        }

        return result.affectedRows;
      });
    } catch (error) {
      console.error('TicketTypeModel.markAsSold error:', error);
      throw error;
    }
  }

  async checkAvailability(ticketTypeId) {
    try {
      const [rows] = await this.db.execute(`
        SELECT 
          id,
          name,
          price,
          quantity,
          sold_count,
          reserved_count,
          (quantity - sold_count - reserved_count) as available_count,
          sales_start,
          sales_end,
          is_active
        FROM ticket_types 
        WHERE id = ?
      `, [ticketTypeId]);

      const ticketType = rows[0];
      
      if (!ticketType) {
        return { available: false, reason: 'Ticket type not found' };
      }

      if (!ticketType.is_active) {
        return { available: false, reason: 'Ticket type is not active' };
      }

      const now = new Date();
      
      if (ticketType.sales_start && now < new Date(ticketType.sales_start)) {
        return { available: false, reason: 'Sales have not started yet' };
      }

      if (ticketType.sales_end && now > new Date(ticketType.sales_end)) {
        return { available: false, reason: 'Sales have ended' };
      }

      if (ticketType.available_count <= 0) {
        return { available: false, reason: 'Sold out' };
      }

      return { 
        available: true, 
        available_count: ticketType.available_count,
        ticket_type: ticketType 
      };
    } catch (error) {
      console.error('TicketTypeModel.checkAvailability error:', error);
      throw error;
    }
  }
}

export default new TicketTypeModel();