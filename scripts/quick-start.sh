#!/bin/bash

# DevOps Blog Project Quick Start Guide
# This script provides instructions for getting started with the project

cat << 'EOF'
🚀 DevOps Personal Blog Project Setup Complete!

This comprehensive DevOps project includes:
- React frontend with modern UI
- Node.js/Express backend API
- PostgreSQL database
- Docker containerization
- Kubernetes orchestration
- Jenkins CI/CD pipeline
- Prometheus & Grafana monitoring
- Cloudflare Tunnel networking

📋 QUICK START OPTIONS:

1. DOCKER COMPOSE (Easiest - works with root):
   ./scripts/setup-docker-compose.sh
   
   Access:
   - Frontend: http://localhost:3000
   - Backend: http://localhost:3001
   - Grafana: http://localhost:3003 (admin/admin123)
   - Prometheus: http://localhost:9090

2. DOCKER COMPOSE (Manual):
   docker-compose up -d
   
3. KUBERNETES (Advanced):
   ./scripts/setup-local.sh
   
   Note: If you encounter Minikube driver issues:
   - For root users: Use Docker driver (automatically handled)
   - For non-root users: Use preferred driver (docker, virtualbox, etc.)
   - If "none" driver fails: Try 'minikube delete && minikube start --driver=docker --force'
   
   This will:
   - Start Minikube with appropriate driver
   - Build Docker images
   - Deploy to Kubernetes
   - Set up monitoring

3. LOCAL DEVELOPMENT:
   # Terminal 1 - Backend
   cd backend && npm install && npm run dev
   
   # Terminal 2 - Frontend  
   cd frontend && npm install && npm start
   
   # Terminal 3 - Database
   docker run --name postgres-dev \
     -e POSTGRES_USER=bloguser \
     -e POSTGRES_PASSWORD=blogpassword \
     -e POSTGRES_DB=blogdb \
     -p 5432:5432 -d postgres:15-alpine

🛠️ PROJECT STRUCTURE:
- frontend/          # React application
- backend/           # Node.js API
- kubernetes/        # K8s manifests
- jenkins/           # CI/CD pipeline
- monitoring/        # Prometheus/Grafana
- scripts/           # Helper scripts
- docs/              # Documentation

📚 LEARNING OBJECTIVES:
This project demonstrates:
✅ Container orchestration with Kubernetes
✅ CI/CD pipeline automation
✅ Infrastructure as Code
✅ Application monitoring & observability
✅ Security best practices
✅ Production deployment strategies

🔧 CUSTOMIZATION:
1. Update domains in kubernetes/ingress/
2. Configure Cloudflare Tunnel tokens
3. Set up Jenkins credentials
4. Customize Grafana dashboards
5. Add your own blog content

📖 DOCUMENTATION:
- Full setup guide: docs/README.md
- API documentation: http://localhost:3001 (when running)
- Architecture details in project README

🆘 TROUBLESHOOTING:

Common Issues & Solutions:

1. MINIKUBE DRIVER ISSUES:
   Error: "NOT_FOUND_CRI_DOCKERD" with none driver
   Solution: Use Docker driver instead
   → minikube delete && minikube start --driver=docker --force
   
   Error: "The 'none' driver requires cri-dockerd"
   Solution: Switch to Docker driver (preferred for containers)
   → rm -rf ~/.minikube && minikube start --driver=docker --force

2. BACKEND CONNECTION ISSUES:
   Error: Database connection failed
   Solution: Ensure PostgreSQL container is running
   → docker-compose up postgres -d
   → Update DB_HOST=localhost in backend/.env
   
3. PORT CONFLICTS:
   Error: "EADDRINUSE: address already in use"
   Solution: Kill processes using the ports
   → lsof -ti:3001 | xargs kill -9  # Backend
   → lsof -ti:3000 | xargs kill -9  # Frontend
   → lsof -ti:5432 | xargs kill -9  # Database

4. GENERAL DEBUGGING:
   - Check logs: kubectl logs -f deployment/backend-deployment -n blog
   - Health check: curl http://localhost:3001/health
   - Reset everything: ./scripts/cleanup.sh

Happy learning and building! 🎉

EOF
