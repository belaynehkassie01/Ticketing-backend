// backend/src/utils/offline/cache.manager.js
export default {
  // Cache configuration
  config: {
    ticketCacheTTL: 24 * 60 * 60 * 1000, // 24 hours for tickets
    eventCacheTTL: 7 * 24 * 60 * 60 * 1000, // 7 days for events
    userCacheTTL: 60 * 60 * 1000, // 1 hour for users
    maxCacheSize: 1000, // Max items in cache
    cleanupInterval: 30 * 60 * 1000 // Cleanup every 30 minutes
  },
  
  // In-memory cache storage
  cache: new Map(),
  
  // Initialize cache manager
  init: function() {
    // Start cleanup interval
    setInterval(() => this.cleanup(), this.config.cleanupInterval);
    
    // Load persisted cache if available
    this.loadPersistedCache();
    
    return this;
  },
  
  // Generate cache key
  generateKey: function(prefix, id) {
    return `${prefix}:${id}`;
  },
  
  // Store item in cache
  set: function(key, value, ttl = null) {
    const now = Date.now();
    const expiration = ttl ? now + ttl : null;
    
    this.cache.set(key, {
      value,
      expiration,
      createdAt: now,
      lastAccessed: now,
      accessCount: 1
    });
    
    // Enforce max cache size
    if (this.cache.size > this.config.maxCacheSize) {
      this.evictOldest();
    }
    
    // Persist if needed
    this.persistIfNeeded(key);
    
    return true;
  },
  
  // Get item from cache
  get: function(key) {
    const item = this.cache.get(key);
    
    if (!item) {
      return null;
    }
    
    // Check if expired
    if (item.expiration && Date.now() > item.expiration) {
      this.cache.delete(key);
      return null;
    }
    
    // Update access metadata
    item.lastAccessed = Date.now();
    item.accessCount++;
    
    return item.value;
  },
  
  // Delete item from cache
  delete: function(key) {
    return this.cache.delete(key);
  },
  
  // Check if key exists in cache
  has: function(key) {
    const item = this.cache.get(key);
    
    if (!item) {
      return false;
    }
    
    // Check if expired
    if (item.expiration && Date.now() > item.expiration) {
      this.cache.delete(key);
      return false;
    }
    
    return true;
  },
  
  // Clear all cache
  clear: function() {
    this.cache.clear();
    this.clearPersistedCache();
    return true;
  },
  
  // Get cache statistics
  getStats: function() {
    const now = Date.now();
    let expiredCount = 0;
    let totalSize = 0;
    
    this.cache.forEach(item => {
      if (item.expiration && now > item.expiration) {
        expiredCount++;
      }
      totalSize += this.estimateSize(item.value);
    });
    
    return {
      totalItems: this.cache.size,
      expiredItems: expiredCount,
      cacheSize: totalSize,
      maxSize: this.config.maxCacheSize,
      memoryUsage: process.memoryUsage().heapUsed
    };
  },
  
  // Cleanup expired items
  cleanup: function() {
    const now = Date.now();
    let cleanedCount = 0;
    
    this.cache.forEach((item, key) => {
      if (item.expiration && now > item.expiration) {
        this.cache.delete(key);
        cleanedCount++;
      }
    });
    
    // Also persist cleanup
    this.persistCache();
    
    return cleanedCount;
  },
  
  // Evict oldest items when cache is full
  evictOldest: function(count = 10) {
    const entries = Array.from(this.cache.entries());
    
    // Sort by last accessed time (oldest first)
    entries.sort((a, b) => a[1].lastAccessed - b[1].lastAccessed);
    
    // Remove oldest entries
    for (let i = 0; i < Math.min(count, entries.length); i++) {
      this.cache.delete(entries[i][0]);
    }
    
    return entries.length;
  },
  
  // Estimate size of value in bytes
  estimateSize: function(value) {
    try {
      const stringified = JSON.stringify(value);
      return Buffer.byteLength(stringified, 'utf8');
    } catch (error) {
      return 0;
    }
  },
  
  // Ticket-specific cache methods
  tickets: {
    // Cache ticket validation data
    cacheTicket: function(ticketId, ticketData, manager) {
      const key = manager.generateKey('ticket', ticketId);
      return manager.set(key, ticketData, manager.config.ticketCacheTTL);
    },
    
    // Get cached ticket
    getTicket: function(ticketId, manager) {
      const key = manager.generateKey('ticket', ticketId);
      return manager.get(key);
    },
    
    // Cache ticket check-in status
    cacheCheckin: function(ticketId, checkinData, manager) {
      const key = manager.generateKey('checkin', ticketId);
      return manager.set(key, checkinData, manager.config.ticketCacheTTL);
    },
    
    // Batch cache tickets for an event
    cacheEventTickets: function(eventId, tickets, manager) {
      const eventKey = manager.generateKey('event_tickets', eventId);
      const ticketMap = {};
      
      tickets.forEach(ticket => {
        const ticketKey = manager.generateKey('ticket', ticket.id);
        manager.set(ticketKey, ticket, manager.config.ticketCacheTTL);
        ticketMap[ticket.id] = true;
      });
      
      // Store list of ticket IDs for the event
      return manager.set(eventKey, {
        eventId,
        ticketIds: Object.keys(ticketMap),
        cachedAt: new Date().toISOString(),
        count: tickets.length
      }, manager.config.eventCacheTTL);
    },
    
    // Get all cached tickets for an event
    getEventTickets: function(eventId, manager) {
      const eventKey = manager.generateKey('event_tickets', eventId);
      const eventCache = manager.get(eventKey);
      
      if (!eventCache) {
        return null;
      }
      
      const tickets = [];
      eventCache.ticketIds.forEach(ticketId => {
        const ticketKey = manager.generateKey('ticket', ticketId);
        const ticket = manager.get(ticketKey);
        if (ticket) {
          tickets.push(ticket);
        }
      });
      
      return {
        eventId,
        tickets,
        cachedAt: eventCache.cachedAt,
        count: tickets.length
      };
    },
    
    // Invalidate ticket cache
    invalidateTicket: function(ticketId, manager) {
      const ticketKey = manager.generateKey('ticket', ticketId);
      const checkinKey = manager.generateKey('checkin', ticketId);
      
      manager.delete(ticketKey);
      manager.delete(checkinKey);
      
      return true;
    }
  },
  
  // Event-specific cache methods
  events: {
    // Cache event data
    cacheEvent: function(eventId, eventData, manager) {
      const key = manager.generateKey('event', eventId);
      return manager.set(key, eventData, manager.config.eventCacheTTL);
    },
    
    // Get cached event
    getEvent: function(eventId, manager) {
      const key = manager.generateKey('event', eventId);
      return manager.get(key);
    },
    
    // Cache event availability
    cacheAvailability: function(eventId, availability, manager) {
      const key = manager.generateKey('availability', eventId);
      return manager.set(key, availability, 5 * 60 * 1000); // 5 minutes TTL
    },
    
    // Cache event search results
    cacheSearch: function(query, results, manager) {
      const key = manager.generateKey('search', this.hashQuery(query));
      return manager.set(key, results, 15 * 60 * 1000); // 15 minutes TTL
    },
    
    // Get cached search results
    getSearch: function(query, manager) {
      const key = manager.generateKey('search', this.hashQuery(query));
      return manager.get(key);
    },
    
    // Hash query for cache key
    hashQuery: function(query) {
      // Simple hash for query
      let hash = 0;
      for (let i = 0; i < query.length; i++) {
        hash = ((hash << 5) - hash) + query.charCodeAt(i);
        hash = hash & hash;
      }
      return hash.toString(36);
    }
  },
  
  // User-specific cache methods
  users: {
    // Cache user data
    cacheUser: function(userId, userData, manager) {
      const key = manager.generateKey('user', userId);
      return manager.set(key, userData, manager.config.userCacheTTL);
    },
    
    // Get cached user
    getUser: function(userId, manager) {
      const key = manager.generateKey('user', userId);
      return manager.get(key);
    },
    
    // Cache user tickets
    cacheUserTickets: function(userId, tickets, manager) {
      const key = manager.generateKey('user_tickets', userId);
      return manager.set(key, tickets, manager.config.userCacheTTL);
    },
    
    // Get cached user tickets
    getUserTickets: function(userId, manager) {
      const key = manager.generateKey('user_tickets', userId);
      return manager.get(key);
    },
    
    // Invalidate user cache
    invalidateUser: function(userId, manager) {
      const userKey = manager.generateKey('user', userId);
      const ticketsKey = manager.generateKey('user_tickets', userId);
      
      manager.delete(userKey);
      manager.delete(ticketsKey);
      
      return true;
    }
  },
  
  // Payment-specific cache methods
  payments: {
    // Cache payment status
    cachePayment: function(paymentId, paymentData, manager) {
      const key = manager.generateKey('payment', paymentId);
      return manager.set(key, paymentData, 30 * 60 * 1000); // 30 minutes TTL
    },
    
    // Get cached payment
    getPayment: function(paymentId, manager) {
      const key = manager.generateKey('payment', paymentId);
      return manager.get(key);
    },
    
    // Cache reservation
    cacheReservation: function(reservationId, reservationData, manager) {
      const key = manager.generateKey('reservation', reservationId);
      return manager.set(key, reservationData, 15 * 60 * 1000); // 15 minutes TTL
    },
    
    // Get cached reservation
    getReservation: function(reservationId, manager) {
      const key = manager.generateKey('reservation', reservationId);
      return manager.get(key);
    }
  },
  
  // Offline sync cache methods
  sync: {
    // Cache offline operations
    cacheOperation: function(deviceId, operation, manager) {
      const key = manager.generateKey('sync_op', `${deviceId}:${Date.now()}`);
      return manager.set(key, {
        deviceId,
        operation,
        timestamp: new Date().toISOString(),
        status: 'pending'
      }, 7 * 24 * 60 * 60 * 1000); // 7 days TTL
    },
    
    // Get pending operations for device
    getPendingOperations: function(deviceId, manager) {
      const ops = [];
      const prefix = 'sync_op:';
      
      manager.cache.forEach((item, key) => {
        if (key.startsWith(prefix) && item.value.deviceId === deviceId && item.value.status === 'pending') {
          ops.push(item.value);
        }
      });
      
      return ops.sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp));
    },
    
    // Mark operation as synced
    markSynced: function(deviceId, operationId, manager) {
      const key = manager.generateKey('sync_op', `${deviceId}:${operationId}`);
      const item = manager.cache.get(key);
      
      if (item) {
        item.value.status = 'synced';
        item.value.syncedAt = new Date().toISOString();
        return true;
      }
      
      return false;
    }
  },
  
  // Persistence methods (for Node.js environment)
  persistCache: function() {
    try {
      // In browser, use localStorage
      // In Node.js, we could use file system or Redis
      // This is a simplified version
      const cacheData = {
        timestamp: new Date().toISOString(),
        items: Array.from(this.cache.entries())
      };
      
      // Store in memory for this example
      // In production, you would write to disk or database
      global.cacheSnapshot = cacheData;
      
      return true;
    } catch (error) {
      console.error('Failed to persist cache:', error);
      return false;
    }
  },
  
  loadPersistedCache: function() {
    try {
      if (global.cacheSnapshot) {
        const { items } = global.cacheSnapshot;
        
        items.forEach(([key, item]) => {
          // Check if item is still valid
          if (!item.expiration || Date.now() < item.expiration) {
            this.cache.set(key, item);
          }
        });
        
        return items.length;
      }
      
      return 0;
    } catch (error) {
      console.error('Failed to load persisted cache:', error);
      return 0;
    }
  },
  
  clearPersistedCache: function() {
    try {
      delete global.cacheSnapshot;
      return true;
    } catch (error) {
      console.error('Failed to clear persisted cache:', error);
      return false;
    }
  },
  
  persistIfNeeded: function(key) {
    // Only persist certain important caches
    const persistKeys = ['ticket:', 'event:', 'user:'];
    
    if (persistKeys.some(prefix => key.startsWith(prefix))) {
      // Debounce persistence to avoid too many writes
      if (!this.persistTimeout) {
        this.persistTimeout = setTimeout(() => {
          this.persistCache();
          this.persistTimeout = null;
        }, 5000); // Persist after 5 seconds of inactivity
      }
    }
  },
  
  // Export cache for debugging
  exportCache: function() {
    const exportData = {};
    
    this.cache.forEach((item, key) => {
      exportData[key] = {
        value: item.value,
        expiration: item.expiration,
        createdAt: new Date(item.createdAt).toISOString(),
        lastAccessed: new Date(item.lastAccessed).toISOString(),
        accessCount: item.accessCount,
        ttl: item.expiration ? item.expiration - Date.now() : null
      };
    });
    
    return exportData;
  },
  
  // Import cache data
  importCache: function(cacheData) {
    try {
      Object.entries(cacheData).forEach(([key, item]) => {
        this.cache.set(key, {
          value: item.value,
          expiration: item.expiration,
          createdAt: new Date(item.createdAt).getTime(),
          lastAccessed: new Date(item.lastAccessed).getTime(),
          accessCount: item.accessCount || 1
        });
      });
      
      return true;
    } catch (error) {
      console.error('Failed to import cache:', error);
      return false;
    }
  }
}.init(); // Auto-initialize