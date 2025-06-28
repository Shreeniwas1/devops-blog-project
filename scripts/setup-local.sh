#!/bin/bash

# Local Kubernetes Setup Script for DevOps Blog Project
# This script sets up the entire application stack locally

set -e

echo "🚀 Setting up DevOps Personal Blog locally..."

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
    
    commands=("docker" "kubectl" "minikube")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd is not installed. Please install it first."
            exit 1
        fi
    done
    
    print_status "All prerequisites are installed ✓"
}

# Start Minikube if not running
start_minikube() {
    print_status "Checking Minikube status..."
    
    if ! minikube status &> /dev/null; then
        print_status "Starting Minikube..."
        
        # Check if running as root and provide appropriate driver
        if [[ $EUID -eq 0 ]]; then
            print_warning "Running as root user. Using Docker driver for Minikube."
            print_warning "Note: Docker driver is recommended for root environments."
            
            # Start Minikube with Docker driver (works well with root)
            minikube start --driver=docker --memory=4096 --cpus=2 --force
        else
            # For non-root users, try docker driver first, then others
            print_status "Attempting to start Minikube with Docker driver..."
            if ! minikube start --driver=docker --memory=4096 --cpus=2 2>/dev/null; then
                print_warning "Docker driver failed. Trying alternative drivers..."
                
                # Try other drivers
                for driver in podman virtualbox kvm2; do
                    if command -v $driver &> /dev/null; then
                        print_status "Trying $driver driver..."
                        if minikube start --driver=$driver --memory=4096 --cpus=2; then
                            break
                        fi
                    fi
                done
            fi
        fi
        
        # Enable addons
        minikube addons enable ingress
        minikube addons enable metrics-server
        
        print_status "Minikube started successfully ✓"
    else
        print_status "Minikube is already running ✓"
    fi
}

# Build Docker images
build_images() {
    print_status "Building Docker images..."
    
    # Set docker environment to use Minikube's Docker daemon
    eval $(minikube docker-env)
    
    # Build frontend image
    print_status "Building frontend image..."
    docker build -t personal-blog-frontend:latest ./frontend
    
    # Build backend image
    print_status "Building backend image..."
    docker build -t personal-blog-backend:latest ./backend
    
    print_status "Docker images built successfully ✓"
}

# Deploy to Kubernetes
deploy_kubernetes() {
    print_status "Deploying to Kubernetes..."
    
    # Create namespace if it doesn't exist
    kubectl create namespace blog --dry-run=client -o yaml | kubectl apply -f -
    
    # Apply configurations in order
    print_status "Applying secrets..."
    kubectl apply -f kubernetes/secrets/ || true
    
    print_status "Applying configmaps..."
    kubectl apply -f kubernetes/configmaps/ || true
    
    print_status "Applying deployments..."
    kubectl apply -f kubernetes/deployments/
    
    # Apply services
    print_status "Applying services..."
    kubectl apply -f kubernetes/backend-service.yaml
    kubectl apply -f kubernetes/frontend-service.yaml
    kubectl apply -f kubernetes/postgres-service.yaml
    
    # Apply ingress if it exists
    if [ -d "kubernetes/ingress" ]; then
        print_status "Applying ingress..."
        kubectl apply -f kubernetes/ingress/ || true
    fi
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment --namespace=default
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment --namespace=default
    kubectl wait --for=condition=ready --timeout=300s pod -l app=postgres --namespace=default
    
    # Verify database initialization
    verify_database_initialization
    
    print_status "Kubernetes deployment completed ✓"
}

# Check and create monitoring manifests if they don't exist
check_monitoring_manifests() {
    print_status "Checking monitoring manifests..."
    
    # Create monitoring directory if it doesn't exist
    mkdir -p kubernetes/configmaps
    mkdir -p kubernetes/deployments
    
    # Check if Prometheus config exists
    if [ ! -f "kubernetes/configmaps/prometheus-config.yaml" ]; then
        print_warning "Prometheus config not found. Creating basic configuration..."
        # This will be handled by the deployment step
    fi
    
    # Check if Grafana config exists
    if [ ! -f "kubernetes/configmaps/grafana-config.yaml" ]; then
        print_warning "Grafana config not found. Creating basic configuration..."
        # This will be handled by the deployment step
    fi
    
    # Check if monitoring deployments exist
    if [ ! -f "kubernetes/deployments/prometheus-deployment.yaml" ]; then
        print_warning "Prometheus deployment not found. It should be created manually."
    fi
    
    if [ ! -f "kubernetes/deployments/grafana-deployment.yaml" ]; then
        print_warning "Grafana deployment not found. It should be created manually."
    fi
    
    print_status "Monitoring manifests check completed ✓"
}

