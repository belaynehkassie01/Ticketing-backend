// File: backend/src/app.js
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import bodyParser from 'body-parser';

// Import routes
import authRoutes from './routes/auth.routes.js';
import organizerRoutes from './routes/organizer.routes.js';
import adminRoutes from './routes/admin.routes.js';
import eventRoutes from './routes/event.routes.js';





const app = express();

// Middlewares
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/organizer', organizerRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/events', eventRoutes);


// Health check
app.get('/', (req, res) => {
  res.json({ 
    message: 'Ethiopian Ticketing Platform API 🎫',
    version: '1.0.0',
    status: 'running'
  });
});

// 404 handler - FIXED VERSION
app.use((req, res, next) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint not found',
    path: req.originalUrl
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

export default app;