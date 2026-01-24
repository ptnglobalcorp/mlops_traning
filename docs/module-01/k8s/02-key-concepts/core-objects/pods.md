# Pods

**The smallest deployable unit in Kubernetes**

## Overview

A Pod is the smallest and simplest Kubernetes object. It represents a single instance of a running process in your cluster. Pods contain one or more containers that share storage, network, and runtime specifications.

## What is a Pod?

### Key Characteristics

- **Atomic unit**: One or more containers that must run together
- **Shared network**: All containers in a pod share the same IP address
- **Shared storage**: Containers can share volumes
- **Ephemeral**: Pods are created, destroyed, and recreated as needed
- **Unique IP**: Each pod gets a unique IP address in the cluster

### Pod vs Container

```
┌─────────────────────────────────────────────────────────────┐
│                        Pod                                  │
│  IP: 10.244.1.5                                            │
│                                                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Container 1 │  │  Container 2 │  │  Container 3 │     │
│  │   (App)      │  │  (Sidecar)   │  │  (Proxy)     │     │
│  │              │  │              │  │              │     │
│  │  Port: 8080  │  │  Port: 9090  │  │  Port: 80    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                            │
│  Shared:                                                   │
│  • Network namespace (IP, ports)                           │
│  • Storage volumes                                         │
│  • IPC namespace                                           │
│  • Security context                                        │
└─────────────────────────────────────────────────────────────┘
```

## When to Use Multi-Container Pods

### Common Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| **Sidecar** | Logging, monitoring | App + log collector |
| **Ambassador** | Proxy, routing | App + service mesh proxy |
| **Adapter** | Transform output | App + metrics adapter |
| **Init Container** | Setup tasks | Database migration before app starts |

### Example: ML Model Serving Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ml-model-pod
  labels:
    app: ml-model
    version: v2
spec:
  containers:
  # Main container: ML model serving
  - name: model-server
    image: registry/ml-model-serving:v2.1
    ports:
    - containerPort: 9000
      name: grpc
    resources:
      requests:
        memory: "2Gi"
        cpu: "1000m"
        nvidia.com/gpu: 1
      limits:
        memory: "4Gi"
        cpu: "2000m"
        nvidia.com/gpu: 1

  # Sidecar: Metrics collection
  - name: metrics-collector
    image: prometheus-exporter:latest
    ports:
    - containerPort: 9090
      name: metrics
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"

  # Sidecar: Logging
  - name: log-collector
    image: fluent-bit:latest
    volumeMounts:
    - name: varlog
      mountPath: /var/log
    resources:
      requests:
        memory: "64Mi"
        cpu: "50m"
      limits:
        memory: "128Mi"
        cpu: "100m"

  volumes:
  - name: varlog
    emptyDir: {}
```

## Pod Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Pending   │ → │   Running   │ → │  Succeeded  │
│  (Scheduled)│     │  (At least  │     │  (Terminal  │
└─────────────┘     │   one       │     │   state)    │
        ↑            │  container  │     └─────────────┘
        │            │   running)  │
        │            └─────────────┘
        │                  ↓
        │            ┌─────────────┐     ┌─────────────┐
        └────────────│  Failed     │ ←  │   Unknown   │
                     │  (Terminal  │     │  (Network   │
                     │   error)    │     │   error)    │
                     └─────────────┘     └─────────────┘
```

### Phase Descriptions

| Phase | Description |
|-------|-------------|
| **Pending** | Pod accepted but not running (scheduling, pulling image) |
| **Running** | At least one container is running |
| **Succeeded** | All containers terminated successfully |
| **Failed** | At least one container terminated in error |
| **Unknown** | Pod state cannot be determined (communication error) |

## Creating Pods

### Method 1: Imperative (Quick Testing)

```bash
# Create a simple pod
kubectl run nginx --image=nginx

# Create with command
kubectl run busybox --image=busybox --command -- sleep 3600

# Create with restart policy
kubectl run nginx --image=nginx --restart=Never
```

### Method 2: Declarative (Recommended)

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
    environment: dev
spec:
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
```

```bash
# Create from YAML
kubectl apply -f pod.yaml

# Delete pod
kubectl delete pod nginx-pod
```

## Pod Configuration

### Resource Requests and Limits

```yaml
spec:
  containers:
  - name: app
    image: myapp:v1
    resources:
      requests:              # Guaranteed resources
        memory: "512Mi"
        cpu: "500m"
      limits:                # Maximum allowed
        memory: "1Gi"
        cpu: "1000m"