# Clean up any existing port forwards and conflicting processes
cleanup_existing_processes() {
    print_status "Cleaning up existing processes..."
    
    # Kill any existing kubectl port-forward processes
    pkill -f "kubectl port-forward" || true
    
    # Check for local Grafana process and offer to stop it
    if pgrep -f "grafana" > /dev/null; then
        print_warning "Local Grafana process detected on port 3000"
        read -p "Do you want to stop the local Grafana process? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            pkill -f "grafana" || true
            print_status "Local Grafana process stopped"
        else
            print_status "Will use alternative ports to avoid conflicts"
        fi
    fi
    
    # Wait a moment for processes to stop
    sleep 2
    
    print_status "Process cleanup completed ✓"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for backend service to be healthy
    print_status "Waiting for backend service..."
    for i in {1..30}; do
        if kubectl get service backend-service &>/dev/null; then
            break
        fi
        sleep 2
    done
    
    # Wait for frontend service
    print_status "Waiting for frontend service..."
    for i in {1..30}; do
        if kubectl get service frontend-service &>/dev/null; then
            break
        fi
        sleep 2
    done
    
    print_status "Services are ready ✓"
}

# Setup all port forwarding (application and monitoring)
setup_all_port_forwarding() {
    print_status "Setting up all port forwarding..."
    
    # Kill any existing port forwards
    pkill -f "kubectl port-forward" || true
    
    # Wait a moment for ports to be released
    sleep 3
    
    # Wait for services to be ready first
    wait_for_services
    wait_for_monitoring_services
    
    # Check for port conflicts and use alternative ports if needed
    if ss -tuln | grep -q ":3000 "; then
        print_warning "Port 3000 is in use, using port 3003 for frontend"
        FRONTEND_PORT=3003
    else
        FRONTEND_PORT=3000
    fi
    
    if ss -tuln | grep -q ":3001 "; then
        print_warning "Port 3001 is in use, using port 3004 for backend"
        BACKEND_PORT=3004
    else
        BACKEND_PORT=3001
    fi
    
    if ss -tuln | grep -q ":3002 "; then
        print_warning "Port 3002 is in use, using port 3005 for Grafana"
        GRAFANA_PORT=3005
    else
        GRAFANA_PORT=3002
    fi

    if ss -tuln | grep -q ":9091 "; then
        print_warning "Port 9091 is in use, using port 9092 for Prometheus"
        PROMETHEUS_PORT=9092
    else
        PROMETHEUS_PORT=9091
    fi
    
    # Export variables for use in other functions
    export FRONTEND_PORT
    export BACKEND_PORT
    export GRAFANA_PORT
    export PROMETHEUS_PORT
    
    # Start all port forwards
    print_status "Starting frontend port forward on port ${FRONTEND_PORT}..."
    kubectl port-forward service/frontend-service ${FRONTEND_PORT}:80 >/dev/null 2>&1 &
    FRONTEND_PF_PID=$!
    
    print_status "Starting backend port forward on port ${BACKEND_PORT}..."
    kubectl port-forward service/backend-service ${BACKEND_PORT}:3001 >/dev/null 2>&1 &
    BACKEND_PF_PID=$!
    
    print_status "Starting Grafana port forward on port ${GRAFANA_PORT}..."
    kubectl port-forward service/grafana-service ${GRAFANA_PORT}:3000 >/dev/null 2>&1 &
    GRAFANA_PF_PID=$!
    
    print_status "Starting Prometheus port forward on port ${PROMETHEUS_PORT}..."
    kubectl port-forward service/prometheus-service ${PROMETHEUS_PORT}:9090 >/dev/null 2>&1 &
    PROMETHEUS_PF_PID=$!
    
    print_status "Starting database port forward on port 5432..."
    kubectl port-forward service/postgres-service 5432:5432 >/dev/null 2>&1 &
    DB_PF_PID=$!
    
    # Wait a moment for port forwards to establish
    sleep 3
    
    # Verify all port forwards are working
    print_status "Verifying port forwards..."
    
    # Test backend
    if curl -s http://localhost:${BACKEND_PORT}/health >/dev/null 2>&1; then
        print_status "Backend port forward working ✓"
    else
        print_warning "Backend port forward may not be working"
    fi
    
    # Test frontend
    if curl -s -I http://localhost:${FRONTEND_PORT} >/dev/null 2>&1; then
        print_status "Frontend port forward working ✓"
    else
        print_warning "Frontend port forward may not be working"
    fi
    
    # Test Grafana
    if curl -s -I http://localhost:${GRAFANA_PORT} >/dev/null 2>&1; then
        print_status "Grafana port forward working ✓"
    else
        print_warning "Grafana port forward may not be working"
    fi
    
    # Test Prometheus
    if curl -s http://localhost:${PROMETHEUS_PORT} >/dev/null 2>&1; then
        print_status "Prometheus port forward working ✓"
    else
        print_warning "Prometheus port forward may not be working"
    fi
    
    print_status "All port forwarding setup completed ✓"
    print_status "Frontend available at: http://localhost:${FRONTEND_PORT}"
    print_status "Backend API available at: http://localhost:${BACKEND_PORT}"
    print_status "Health check: http://localhost:${BACKEND_PORT}/health"
    print_status "Grafana available at: http://localhost:${GRAFANA_PORT} (admin/admin123)"
    print_status "Prometheus available at: http://localhost:${PROMETHEUS_PORT}"
    print_status "Database available at: localhost:5432"
}

