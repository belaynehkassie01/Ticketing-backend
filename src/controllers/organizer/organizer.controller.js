// File: backend/src/controllers/organizer/organizer.controller.js
import organizerApplicationModel from '../../database/models/organizer_application.js';
import organizerModel from '../../database/models/organizer.js';
import userModel from '../../database/models/user.js';

export const organizerController = {
  // Apply to become an organizer
  async applyToBeOrganizer(req, res) {
    try {
      const userId = req.user.id;
      const applicationData = req.body;

      // Check if user already has a pending application
      const existingApplications = await organizerApplicationModel.getApplicationsByUserId(userId);
      const pendingApp = existingApplications.find(app => app.status === 'pending');
      
      if (pendingApp) {
        return res.status(400).json({
          success: false,
          message: 'You already have a pending application'
        });
      }

      // Check if user is already an organizer
      const existingOrganizer = await organizerModel.getOrganizerByUserId(userId);
      if (existingOrganizer) {
        return res.status(400).json({
          success: false,
          message: 'You are already an organizer'
        });
      }

      // Required fields validation
      if (!applicationData.business_name || !applicationData.business_type) {
        return res.status(400).json({
          success: false,
          message: 'Business name and type are required'
        });
      }

      // Create application
      const applicationId = await organizerApplicationModel.createApplication(userId, applicationData);
      
      // Update user's organizer status
      await userModel.applyForOrganizer(userId);

      // Get the created application
      const application = await organizerApplicationModel.findById(applicationId);

      res.status(201).json({
        success: true,
        message: 'Application submitted successfully',
        data: {
          application,
          next_steps: 'Your application will be reviewed within 2-3 business days'
        }
      });

    } catch (error) {
      console.error('Apply to be organizer error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to submit application',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get my applications
  async getMyApplications(req, res) {
    try {
      const userId = req.user.id;
      
      const applications = await organizerApplicationModel.getApplicationsByUserId(userId);

      res.json({
        success: true,
        data: {
          applications,
          count: applications.length
        }
      });

    } catch (error) {
      console.error('Get my applications error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get applications'
      });
    }
  },

  // Get application details
  async getApplicationDetails(req, res) {
    try {
      const { applicationId } = req.params;
      const userId = req.user.id;

      const application = await organizerApplicationModel.getApplicationWithUser(applicationId);

      if (!application) {
        return res.status(404).json({
          success: false,
          message: 'Application not found'
        });
      }

      // Check if user owns this application (unless admin)
      if (application.user_id !== userId && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'You do not have permission to view this application'
        });
      }

      res.json({
        success: true,
        data: { application }
      });

    } catch (error) {
      console.error('Get application details error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get application details'
      });
    }
  },

  // Get organizer profile (for organizers)
  async getOrganizerProfile(req, res) {
    try {
      const userId = req.user.id;

      const organizer = await organizerModel.getOrganizerByUserId(userId);

      if (!organizer) {
        return res.status(404).json({
          success: false,
          message: 'Organizer profile not found'
        });
      }

      // Get organizer stats
      const organizerWithStats = await organizerModel.getOrganizerWithUser(organizer.id);

      res.json({
        success: true,
        data: {
          organizer: organizerWithStats
        }
      });

    } catch (error) {
      console.error('Get organizer profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get organizer profile'
      });
    }
  },

  // Update organizer profile
  async updateOrganizerProfile(req, res) {
    try {
      const userId = req.user.id;
      const updates = req.body;

      const organizer = await organizerModel.getOrganizerByUserId(userId);

      if (!organizer) {
        return res.status(404).json({
          success: false,
          message: 'Organizer profile not found'
        });
      }

      // Define allowed updates
      const allowedUpdates = [
        'business_name_amharic',
        'business_phone',
        'business_email',
        'website',
        'sub_city',
        'woreda',
        'house_number',
        'bank_branch'
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

      await organizerModel.update(organizer.id, filteredUpdates);

      const updatedOrganizer = await organizerModel.getOrganizerByUserId(userId);

      res.json({
        success: true,
        message: 'Profile updated successfully',
        data: {
          organizer: updatedOrganizer
        }
      });

    } catch (error) {
      console.error('Update organizer profile error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update profile'
      });
    }
  }
};