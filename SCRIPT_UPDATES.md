# DevOps Blog Project - Script Updates Summary

## Updated Scripts for Grafana and Prometheus Integration

### 🧹 cleanup.sh Updates

**Enhanced Kubernetes cleanup:**
- Added cleanup for Grafana deployment and service
- Added cleanup for Prometheus deployment and service  
- Added cleanup for all monitoring ConfigMaps (datasources, dashboards, config)
- Added cleanup for Prometheus RBAC resources (ClusterRole, ClusterRoleBinding, ServiceAccount)
- Cleans up both namespaced and non-namespaced resources
- Added cleanup for monitoring Docker images

**Docker image cleanup:**
- Now removes Prometheus and Grafana images
- Maintains existing cleanup for blog application images

### 🚀 setup-local.sh Updates

**Monitoring Integration:**
- Replaced Helm-based monitoring with native Kubernetes manifests
- Added `check_monitoring_manifests()` function to validate required files
- Integrated Prometheus and Grafana deployment into main workflow
- Added proper error handling for missing manifests

**Deployment Flow:**
- Updated to deploy to default namespace (consistent with current setup)
- Fixed service references to match actual deployment structure
- Added monitoring deployment after main application deployment
- Improved error handling with fallback mechanisms

**Port Forwarding:**
- Fixed port conflicts (Grafana now on port 3002)
- Backend remains on port 3001
- Frontend on port 3000
- Prometheus on port 9091
- PostgreSQL on port 5432

### 🔍 New validate.sh Script

**Validation Features:**
- Checks existence of all required files
- Validates directory structure
- Color-coded output for easy reading
- Comprehensive check for monitoring components

## Usage Instructions

### Setup Everything:
```bash
./scripts/setup-local.sh
```

### Validate Project Structure:
```bash
./scripts/validate.sh
```

### Clean Everything Up:
```bash
./scripts/cleanup.sh
```

## Access URLs After Setup

- **Frontend**: http://localhost:3003 (or 3000 if available)
- **Backend API**: http://localhost:3001 (or 3004 if 3001 is in use)
- **Grafana**: http://localhost:3002 (or 3005 if 3002 is in use) - (admin/admin123)
- **Prometheus**: http://localhost:9091 (or 9092 if 9091 is in use)
- **Database**: localhost:5432

**Note**: The scripts automatically detect port conflicts and use alternative ports when needed.

## Key Improvements

1. **Consistent Namespace Usage**: All resources deploy to default namespace
2. **Robust Error Handling**: Scripts handle missing files gracefully
3. **Port Conflict Resolution**: Scripts now automatically detect port conflicts and use alternative ports
4. **Process Cleanup**: Added cleanup of existing processes that might conflict
5. **Complete Monitoring Stack**: Full Prometheus + Grafana integration
6. **Validation Support**: Easy way to check project completeness
7. **Comprehensive Cleanup**: Removes all created resources properly

### 🔧 **Port Conflict Handling**

The updated scripts include intelligent port conflict detection:

- **Frontend**: Uses port 3000, falls back to 3003 if occupied
- **Backend**: Uses port 3001, falls back to 3004 if occupied  
- **Grafana**: Uses port 3002, falls back to 3005 if occupied
- **Prometheus**: Uses port 9091, falls back to 9092 if occupied

The scripts will automatically detect if ports are in use and choose alternative ports, displaying the actual ports being used in the output.

## Prerequisites

- Docker
- kubectl
- Minikube
- All Kubernetes manifests (validated by scripts)

The scripts now provide a complete end-to-end solution for deploying and managing the DevOps Blog Project with full monitoring capabilities.

## Troubleshooting

### Dashboard "title cannot be empty" Error

If you see this error in Grafana logs:
```
error="Dashboard title cannot be empty"
```

**Solution:**
```bash
# Update the dashboard ConfigMap with correct format
kubectl create configmap grafana-dashboard-blog \
    --from-file=blog-dashboard.json=monitoring/grafana-dashboards/my-blog-dashboard.json \
    --dry-run=client -o yaml | kubectl apply -f -

# Restart Grafana to load the corrected dashboard
kubectl rollout restart deployment/grafana-deployment
```

### Port Conflicts

If you encounter port conflicts, the scripts will automatically detect and use alternative ports:
- Frontend: 3000 → 3003
- Backend: 3001 → 3004  
- Grafana: 3002 → 3005
- Prometheus: 9091 → 9092

### Services Not Accessible

Check pod status:
```bash
kubectl get pods
kubectl logs -f deployment/grafana-deployment
kubectl logs -f deployment/prometheus-deployment
```

Restart port forwarding:
```bash
pkill -f "kubectl port-forward"
kubectl port-forward service/grafana-service 3002:3000 &
kubectl port-forward service/prometheus-service 9091:9090 &
```
