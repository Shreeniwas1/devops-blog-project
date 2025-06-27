const express = require('express');
const db = require('../config/database');

const router = express.Router();

// Prometheus metrics endpoint
router.get('/', async (req, res) => {
  try {
    const metrics = [];
    
    // Application metrics
    metrics.push(`# HELP nodejs_uptime_seconds Process uptime in seconds`);
    metrics.push(`# TYPE nodejs_uptime_seconds counter`);
    metrics.push(`nodejs_uptime_seconds ${process.uptime()}`);
    
    metrics.push(`# HELP nodejs_memory_usage_bytes Process memory usage in bytes`);
    metrics.push(`# TYPE nodejs_memory_usage_bytes gauge`);
    const memUsage = process.memoryUsage();
    metrics.push(`nodejs_memory_usage_bytes{type="rss"} ${memUsage.rss}`);
    metrics.push(`nodejs_memory_usage_bytes{type="heapTotal"} ${memUsage.heapTotal}`);
    metrics.push(`nodejs_memory_usage_bytes{type="heapUsed"} ${memUsage.heapUsed}`);
    
    // Database metrics
    try {
      const postCountResult = await db.query('SELECT COUNT(*) as count FROM posts');
      const postCount = postCountResult.rows[0].count;
      
      metrics.push(`# HELP blog_posts_total Total number of blog posts`);
      metrics.push(`# TYPE blog_posts_total gauge`);
      metrics.push(`blog_posts_total ${postCount}`);
    } catch (dbError) {
      console.error('Error fetching database metrics:', dbError);
    }
    
    // HTTP request metrics (basic)
    metrics.push(`# HELP http_requests_total Total number of HTTP requests`);
    metrics.push(`# TYPE http_requests_total counter`);
    metrics.push(`http_requests_total{method="GET",status="200"} ${global.requestCount || 0}`);
    
    res.set('Content-Type', 'text/plain');
    res.send(metrics.join('\n'));
  } catch (error) {
    console.error('Error generating metrics:', error);
    res.status(500).send('Error generating metrics');
  }
});

module.exports = router;
