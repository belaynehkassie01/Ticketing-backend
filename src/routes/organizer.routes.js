// File: backend/src/routes/organizer.routes.js
import express from 'express';
import { organizerController } from '../controllers/organizer/organizer.controller.js';
import { authenticate, authorize } from '../middlewares/auth.middleware.js';

const router = express.Router();

// Apply to become organizer
router.post('/apply', 
  authenticate, 
  authorize('customer'), 
  organizerController.applyToBeOrganizer
);

// Get my applications
router.get('/applications', 
  authenticate, 
  organizerController.getMyApplications
);

// Get application details
router.get('/applications/:applicationId', 
  authenticate, 
  organizerController.getApplicationDetails
);

// Get organizer profile
router.get('/profile', 
  authenticate, 
  authorize('organizer', 'admin'), 
  organizerController.getOrganizerProfile
);

// Update organizer profile
router.put('/profile', 
  authenticate, 
  authorize('organizer', 'admin'), 
  organizerController.updateOrganizerProfile
);

export default router;