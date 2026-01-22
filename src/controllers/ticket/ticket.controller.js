// File: backend/src/controllers/event/ticket.controller.js
import ticketTypeModel from '../../database/models/ticket_type.js';
import eventModel from '../../database/models/event.js';

export const ticketController = {
  // Create ticket type for event
  async createTicketType(req, res) {
    try {
      const { eventId } = req.params;
      const organizerId = req.user.organizer_id;
      const ticketData = req.body;

      // Verify event belongs to organizer
      const event = await eventModel.findById(eventId);
      
      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      if (event.organizer_id !== organizerId && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to add tickets to this event'
        });
      }

      // Required fields
      if (!ticketData.name || !ticketData.price || !ticketData.quantity) {
        return res.status(400).json({
          success: false,
          message: 'Name, price, and quantity are required'
        });
      }

      // Validate price
      if (ticketData.price <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Price must be greater than 0'
        });
      }

      // Validate quantity
      if (ticketData.quantity <= 0) {
        return res.status(400).json({
          success: false,
          message: 'Quantity must be greater than 0'
        });
      }

      const ticketTypeId = await ticketTypeModel.createTicketType(eventId, ticketData);

      const ticketType = await ticketTypeModel.findById(ticketTypeId);

      res.status(201).json({
        success: true,
        message: 'Ticket type created successfully',
        data: { ticket_type: ticketType }
      });

    } catch (error) {
      console.error('Create ticket type error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create ticket type',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get ticket types for event
  async getEventTicketTypes(req, res) {
    try {
      const { eventId } = req.params;

      const event = await eventModel.findById(eventId);

      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      // Only show ticket types for published events or to owners
      const includeHidden = event.organizer_id === req.user?.organizer_id || req.user?.role === 'admin';
      
      const ticketTypes = await ticketTypeModel.getTicketTypesForEvent(eventId, includeHidden);

      res.json({
        success: true,
        data: {
          ticket_types: ticketTypes,
          count: ticketTypes.length
        }
      });

    } catch (error) {
      console.error('Get ticket types error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get ticket types'
      });
    }
  },

  // Update ticket type
  async updateTicketType(req, res) {
    try {
      const { ticketTypeId } = req.params;
      const updates = req.body;

      // Get ticket type
      const ticketType = await ticketTypeModel.findById(ticketTypeId);
      
      if (!ticketType) {
        return res.status(404).json({
          success: false,
          message: 'Ticket type not found'
        });
      }

      // Get event to check permissions
      const event = await eventModel.findById(ticketType.event_id);
      
      if (event.organizer_id !== req.user.organizer_id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to update this ticket type'
        });
      }

      // Don't allow updates if tickets are already sold
      if (ticketType.sold_count > 0) {
        return res.status(400).json({
          success: false,
          message: 'Cannot update ticket type after tickets have been sold'
        });
      }

      // Define allowed updates
      const allowedUpdates = [
        'name',
        'name_amharic',
        'description',
        'description_amharic',
        'max_per_user',
        'min_per_user',
        'sales_end',
        'seating_info',
        'benefits',
        'is_hidden'
      ];

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

      // Handle benefits as JSON
      if (filteredUpdates.benefits && Array.isArray(filteredUpdates.benefits)) {
        filteredUpdates.benefits = JSON.stringify(filteredUpdates.benefits);
      }

      await ticketTypeModel.update(ticketTypeId, filteredUpdates);

      const updatedTicketType = await ticketTypeModel.findById(ticketTypeId);

      res.json({
        success: true,
        message: 'Ticket type updated successfully',
        data: { ticket_type: updatedTicketType }
      });

    } catch (error) {
      console.error('Update ticket type error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update ticket type'
      });
    }
  },

  // Check ticket availability
  async checkAvailability(req, res) {
    try {
      const { ticketTypeId } = req.params;
      const { quantity = 1 } = req.body;

      const availability = await ticketTypeModel.checkAvailability(ticketTypeId);

      if (!availability.available) {
        return res.status(400).json({
          success: false,
          message: availability.reason,
          data: availability
        });
      }

      // Check if requested quantity is available
      if (quantity > availability.available_count) {
        return res.status(400).json({
          success: false,
          message: `Only ${availability.available_count} tickets available`,
          data: availability
        });
      }

      // Check max per user
      if (availability.ticket_type.max_per_user && quantity > availability.ticket_type.max_per_user) {
        return res.status(400).json({
          success: false,
          message: `Maximum ${availability.ticket_type.max_per_user} tickets per user`,
          data: availability
        });
      }

      res.json({
        success: true,
        data: {
          ...availability,
          requested_quantity: quantity,
          total_price: availability.ticket_type.price * quantity,
          vat_amount: availability.ticket_type.vat_amount * quantity
        }
      });

    } catch (error) {
      console.error('Check availability error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to check availability'
      });
    }
  }
};