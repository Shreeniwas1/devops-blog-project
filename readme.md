~/devops-blog-project/
├── frontend/             # Your React/Vue/Static HTML files
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   └── package.json
├── backend/              # Your Node.js/Express API
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── kubernetes/           # All Kubernetes YAML manifests
│   ├── deployments/
│   │   ├── frontend-deployment.yaml
│   │   ├── backend-deployment.yaml
│   │   └── postgres-statefulset.yaml
│   ├── services/
│   │   ├── frontend-service.yaml
│   │   ├── backend-service.yaml
│   │   └── postgres-service.yaml
│   ├── ingress/
│   │   └── blog-ingress.yaml
│   ├── configmaps/
│   ├── secrets/          # Use for template/example, not actual secrets
│   └── cloudflare-tunnel/
│       └── cloudflared-deployment.yaml
├── jenkins/              # Jenkinsfile and any related scripts
│   └── Jenkinsfile
├── monitoring/           # Prometheus/Grafana configs (if external to K8s)
│   ├── prometheus.yaml
│   └── grafana-dashboards/
│       └── my-blog-dashboard.json
├── docs/                 # Project documentation, architecture diagrams
│   └── README.md
├── scripts/              # Helper scripts (e.g., local K8s setup, cleanup)
├── .gitignore
└── README.md             # Project overview