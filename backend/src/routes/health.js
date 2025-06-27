const express = require('express');
const db = require('../config/database');

const router = express.Router();

// Health check endpoint
router.get('/', async (req, res) => {
  const healthcheck = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now(),
    service: 'personal-blog-backend',
    version: process.env.npm_package_version || '1.0.0'
  };

  try {
    // Check database connection
    await db.query('SELECT 1');
    healthcheck.database = 'connected';
  } catch (error) {
    healthcheck.database = 'disconnected';
    healthcheck.message = 'Database connection failed';
    return res.status(503).json(healthcheck);
  }

  res.json(healthcheck);
});

// Readiness probe
router.get('/ready', async (req, res) => {
  try {
    // Check if database is ready
    await db.query('SELECT 1');
    res.status(200).json({ status: 'ready' });
  } catch (error) {
    res.status(503).json({ status: 'not ready', error: error.message });
  }
});

// Liveness probe
router.get('/live', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

module.exports = router;