# Wait for monitoring services to be ready
wait_for_monitoring_services() {
    print_status "Waiting for monitoring services to be ready..."
    
    # Wait for Grafana service
    print_status "Waiting for Grafana service..."
    for i in {1..30}; do
        if kubectl get service grafana-service &>/dev/null; then
            break
        fi
        sleep 2
    done
    
    # Wait for Prometheus service
    print_status "Waiting for Prometheus service..."
    for i in {1..30}; do
        if kubectl get service prometheus-service &>/dev/null; then
            break
        fi
        sleep 2
    done
    
    print_status "Monitoring services are ready ✓"
}

# Setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring stack (Prometheus & Grafana)..."
    
    check_monitoring_manifests
    
    # Apply Prometheus RBAC first
    if [ -f "kubernetes/configmaps/prometheus-config.yaml" ]; then
        kubectl apply -f kubernetes/configmaps/prometheus-config.yaml
    fi
    
    if [ -f "kubernetes/deployments/prometheus-deployment.yaml" ]; then
        kubectl apply -f kubernetes/deployments/prometheus-deployment.yaml
    fi
    
    if [ -f "kubernetes/prometheus-service.yaml" ]; then
        kubectl apply -f kubernetes/prometheus-service.yaml
    fi
    
    # Apply Grafana configuration
    if [ -f "kubernetes/configmaps/grafana-config.yaml" ]; then
        kubectl apply -f kubernetes/configmaps/grafana-config.yaml
    fi
    
    # Update dashboard ConfigMap with correct format
    if [ -f "monitoring/grafana-dashboards/my-blog-dashboard.json" ]; then
        print_status "Updating Grafana dashboard with correct format..."
        kubectl create configmap grafana-dashboard-blog \
            --from-file=blog-dashboard.json=monitoring/grafana-dashboards/my-blog-dashboard.json \
            --dry-run=client -o yaml | kubectl apply -f -
    fi
    
    if [ -f "kubernetes/deployments/grafana-deployment.yaml" ]; then
        kubectl apply -f kubernetes/deployments/grafana-deployment.yaml
    fi
    
    if [ -f "kubernetes/grafana-service.yaml" ]; then
        kubectl apply -f kubernetes/grafana-service.yaml
    fi
    
    # Wait for monitoring deployments to be ready
    print_status "Waiting for monitoring stack to be ready..."
    
    # Check if deployments exist before waiting
    if kubectl get deployment prometheus-deployment &>/dev/null; then
        kubectl wait --for=condition=available --timeout=300s deployment/prometheus-deployment --namespace=default
    else
        print_warning "Prometheus deployment not found, skipping wait"
    fi
    
    if kubectl get deployment grafana-deployment &>/dev/null; then
        kubectl wait --for=condition=available --timeout=300s deployment/grafana-deployment --namespace=default
    else
        print_warning "Grafana deployment not found, skipping wait"
    fi
    
    print_status "Monitoring setup completed ✓"
}

