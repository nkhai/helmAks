# Nginx Helm Chart Structure

## 📁 Directory Structure

```
C:\WorkPlace\helm\
├── create-chart/
│   └── nginx/                          # Helm chart root
│       ├── Chart.yaml                  # Chart metadata
│       ├── values.yaml                 # Default configuration values
│       ├── .helmignore                 # Files to ignore during packaging
│       └── templates/                  # Kubernetes manifest templates
│           ├── deployment.yaml         # Nginx deployment
│           └── service.yaml            # ClusterIP service
└── setting-values/                     # Additional values directory
```

## 🎯 Chart Details

### **Chart Information (Chart.yaml):**
- **Name**: nginx
- **Version**: 0.1.0
- **App Version**: 1.25.3
- **Type**: Application chart
- **Description**: Basic Nginx Helm chart for Kubernetes deployment

### **Deployment Configuration (deployment.yaml):**
- **Image**: `nginx:1.25.3` from Docker Hub
- **Replicas**: 1
- **Port**: 80 (HTTP)
- **Labels**: `app: nginx`, `version: 1.25.3`
- **Health Checks**: Liveness and readiness probes configured
- **Resources**: CPU and memory limits/requests defined

### **Service Configuration (service.yaml):**
- **Type**: ClusterIP
- **Port**: 80 → 80 (HTTP)
- **Selector**: `app: nginx`
- **Protocol**: TCP

### **Key Features:**
- ✅ **No Helm templating variables** - Static configuration as requested
- ✅ **Basic nginx deployment** with single replica
- ✅ **ClusterIP service** for internal cluster access
- ✅ **Health probes** for production readiness
- ✅ **Resource limits** for cluster resource management
- ✅ **Comprehensive .helmignore** for clean packaging

## 🚀 Usage Commands

### **Install the chart:**
```bash
helm install my-nginx ./create-chart/nginx
```

### **Package the chart:**
```bash
helm package ./create-chart/nginx
```

### **Lint the chart:**
```bash
helm lint ./create-chart/nginx
```

### **Template validation:**
```bash
helm template my-nginx ./create-chart/nginx
```

## 📋 Notes

- All values are hardcoded (no Helm templating variables used)
- Chart follows Helm best practices for structure
- Ready for deployment to any Kubernetes cluster
- Service exposes nginx on port 80 within the cluster