const { Pool } = require('pg');

// Database configuration
const pool = new Pool({
  user: process.env.DB_USER || 'bloguser',
  host: process.env.DB_HOST || 'postgres-service',
  database: process.env.DB_NAME || 'blogdb',
  password: process.env.DB_PASSWORD || 'blogpassword',
  port: process.env.DB_PORT || 5432,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test the connection
pool.on('connect', () => {
  console.log('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle PostgreSQL client', err);
  process.exit(-1);
});

// Initialize database schema
async function initializeDatabase() {
  let retries = 5;
  while (retries > 0) {
    try {
      console.log('Attempting to initialize database...');
      
      // Test connection first
      await pool.query('SELECT 1');
      console.log('Database connection established');
      
      const createTableQuery = `
        CREATE TABLE IF NOT EXISTS posts (
          id SERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          content TEXT NOT NULL,
          excerpt TEXT,
          tags VARCHAR(255),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `;
      
      await pool.query(createTableQuery);
      console.log('Database schema initialized');
      
      // Insert sample data if table is empty
      const countResult = await pool.query('SELECT COUNT(*) FROM posts');
      const count = parseInt(countResult.rows[0].count);
      
      if (count === 0) {
        console.log('No posts found, inserting sample data...');
        const samplePosts = [
        {
          title: 'Getting Started with DevOps',
          content: `# Getting Started with DevOps

DevOps is a set of practices that combines software development (Dev) and IT operations (Ops). It aims to shorten the systems development life cycle and provide continuous delivery with high software quality.

## Key Principles

1. **Collaboration**: Breaking down silos between development and operations teams
2. **Automation**: Automating repetitive tasks and processes
3. **Continuous Integration**: Regularly merging code changes into a central repository
4. **Continuous Deployment**: Automatically deploying code changes to production
5. **Monitoring**: Continuously monitoring applications and infrastructure

## Benefits of DevOps

- Faster time to market
- Improved collaboration and communication
- Higher quality software
- Better customer satisfaction
- Increased efficiency and productivity`,
          excerpt: 'Learn the fundamentals of DevOps and how it transforms software development and deployment processes.',
          tags: 'DevOps, Getting Started, Fundamentals'
        },
        {
          title: 'Docker Containerization Best Practices',
          content: `# Docker Containerization Best Practices

Docker has revolutionized how we package and deploy applications. Here are some best practices for using Docker effectively.

## Dockerfile Best Practices

### Use Multi-stage Builds
\`\`\`dockerfile
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine
WORKDIR /app
COPY --from=build /app/node_modules ./node_modules
COPY . .
CMD ["npm", "start"]
\`\`\`

### Minimize Layer Count
- Combine RUN commands where possible
- Use .dockerignore files
- Choose appropriate base images

### Security Considerations
- Run as non-root user
- Scan images for vulnerabilities
- Keep base images updated

## Container Management

1. **Resource Limits**: Always set memory and CPU limits
2. **Health Checks**: Implement proper health check endpoints
3. **Logging**: Use structured logging and centralized log management
4. **Secrets Management**: Never hardcode secrets in images`,
          excerpt: 'Master Docker containerization with these essential best practices for security, performance, and maintainability.',
          tags: 'Docker, Containers, Best Practices, Security'
        },
        {
          title: 'Kubernetes Deployment Strategies',
          content: `# Kubernetes Deployment Strategies

Kubernetes offers various deployment strategies to help you update your applications safely and efficiently.

## Rolling Updates

The default deployment strategy in Kubernetes:

\`\`\`yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1
  template:
    spec:
      containers:
      - name: app
        image: my-app:v2
\`\`\`

## Blue-Green Deployments

Deploy to a separate environment and switch traffic:

1. Deploy new version to "green" environment
2. Test the green environment
3. Switch traffic from "blue" to "green"
4. Keep blue as fallback

## Canary Deployments

Gradually roll out changes to a subset of users:

- Start with 5% of traffic
- Monitor metrics and user feedback
- Gradually increase traffic percentage
- Rollback if issues are detected

## Best Practices

- Always use readiness and liveness probes
- Implement proper monitoring and alerting
- Have a rollback strategy
- Test deployments in staging first`,
          excerpt: 'Explore different Kubernetes deployment strategies including rolling updates, blue-green, and canary deployments.',
          tags: 'Kubernetes, Deployment, DevOps, Strategies'
        }
      ];
      
      for (const post of samplePosts) {
        await pool.query(
          'INSERT INTO posts (title, content, excerpt, tags) VALUES ($1, $2, $3, $4)',
          [post.title, post.content, post.excerpt, post.tags]
        );
      }
      
      console.log('Sample data inserted successfully');
      } else {
        console.log(`Found ${count} existing posts in database`);
      }
      
      console.log('Database initialization completed successfully');
      return true;
      
    } catch (error) {
      console.error(`Database initialization failed (${retries} retries left):`, error.message);
      retries--;
      if (retries > 0) {
        console.log('Retrying database initialization in 3 seconds...');
        await new Promise(resolve => setTimeout(resolve, 3000));
      } else {
        console.error('Database initialization failed after all retries');
        throw error;
      }
    }
  }
}

// Don't initialize immediately - export the function instead
module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
  initializeDatabase
};
