#!/bin/bash

# Simple Docker setup without Docker Compose
# This script runs each service individually using docker run commands

set -e

echo "🚀 Setting up DevOps Personal Blog with individual Docker containers..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create network
create_network() {
    print_status "Creating Docker network..."
    docker network create blog-network || print_warning "Network already exists"
}

# Start PostgreSQL
start_database() {
    print_status "Starting PostgreSQL database..."
    
    docker run -d \
        --name blog-postgres \
        --network blog-network \
        -e POSTGRES_DB=blogdb \
        -e POSTGRES_USER=bloguser \
        -e POSTGRES_PASSWORD=blogpassword \
        -p 5432:5432 \
        -v blog-postgres-data:/var/lib/postgresql/data \
        postgres:15-alpine || print_warning "PostgreSQL container already exists"
        
    print_status "Waiting for PostgreSQL to be ready..."
    sleep 10
    
    # Initialize database with sample data
    docker exec blog-postgres psql -U bloguser -d blogdb -c "
        CREATE TABLE IF NOT EXISTS posts (
            id SERIAL PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            content TEXT NOT NULL,
            excerpt TEXT,
            tags VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        
        INSERT INTO posts (title, content, excerpt, tags) 
        SELECT 'Welcome to DevOps Blog', 
               'This is a sample blog post about DevOps practices...', 
               'Learn about DevOps with this comprehensive guide', 
               'DevOps, Tutorial, Getting Started'
        WHERE NOT EXISTS (SELECT 1 FROM posts LIMIT 1);
    " || print_warning "Database initialization may have failed"
}

# Build and start backend
start_backend() {
    print_status "Building and starting backend..."
    
    # Build backend image
    docker build -t blog-backend:latest ./backend
    
    # Start backend container
    docker run -d \
        --name blog-backend \
        --network blog-network \
        -e NODE_ENV=development \
        -e PORT=3001 \
        -e DB_HOST=blog-postgres \
        -e DB_PORT=5432 \
        -e DB_NAME=blogdb \
        -e DB_USER=bloguser \
        -e DB_PASSWORD=blogpassword \
        -e JWT_SECRET=dev-jwt-secret \
        -p 3001:3001 \
        blog-backend:latest || print_warning "Backend container already exists"
}

# Build and start frontend
start_frontend() {
    print_status "Building and starting frontend..."
    
    # Create environment file for frontend
    echo "REACT_APP_API_URL=http://localhost:3001" > ./frontend/.env
    
    # Build frontend image
    docker build -t blog-frontend:latest ./frontend
    
    # Start frontend container
    docker run -d \
        --name blog-frontend \
        --network blog-network \
        -p 3000:80 \
        blog-frontend:latest || print_warning "Frontend container already exists"
}

# Check service health
check_services() {
    print_status "Checking service health..."
    
    # Wait a moment for services to start
    sleep 5
    
    # Check backend health
    if curl -s http://localhost:3001/health > /dev/null; then
        print_status "Backend is healthy ✓"
    else
        print_warning "Backend health check failed"
    fi
    
    # Check frontend
    if curl -s http://localhost:3000 > /dev/null; then
        print_status "Frontend is accessible ✓"
    else
        print_warning "Frontend accessibility check failed"
    fi
}

# Clean up any existing containers
cleanup_existing() {
    print_status "Cleaning up existing containers..."
    
    docker stop blog-frontend blog-backend blog-postgres 2>/dev/null || true
    docker rm blog-frontend blog-backend blog-postgres 2>/dev/null || true
}

# Main function
main() {
    print_status "Starting simple Docker setup..."
    
    cleanup_existing
    create_network
    start_database
    start_backend
    start_frontend
    check_services
    
    print_status "🎉 Setup completed!"
    print_status ""
    print_status "Application URLs:"
    print_status "  Frontend: http://localhost:3000"
    print_status "  Backend API: http://localhost:3001"
    print_status "  Health Check: http://localhost:3001/health"
    print_status ""
    print_status "Container Management:"
    print_status "  View logs: docker logs blog-backend"
    print_status "  Stop all: docker stop blog-frontend blog-backend blog-postgres"
    print_status "  Remove all: docker rm blog-frontend blog-backend blog-postgres"
    print_status ""
    print_status "Happy coding! 🚀"
}

main "$@"
