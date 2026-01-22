// File: backend/src/controllers/admin/organizer.controller.js
import organizerApplicationModel from '../../database/models/organizer_application.js';
import organizerModel from '../../database/models/organizer.js';
import userModel from '../../database/models/user.js';

export const adminOrganizerController = {
  // Get all pending applications
  async getPendingApplications(req, res) {
    try {
      const applications = await organizerApplicationModel.getApplicationsByStatus('pending');

      // Get user details for each application
      const applicationsWithUsers = await Promise.all(
        applications.map(async (app) => {
          const user = await userModel.findById(app.user_id);
          return {
            ...app,
            user: {
              phone: user?.phone,
              full_name: user?.full_name,
              created_at: user?.created_at
            }
          };
        })
      );

      res.json({
        success: true,
        data: {
          applications: applicationsWithUsers,
          count: applicationsWithUsers.length
        }
      });

    } catch (error) {
      console.error('Get pending applications error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get pending applications'
      });
    }
  },

  // Review application
  async reviewApplication(req, res) {
    try {
      const { applicationId } = req.params;
      const { status, review_notes } = req.body;
      const adminId = req.user.id;

      // Validate status
      const validStatuses = ['approved', 'rejected', 'needs_info'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid status. Must be: approved, rejected, or needs_info'
        });
      }

      // Get application
      const application = await organizerApplicationModel.getApplicationWithUser(applicationId);
      
      if (!application) {
        return res.status(404).json({
          success: false,
          message: 'Application not found'
        });
      }

      if (application.status !== 'pending') {
        return res.status(400).json({
          success: false,
          message: `Application is already ${application.status}`
        });
      }

      // Update application status
      await organizerApplicationModel.updateApplicationStatus(
        applicationId, 
        status, 
        review_notes, 
        adminId
      );

      // If approved, create organizer profile and update user
      if (status === 'approved') {
        // Create organizer
        const organizerData = {
          business_name: application.business_name,
          business_type: application.business_type,
          business_phone: application.contact_phone,
          business_email: application.contact_email,
          bank_name: application.bank_name,
          bank_account: application.bank_account,
          account_holder_name: application.account_holder_name
        };

        const organizerId = await organizerModel.createOrganizer(application.user_id, organizerData);
        
        // Update user to organizer
        await userModel.approveOrganizer(application.user_id, organizerId);
      } else if (status === 'rejected') {
        // Update user status to rejected
        await userModel.rejectOrganizer(application.user_id);
      }

      // Get updated application
      const updatedApplication = await organizerApplicationModel.getApplicationWithUser(applicationId);

      res.json({
        success: true,
        message: `Application ${status} successfully`,
        data: {
          application: updatedApplication
        }
      });

    } catch (error) {
      console.error('Review application error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to review application',
        error: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  },

  // Get all organizers
  async getAllOrganizers(req, res) {
    try {
      const organizers = await organizerModel.getActiveOrganizers();

      // Get user details for each organizer
      const organizersWithUsers = await Promise.all(
        organizers.map(async (org) => {
          const user = await userModel.findById(org.user_id);
          return {
            ...org,
            user: {
              phone: user?.phone,
              full_name: user?.full_name,
              preferred_language: user?.preferred_language
            }
          };
        })
      );

      res.json({
        success: true,
        data: {
          organizers: organizersWithUsers,
          count: organizersWithUsers.length
        }
      });

    } catch (error) {
      console.error('Get all organizers error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get organizers'
      });
    }
  },

  // Get organizer details
  async getOrganizerDetails(req, res) {
    try {
      const { organizerId } = req.params;

      const organizer = await organizerModel.getOrganizerWithUser(organizerId);

      if (!organizer) {
        return res.status(404).json({
          success: false,
          message: 'Organizer not found'
        });
      }

      res.json({
        success: true,
        data: { organizer }
      });

    } catch (error) {
      console.error('Get organizer details error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get organizer details'
      });
    }
  },

  // Update organizer status (suspend/activate)
  async updateOrganizerStatus(req, res) {
    try {
      const { organizerId } = req.params;
      const { status } = req.body;

      const validStatuses = ['approved', 'suspended'];
      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          success: false,
          message: 'Invalid status. Must be: approved or suspended'
        });
      }

      const organizer = await organizerModel.findById(organizerId);

      if (!organizer) {
        return res.status(404).json({
          success: false,
          message: 'Organizer not found'
        });
      }

      await organizerModel.update(organizerId, { status });

      const updatedOrganizer = await organizerModel.getOrganizerWithUser(organizerId);

      res.json({
        success: true,
        message: `Organizer ${status} successfully`,
        data: {
          organizer: updatedOrganizer
        }
      });

    } catch (error) {
      console.error('Update organizer status error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update organizer status'
      });
    }
  }
};