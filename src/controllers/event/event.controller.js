// File: backend/src/controllers/event/event.controller.js
import eventModel from '../../database/models/event.js';
import ticketTypeModel from '../../database/models/ticket_type.js';
import organizerModel from '../../database/models/organizer.js';
import { isEthiopianHoliday } from '../../utils/ethiopian/calendar.util.js';

export const eventController = {
  // Create new event (organizer only)
  async createEvent(req, res) {
    try {
      const organizerId = req.user.organizer_id;
      
      if (!organizerId) {
        return res.status(403).json({
          success: false,
          message: 'You must be an organizer to create events'
        });
      }

      const eventData = req.body;

      // Required fields validation
      const requiredFields = ['title', 'category_id', 'city_id', 'start_date', 'end_date'];
      for (const field of requiredFields) {
        if (!eventData[field]) {
          return res.status(400).json({
            success: false,
            message: `${field} is required`
          });
        }
      }

      // Check if event is on Ethiopian holiday
      const holidayConflict = await eventModel.checkHolidayConflict(eventData.start_date);
      
      if (holidayConflict) {
        return res.status(400).json({
          success: false,
          message: `Event cannot be scheduled on Ethiopian holiday: ${holidayConflict.name}`,
          holiday: holidayConflict
        });
      }

      // Create event
      const eventId = await eventModel.createEvent(organizerId, eventData);

      const event = await eventModel.getEventWithDetails(eventId);

      res.status(201).json({
        success: true,
        message: 'Event created successfully (in draft mode)',
        data: {
          event,
          next_steps: 'Add ticket types and publish when ready'
        }
      });

    } catch (error) {
      console.error('Create event error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to create event',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Publish event
  async publishEvent(req, res) {
    try {
      const { eventId } = req.params;
      const organizerId = req.user.organizer_id;

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
          message: 'You do not have permission to publish this event'
        });
      }

      // Check if event has ticket types
      const ticketTypes = await ticketTypeModel.getTicketTypesForEvent(eventId);
      
      if (ticketTypes.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Event must have at least one ticket type before publishing'
        });
      }

      // Publish event
      await eventModel.publishEvent(eventId);

      const updatedEvent = await eventModel.getEventWithDetails(eventId);

      res.json({
        success: true,
        message: 'Event published successfully',
        data: { event: updatedEvent }
      });

    } catch (error) {
      console.error('Publish event error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to publish event'
      });
    }
  },

  // Get event details
  async getEventDetails(req, res) {
    try {
      const { eventId } = req.params;

      const event = await eventModel.getEventWithDetails(eventId);

      if (!event) {
        return res.status(404).json({
          success: false,
          message: 'Event not found'
        });
      }

      // Only show published events to non-owners
      if (event.status !== 'published' && 
          event.organizer_id !== req.user?.organizer_id && 
          req.user?.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Event is not published'
        });
      }

      // Get ticket types
      const ticketTypes = await ticketTypeModel.getTicketTypesForEvent(eventId);

      res.json({
        success: true,
        data: {
          event,
          ticket_types: ticketTypes,
          ticket_count: ticketTypes.length
        }
      });

    } catch (error) {
      console.error('Get event details error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get event details'
      });
    }
  },

  // List events with filters
  async listEvents(req, res) {
    try {
      const filters = {
        city_id: req.query.city_id,
        category_id: req.query.category_id,
        start_date_from: req.query.start_date_from,
        start_date_to: req.query.start_date_to,
        search: req.query.search,
        sort_by: req.query.sort_by || 'date_asc'
      };

      const options = {
        limit: parseInt(req.query.limit) || 20,
        offset: parseInt(req.query.offset) || 0
      };

      const events = await eventModel.getPublishedEvents(filters, options);

      // Get total count for pagination
      const [countRows] = await eventModel.db.execute(`
        SELECT COUNT(*) as total 
        FROM events 
        WHERE status = 'published' 
        AND visibility = 'public'
        AND start_date > NOW()
      `);

      res.json({
        success: true,
        data: {
          events,
          pagination: {
            total: countRows[0].total,
            limit: options.limit,
            offset: options.offset,
            has_more: (options.offset + options.limit) < countRows[0].total
          }
        }
      });

    } catch (error) {
      console.error('List events error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to list events'
      });
    }
  },

  // Get organizer's events
  async getMyEvents(req, res) {
    try {
      const organizerId = req.user.organizer_id;
      
      if (!organizerId) {
        return res.status(403).json({
          success: false,
          message: 'You must be an organizer to view your events'
        });
      }

      const events = await eventModel.getEventsByOrganizer(organizerId, {
        status: req.query.status,
        limit: parseInt(req.query.limit) || 50
      });

      res.json({
        success: true,
        data: {
          events,
          count: events.length
        }
      });

    } catch (error) {
      console.error('Get my events error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get your events'
      });
    }
  },

  // Update event
  async updateEvent(req, res) {
    try {
      const { eventId } = req.params;
      const organizerId = req.user.organizer_id;
      const updates = req.body;

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
          message: 'You do not have permission to update this event'
        });
      }

      // Don't allow updates to published events (except admins)
      if (event.status === 'published' && req.user.role !== 'admin') {
        return res.status(400).json({
          success: false,
          message: 'Cannot update published events. Please contact admin.'
        });
      }

      // Define allowed updates
      const allowedUpdates = [
        'title',
        'title_amharic',
        'description',
        'description_amharic',
        'short_description',
        'category_id',
        'city_id',
        'venue_id',
        'venue_custom',
        'address_details',
        'start_date',
        'end_date',
        'cover_image',
        'gallery_images',
        'age_restriction',
        'is_charity',
        'charity_org'
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

      await eventModel.update(eventId, filteredUpdates);

      const updatedEvent = await eventModel.getEventWithDetails(eventId);

      res.json({
        success: true,
        message: 'Event updated successfully',
        data: { event: updatedEvent }
      });

    } catch (error) {
      console.error('Update event error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update event'
      });
    }
  }
};