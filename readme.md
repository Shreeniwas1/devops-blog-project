# DevOps Blog Project 🚀

A comprehensive DevOps-focused personal blog application showcasing modern cloud-native development practices, containerization, orchestration, and monitoring.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Monitoring & Observability](#monitoring--observability)
- [CI/CD Pipeline](#cicd-pipeline)
- [Documentation](#documentation)
- [Contributing](#contributing)

## 🎯 Overview

This project demonstrates a complete DevOps pipeline for a modern web application, including:

- **React frontend** with modern UI components
- **Node.js/Express backend** API with PostgreSQL database
- **Containerized deployment** using Docker
- **Kubernetes orchestration** with full manifest files
- **CI/CD pipeline** using Jenkins
- **Monitoring stack** with Prometheus and Grafana
- **Infrastructure as Code** practices
- **Security best practices** and secret management

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend │    │ Node.js Backend │    │   PostgreSQL    │
│      (Port 80)   │◄──►│   (Port 3001)   │◄──►│   Database      │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────────────────────────────────┐
         │            Kubernetes Cluster                │
         │  ┌─────────┐ ┌─────────┐ ┌─────────────────┐ │
         │  │ Ingress │ │ Service │ │   ConfigMaps    │ │
         │  └─────────┘ └─────────┘ └─────────────────┘ │
         └─────────────────────────────────────────────┘
                                 │
         ┌─────────────────────────────────────────────┐
         │         Monitoring & Observability          │
         │  ┌─────────────┐ ┌─────────────────────────┐ │
         │  │ Prometheus  │ │       Grafana           │ │
         │  └─────────────┘ └─────────────────────────┘ │
         └─────────────────────────────────────────────┘
```

## 🛠️ Technology Stack

### Frontend
- **React 18** - Modern UI library
- **React Router DOM** - Client-side routing
- **Styled Components** - CSS-in-JS styling
- **Axios** - HTTP client
- **React Markdown** - Markdown rendering

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **PostgreSQL** - Relational database
- **JWT** - Authentication
- **bcryptjs** - Password hashing
- **Helmet** - Security middleware

### DevOps & Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Jenkins** - CI/CD automation
- **Prometheus** - Metrics collection
- **Grafana** - Visualization and dashboards
- **Cloudflare Tunnel** - Secure exposure

### Development Tools
- **PlantUML** - Architecture diagrams
- **Jest** - Testing framework
- **ESLint** - Code linting
- **Prettier** - Code formatting

## 📁 Project Structure

```
~/devops-blog-project/
├── frontend/                     # React application
│   ├── src/                     # Source code
│   ├── public/                  # Static assets
│   ├── Dockerfile              # Frontend container
│   └── package.json            # Dependencies
├── backend/                     # Node.js API
│   ├── src/                    # Source code
│   │   ├── config/             # Database configuration
│   │   └── routes/             # API routes
│   ├── Dockerfile              # Backend container
│   ├── package.json            # Dependencies
│   └── server.js               # Entry point
├── database/                    # Database setup
│   └── init.sql                # Initial schema
├── kubernetes/                  # K8s manifests
│   ├── deployments/            # Deployment configs
│   ├── services/               # Service definitions
│   ├── configmaps/             # Configuration maps
│   ├── secrets/                # Secret templates
│   ├── ingress/                # Ingress controllers
│   └── cloudflare-tunnel/      # Tunnel configuration
├── jenkins/                     # CI/CD pipeline
│   └── Jenkinsfile             # Pipeline definition
├── monitoring/                  # Observability stack
│   ├── prometheus.yaml         # Metrics configuration
│   └── grafana-dashboards/     # Custom dashboards
├── plantuml/                    # Architecture diagrams
│   ├── *.puml                  # Diagram sources
│   └── validate-diagrams.sh    # Validation script
├── scripts/                     # Automation scripts
│   ├── quick-start.sh          # Quick deployment
│   ├── setup-docker-compose.sh # Local setup
│   ├── setup-local.sh          # Development setup
│   └── cleanup.sh              # Environment cleanup
├── docs/                        # Documentation
│   ├── README.md               # Detailed docs
│   └── TROUBLESHOOTING.md      # Common issues
├── docker-compose.yml           # Local development
├── .gitignore                   # Git ignore rules
└── README.md                    # This file
```

## 🚀 Quick Start

### Prerequisites

- **Docker** and **Docker Compose**
- **Node.js** (v16+) and **npm**
- **Minikube** or **kubectl** (for K8s deployment)
- **Git**

### 1. Clone the Repository

```bash
git clone https://github.com/Shreeniwas1/devops-blog-project.git
cd devops-blog-project
```

### 2. Local Development with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:3001
# Database: localhost:5432
```

### 3. Quick Setup Script

```bash
# Make scripts executable and run quick setup
chmod +x scripts/*.sh
./scripts/quick-start.sh
```

## 🌐 Deployment Options

### Option 1: Docker Compose (Development)

```bash
./scripts/setup-docker-compose.sh
```

### Option 2: Kubernetes (Production)

```bash
# Start minikube
minikube start

# Apply Kubernetes manifests
kubectl apply -f kubernetes/

# Get service URLs
minikube service list
```

### Option 3: Cloud Deployment

The project includes configurations for:
- **AWS EKS**
- **Google GKE** 
- **Azure AKS**
- **Cloudflare Tunnel** for secure exposure

## 📊 Monitoring & Observability

### Prometheus Metrics
- Application performance metrics
- Infrastructure monitoring
- Custom business metrics

### Grafana Dashboards
- System overview dashboard
- Application performance dashboard
- Database monitoring dashboard
- Custom blog analytics

Access Grafana: `http://localhost:3001/grafana` (after deployment)

## 🔄 CI/CD Pipeline

### Jenkins Pipeline Features
- **Automated builds** on code commits
- **Multi-stage testing** (unit, integration, e2e)
- **Security scanning** with SAST tools
- **Docker image building** and registry push
- **Kubernetes deployment** automation
- **Rollback capabilities**

### Pipeline Stages
1. **Source** - Code checkout
2. **Build** - Compile and package
3. **Test** - Automated testing
4. **Security** - Vulnerability scanning
5. **Package** - Docker image creation
6. **Deploy** - Kubernetes deployment
7. **Monitor** - Health checks and alerts

## 📚 Documentation

- [**Architecture Documentation**](docs/README.md) - Detailed system design
- [**Troubleshooting Guide**](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [**PlantUML Diagrams**](plantuml/) - Visual architecture representations
- [**API Documentation**](backend/src/routes/) - Backend API endpoints

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines
- Follow existing code style and conventions
- Add tests for new features
- Update documentation as needed
- Ensure all CI/CD checks pass

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Kubernetes Community** for excellent orchestration tools
- **Prometheus & Grafana** for observability solutions
- **React & Node.js** communities for robust frameworks
- **DevOps Community** for best practices and inspiration

## 🔗 Links

- **Repository**: [github.com/Shreeniwas1/devops-blog-project](https://github.com/Shreeniwas1/devops-blog-project)
- **Issues**: [Report a bug or request a feature](https://github.com/Shreeniwas1/devops-blog-project/issues)
- **Discussions**: [Join the conversation](https://github.com/Shreeniwas1/devops-blog-project/discussions)

---

**⭐ Star this repository if you find it helpful!**