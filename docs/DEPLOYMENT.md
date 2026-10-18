# CraftCV Deployment and Operations Guide

This document describes the deployment architecture, containerization, monitoring setup, and Kubernetes orchestration for CraftCV (DevOps CSUL511 Midsem 2).

---

## 1. Containerization (M5)

CraftCV uses a multi-stage production Docker build defined in [Dockerfile](../Dockerfile):

- **Build Stage**: Node.js 20 Alpine environment (`node:20-alpine`) compiles Vite + React assets with optimization.
- **Production Stage**: Lightweight Nginx Alpine server (`nginx:alpine`) serves static bundles with:
  - SPA routing fallback (`try_files $uri $uri/ /index.html`).
  - Active `/health` endpoint responding with running commit SHA and health status.
  - Gzip asset compression and aggressive caching for immutable bundles.
  - Built-in container `HEALTHCHECK` pinging `/health`.

### Local Container Run
```bash
# Build the Docker image
make docker-build
# or: docker build -t craftcv:latest .

# Run with Docker Compose (includes Prometheus & Blackbox prober)
make docker-up
# or: docker compose up -d
```

### Endpoints
- **Application UI**: `http://localhost:80`
- **Health Check**: `http://localhost:80/health`
- **Prometheus UI**: `http://localhost:9090`
- **Blackbox Exporter**: `http://localhost:9115`

---

## 2. Monitoring Setup (M6)

Application uptime and HTTP metrics are continuously monitored using Prometheus and Blackbox Exporter:

- [monitoring/prometheus.yml](../monitoring/prometheus.yml): Scrapes Prometheus itself and delegates HTTP probing of `/health` and `/` to Blackbox Exporter.
- [monitoring/blackbox.yml](../monitoring/blackbox.yml): Configured for HTTP 2xx probes with 5-second timeouts.
- [monitoring/dashboard.json](../monitoring/dashboard.json): Pre-configured Grafana dashboard visualizing:
  - Uptime status gauge (`probe_success`)
  - HTTP status codes (`probe_http_status_code`)
  - Response latencies (`probe_duration_seconds`)
  - DNS lookup and TCP connect times

---

## 3. Kubernetes Orchestration (M7)

Kubernetes manifests are located in the [k8s/](../k8s) directory:

- [k8s/deployment.yaml](../k8s/deployment.yaml):
  - 2 Replicas with RollingUpdate strategy (`maxSurge: 1`, `maxUnavailable: 0`).
  - CPU & memory resource requests/limits.
  - Liveness & Readiness HTTP probes targeting `/health`.
- [k8s/service.yaml](../k8s/service.yaml):
  - NodePort service exposing port 80 externally via port 30080.

### Deploying to a Local Kubernetes Cluster (kind / k3d / minikube)
```bash
# Create local kind cluster
kind create cluster --name devops-craftcv

# Load or pull image
docker tag craftcv:latest ghcr.io/skit-devops-2026/devops-24eskcs084-frontend:latest
kind load docker-image ghcr.io/skit-devops-2026/devops-24eskcs084-frontend:latest --name devops-craftcv

# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Verify pods and service
kubectl get pods -l app=craftcv
kubectl get svc craftcv-service

# Capture screenshot for docs/deployment.png
# Save terminal screenshot or browser output showing kubectl get pods
```

---

## 4. Live Deployment Platforms (M6)

To obtain full marks for the Live URL:
1. Connect the repository `skit-devops-2026/devops-24ESKCS084` to **Render** (as a Static Site or Web Service using Docker) or **Vercel** / **Railway** / **Fly.io**.
2. Root directory: `Frontend` (or repository root with Docker).
3. Build command: `npm run build`.
4. Publish directory: `dist`.
5. Once deployed, verify `https://<your-app>.onrender.com/health` returns HTTP 200.
6. Update the `## Live URL` section in [README.md](../README.md) with your public URL.
