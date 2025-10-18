# WordPress External IP Access Configuration

## 🌐 **Exposing WordPress via External IP: 135.171.192.43**

### **Scenario Analysis:**
Since you have a VM with IP `135.171.192.43`, we need to configure WordPress to be accessible from external networks. Here are the best approaches:

---

## 🚀 **Method 1: NodePort Service (Recommended for VM/Minikube)**

### **Update custome_param.yaml for NodePort:**
```yaml
# === Service Configuration ===
service:
  type: NodePort
  port: 80
  httpsPort: 443
  nodePorts:
    http: 30080
    https: 30443
```

### **Commands:**
```bash
# 1. Update the existing WordPress service
helm upgrade my-wordpress bitnami/wordpress --version 27.0.10 -f custome_param.yaml

# 2. Check the NodePort service
kubectl get svc my-wordpress

# 3. Access WordPress via:
# http://135.171.192.43:30080
# https://135.171.192.43:30443
```

---

## 🔧 **Method 2: LoadBalancer with External IP**

### **Update custome_param.yaml for LoadBalancer:**
```yaml
# === Service Configuration ===
service:
  type: LoadBalancer
  port: 80
  httpsPort: 443
  loadBalancerIP: "135.171.192.43"
  externalIPs:
    - "135.171.192.43"
```

### **Commands:**
```bash
# Update WordPress with LoadBalancer IP
helm upgrade my-wordpress bitnami/wordpress --version 27.0.10 -f custome_param.yaml

# Check service status
kubectl get svc my-wordpress -o wide
```

---

## 🛠️ **Method 3: Port Forwarding (Temporary Access)**

```bash
# Forward WordPress port to VM's external interface
kubectl port-forward svc/my-wordpress 8080:80 --address=0.0.0.0

# Access via: http://135.171.192.43:8080
```

---

## 🔒 **Method 4: Ingress Controller (Advanced)**

### **1. Install NGINX Ingress Controller:**
```bash
# For Minikube
minikube addons enable ingress

# For standard Kubernetes
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx
```

### **2. Update custome_param.yaml for Ingress:**
```yaml
# === Service Configuration ===
service:
  type: ClusterIP
  port: 80

# === Ingress Configuration ===
ingress:
  enabled: true
  hostname: wordpress.local
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
  extraHosts:
    - name: "135.171.192.43"
      path: /
  tls: false
```

### **3. Create Custom Ingress:**
```yaml
# wordpress-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: wordpress-external-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: "135.171.192.43"
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-wordpress
            port:
              number: 80
```

```bash
kubectl apply -f wordpress-ingress.yaml
```

---

## 🔥 **Complete Configuration Files**

### **Option A: NodePort Configuration (custome_param.yaml)**
```yaml
# WordPress Custom Configuration
# File: custome_param.yaml

# === WordPress Configuration ===
wordpressUsername: khai
wordpressBlogName: "Khai's WordPress Blog"
wordpressEmail: admin@example.com

# === Use Existing Secret ===
existingSecret: "custom-wp"

# === Replica Configuration ===
replicaCount: 3

# === MariaDB Configuration ===
mariadb:
  auth:
    existingSecret: "custom-wp"
    secretKeys:
      rootPasswordKey: "mariadb-root-password"
      userPasswordKey: "mariadb-password"
    database: wordpress
    username: wordpress

# === Service Configuration - NodePort ===
service:
  type: NodePort
  port: 80
  httpsPort: 443
  nodePorts:
    http: 30080
    https: 30443

# === WordPress External Access ===
wordpressScheme: http
wordpressHost: "135.171.192.43:30080"

# === Persistence Configuration ===
persistence:
  enabled: true
  size: 10Gi

# === Resource Configuration ===
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### **Option B: LoadBalancer Configuration (custome_param.yaml)**
```yaml
# WordPress Custom Configuration
# File: custome_param.yaml

# === WordPress Configuration ===
wordpressUsername: khai
wordpressBlogName: "Khai's WordPress Blog"
wordpressEmail: admin@example.com

