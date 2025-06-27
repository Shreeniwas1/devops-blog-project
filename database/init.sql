-- Initialize the blog database
CREATE DATABASE IF NOT EXISTS blogdb;

-- Connect to the blog database
\c blogdb;

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    excerpt TEXT,
    tags VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_tags ON posts USING GIN (to_tsvector('english', tags));

-- Insert sample blog posts
INSERT INTO posts (title, content, excerpt, tags) VALUES
(
    'Welcome to My DevOps Journey',
    '# Welcome to My DevOps Journey

    This is the beginning of my exploration into the world of DevOps. In this blog, I''ll be sharing my experiences, challenges, and learnings as I dive deep into various DevOps tools and practices.

    ## What You Can Expect

    - **Real-world examples** of DevOps implementations
    - **Step-by-step tutorials** for various tools
    - **Best practices** and lessons learned
    - **Project showcases** demonstrating end-to-end workflows

    ## Technologies I''ll Cover

    - Container orchestration with Kubernetes
    - CI/CD pipelines with Jenkins
    - Infrastructure as Code
    - Monitoring and observability
    - Security practices

    Stay tuned for more content!',
    'Welcome to my DevOps blog where I share practical insights and experiences from my journey into DevOps engineering.',
    'DevOps, Welcome, Introduction'
),
(
    'Docker Best Practices for Production',
    '# Docker Best Practices for Production

    After working with Docker in production environments, I''ve learned several important lessons about building efficient and secure containers.

    ## Multi-stage Builds

    Always use multi-stage builds to reduce image size:

    ```dockerfile
    # Build stage
    FROM node:18-alpine AS builder
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --only=production

    # Production stage
    FROM node:18-alpine
    WORKDIR /app
    COPY --from=builder /app/node_modules ./node_modules
    COPY . .
    EXPOSE 3000
    CMD ["npm", "start"]
    ```

    ## Security Considerations

    1. **Use non-root users**: Always run containers as non-root
    2. **Scan for vulnerabilities**: Regularly scan images for security issues
    3. **Minimal base images**: Use Alpine or distroless images
    4. **Secrets management**: Never hardcode secrets in images

    ## Performance Tips

    - Use .dockerignore to exclude unnecessary files
    - Optimize layer caching by ordering commands properly
    - Use specific tags instead of "latest"
    - Implement health checks for better orchestration',
    'Learn essential Docker best practices for production deployments, including security, performance, and maintainability tips.',
    'Docker, Containers, Production, Security, Best Practices'
),
(
    'Kubernetes Deployment Strategies Explained',
    '# Kubernetes Deployment Strategies Explained

    Kubernetes offers several deployment strategies to update your applications safely and efficiently. Let''s explore the most common ones.

    ## Rolling Update (Default)

    This is the default strategy that gradually replaces old pods with new ones:

    ```yaml
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
    ```

    **Pros:**
    - Zero downtime
    - Gradual rollout
    - Easy rollback

    **Cons:**
    - Mixed versions running simultaneously
    - Longer deployment time

    ## Blue-Green Deployment

    Deploy to a separate environment and switch traffic all at once:

    1. Deploy new version to "green" environment
    2. Test thoroughly
    3. Switch traffic from "blue" to "green"
    4. Keep "blue" as backup

    ## Canary Deployment

    Gradually roll out to a subset of users:

    - Start with 5% of traffic
    - Monitor metrics
    - Gradually increase percentage
    - Rollback if issues detected

    ## Choosing the Right Strategy

    - **Rolling Update**: Most common, good for stateless apps
    - **Blue-Green**: Best for critical apps requiring zero downtime
    - **Canary**: Ideal for testing new features with real users',
    'Comprehensive guide to Kubernetes deployment strategies including rolling updates, blue-green, and canary deployments.',
    'Kubernetes, Deployment, DevOps, Blue-Green, Canary'
),
(
    'Building a Complete CI/CD Pipeline with Jenkins',
    '# Building a Complete CI/CD Pipeline with Jenkins

    Setting up a robust CI/CD pipeline is crucial for modern software development. Here''s how I built a complete pipeline using Jenkins.

    ## Pipeline Overview

    Our pipeline includes:
    1. Code checkout
    2. Testing (unit, integration, security)
    3. Building Docker images
    4. Pushing to registry
    5. Deploying to staging
    6. Production deployment (with approval)

    ## Jenkinsfile Structure

    ```groovy
    pipeline {
        agent any
        
        environment {
            DOCKER_REGISTRY = ''your-registry.com''
            KUBECONFIG = credentials(''kubeconfig'')
        }
        
        stages {
            stage(''Build'') {
                steps {
                    sh ''npm install''
                    sh ''npm run build''
                }
            }
            
            stage(''Test'') {
                parallel {
                    stage(''Unit Tests'') {
                        steps {
                            sh ''npm test''
                        }
                    }
                    stage(''Security Scan'') {
                        steps {
                            sh ''npm audit''
                        }
                    }
                }
            }
            
            stage(''Docker Build'') {
                steps {
                    script {
                        def image = docker.build("${DOCKER_REGISTRY}/my-app:${BUILD_NUMBER}")
                        docker.withRegistry("https://${DOCKER_REGISTRY}") {
                            image.push()
                        }
                    }
                }
            }
        }
    }
    ```

    ## Best Practices

    1. **Parallel execution**: Run independent tasks in parallel
    2. **Fail fast**: Stop pipeline on first failure
    3. **Secure secrets**: Use Jenkins credentials management
    4. **Notifications**: Send alerts on build status
    5. **Rollback strategy**: Always have a way to rollback

    ## Monitoring and Observability

    - Track deployment success rates
    - Monitor build times
    - Set up alerts for failures
    - Use Blue Ocean for better visualization',
    'Step-by-step guide to building a production-ready CI/CD pipeline with Jenkins, including best practices and monitoring.',
    'Jenkins, CI/CD, Pipeline, DevOps, Automation'
),
(
    'Monitoring Applications with Prometheus and Grafana',
    '# Monitoring Applications with Prometheus and Grafana

    Effective monitoring is essential for maintaining reliable applications. Here''s how I set up comprehensive monitoring using Prometheus and Grafana.

    ## Prometheus Configuration

    ```yaml
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
      - job_name: ''my-app''
        static_configs:
          - targets: [''localhost:3001'']
        metrics_path: ''/metrics''
    ```

    ## Application Metrics

    Key metrics to monitor:

    ### Golden Signals
    1. **Latency**: Response time of requests
    2. **Traffic**: Rate of requests
    3. **Errors**: Rate of failed requests
    4. **Saturation**: Resource utilization

    ### Custom Metrics
    ```javascript
    const promClient = require(''prom-client'');

    const httpRequestDuration = new promClient.Histogram({
      name: ''http_request_duration_seconds'',
      help: ''Duration of HTTP requests in seconds'',
      labelNames: [''method'', ''route'', ''status_code'']
    });

    // Middleware to track metrics
    app.use((req, res, next) => {
      const start = Date.now();
      
      res.on(''finish'', () => {
        const duration = (Date.now() - start) / 1000;
        httpRequestDuration.observe(
          { method: req.method, route: req.route?.path, status_code: res.statusCode },
          duration
        );
      });
      
      next();
    });
    ```

    ## Grafana Dashboards

    Essential dashboard panels:
    - Request rate and response time
    - Error rate and status codes
    - Resource utilization (CPU, memory)
    - Database performance metrics
    - Infrastructure metrics

    ## Alerting

    Set up alerts for:
    - High error rates (>5%)
    - Slow response times (>2s)
    - High resource usage (>80%)
    - Service unavailability

    ## Best Practices

    1. **Start with the basics**: Implement golden signals first
    2. **Avoid metric explosion**: Be selective with labels
    3. **Use SLIs and SLOs**: Define service level objectives
    4. **Regular review**: Continuously improve your metrics
    5. **Runbook automation**: Link alerts to resolution steps',
    'Complete guide to application monitoring with Prometheus and Grafana, including metrics, dashboards, and alerting best practices.',
    'Prometheus, Grafana, Monitoring, Observability, DevOps'
);

-- Grant permissions
GRANT ALL PRIVILEGES ON TABLE posts TO bloguser;
GRANT USAGE, SELECT ON SEQUENCE posts_id_seq TO bloguser;
