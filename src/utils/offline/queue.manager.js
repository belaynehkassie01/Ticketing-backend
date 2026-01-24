// backend/src/utils/offline/queue.manager.js
import crypto from 'crypto';

export default {
  // Queue configuration
  config: {
    maxQueueSize: 1000,
    retryAttempts: 3,
    retryDelay: 5000, // 5 seconds
    cleanupAge: 7 * 24 * 60 * 60 * 1000, // Clean up after 7 days
    batchSize: 50,
    concurrency: 3
  },
  
  // In-memory queues
  queues: {
    pending: new Map(),
    processing: new Map(),
    completed: new Map(),
    failed: new Map()
  },
  
  // Operation types
  operationTypes: {
    CHECKIN: 'checkin',
    PAYMENT: 'payment',
    TICKET_UPDATE: 'ticket_update',
    EVENT_UPDATE: 'event_update',
    SYNC_DATA: 'sync_data'
  },
  
  // Initialize queue manager
  init: function() {
    // Load persisted queue if available
    this.loadPersistedQueue();
    
    // Start periodic cleanup
    setInterval(() => this.cleanupOldItems(), 60 * 60 * 1000); // Every hour
    
    return this;
  },
  
  // Generate operation ID
  generateOperationId: function() {
    return `op_${Date.now()}_${crypto.randomBytes(4).toString('hex')}`;
  },
  
  // Add operation to queue
  enqueue: function(operation) {
    const operationId = operation.id || this.generateOperationId();
    
    const queueItem = {
      id: operationId,
      type: operation.type,
      data: operation.data,
      metadata: {
        deviceId: operation.deviceId,
        userId: operation.userId,
        timestamp: new Date().toISOString(),
        createdAt: Date.now(),
        retryCount: 0,
        status: 'pending',
        ...operation.metadata
      },
      attempts: []
    };
    
    // Validate operation
    const validation = this.validateOperation(queueItem);
    if (!validation.valid) {
      throw new Error(`Invalid operation: ${validation.error}`);
    }
    
    this.queues.pending.set(operationId, queueItem);
    
    // Persist if needed
    this.persistIfNeeded();
    
    return {
      success: true,
      operationId,
      timestamp: queueItem.metadata.timestamp,
      position: this.queues.pending.size
    };
  },
  
  // Get next batch of operations to process
  getNextBatch: function(batchSize = this.config.batchSize) {
    const batch = [];
    const now = Date.now();
    
    // Get pending operations, sorted by timestamp
    const pendingOps = Array.from(this.queues.pending.values())
      .sort((a, b) => a.metadata.createdAt - b.metadata.createdAt);
    
    for (const op of pendingOps) {
      // Check if operation is ready for processing (not in retry delay)
      const lastAttempt = op.attempts[op.attempts.length - 1];
      const canRetry = !lastAttempt || 
        (now - lastAttempt.timestamp >= this.getRetryDelay(op.metadata.retryCount));
      
      if (canRetry && batch.length < batchSize) {
        batch.push(op);
        
        // Move to processing queue
        this.queues.pending.delete(op.id);
        this.queues.processing.set(op.id, {
          ...op,
          metadata: {
            ...op.metadata,
            startedAt: now,
            status: 'processing'
          }
        });
      }
    }
    
    return batch;
  },
  
  // Process operation
  processOperation: async function(operationId, processor) {
    const operation = this.queues.processing.get(operationId);
    
    if (!operation) {
      throw new Error(`Operation ${operationId} not found in processing queue`);
    }
    
    const attempt = {
      attemptNumber: operation.metadata.retryCount + 1,
      timestamp: Date.now(),
      status: 'processing'
    };
    
    try {
      // Process the operation
      const result = await processor(operation);
      
      attempt.status = 'success';
      attempt.result = result;
      attempt.completedAt = Date.now();
      attempt.duration = attempt.completedAt - attempt.timestamp;
      
      // Move to completed queue
      this.queues.processing.delete(operationId);
      
      const completedOp = {
        ...operation,
        attempts: [...operation.attempts, attempt],
        metadata: {
          ...operation.metadata,
          retryCount: operation.metadata.retryCount + 1,
          completedAt: attempt.completedAt,
          status: 'completed',
          result
        }
      };
      
      this.queues.completed.set(operationId, completedOp);
      
      // Clean up old completed items if queue is too large
      if (this.queues.completed.size > this.config.maxQueueSize) {
        this.cleanupCompletedQueue();
      }
      
      return {
        success: true,
        operationId,
        result,
        duration: attempt.duration
      };
      
    } catch (error) {
      attempt.status = 'failed';
      attempt.error = {
        message: error.message,
        code: error.code,
        stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
      };
      attempt.completedAt = Date.now();
      attempt.duration = attempt.completedAt - attempt.timestamp;
      
      // Check if we should retry
      const shouldRetry = operation.metadata.retryCount < this.config.retryAttempts;
      
      if (shouldRetry) {
        // Move back to pending queue for retry
        this.queues.processing.delete(operationId);
        
        const retryOp = {
          ...operation,
          attempts: [...operation.attempts, attempt],
          metadata: {
            ...operation.metadata,
            retryCount: operation.metadata.retryCount + 1,
            lastError: error.message,
            status: 'pending'
          }
        };
        
        this.queues.pending.set(operationId, retryOp);
        
        return {
          success: false,
          operationId,
          error: error.message,
          willRetry: true,
          retryCount: retryOp.metadata.retryCount,
          nextRetryDelay: this.getRetryDelay(retryOp.metadata.retryCount)
        };
      } else {
        // Max retries exceeded, move to failed queue
        this.queues.processing.delete(operationId);
        
        const failedOp = {
          ...operation,
          attempts: [...operation.attempts, attempt],
          metadata: {
            ...operation.metadata,
            retryCount: operation.metadata.retryCount + 1,
            completedAt: attempt.completedAt,
            status: 'failed',
            finalError: error.message
          }
        };
        
        this.queues.failed.set(operationId, failedOp);
        
        return {
          success: false,
          operationId,
          error: error.message,
          willRetry: false,
          final: true
        };
      }
    }
  },
  
  // Get retry delay based on attempt count
  getRetryDelay: function(attemptCount) {
    // Exponential backoff with jitter
    const baseDelay = this.config.retryDelay;
    const maxDelay = 5 * 60 * 1000; // 5 minutes max
    
    const delay = Math.min(
      baseDelay * Math.pow(2, attemptCount),
      maxDelay
    );
    
    // Add jitter (±20%)
    const jitter = delay * 0.2 * (Math.random() * 2 - 1);
    
    return Math.round(delay + jitter);
  },
  
  // Validate operation before queuing
  validateOperation: function(operation) {
    const { type, data, metadata } = operation;
    
    // Check required fields
    if (!type || !this.operationTypes[type.toUpperCase()]) {
      return { valid: false, error: `Invalid operation type: ${type}` };
    }
    
    if (!data) {
      return { valid: false, error: 'Operation data is required' };
    }
    
    if (!metadata.deviceId) {
      return { valid: false, error: 'Device ID is required for offline operations' };
    }
    
    // Type-specific validation
    switch (type) {
      case this.operationTypes.CHECKIN:
        if (!data.ticketId || !data.eventId) {
          return { valid: false, error: 'Ticket ID and Event ID are required for checkin' };
        }
        break;
        
      case this.operationTypes.PAYMENT:
        if (!data.amount || !data.paymentMethod) {
          return { valid: false, error: 'Amount and payment method are required for payment' };
        }
        break;
        
      case this.operationTypes.TICKET_UPDATE:
        if (!data.ticketId) {
          return { valid: false, error: 'Ticket ID is required for ticket update' };
        }
        break;
    }
    
    return { valid: true };
  },
  
  // Get queue statistics
  getStats: function() {
    return {
      pending: this.queues.pending.size,
      processing: this.queues.processing.size,
      completed: this.queues.completed.size,
      failed: this.queues.failed.size,
      total: this.queues.pending.size + 
             this.queues.processing.size + 
             this.queues.completed.size + 
             this.queues.failed.size,
      maxQueueSize: this.config.maxQueueSize,
      retryAttempts: this.config.retryAttempts
    };
  },
  
  // Get operations by device
  getDeviceOperations: function(deviceId, status = 'pending') {
    const queue = this.queues[status];
    if (!queue) {
      throw new Error(`Invalid status: ${status}`);
    }
    
    const operations = [];
    queue.forEach(op => {
      if (op.metadata.deviceId === deviceId) {
        operations.push(op);
      }
    });
    
    return operations.sort((a, b) => a.metadata.createdAt - b.metadata.createdAt);
  },
  
  // Get operations by user
  getUserOperations: function(userId, status = 'pending') {
    const queue = this.queues[status];
    if (!queue) {
      throw new Error(`Invalid status: ${status}`);
    }
    
    const operations = [];
    queue.forEach(op => {
      if (op.metadata.userId === userId) {
        operations.push(op);
      }
    });
    
    return operations.sort((a, b) => a.metadata.createdAt - b.metadata.createdAt);
  },
  
  // Clean up old items
  cleanupOldItems: function() {
    const now = Date.now();
    const cleanupAge = this.config.cleanupAge;
    
    let cleanedCount = 0;
    
    // Clean completed queue
    this.queues.completed.forEach((op, id) => {
      if (now - op.metadata.completedAt > cleanupAge) {
        this.queues.completed.delete(id);
        cleanedCount++;
      }
    });
    
    // Clean failed queue
    this.queues.failed.forEach((op, id) => {
      if (now - op.metadata.completedAt > cleanupAge) {
        this.queues.failed.delete(id);
        cleanedCount++;
      }
    });
    
    return cleanedCount;
  },
  
  // Clean up completed queue when it gets too large
  cleanupCompletedQueue: function() {
    const maxSize = Math.floor(this.config.maxQueueSize * 0.5); // Keep 50% of max size
    
    if (this.queues.completed.size <= maxSize) {
      return 0;
    }
    
    // Sort by completion time (oldest first)
    const completedOps = Array.from(this.queues.completed.entries())
      .sort((a, b) => a[1].metadata.completedAt - b[1].metadata.completedAt);
    
    const toRemove = completedOps.slice(0, this.queues.completed.size - maxSize);
    
    toRemove.forEach(([id]) => {
      this.queues.completed.delete(id);
    });
    
    return toRemove.length;
  },
  
  // Retry failed operations
  retryFailedOperations: function(operationIds = []) {
    let retriedCount = 0;
    
    if (operationIds.length === 0) {
      // Retry all failed operations
      this.queues.failed.forEach((op, id) => {
        if (this.moveToPending(id, 'failed')) {
          retriedCount++;
        }
      });
    } else {
      // Retry specific operations
      operationIds.forEach(id => {
        if (this.moveToPending(id, 'failed')) {
          retriedCount++;
        }
      });
    }
    
    return retriedCount;
  },
  
  // Move operation between queues
  moveToPending: function(operationId, fromQueue) {
    const sourceQueue = this.queues[fromQueue];
    if (!sourceQueue) {
      throw new Error(`Invalid source queue: ${fromQueue}`);
    }
    
    const operation = sourceQueue.get(operationId);
    if (!operation) {
      return false;
    }
    
    // Update operation for retry
    const retryOp = {
      ...operation,
      metadata: {
        ...operation.metadata,
        status: 'pending',
        lastError: null
      }
    };
    
    // Move to pending queue
    this.queues.pending.set(operationId, retryOp);
    sourceQueue.delete(operationId);
    
    return true;
  },
  
  // Remove operation from queue
  removeOperation: function(operationId, fromQueue = 'pending') {
    const queue = this.queues[fromQueue];
    if (!queue) {
      throw new Error(`Invalid queue: ${fromQueue}`);
    }
    
    return queue.delete(operationId);
  },
  
  // Get operation by ID
  getOperation: function(operationId) {
    // Check all queues
    for (const [queueName, queue] of Object.entries(this.queues)) {
      const operation = queue.get(operationId);
      if (operation) {
        return {
          ...operation,
          queue: queueName
        };
      }
    }
    
    return null;
  },
  
  // Export queue data for debugging
  exportQueue: function() {
    const exportData = {};
    
    Object.entries(this.queues).forEach(([queueName, queue]) => {
      exportData[queueName] = Array.from(queue.entries()).map(([id, op]) => ({
        id,
        ...op
      }));
    });
    
    return exportData;
  },
  
  // Import queue data
  importQueue: function(queueData) {
    try {
      Object.entries(queueData).forEach(([queueName, operations]) => {
        if (this.queues[queueName]) {
          operations.forEach(({ id, ...op }) => {
            this.queues[queueName].set(id, op);
          });
        }
      });
      
      return true;
    } catch (error) {
      console.error('Failed to import queue:', error);
      return false;
    }
  },
  
  // Persistence methods
  persistIfNeeded: function() {
    // In production, this would persist to disk or database
    // For now, we'll just store in memory
    if (!this.persistTimeout) {
      this.persistTimeout = setTimeout(() => {
        this.persistQueue();
        this.persistTimeout = null;
      }, 10000); // Persist after 10 seconds
    }
  },
  
  persistQueue: function() {
    try {
      const queueData = this.exportQueue();
      global.queueSnapshot = {
        timestamp: new Date().toISOString(),
        data: queueData
      };
      
      return true;
    } catch (error) {
      console.error('Failed to persist queue:', error);
      return false;
    }
  },
  
  loadPersistedQueue: function() {
    try {
      if (global.queueSnapshot) {
        this.importQueue(global.queueSnapshot.data);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Failed to load persisted queue:', error);
      return false;
    }
  },
  
  // Domain-specific queue methods
  checkin: {
    // Enqueue checkin operation
    enqueueCheckin: function(ticketId, eventId, deviceId, userId, checkinData, manager) {
      return manager.enqueue({
        type: manager.operationTypes.CHECKIN,
        data: {
          ticketId,
          eventId,
          ...checkinData
        },
        metadata: {
          deviceId,
          userId,
          operation: 'checkin'
        }
      });
    },
    
    // Process checkin operation
    processCheckin: async function(operation, checkinService) {
      const { ticketId, eventId, ...data } = operation.data;
      
      // Call the actual checkin service
      return await checkinService.processOfflineCheckin(
        ticketId,
        eventId,
        data,
        operation.metadata.deviceId
      );
    }
  },
  
  payment: {
    // Enqueue payment operation
    enqueuePayment: function(paymentData, deviceId, userId, manager) {
      return manager.enqueue({
        type: manager.operationTypes.PAYMENT,
        data: paymentData,
        metadata: {
          deviceId,
          userId,
          operation: 'payment'
        }
      });
    },
    
    // Process payment operation
    processPayment: async function(operation, paymentService) {
      return await paymentService.processOfflinePayment(
        operation.data,
        operation.metadata.deviceId,
        operation.metadata.userId
      );
    }
  },
  
  sync: {
    // Enqueue sync operation
    enqueueSync: function(syncData, deviceId, userId, manager) {
      return manager.enqueue({
        type: manager.operationTypes.SYNC_DATA,
        data: syncData,
        metadata: {
          deviceId,
          userId,
          operation: 'sync'
        }
      });
    },
    
    // Process sync operation
    processSync: async function(operation, syncService) {
      return await syncService.syncOfflineData(
        operation.data,
        operation.metadata.deviceId,
        operation.metadata.userId
      );
    }
  }
}.init(); // Auto-initialize