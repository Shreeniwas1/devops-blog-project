#!/bin/bash

# Validation script to check if all required files exist
echo "🔍 Validating DevOps Blog Project setup..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_check() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $1 missing"
        return 1
    fi
}

print_dir_check() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} Directory $1 exists"
        return 0
    else
        echo -e "${RED}✗${NC} Directory $1 missing"
        return 1
    fi
}

echo "Checking core application files..."
print_check "frontend/Dockerfile"
print_check "backend/Dockerfile"
print_check "backend/package.json"
print_check "frontend/package.json"

echo -e "\nChecking Kubernetes manifests..."
print_dir_check "kubernetes"
print_check "kubernetes/deployments/backend-deployment.yaml"
print_check "kubernetes/deployments/frontend-deployment.yaml"
print_check "kubernetes/deployments/postgres-statefulset.yaml"
print_check "kubernetes/backend-service.yaml"
print_check "kubernetes/frontend-service.yaml"
print_check "kubernetes/postgres-service.yaml"

echo -e "\nChecking monitoring manifests..."
print_check "kubernetes/deployments/prometheus-deployment.yaml"
print_check "kubernetes/deployments/grafana-deployment.yaml"
print_check "kubernetes/configmaps/prometheus-config.yaml"
print_check "kubernetes/configmaps/grafana-config.yaml"
print_check "kubernetes/prometheus-service.yaml"
print_check "kubernetes/grafana-service.yaml"
print_check "monitoring/grafana-dashboards/my-blog-dashboard.json"

echo -e "\nChecking scripts..."
print_check "scripts/setup-local.sh"
print_check "scripts/cleanup.sh"

echo -e "\nValidation completed!"
echo -e "${YELLOW}Note:${NC} Missing files will be created or ignored during setup."
