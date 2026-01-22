// File: backend/src/routes/admin.routes.js
import express from 'express';
import { adminOrganizerController } from '../controllers/admin/organizer.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Organizer management (admin only)
router.get('/organizers/pending', 
  authenticate, 
  authorize('admin'), 
  adminOrganizerController.getPendingApplications
);

router.put('/organizers/applications/:applicationId/review', 
  authenticate, 
  authorize('admin'), 
  adminOrganizerController.reviewApplication
);

router.get('/organizers', 
  authenticate, 
  authorize('admin'), 
  adminOrganizerController.getAllOrganizers
);

router.get('/organizers/:organizerId', 
  authenticate, 
  authorize('admin'), 
  adminOrganizerController.getOrganizerDetails
);

router.put('/organizers/:organizerId/status', 
  authenticate, 
  authorize('admin'), 
  adminOrganizerController.updateOrganizerStatus
);

export default router;