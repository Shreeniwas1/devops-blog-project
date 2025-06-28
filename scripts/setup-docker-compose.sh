#!/bin/bash

# Docker Compose Setup Script for DevOps Blog Project
# This script sets up the application using Docker Compose (no root required)

set -e

echo "🚀 Setting up DevOps Personal Blog with Docker Compose..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        echo "Installation guide: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Installation guide: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running. Please start Docker first."
        exit 1
    fi
    
    print_status "All prerequisites are installed ✓"
}

# Check if user is in docker group (for non-root usage)
check_docker_permissions() {
    if [[ $EUID -ne 0 ]]; then
        if ! groups $USER | grep -q docker; then
            print_warning "User $USER is not in the docker group."
            print_warning "You may need to run: sudo usermod -aG docker $USER"
            print_warning "Then log out and log back in, or run: newgrp docker"
            
            # Test if docker works without sudo
            if ! docker ps &> /dev/null; then
                print_error "Cannot run docker commands. Please add user to docker group or run with sudo."
                exit 1
            fi
        fi
    fi
}

# Create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p database/
    mkdir -p monitoring/grafana-dashboards/
    
    print_status "Directories created ✓"
}

# Setup environment files
setup_environment() {
    print_status "Setting up environment configuration..."
    
    # Create backend .env file
    cat > backend/.env << EOF
NODE_ENV=development
PORT=3001
DB_HOST=postgres
DB_PORT=5432
DB_NAME=blogdb
DB_USER=bloguser
DB_PASSWORD=blogpassword
JWT_SECRET=dev-jwt-secret-change-in-production
FRONTEND_URL=http://localhost:3000
EOF

    # Create frontend .env file
    cat > frontend/.env << EOF
REACT_APP_API_URL=http://localhost:3001
EOF

    print_status "Environment configuration completed ✓"
}

# Start services with Docker Compose
start_services() {
    print_status "Starting services with Docker Compose..."
    
    # Use docker-compose or docker compose based on what's available
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    # Pull latest images
    print_status "Pulling latest images..."
    $COMPOSE_CMD pull
    
    # Build and start services
    print_status "Building and starting services..."
    $COMPOSE_CMD up -d --build
    
    print_status "Services started successfully ✓"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for database
    print_status "Waiting for database..."
    for i in {1..30}; do
        if docker exec devops-blog-project-postgres-1 pg_isready -U bloguser -d blogdb &> /dev/null; then
            break
        fi
        sleep 2
    done
    
    # Wait for backend
    print_status "Waiting for backend API..."
    for i in {1..30}; do
        if curl -s http://localhost:3001/health &> /dev/null; then
            break
        fi
        sleep 2
    done
    
    # Wait for frontend
    print_status "Waiting for frontend..."
    for i in {1..30}; do
        if curl -s http://localhost:3000 &> /dev/null; then
            break
        fi
        sleep 2
    done
    
    print_status "All services are ready ✓"
}

# Show service status
show_status() {
    print_status "Checking service status..."
    
    if command -v docker-compose &> /dev/null; then
        docker-compose ps
    else
        docker compose ps
    fi
}

# Main function
main() {
    print_status "Starting DevOps Personal Blog setup with Docker Compose..."
    
    check_prerequisites
    check_docker_permissions
    create_directories
    setup_environment
    start_services
    wait_for_services
    show_status
    
    print_status "🎉 Setup completed successfully!"
    print_status ""
    print_status "Application URLs:"
    print_status "  Frontend: http://localhost:3000"
    print_status "  Backend API: http://localhost:3001"
    print_status "  Health Check: http://localhost:3001/health"
    print_status "  Metrics: http://localhost:3001/metrics"
    print_status "  Grafana: http://localhost:3003 (admin/admin123)"
    print_status "  Prometheus: http://localhost:9090"
    print_status ""
    print_status "Useful commands:"
    if command -v docker-compose &> /dev/null; then
        print_status "  docker-compose logs -f backend"
        print_status "  docker-compose logs -f frontend"
        print_status "  docker-compose down"
        print_status "  docker-compose restart"
    else
        print_status "  docker compose logs -f backend"
        print_status "  docker compose logs -f frontend"
        print_status "  docker compose down"
        print_status "  docker compose restart"
    fi
    print_status ""
    print_status "To stop the application:"
    if command -v docker-compose &> /dev/null; then
        print_status "  docker-compose down"
    else
        print_status "  docker compose down"
    fi
}

# Run main function
main "$@"