# === Use Existing Secret ===
existingSecret: "custom-wp"

# === Replica Configuration ===
replicaCount: 3

# === MariaDB Configuration ===
mariadb:
  auth:
    existingSecret: "custom-wp"
    secretKeys:
      rootPasswordKey: "mariadb-root-password"
      userPasswordKey: "mariadb-password"
    database: wordpress
    username: wordpress

# === Service Configuration - LoadBalancer ===
service:
  type: LoadBalancer
  port: 80
  httpsPort: 443
  loadBalancerIP: "135.171.192.43"
  externalIPs:
    - "135.171.192.43"

# === WordPress External Access ===
wordpressScheme: http
wordpressHost: "135.171.192.43"

# === Persistence Configuration ===
persistence:
  enabled: true
  size: 10Gi

# === Resource Configuration ===
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

---

## 🚦 **Network Configuration Required**

### **1. VM Firewall Rules:**
```bash
# Allow HTTP traffic (port 80 and 30080)
sudo ufw allow 80/tcp
sudo ufw allow 30080/tcp
sudo ufw allow 443/tcp
sudo ufw allow 30443/tcp

# Or allow port range for NodePorts
sudo ufw allow 30000:32767/tcp
```

### **2. Azure NSG Rules (if using Azure VM):**
```bash
# Create inbound rules for WordPress access
az network nsg rule create \
  --resource-group vkn1hc \
  --nsg-name vkn1hcVmForTestTrainningNSG \
  --name AllowWordPressHTTP \
  --priority 1100 \
  --source-address-prefixes '*' \
  --destination-port-ranges 80 30080 \
  --access Allow \
  --protocol Tcp

az network nsg rule create \
  --resource-group vkn1hc \
  --nsg-name vkn1hcVmForTestTrainningNSG \
  --name AllowWordPressHTTPS \
  --priority 1101 \
  --source-address-prefixes '*' \
  --destination-port-ranges 443 30443 \
  --access Allow \
  --protocol Tcp
```

---

## 🎯 **Recommended Approach for Your Setup**

### **Step 1: Use NodePort (Easiest)**
```bash
# 1. Create the secret first
kubectl create secret generic custom-wp \
  --from-literal=wordpress-password=khaipass \
  --from-literal=mariadb-root-password=khaipass \
  --from-literal=mariadb-password=khaipass

# 2. Update your custome_param.yaml with NodePort configuration (Option A above)

# 3. Install/Upgrade WordPress
helm upgrade --install my-wordpress bitnami/wordpress --version 27.0.10 -f custome_param.yaml

# 4. Configure VM firewall
sudo ufw allow 30080/tcp
sudo ufw allow 30443/tcp

# 5. Access WordPress at:
# http://135.171.192.43:30080
```

### **Step 2: Verify Access**
```bash
# Check service status
kubectl get svc my-wordpress

# Check pods
kubectl get pods -l app.kubernetes.io/name=wordpress

# Test connectivity from VM
curl -I http://localhost:30080

# Access from browser:
# http://135.171.192.43:30080
```

---

## 📋 **Troubleshooting Commands**

```bash
# Check service details
kubectl describe svc my-wordpress

# Check endpoints
kubectl get endpoints my-wordpress

# Check if pods are ready
kubectl get pods -l app.kubernetes.io/name=wordpress -o wide

# Check logs
kubectl logs -l app.kubernetes.io/name=wordpress

# Test network connectivity
kubectl exec -it <wordpress-pod> -- wget -O- http://localhost:8080

# Check NodePort allocation
kubectl get svc my-wordpress -o jsonpath='{.spec.ports[*].nodePort}'
```

---

## 🌟 **Final Access URLs**

After configuration, you can access WordPress via:

- **NodePort**: `http://135.171.192.43:30080`
- **LoadBalancer**: `http://135.171.192.43` (if supported)
- **Port Forward**: `http://135.171.192.43:8080` (temporary)

**Login Credentials:**
- Username: `khai`
- Password: `khaipass`

Choose **NodePort method** for the most reliable access on VM/Minikube setups!