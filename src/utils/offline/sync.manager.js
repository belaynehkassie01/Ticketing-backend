// backend/src/utils/offline/sync.manager.js
import logger from '../logger.util.js';

export default {
  // Sync statuses
  status: {
    PENDING: 'pending',
    IN_PROGRESS: 'in_progress',
    COMPLETED: 'completed',
    FAILED: 'failed',
    PARTIAL: 'partial',
    CONFLICT: 'conflict'
  },
  
  // Sync types based on your tables
  syncTypes: {
    CHECKIN: 'checkin',
    TICKET_DOWNLOAD: 'ticket_download',
    EVENT_DATA: 'event_data',
    PROFILE: 'profile',
    PAYMENT: 'payment',
    ALL: 'all'
  },
  
  // Sync queue for offline operations
  syncQueue: new Map(),
  
  // Initialize sync manager
  init: function() {
    logger.info('Sync Manager initialized', {
      module: 'sync_manager',
      action: 'init'
    });
    
    // Load pending syncs from database
    this.loadPendingSyncs();
    
    // Start sync processor
    this.startSyncProcessor();
    
    return this;
  },
  
  // Load pending syncs from database
  loadPendingSyncs: async function() {
    try {
      // This would query your offline_sync_logs table
      // For now, we'll use a mock implementation
      logger.info('Loading pending syncs from database', {
        module: 'sync_manager',
        action: 'load_pending_syncs'
      });
      
      // In production, this would be:
      // const pendingSyncs = await db.query(`
      //   SELECT * FROM offline_sync_logs 
      //   WHERE status IN ('pending', 'failed')
      //   AND retry_count < 3
      //   ORDER BY created_at ASC
      // `);
      
      return [];
    } catch (error) {
      logger.error('Failed to load pending syncs', {
        module: 'sync_manager',
        error: error.message,
        action: 'load_pending_syncs'
      });
      return [];
    }
  },
  
  // Start sync processor
  startSyncProcessor: function() {
    // Process sync queue every 30 seconds
    setInterval(() => {
      this.processSyncQueue();
    }, 30000);
    
    logger.info('Sync processor started', {
      module: 'sync_manager',
      interval: '30s',
      action: 'start_processor'
    });
  },
  
  // Add sync job to queue
  addToQueue: function(syncJob) {
    const jobId = this.generateJobId();
    
    const job = {
      id: jobId,
      ...syncJob,
      status: this.status.PENDING,
      createdAt: new Date().toISOString(),
      retryCount: 0,
      lastAttempt: null,
      nextRetry: new Date().toISOString()
    };
    
    this.syncQueue.set(jobId, job);
    
    logger.info('Sync job added to queue', {
      module: 'sync_manager',
      jobId,
      type: syncJob.type,
      deviceId: syncJob.deviceId,
      action: 'add_to_queue'
    });
    
    return jobId;
  },
  
  // Generate unique job ID
  generateJobId: function() {
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 9);
    return `SYNC-${timestamp}-${random}`;
  },
  
  // Process sync queue
  processSyncQueue: async function() {
    const pendingJobs = Array.from(this.syncQueue.values())
      .filter(job => job.status === this.status.PENDING)
      .sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    
    if (pendingJobs.length === 0) {
      return;
    }
    
    logger.debug('Processing sync queue', {
      module: 'sync_manager',
      pendingJobs: pendingJobs.length,
      action: 'process_queue'
    });
    
    // Process jobs with concurrency limit
    const concurrentLimit = 3;
    const processingJobs = [];
    
    for (let i = 0; i < Math.min(concurrentLimit, pendingJobs.length); i++) {
      processingJobs.push(this.processJob(pendingJobs[i]));
    }
    
    await Promise.all(processingJobs);
  },
  
  // Process individual sync job
  processJob: async function(job) {
    try {
      // Update job status
      job.status = this.status.IN_PROGRESS;
      job.lastAttempt = new Date().toISOString();
      this.syncQueue.set(job.id, job);
      
      logger.info('Processing sync job', {
        module: 'sync_manager',
        jobId: job.id,
        type: job.type,
        deviceId: job.deviceId,
        action: 'process_job'
      });
      
      // Process based on sync type
      let result;
      switch (job.type) {
        case this.syncTypes.CHECKIN:
          result = await this.processCheckinSync(job);
          break;
        case this.syncTypes.TICKET_DOWNLOAD:
          result = await this.processTicketDownloadSync(job);
          break;
        case this.syncTypes.EVENT_DATA:
          result = await this.processEventDataSync(job);
          break;
        case this.syncTypes.PROFILE:
          result = await this.processProfileSync(job);
          break;
        case this.syncTypes.ALL:
          result = await this.processFullSync(job);
          break;
        default:
          throw new Error(`Unknown sync type: ${job.type}`);
      }
      
      // Mark job as completed
      job.status = this.status.COMPLETED;
      job.completedAt = new Date().toISOString();
      job.result = result;
      this.syncQueue.set(job.id, job);
      
      // Log to database (offline_sync_logs table)
      await this.logSyncToDatabase(job, result);
      
      logger.info('Sync job completed', {
        module: 'sync_manager',
        jobId: job.id,
        type: job.type,
        records: result.recordsProcessed,
        action: 'job_completed'
      });
      
    } catch (error) {
      await this.handleJobError(job, error);
    }
  },
  
  // Process checkin sync (from offline checkins)
  processCheckinSync: async function(job) {
    const { deviceId, data } = job;
    
    logger.info('Processing checkin sync', {
      module: 'sync_manager',
      jobId: job.id,
      deviceId,
      checkinsCount: data?.checkins?.length || 0,
      action: 'process_checkin_sync'
    });
    
    // Process each checkin record
    const processed = [];
    const failed = [];
    
    for (const checkin of data.checkins || []) {
      try {
        // Validate checkin data
        this.validateCheckinData(checkin);
        
        // Create checkin log in database
        const result = await this.saveCheckinToDatabase(checkin);
        
        processed.push({
          ticketId: checkin.ticketId,
          checkinId: result.id,
          timestamp: checkin.timestamp
        });
      } catch (error) {
        failed.push({
          ticketId: checkin.ticketId,
          error: error.message,
          timestamp: checkin.timestamp
        });
      }
    }
    
    return {
      type: this.syncTypes.CHECKIN,
      recordsProcessed: processed.length,
      recordsFailed: failed.length,
      processed,
      failed,
      deviceId
    };
  },
  
  // Process ticket download sync
  processTicketDownloadSync: async function(job) {
    const { userId, deviceId, data } = job;
    
    logger.info('Processing ticket download sync', {
      module: 'sync_manager',
      jobId: job.id,
      userId,
      deviceId,
      action: 'process_ticket_sync'
    });
    
    // Get tickets for user
    const tickets = await this.getUserTickets(userId);
    
    return {
      type: this.syncTypes.TICKET_DOWNLOAD,
      recordsProcessed: tickets.length,
      tickets,
      lastSync: new Date().toISOString(),
      userId,
      deviceId
    };
  },
  
  // Process event data sync
  processEventDataSync: async function(job) {
    const { deviceId, data } = job;
    const { cityId, categories, dateRange } = data || {};
    
    logger.info('Processing event data sync', {
      module: 'sync_manager',
      jobId: job.id,
      deviceId,
      cityId,
      action: 'process_event_sync'
    });
    
    // Get events based on filters
    const events = await this.getEventsForSync(cityId, categories, dateRange);
    
    return {
      type: this.syncTypes.EVENT_DATA,
      recordsProcessed: events.length,
      events,
      lastSync: new Date().toISOString(),
      deviceId
    };
  },
  
  // Process profile sync
  processProfileSync: async function(job) {
    const { userId, deviceId, data } = job;
    
    logger.info('Processing profile sync', {
      module: 'sync_manager',
      jobId: job.id,
      userId,
      deviceId,
      action: 'process_profile_sync'
    });
    
    // Get user profile
    const profile = await this.getUserProfile(userId);
    
    // Get user tickets
    const tickets = await this.getUserTickets(userId);
    
    return {
      type: this.syncTypes.PROFILE,
      profile,
      tickets: tickets.length,
      lastSync: new Date().toISOString(),
      userId,
      deviceId
    };
  },
  
  // Process full sync (all data)
  processFullSync: async function(job) {
    const { userId, deviceId } = job;
    
    logger.info('Processing full sync', {
      module: 'sync_manager',
      jobId: job.id,
      userId,
      deviceId,
      action: 'process_full_sync'
    });
    
    // Get profile
    const profile = await this.getUserProfile(userId);
    
    // Get tickets
    const tickets = await this.getUserTickets(userId);
    
    // Get events (based on user's city)
    const events = await this.getEventsForSync(profile.cityId);
    
    return {
      type: this.syncTypes.ALL,
      profile,
      tickets: tickets.length,
      events: events.length,
      lastSync: new Date().toISOString(),
      userId,
      deviceId
    };
  },
  
  // Handle job error
  handleJobError: async function(job, error) {
    job.retryCount++;
    job.lastError = error.message;
    job.lastAttempt = new Date().toISOString();
    
    if (job.retryCount >= 3) {
      // Max retries reached, mark as failed
      job.status = this.status.FAILED;
      job.failedAt = new Date().toISOString();
      
      logger.error('Sync job failed after max retries', {
        module: 'sync_manager',
        jobId: job.id,
        type: job.type,
        retryCount: job.retryCount,
        error: error.message,
        action: 'job_failed'
      });
    } else {
      // Schedule retry with exponential backoff
      const backoffDelay = Math.pow(2, job.retryCount) * 30000; // 30s, 1m, 2m
      job.status = this.status.PENDING;
      job.nextRetry = new Date(Date.now() + backoffDelay).toISOString();
      
      logger.warning('Sync job scheduled for retry', {
        module: 'sync_manager',
        jobId: job.id,
        type: job.type,
        retryCount: job.retryCount,
        nextRetry: job.nextRetry,
        error: error.message,
        action: 'job_retry_scheduled'
      });
    }
    
    this.syncQueue.set(job.id, job);
    
    // Log error to database
    await this.logSyncErrorToDatabase(job, error);
  },
  
  // Validate checkin data
  validateCheckinData: function(checkin) {
    const requiredFields = ['ticketId', 'eventId', 'organizerId', 'timestamp'];
    const missingFields = requiredFields.filter(field => !checkin[field]);
    
    if (missingFields.length > 0) {
      throw new Error(`Missing required fields: ${missingFields.join(', ')}`);
    }
    
    // Validate ticket ID format
    if (!checkin.ticketId.match(/^TKT-[A-Z0-9]{8,12}$/)) {
      throw new Error('Invalid ticket ID format');
    }
    
    // Validate timestamp (not in future)
    const checkinTime = new Date(checkin.timestamp);
    const now = new Date();
    
    if (checkinTime > now) {
      throw new Error('Checkin timestamp cannot be in the future');
    }
    
    // Validate coordinates if present
    if (checkin.latitude && checkin.longitude) {
      if (Math.abs(checkin.latitude) > 90 || Math.abs(checkin.longitude) > 180) {
        throw new Error('Invalid coordinates');
      }
    }
    
    return true;
  },
  
  // Save checkin to database (mocked)
  saveCheckinToDatabase: async function(checkin) {
    // In production, this would insert into checkin_logs table
    // Example query:
    /*
    const [result] = await db.query(`
      INSERT INTO checkin_logs 
      (ticket_id, event_id, organizer_id, checked_in_by, checkin_method, 
       checkin_time, device_id, latitude, longitude, is_online, sync_status)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      checkin.ticketId,
      checkin.eventId,
      checkin.organizerId,
      checkin.checkedInBy || 'offline_device',
      checkin.checkinMethod || 'offline_sync',
      checkin.timestamp,
      checkin.deviceId,
      checkin.latitude,
      checkin.longitude,
      false, // Was offline
      'synced'
    ]);
    */
    
    // Mock implementation
    return {
      id: `CHK-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      ...checkin,
      syncedAt: new Date().toISOString()
    };
  },
  
  // Get user tickets (mocked)
  getUserTickets: async function(userId) {
    // In production, query individual_tickets table
    // This is a mock implementation
    return [
      {
        id: 'TKT-001',
        eventId: 'EVT-001',
        eventName: 'Concert in Addis',
        status: 'paid',
        purchaseDate: '2024-01-15'
      }
    ];
  },
  
  // Get events for sync (mocked)
  getEventsForSync: async function(cityId, categories, dateRange) {
    // In production, query events table with filters
    // This is a mock implementation
    return [
      {
        id: 'EVT-001',
        title: 'Concert in Addis',
        cityId: cityId || 1,
        startDate: '2024-02-01',
        endDate: '2024-02-01'
      }
    ];
  },
  
  // Get user profile (mocked)
  getUserProfile: async function(userId) {
    // In production, query users table
    // This is a mock implementation
    return {
      id: userId,
      name: 'John Doe',
      cityId: 1,
      phone: '+251911223344'
    };
  },
  
  // Log sync to database
  logSyncToDatabase: async function(job, result) {
    // In production, insert into offline_sync_logs table
    /*
    await db.query(`
      INSERT INTO offline_sync_logs 
      (device_id, user_id, device_type, app_version, sync_type, 
       records_count, data_size_kb, status, started_at, completed_at, 
       duration_ms, connection_type, network_speed_kbps, city_id)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      job.deviceId,
      job.userId,
      job.deviceType,
      job.appVersion,
      job.type,
      result.recordsProcessed,
      this.calculateDataSize(result),
      this.status.COMPLETED,
      job.createdAt,
      new Date().toISOString(),
      Date.now() - new Date(job.createdAt).getTime(),
      job.connectionType,
      job.networkSpeed,
      job.cityId
    ]);
    */
    
    logger.info('Sync logged to database', {
      module: 'sync_manager',
      jobId: job.id,
      type: job.type,
      records: result.recordsProcessed,
      action: 'log_to_database'
    });
  },
  
  // Log sync error to database
  logSyncErrorToDatabase: async function(job, error) {
    // In production, update offline_sync_logs table
    /*
    await db.query(`
      UPDATE offline_sync_logs 
      SET status = ?, error_message = ?, retry_count = ?, 
          updated_at = CURRENT_TIMESTAMP
      WHERE device_id = ? AND sync_type = ? AND status = 'in_progress'
    `, [
      this.status.FAILED,
      error.message,
      job.retryCount,
      job.deviceId,
      job.type
    ]);
    */
    
    logger.error('Sync error logged to database', {
      module: 'sync_manager',
      jobId: job.id,
      type: job.type,
      error: error.message,
      retryCount: job.retryCount,
      action: 'log_error_to_database'
    });
  },
  
  // Calculate data size in KB
  calculateDataSize: function(data) {
    const jsonString = JSON.stringify(data);
    const sizeInBytes = Buffer.byteLength(jsonString, 'utf8');
    return Math.ceil(sizeInBytes / 1024);
  },
  
  // Get sync status
  getSyncStatus: function(jobId) {
    const job = this.syncQueue.get(jobId);
    if (!job) {
      return {
        found: false,
        message: 'Job not found'
      };
    }
    
    return {
      found: true,
      jobId: job.id,
      type: job.type,
      status: job.status,
      createdAt: job.createdAt,
      lastAttempt: job.lastAttempt,
      retryCount: job.retryCount,
      nextRetry: job.nextRetry,
      result: job.result,
      error: job.lastError
    };
  },
  
  // Get queue statistics
  getQueueStats: function() {
    const jobs = Array.from(this.syncQueue.values());
    
    return {
      totalJobs: jobs.length,
      pending: jobs.filter(j => j.status === this.status.PENDING).length,
      inProgress: jobs.filter(j => j.status === this.status.IN_PROGRESS).length,
      completed: jobs.filter(j => j.status === this.status.COMPLETED).length,
      failed: jobs.filter(j => j.status === this.status.FAILED).length,
      byType: this.groupByType(jobs),
      oldestPending: this.getOldestPending(jobs)
    };
  },
  
  // Group jobs by type
  groupByType: function(jobs) {
    const groups = {};
    jobs.forEach(job => {
      if (!groups[job.type]) {
        groups[job.type] = 0;
      }
      groups[job.type]++;
    });
    return groups;
  },
  
  // Get oldest pending job
  getOldestPending: function(jobs) {
    const pending = jobs.filter(j => j.status === this.status.PENDING);
    if (pending.length === 0) return null;
    
    return pending.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt))[0];
  },
  
  // Clean up completed jobs (older than 7 days)
  cleanupOldJobs: function() {
    const cutoffDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000); // 7 days ago
    
    Array.from(this.syncQueue.entries()).forEach(([jobId, job]) => {
      if (job.status === this.status.COMPLETED && new Date(job.completedAt) < cutoffDate) {
        this.syncQueue.delete(jobId);
      }
    });
    
    logger.info('Cleaned up old sync jobs', {
      module: 'sync_manager',
      cutoffDate: cutoffDate.toISOString(),
      action: 'cleanup_jobs'
    });
  },
  
  // Force sync for device
  forceSync: function(deviceId, syncType = this.syncTypes.ALL) {
    const job = {
      type: syncType,
      deviceId,
      priority: 'high',
      force: true
    };
    
    const jobId = this.addToQueue(job);
    
    logger.info('Force sync initiated', {
      module: 'sync_manager',
      jobId,
      deviceId,
      syncType,
      action: 'force_sync'
    });
    
    return jobId;
  },
  
  // Reset failed syncs for device
  resetFailedSyncs: function(deviceId) {
    Array.from(this.syncQueue.values())
      .filter(job => job.deviceId === deviceId && job.status === this.status.FAILED)
      .forEach(job => {
        job.status = this.status.PENDING;
        job.retryCount = 0;
        job.lastError = null;
        job.nextRetry = new Date().toISOString();
        this.syncQueue.set(job.id, job);
      });
    
    logger.info('Reset failed syncs for device', {
      module: 'sync_manager',
      deviceId,
      action: 'reset_failed_syncs'
    });
  }
};