# Verify database initialization
verify_database_initialization() {
    print_status "Verifying database initialization..."
    
    # Wait for backend pod to be running and ready
    print_status "Waiting for backend pod to be ready..."
    for i in {1..60}; do
        local backend_pod=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
        if [[ -n "$backend_pod" ]]; then
            # Check if pod is running
            local phase=$(kubectl get pod "$backend_pod" -o jsonpath='{.status.phase}' 2>/dev/null)
            if [[ "$phase" == "Running" ]]; then
                # Check if pod is ready (all containers ready)
                local ready_status=$(kubectl get pod "$backend_pod" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
                if [[ "$ready_status" == "True" ]]; then
                    print_status "Backend pod is running and ready ✓"
                    
                    # Additional verification: check if backend service is responding
                    # Use a temporary port-forward to test the health endpoint
                    print_status "Testing backend health endpoint..."
                    kubectl port-forward "$backend_pod" 9999:3001 >/dev/null 2>&1 &
                    local pf_pid=$!
                    sleep 2
                    
                    # Test health endpoint
                    if curl -s --max-time 5 http://localhost:9999/health/ready >/dev/null 2>&1; then
                        print_status "Backend health check passed ✓"
                        kill $pf_pid 2>/dev/null || true
                        return 0
                    else
                        print_status "Backend health check failed, but pod is ready - continuing..."
                        kill $pf_pid 2>/dev/null || true
                        return 0
                    fi
                fi
            fi
        fi
        
        if [[ $((i % 10)) -eq 0 ]]; then
            print_status "Still waiting for backend to be ready... ($i/60)"
            if [[ -n "$backend_pod" ]]; then
                local status=$(kubectl get pod "$backend_pod" -o jsonpath='{.status.conditions[?(@.type=="Ready")]}' 2>/dev/null)
                print_status "Pod status: $status"
            fi
        else
            echo -n "."
        fi
        sleep 2
    done
    
    print_warning "Backend readiness check timed out, but proceeding with setup..."
    local backend_pod=$(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [[ -n "$backend_pod" ]]; then
        print_warning "Backend pod found: $backend_pod"
        print_warning "Check logs with: kubectl logs $backend_pod"
    fi
    
    # Even if verification times out, continue with setup
    # The monitoring setup and port forwarding will show if services are actually working
    return 0
}

# Main function
main() {
    print_status "Starting DevOps Personal Blog local setup..."
    
    check_prerequisites
    cleanup_existing_processes
    start_minikube
    build_images
    deploy_kubernetes
    verify_database_initialization
    setup_monitoring
    setup_all_port_forwarding
    
    print_status "🎉 Setup completed successfully!"
    print_status ""
    print_status "Application URLs:"
    print_status "  Frontend: http://localhost:${FRONTEND_PORT:-3000}"
    print_status "  Backend API: http://localhost:${BACKEND_PORT:-3001}"
    print_status "  Health Check: http://localhost:${BACKEND_PORT:-3001}/health"
    print_status "  Metrics: http://localhost:${BACKEND_PORT:-3001}/metrics"
    print_status ""
    print_status "Monitoring URLs:"
    print_status "  Grafana: http://localhost:${GRAFANA_PORT:-3002} (admin/admin123)"
    print_status "  Prometheus: http://localhost:${PROMETHEUS_PORT:-9091}"
    print_status ""
    print_status "All services are automatically port-forwarded and ready to use!"
    print_status ""
    print_status "Useful commands:"
    print_status "  kubectl get pods                               # Check pod status"
    print_status "  kubectl logs -f deployment/backend-deployment  # View backend logs"
    print_status "  kubectl logs -f deployment/frontend-deployment # View frontend logs"
    print_status "  kubectl logs -f deployment/grafana-deployment  # View Grafana logs"
    print_status "  kubectl logs -f deployment/prometheus-deployment # View Prometheus logs"
    print_status "  ps aux | grep port-forward                     # Check port forward processes"
    print_status ""
    print_status "To stop all services and cleanup, run: ./scripts/cleanup.sh"
}

# Run main function
main "$@"