```

**Why set both?**
- **Requests**: Used for scheduling (ensure node has enough capacity)
- **Limits**: Prevent container from using all resources (noisy neighbor)

### Environment Variables

```yaml
spec:
  containers:
  - name: app
    image: myapp:v1
    env:
    - name: DATABASE_URL
      value: "postgresql://db:5432/mydb"
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: api-secret
          key: key
    - name: CONFIG_FILE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: config.yaml
```

### Probes (Health Checks)

```yaml
spec:
  containers:
  - name: app
    image: myapp:v1

    # Liveness: Is the container running?
    livenessProbe:
      httpGet:
        path: /health
        port: 8080
      initialDelaySeconds: 30
      periodSeconds: 10
      timeoutSeconds: 5
      failureThreshold: 3

    # Readiness: Is the container ready to serve traffic?
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 5
      timeoutSeconds: 3
      failureThreshold: 2

    # Startup: Has the container started?
    startupProbe:
      httpGet:
        path: /startup
        port: 8080
      initialDelaySeconds: 0
      periodSeconds: 5
      failureThreshold: 30  # 150 seconds total
```

### Volume Mounts

```yaml
spec:
  containers:
  - name: app
    image: myapp:v1
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
    - name: data-volume
      mountPath: /data
    - name: empty-volume
      mountPath: /tmp
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: data-volume
    persistentVolumeClaim:
      claimName: data-pvc
  - name: empty-volume
    emptyDir: {}
```

## Managing Pods

### Common Commands

```bash
# List pods
kubectl get pods

# List pods with more details
kubectl get pods -o wide

# Watch pods (live updates)
kubectl get pods --watch

# Describe pod (detailed information)
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Follow logs (stream)
kubectl logs -f <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash

# Copy files to/from pod
kubectl cp /local/file.txt <pod-name>:/path/
kubectl cp <pod-name>:/path/file.txt /local/

# Delete pod
kubectl delete pod <pod-name>

# Delete all pods
kubectl delete pods --all
```

### Debugging Pods

```bash
# Check pod events
kubectl describe pod <pod-name> | grep -A 20 Events

# Check logs from previous container (if crashed)
kubectl logs <pod-name> --previous

# Check pod status
kubectl get pod <pod-name> -o yaml

# Port forward to local port
kubectl port-forward <pod-name> 8080:80

# Get resource usage
kubectl top pod <pod-name>
```

## Common Pod Issues

### ImagePullBackOff / ErrImagePull

**Cause:** Image not found or authentication issue.

**Solution:**
```bash
# Check image name
kubectl describe pod <pod-name>

# Create image pull secret
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<user> \
  --docker-password=<password>

# Use secret in pod
spec:
  imagePullSecrets:
  - name: regcred
```

### CrashLoopBackOff

**Cause:** Container keeps crashing.

**Solution:**
```bash
# View logs
kubectl logs <pod-name>

# Check if command exists
kubectl exec -it <pod-name> -- which <command>

# Check resource limits
kubectl describe pod <pod-name> | grep -A 5 Limits
```

### Pending State

**Cause:** Pod cannot be scheduled.

**Solution:**
```bash
# Check events
kubectl describe pod <pod-name>

# Check node resources
kubectl describe nodes

# Check taints and tolerations
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## Pod Best Practices

### 1. Always Set Resource Limits

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### 2. Use Probes for Self-Healing

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
```

### 3. Run as Non-Root

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
```

### 4. Use Labels for Organization

```yaml
metadata:
  labels:
    app: myapp
    version: v1.2.0
    environment: production
    team: data-science
```

### 5. Never Use :latest Tag

```yaml
# Bad
image: myapp:latest

# Good
image: myapp:v1.2.3
```

## Summary

| Aspect | Key Point |
|--------|-----------|
| **Pod** | Smallest deployable unit |
| **Containers** | One or more per pod |
| **Networking** | Shared IP address |
| **Storage** | Can share volumes |
| **Lifecycle** | Ephemeral, recreated |
| **Best Practice** | Use Deployments, not Pods directly |

## Next Steps

1. **Learn Deployments**: [Deployments](deployments.md)
2. **Understand Namespaces**: [Namespaces](namespaces.md)
3. **Practice**: [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

---

**Continue Learning:**
- [Deployments](deployments.md)
- [Namespaces](namespaces.md)

**Practice:** [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

**Return to:** [Core Concepts](README.md) | [Kubernetes Module](../README.md)
