// File: backend/src/routes/event.routes.js
import express from 'express';
import { eventController } from '../controllers/event/event.controller.js';
import { ticketController } from '../controllers/ticket/ticket.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Public routes
router.get('/', eventController.listEvents);
router.get('/:eventId', eventController.getEventDetails);
router.get('/:eventId/tickets', ticketController.getEventTicketTypes);

// Organizer routes
router.post('/', 
  authenticate, 
  authorize('organizer', 'admin'), 
  eventController.createEvent
);

router.put('/:eventId/publish', 
  authenticate, 
  authorize('organizer', 'admin'), 
  eventController.publishEvent
);

router.get('/organizer/my-events', 
  authenticate, 
  authorize('organizer', 'admin'), 
  eventController.getMyEvents
);

router.put('/:eventId', 
  authenticate, 
  authorize('organizer', 'admin'), 
  eventController.updateEvent
);

// Ticket management
router.post('/:eventId/tickets', 
  authenticate, 
  authorize('organizer', 'admin'), 
  ticketController.createTicketType
);

router.put('/tickets/:ticketTypeId', 
  authenticate, 
  authorize('organizer', 'admin'), 
  ticketController.updateTicketType
);

// Ticket availability check (public)
router.post('/tickets/:ticketTypeId/check', 
  ticketController.checkAvailability
);

export default router;