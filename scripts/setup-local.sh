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
    kubectl apply -f kubernetes/secrets/ -n blog
    
    print_status "Applying configmaps..."
    kubectl apply -f kubernetes/configmaps/ -n blog
    
    print_status "Applying deployments..."
    kubectl apply -f kubernetes/deployments/ -n blog
    
    print_status "Applying ingress..."
    kubectl apply -f kubernetes/ingress/ -n blog
    
    # Wait for deployments to be ready
    print_status "Waiting for deployments to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n blog
    kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n blog
    kubectl wait --for=condition=ready --timeout=300s pod -l app=postgres -n blog
    
    print_status "Kubernetes deployment completed ✓"
}

# Setup port forwarding
setup_port_forwarding() {
    print_status "Setting up port forwarding..."
    
    # Kill any existing port forwards
    pkill -f "kubectl port-forward" || true
    
    # Forward frontend service
    kubectl port-forward service/frontend-service 3000:80 -n blog &
    
    # Forward backend service
    kubectl port-forward service/backend-service 3001:3001 -n blog &
    
    # Forward PostgreSQL for debugging (optional)
    kubectl port-forward service/postgres-service 5432:5432 -n blog &
    
    print_status "Port forwarding setup completed ✓"
    print_status "Frontend available at: http://localhost:3000"
    print_status "Backend API available at: http://localhost:3001"
    print_status "Database available at: localhost:5432"
}

# Setup monitoring
setup_monitoring() {
    read -p "Do you want to set up monitoring (Prometheus/Grafana)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Setting up monitoring..."
        
        # Add Prometheus Helm repo
        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
        helm repo update
        
        # Install Prometheus
        helm install prometheus prometheus-community/kube-prometheus-stack \
            --namespace monitoring \
            --create-namespace \
            --set grafana.adminPassword=admin123
        
        # Wait for Prometheus to be ready
        kubectl wait --for=condition=ready --timeout=300s pod -l app.kubernetes.io/name=prometheus -n monitoring
        
        # Port forward Grafana
        kubectl port-forward service/prometheus-grafana 3003:80 -n monitoring &
        
        print_status "Monitoring setup completed ✓"
        print_status "Grafana available at: http://localhost:3003 (admin/admin123)"
    fi
}

# Main function
main() {
    print_status "Starting DevOps Personal Blog local setup..."
    
    check_prerequisites
    start_minikube
    build_images
    deploy_kubernetes
    setup_port_forwarding
    setup_monitoring
    
    print_status "🎉 Setup completed successfully!"
    print_status ""
    print_status "Application URLs:"
    print_status "  Frontend: http://localhost:3000"
    print_status "  Backend API: http://localhost:3001"
    print_status "  Health Check: http://localhost:3001/health"
    print_status "  Metrics: http://localhost:3001/metrics"
    print_status ""
    print_status "Useful commands:"
    print_status "  kubectl get pods -n blog"
    print_status "  kubectl logs -f deployment/backend-deployment -n blog"
    print_status "  kubectl logs -f deployment/frontend-deployment -n blog"
    print_status ""
    print_status "To stop the application, run: ./scripts/cleanup.sh"
}

# Run main function
main "$@"
