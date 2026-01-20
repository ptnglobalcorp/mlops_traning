# Lab 02: First Deployment

**Deploy your first application to Kubernetes**

## Overview

In this lab, you'll deploy a simple ML model serving API to Kubernetes. You'll learn how to create deployments, expose services, and manage your application using kubectl.

## Prerequisites

- Completed Lab 01 (Environment Setup)
- Working Kubernetes cluster
- kubectl configured

## Task 1: Create Your First Deployment

Let's deploy a simple ML inference API.

### Step 1: Create a namespace

```bash
# Create a namespace for your ML applications
kubectl create namespace ml-apps

# Set it as default namespace (optional)
kubectl config set-context --current --namespace=ml-apps

# Verify
kubectl get namespaces
```

### Step 2: Create deployment imperatively

```bash
# Create a simple nginx deployment (simulating ML model API)
kubectl create deployment ml-model-api --image=nginx:1.25 --namespace=ml-apps

# Check deployment status
kubectl get deployments -n ml-apps

# Check pods
kubectl get pods -n ml-apps

# Get detailed information
kubectl describe deployment ml-model-api -n ml-apps
```

### Step 3: Scale the deployment

```bash
# Scale to 3 replicas
kubectl scale deployment ml-model-api --replicas=3 -n ml-apps

# Verify scaling
kubectl get pods -n ml-apps

# Check deployment events
kubectl describe deployment ml-model-api -n ml-apps | grep -A 10 Events
```

## Task 2: Expose Your Deployment

### Step 1: Create a service

```bash
# Expose the deployment
kubectl expose deployment ml-model-api --port=80 --type=ClusterIP -n ml-apps

# Check the service
kubectl get services -n ml-apps

# Get service details
kubectl describe service ml-model-api -n ml-apps
```

### Step 2: Test the service

```bash
# Port forward to access locally
kubectl port-forward -n ml-apps svc/ml-model-api 8080:80

# In another terminal, test the connection
curl http://localhost:8080

# Press Ctrl+C to stop port forwarding
```

## Task 3: Declarative Deployment (Recommended)

Now let's deploy using YAML manifests (the production way).

### Step 1: Create deployment YAML

Create a file named `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-inference-api
  namespace: ml-apps
  labels:
    app: ml-inference
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ml-inference
  template:
    metadata:
      labels:
        app: ml-inference
        version: v1.0.0
    spec:
      containers:
      - name: inference
        image: nginx:1.25
        ports:
        - containerPort: 80
          name: http
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 10
          periodSeconds: 5
```

### Step 2: Create service YAML

Create a file named `service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ml-inference-service
  namespace: ml-apps
spec:
  type: ClusterIP
  selector:
    app: ml-inference
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
```

### Step 3: Apply the manifests

```bash
# Apply both files
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Or apply all at once
kubectl apply -f .

# Check resources
kubectl get all -n ml-apps
```

## Task 4: Update Your Deployment

### Step 1: Update the image

```bash
# Update to a newer version (imperative)
kubectl set image deployment/ml-inference-api inference=nginx:1.26 -n ml-apps

# Check rollout status
kubectl rollout status deployment/ml-inference-api -n ml-apps

# Watch the rollout
kubectl get pods -n ml-apps --watch
# Press Ctrl+C to stop watching
```

### Step 2: View rollout history

```bash
# View rollout history
kubectl rollout history deployment/ml-inference-api -n ml-apps

# View specific revision details
kubectl rollout history deployment/ml-inference-api -n ml-apps --revision=2
```

### Step 3: Rollback if needed

```bash
# Rollback to previous version
kubectl rollout undo deployment/ml-inference-api -n ml-apps

# Verify rollback
kubectl get pods -n ml-apps
```

## Task 5: Debug Your Deployment

### Step 1: View logs

```bash
# Get logs from a pod
kubectl logs -n ml-apps -l app=ml-inference

# Follow logs (stream)
kubectl logs -n ml-apps -l app=ml-inference -f

# Get logs from previous container (if crashed)
kubectl logs -n ml-apps <pod-name> --previous
```

### Step 2: Execute commands in pod

```bash
# Get pod name
POD_NAME=$(kubectl get pod -n ml-apps -l app=ml-inference -o jsonpath='{.items[0].metadata.name}')

# Execute command in pod
kubectl exec -n ml-apps $POD_NAME -- ls /

# Open interactive shell
kubectl exec -n ml-apps -it $POD_NAME -- /bin/sh
```

### Step 3: Describe resources

```bash
# Describe pod (detailed information)
kubectl describe pod -n ml-apps -l app=ml-inference

# Describe deployment
kubectl describe deployment ml-inference-api -n ml-apps

# Describe service
kubectl describe service ml-inference-service -n ml-apps
```

## Task 6: Clean Up

```bash
# Delete all resources in namespace
kubectl delete all -n ml-apps --all

# Or delete specific resources
kubectl delete deployment ml-inference-api -n ml-apps
kubectl delete service ml-inference-service -n ml-apps
kubectl delete deployment ml-model-api -n ml-apps
kubectl delete service ml-model-api -n ml-apps

# Optional: Delete namespace
kubectl delete namespace ml-apps
```

## Challenge Exercise

Try these challenges to test your understanding:

### Challenge 1: Deploy with ConfigMap

Create a ConfigMap and use it in your deployment:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: ml-apps
data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: challenge-app
  namespace: ml-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: challenge
  template:
    metadata:
      labels:
        app: challenge
    spec:
      containers:
      - name: app
        image: nginx:1.25
        envFrom:
        - configMapRef:
            name: app-config
```

### Challenge 2: Multi-Container Pod

Create a deployment with sidecar containers:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-container
  namespace: ml-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multi
  template:
    metadata:
      labels:
        app: multi
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
      - name: sidecar
        image: busybox
        command: ["sh", "-c", "while true; do echo 'Sidecar running'; sleep 30;done"]
```

## Verification Checklist

- [ ] Created namespace ml-apps
- [ ] Created deployment imperatively
- [ ] Scaled deployment to 3 replicas
- [ ] Exposed deployment with service
- [ ] Created deployment declaratively with YAML
- [ ] Updated deployment with new image
- [ ] Rolled back deployment
- [ ] Viewed logs and executed commands in pod

## What You Learned

- How to create and manage deployments
- How to expose applications with services
- Imperative vs declarative deployment methods
- How to scale deployments
- How to update and rollback deployments
- Basic debugging techniques

## Common Commands Reference

```bash
# Create resources
kubectl create deployment <name> --image=<image>
kubectl apply -f <file.yaml>

# Get resources
kubectl get all -n <namespace>
kubectl get pods,deployments,services -n <namespace>

# Describe resources
kubectl describe pod <pod-name> -n <namespace>
kubectl describe deployment <name> -n <namespace>

# Scale
kubectl scale deployment <name> --replicas=N -n <namespace>

# Update
kubectl set image deployment/<name> <container>=<image> -n <namespace>

# Rollback
kubectl rollout undo deployment/<name> -n <namespace>

# Logs
kubectl logs -f -l app=<label> -n <namespace>

# Exec
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Delete
kubectl delete deployment <name> -n <namespace>
kubectl delete -f <file.yaml>
```

## Next Steps

1. Learn about [Services & Networking](../../docs/module-k8s/services-networking/README.md)
2. Practice with [Lab 03: Services](../03-services/)

## Additional Resources

- [Deployment Documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)

---

**Next Lab:** [Lab 03: Services](../03-services/)

**Return to:** [Kubernetes Module](../../docs/module-k8s/README.md)
