# DevOps Personal Blog Project Documentation

## Architecture Overview

This project demonstrates a complete DevOps pipeline for a personal blog application using modern containerization, orchestration, and monitoring technologies.

### System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Cloudflare    │───▶│   Kubernetes     │───▶│   PostgreSQL    │
│   Tunnel        │    │   Cluster        │    │   Database      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Jenkins CI/CD  │
                    │   Pipeline       │
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Prometheus &   │
                    │   Grafana        │
                    └──────────────────┘
```

### Technology Stack

- **Frontend**: React.js with styled-components and React Router
- **Backend**: Node.js with Express.js REST API
- **Database**: PostgreSQL with connection pooling
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Kubernetes with StatefulSets and Deployments
- **CI/CD**: Jenkins with automated pipelines
- **Monitoring**: Prometheus metrics and Grafana dashboards
- **Networking**: Cloudflare Tunnel for secure external access
- **Security**: Secret management, HTTPS, and vulnerability scanning

## Getting Started

### Prerequisites

Before setting up the project, ensure you have the following tools installed:

- Docker Desktop or Docker Engine
- Kubernetes (minikube for local development)
- kubectl (Kubernetes CLI)
- Node.js (version 18 or higher)
- Git

### Local Development Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd devops-blog-project
   ```

2. **Run the automated setup**:
   ```bash
   ./scripts/setup-local.sh
   ```

   This script will:
   - Start Minikube if not running
   - Build Docker images
   - Deploy to Kubernetes
   - Set up port forwarding
   - Optionally configure monitoring

3. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - Health Check: http://localhost:3001/health

### Manual Setup

If you prefer to set up components manually:

#### 1. Frontend Development
```bash
cd frontend
npm install
npm start  # Development server on port 3000
```

#### 2. Backend Development
```bash
cd backend
npm install
npm run dev  # Development server on port 3001
```

#### 3. Database Setup
```bash
# Using Docker
docker run --name postgres-dev \
  -e POSTGRES_USER=bloguser \
  -e POSTGRES_PASSWORD=blogpassword \
  -e POSTGRES_DB=blogdb \
  -p 5432:5432 \
  -d postgres:15-alpine
```

## Project Structure

```
devops-blog-project/
├── frontend/                 # React frontend application
│   ├── src/                 # Source code
│   ├── public/              # Static assets
│   ├── package.json         # Dependencies and scripts
│   ├── Dockerfile           # Multi-stage Docker build
│   └── nginx.conf           # Nginx configuration
├── backend/                 # Node.js backend API
│   ├── src/                 # Source code
│   │   ├── routes/          # API routes
│   │   └── config/          # Configuration files
│   ├── package.json         # Dependencies and scripts
│   ├── Dockerfile           # Docker configuration
│   └── healthcheck.js       # Health check script
├── kubernetes/              # Kubernetes manifests
│   ├── deployments/         # Application deployments
│   ├── services/            # Service definitions
│   ├── ingress/             # Ingress configuration
│   ├── configmaps/          # Configuration data
│   ├── secrets/             # Secret management
│   └── cloudflare-tunnel/   # Cloudflare Tunnel config
├── jenkins/                 # CI/CD pipeline
│   └── Jenkinsfile          # Pipeline definition
├── monitoring/              # Monitoring configuration
│   ├── prometheus.yaml      # Prometheus configuration
│   └── grafana-dashboards/  # Grafana dashboard definitions
├── scripts/                 # Helper scripts
│   ├── setup-local.sh       # Local setup automation
│   └── cleanup.sh           # Resource cleanup
└── docs/                    # Additional documentation
```

## Deployment

### Production Deployment

1. **Configure Secrets**: Update the secret values in `kubernetes/secrets/`
2. **Update Domain**: Replace placeholder domains in ingress configuration
3. **Configure Cloudflare**: Set up Cloudflare Tunnel with your domain
4. **Deploy**: Use Jenkins pipeline or kubectl apply

### CI/CD Pipeline

The Jenkins pipeline includes:

1. **Code Checkout**: Pull latest code from repository
2. **Build & Test**: Frontend and backend testing
3. **Security Scanning**: Vulnerability assessment
4. **Docker Build**: Multi-stage image creation
5. **Container Scanning**: Image security analysis
6. **Staging Deployment**: Automated staging environment
7. **Integration Testing**: End-to-end testing
8. **Production Deployment**: Manual approval required

## Monitoring and Observability

### Metrics

The application exposes the following metrics:

- **Application Metrics**: Request count, response time, error rate
- **System Metrics**: CPU usage, memory consumption, uptime
- **Database Metrics**: Connection pool status, query performance
- **Kubernetes Metrics**: Pod status, resource utilization

### Health Checks

- **Liveness Probe**: `/health/live` - Application is running
- **Readiness Probe**: `/health/ready` - Application is ready to serve traffic
- **Startup Probe**: Initial health verification

### Dashboards

Grafana dashboards provide:
- Application performance overview
- Resource utilization monitoring
- Error rate and latency tracking
- Database performance metrics

## Security Considerations

### Container Security
- Non-root user execution
- Multi-stage builds to minimize attack surface
- Regular security scanning with Trivy
- Minimal base images (Alpine Linux)

### Kubernetes Security
- Secret management for sensitive data
- Network policies for traffic control
- Role-based access control (RBAC)
- Pod security policies

### Application Security
- Input validation and sanitization
- Rate limiting to prevent abuse
- HTTPS enforcement
- CORS configuration

## Troubleshooting

### Common Issues

1. **Port Conflicts**: Ensure ports 3000, 3001, and 5432 are available
2. **Docker Issues**: Check Docker daemon is running
3. **Kubernetes Issues**: Verify minikube status and kubectl connectivity
4. **Database Connection**: Check PostgreSQL pod logs

### Useful Commands

```bash
# Check pod status
kubectl get pods -n blog

# View logs
kubectl logs -f deployment/backend-deployment -n blog
kubectl logs -f deployment/frontend-deployment -n blog

# Port forwarding for debugging
kubectl port-forward service/postgres-service 5432:5432 -n blog

# Access database
psql -h localhost -U bloguser -d blogdb

# Restart deployment
kubectl rollout restart deployment/backend-deployment -n blog
```

### Log Locations

- Application logs: Available through kubectl logs
- Container logs: Docker container logs
- System logs: Kubernetes event logs

## Performance Optimization

### Frontend Optimization
- Code splitting with React.lazy
- Image optimization and compression
- CDN integration for static assets
- Gzip compression via Nginx

### Backend Optimization
- Database connection pooling
- Response caching strategies
- API rate limiting
- Compression middleware

### Database Optimization
- Proper indexing strategy
- Connection pool tuning
- Query optimization
- Regular maintenance tasks

## Backup and Recovery

### Database Backup
```bash
# Manual backup
kubectl exec -it postgres-statefulset-0 -n blog -- pg_dump -U bloguser blogdb > backup.sql

# Automated backup (recommended)
# Configure CronJob for regular backups
```

### Disaster Recovery
- Regular database backups
- Configuration version control
- Infrastructure as Code (IaC)
- Multi-region deployment (for production)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions and support:
- Check the troubleshooting section
- Review application logs
- Open an issue in the repository
- Contact the development team
