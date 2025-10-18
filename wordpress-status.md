# WordPress Status Commands - Clean Formatting

## 🎯 Quick Status Check (Clean JSON Format)

```bash
# Service details in clean JSON
kubectl get svc my-wordpress -o json | jq '{
  name: .metadata.name,
  type: .spec.type,
  clusterIP: .spec.clusterIP,
  ports: .spec.ports
}'

# Pod status in clean JSON
kubectl get pods -l app.kubernetes.io/name=wordpress -o json | jq '.items[] | {
  name: .metadata.name,
  status: .status.phase,
  ready: .status.containerStatuses[0].ready,
  ip: .status.podIP,
  node: .spec.nodeName
}'

# All services in table format
kubectl get svc -o wide

# Pods with detailed info
kubectl get pods -o wide
```

## 📊 Current WordPress Status (Last Check)

### Service Details:
```json
{
  "name": "my-wordpress",
  "type": "NodePort",
  "clusterIP": "10.109.78.59",
  "ports": [
    {
      "name": "http",
      "nodePort": 30080,
      "port": 80,
      "protocol": "TCP",
      "targetPort": "http"
    },
    {
      "name": "https",
      "nodePort": 30443,
      "port": 443,
      "protocol": "TCP",
      "targetPort": "https"
    }
  ]
}
```

### Pod Status:
```json
{
  "name": "my-wordpress-6696c64b85-krt9z",
  "status": "Running",
  "ready": true,
  "ip": "10.244.0.3",
  "node": "minikube"
}
```

### Access Information:
- **Minikube IP**: `192.168.49.2`
- **WordPress URL**: `http://192.168.49.2:30080`
- **HTTPS URL**: `https://192.168.49.2:30443`
- **Status**: ✅ **Running and Accessible**

## 🛠 Useful Formatting Commands

### 1. YAML Output (Human Readable)
```bash
kubectl get svc my-wordpress -o yaml
kubectl get pod my-wordpress-6696c64b85-krt9z -o yaml
```

### 2. Custom Columns (Table Format)
```bash
kubectl get pods -o custom-columns="NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP,NODE:.spec.nodeName"
kubectl get svc -o custom-columns="NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,PORTS:.spec.ports[*].port"
```

### 3. JSONPath Queries (Specific Fields)
```bash
# Get just the NodePort
kubectl get svc my-wordpress -o jsonpath='{.spec.ports[0].nodePort}'

# Get pod IPs
kubectl get pods -o jsonpath='{.items[*].status.podIP}'

# Get service type
kubectl get svc my-wordpress -o jsonpath='{.spec.type}'
```

### 4. Using jq for Complex Filtering
```bash
# Filter running pods only
kubectl get pods -o json | jq '.items[] | select(.status.phase=="Running") | {name: .metadata.name, ip: .status.podIP}'

# Get all NodePort services
kubectl get svc -o json | jq '.items[] | select(.spec.type=="NodePort") | {name: .metadata.name, ports: .spec.ports}'
```

## 🎨 Pretty Print Tips

1. **Always use `jq` for JSON formatting**:
   ```bash
   kubectl get svc -o json | jq '.'
   ```

2. **Use `-o wide` for extended table view**:
   ```bash
   kubectl get pods -o wide
   ```

3. **Use `-o yaml` for human-readable config**:
   ```bash
   kubectl get svc my-wordpress -o yaml
   ```

4. **Use custom-columns for specific data**:
   ```bash
   kubectl get pods -o custom-columns="NAME:.metadata.name,STATUS:.status.phase"
   ```