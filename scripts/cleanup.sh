#!/bin/bash

# Cleanup script for DevOps Blog Project
# This script cleans up all resources created during local setup

set -e

echo "🧹 Cleaning up DevOps Personal Blog resources..."

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

# Kill port forwards
cleanup_port_forwards() {
    print_status "Stopping port forwarding..."
    pkill -f "kubectl port-forward" || true
    print_status "Port forwarding stopped ✓"
}

# Remove Kubernetes resources
cleanup_kubernetes() {
    print_status "Removing Kubernetes resources..."
    
    # Delete blog namespace and all resources
    kubectl delete namespace blog --ignore-not-found=true
    
    # Delete monitoring namespace if it exists
    kubectl delete namespace monitoring --ignore-not-found=true
    
    print_status "Kubernetes resources cleaned up ✓"
}

# Remove Docker images
cleanup_docker_images() {
    print_status "Removing Docker images..."
    
    # Set docker environment to use Minikube's Docker daemon
    eval $(minikube docker-env) 2>/dev/null || true
    
    # Remove blog images
    docker rmi personal-blog-frontend:latest || true
    docker rmi personal-blog-backend:latest || true
    
    # Clean up dangling images
    docker image prune -f || true
    
    print_status "Docker images cleaned up ✓"
}

# Stop Minikube
stop_minikube() {
    read -p "Do you want to stop Minikube? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping Minikube..."
        minikube stop
        print_status "Minikube stopped ✓"
        
        read -p "Do you want to delete Minikube cluster completely? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_warning "This will delete the entire Minikube cluster!"
            minikube delete
            print_status "Minikube cluster deleted ✓"
        fi
    fi
}

# Main cleanup function
main() {
    print_status "Starting cleanup process..."
    
    cleanup_port_forwards
    cleanup_kubernetes
    cleanup_docker_images
    stop_minikube
    
    print_status "🎉 Cleanup completed successfully!"
    print_status ""
    print_status "All resources have been cleaned up."
    print_status "To start again, run: ./scripts/setup-local.sh"
}

# Run main function
main "$@"
