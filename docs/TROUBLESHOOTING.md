# Troubleshooting Guide for DevOps Blog Project

## Common Issues and Solutions

### 1. Minikube Docker Driver Root Error

**Error**: `The "docker" driver should not be used with root privileges`

**Solutions**:

#### Option A: Use Docker Compose (Recommended for Development)
```bash
# Use the Docker Compose setup instead
./scripts/setup-docker-compose.sh
```

#### Option B: Run as Non-Root User
```bash
# Create a non-root user
sudo adduser devops
sudo usermod -aG docker devops
sudo usermod -aG sudo devops

# Switch to the new user
su - devops
cd /path/to/project

# Run the setup
./scripts/setup-local.sh
```

#### Option C: Use Minikube with 'none' driver (Root Required)
```bash
# The updated script now handles this automatically
# It will use 'none' driver when running as root
./scripts/setup-local.sh
```

#### Option D: Use Alternative Drivers
```bash
# Install VirtualBox
sudo apt-get install virtualbox

# Or install KVM
sudo apt-get install qemu-kvm libvirt-daemon-system

# The script will automatically try alternative drivers
```

### 2. Docker Permission Issues

**Error**: `Got permission denied while trying to connect to the Docker daemon socket`

**Solutions**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Or logout and login again
```

### 3. Port Already in Use

**Error**: `Port 3000/3001/5432 is already in use`

**Solutions**:
```bash
# Find and kill processes using the ports
sudo lsof -ti:3000 | xargs kill -9
sudo lsof -ti:3001 | xargs kill -9
sudo lsof -ti:5432 | xargs kill -9

# Or use different ports in docker-compose.yml
```

### 4. Kubernetes Deployment Issues

**Error**: `ImagePullBackOff` or `ErrImagePull`

**Solutions**:
```bash
# Ensure Docker environment is set to Minikube
eval $(minikube docker-env)

# Rebuild images
docker build -t personal-blog-frontend:latest ./frontend
docker build -t personal-blog-backend:latest ./backend

# Check if images exist
docker images | grep personal-blog
```

### 5. Database Connection Issues

**Error**: `Connection refused` or `Database not available`

**Solutions**:
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check database logs
docker logs <postgres-container-id>

# For Kubernetes
kubectl logs -f deployment/postgres-statefulset -n blog

# Test database connection
psql -h localhost -U bloguser -d blogdb
```

### 6. Frontend Not Loading

**Error**: `Cannot connect to backend API`

**Solutions**:
```bash
# Check if backend is running
curl http://localhost:3001/health

# Check backend logs
docker logs <backend-container-id>

# For Kubernetes
kubectl logs -f deployment/backend-deployment -n blog

# Verify environment variables
docker exec <backend-container-id> env | grep DB_
```

### 7. Minikube Won't Start

**Error**: Various Minikube startup errors

**Solutions**:
```bash
# Delete existing cluster
minikube delete

# Start fresh
minikube start --driver=docker --memory=4096 --cpus=2

# Check system resources
free -h
df -h

# Check Docker daemon
sudo systemctl status docker
```

### 8. Monitoring Stack Issues

**Error**: Prometheus/Grafana not accessible

**Solutions**:
```bash
# Check if Helm is installed
helm version

# Check monitoring namespace
kubectl get pods -n monitoring

# Restart monitoring stack
helm uninstall prometheus -n monitoring
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set grafana.adminPassword=admin123
```

## Useful Debugging Commands

### Docker Commands
```bash
# List all containers
docker ps -a

# View container logs
docker logs <container-name>

# Execute commands in container
docker exec -it <container-name> /bin/bash

# View container resource usage
docker stats

# Clean up unused resources
docker system prune -a
```

### Kubernetes Commands
```bash
# Check cluster status
kubectl cluster-info

# List all resources
kubectl get all -n blog

# Describe a resource
kubectl describe pod <pod-name> -n blog

# Get logs
kubectl logs -f <pod-name> -n blog

# Execute commands in pod
kubectl exec -it <pod-name> -n blog -- /bin/bash

# Port forward for debugging
kubectl port-forward <pod-name> 3001:3001 -n blog
```

### Database Debugging
```bash
# Connect to database
psql -h localhost -U bloguser -d blogdb

# Check database tables
\dt

# View table contents
SELECT * FROM posts;

# Check database configuration
SHOW all;
```

### Minikube Commands
```bash
# Check Minikube status
minikube status

# View Minikube logs
minikube logs

# SSH into Minikube
minikube ssh

# Check Minikube IP
minikube ip

# Open dashboard
minikube dashboard
```

## Performance Optimization

### For Low-Resource Systems
```bash
# Reduce Minikube resources
minikube start --memory=2048 --cpus=1

# Reduce container resources in docker-compose.yml
# Comment out monitoring services if not needed
```

### For Development
```bash
# Use Docker Compose for faster development
./scripts/setup-docker-compose.sh

# Enable hot reload for frontend
cd frontend && npm start

# Use nodemon for backend
cd backend && npm run dev
```

## Emergency Cleanup

### Complete Cleanup
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images
docker rmi $(docker images -q)

# Clean up Minikube
minikube delete --all

# Clean up Docker Compose
docker-compose down -v --rmi all
```

### Partial Cleanup
```bash
# Use the provided cleanup script
./scripts/cleanup.sh

# Or clean up specific services
docker-compose down
kubectl delete namespace blog
```

## Getting Help

### Log Locations
- Docker logs: `docker logs <container-name>`
- Kubernetes logs: `kubectl logs <pod-name> -n blog`
- System logs: `/var/log/syslog` (Linux)

### Health Checks
```bash
# Application health
curl http://localhost:3001/health

# Service status
docker-compose ps
kubectl get pods -n blog

# Resource usage
docker stats
kubectl top pods -n blog
```

### Useful Aliases
```bash
# Add to ~/.bashrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias dc='docker-compose'
alias dps='docker ps'
```

## Support Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Node.js Documentation](https://nodejs.org/en/docs/)
- [React Documentation](https://reactjs.org/docs/)

Remember: When in doubt, check the logs first!
