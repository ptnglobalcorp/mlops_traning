# Namespaces

**Virtual clusters within a physical Kubernetes cluster**

## Overview

Namespaces are a way to partition cluster resources between multiple users, teams, or projects. They provide a scope for names and provide a mechanism to attach authorization and policy to a subsection of the cluster.

## Why Use Namespaces?

### Key Benefits

| Benefit | Description |
|---------|-------------|
| **Resource Isolation** | Separate resources by team, environment, or project |
| **Name Collision Prevention** | Same resource names can exist in different namespaces |
| **Resource Quotas** | Limit resource usage per namespace |
| **Security** | Apply different RBAC policies per namespace |
| **Organization** | Logical grouping of related resources |
| **Environment Separation** | dev, staging, production in same cluster |

### Real-World Example

```
Kubernetes Cluster
├── ml-platform (namespace)
│   ├── model-serving (deployment)
│   ├── training-jobs (jobs)
│   └── feature-store (statefulset)
├── data-platform (namespace)
│   ├── data-pipeline (deployment)
│   ├── databases (statefulset)
│   └── etcd (statefulset)
├── monitoring (namespace)
│   ├── prometheus (statefulset)
│   ├── grafana (deployment)
│   └── alertmanager (deployment)
├── ingress-nginx (namespace)
│   └── ingress-controller (deployment)
```

## Default Namespaces

Kubernetes creates four namespaces by default:

| Namespace | Purpose |
|-----------|---------|
| **default** | Default namespace for objects with no namespace specified |
| **kube-system** | System objects (control plane components) |
| **kube-public** | Publicly readable data (configmap for cluster-info) |
| **kube-node-lease** | Node lease data for heartbeats |

```bash
# List all namespaces
kubectl get namespaces

# Output:
NAME              STATUS   AGE
default           Active   30d
kube-node-lease   Active   30d
kube-public       Active   30d
kube-system       Active   30d
```

## Creating Namespaces

### Method 1: Imperative

```bash
# Create namespace
kubectl create namespace ml-apps

# Create namespace with labels
kubectl create namespace ml-apps --dry-run=client -o yaml | kubectl apply -f -
```

### Method 2: Declarative (Recommended)

```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ml-apps
  labels:
    environment: production
    team: data-science
    purpose: ml-workloads
```

```bash
# Apply configuration
kubectl apply -f namespace.yaml
```

## Using Namespaces

### Switching Namespaces

```bash
# Set default namespace for current context
kubectl config set-context --current --namespace=ml-apps

# Verify current namespace
kubectl config view --minify | grep namespace

# Use specific namespace for command
kubectl get pods -n ml-apps
kubectl get pods --namespace=ml-apps
```

### Creating Resources in Namespaces

```yaml
# deployment.yaml (specifies namespace)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-model
  namespace: ml-apps  # Resources created in this namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ml-model
  template:
    metadata:
      labels:
        app: ml-model
    spec:
      containers:
      - name: model
        image: ml-model:v2.1
```

```bash
# Apply (resources go to specified namespace)
kubectl apply -f deployment.yaml

# Or specify namespace at apply time
kubectl apply -f deployment.yaml -n ml-apps
```

## Namespace Isolation

### DNS

Services in different namespaces can communicate using the full DNS name:

```bash
# Format: <service-name>.<namespace>.svc.cluster.local

# Example: Access service in ml-apps namespace from default namespace
http://ml-model-service.ml-apps.svc.cluster.local

# Short form (works within cluster)
http://ml-model-service.ml-apps
```

### Resource Quotas

Limit resource usage per namespace:

```yaml
# resource-quota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ml-apps-quota
  namespace: ml-apps
spec:
  hard:
    requests.cpu: "10"
    requests.memory: 20Gi
    limits.cpu: "20"
    limits.memory: 40Gi
    persistentvolumeclaims: "10"
```

```bash
# Apply quota
kubectl apply -f resource-quota.yaml -n ml-apps

# Check quota
kubectl describe quota ml-apps-quota -n ml-apps
```

### Limit Ranges

Set default resource limits for containers:

```yaml
# limit-range.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: ml-apps-limits
  namespace: ml-apps
spec:
  limits:
  - default:
      cpu: "1000m"
      memory: "2Gi"
    defaultRequest:
      cpu: "500m"
      memory: "1Gi"
    type: Container
```

```bash
# Apply limit range
kubectl apply -f limit-range.yaml -n ml-apps

# Check limit range
kubectl describe limitrange ml-apps-limits -n ml-apps
```

## Namespace Patterns

### 1. Environment-Based

```
├── dev (namespace)
├── staging (namespace)
└── production (namespace)
```

**Benefits:**
- Clear separation
- Same application names across environments
- Resource quotas per environment
- Different RBAC policies

**Example:**
```yaml
# Deploy to dev
kubectl apply -f app.yaml -n dev

# Deploy to production
kubectl apply -f app.yaml -n production
```

### 2. Team-Based

```
├── team-data-science (namespace)
├── team-data-engineering (namespace)
└── team-mlops (namespace)
```

**Benefits:**
- Teams work independently
- Resource quotas per team
- Team-specific RBAC policies
- No naming conflicts

### 3. Application-Based

```
├── ml-platform (namespace)
│   ├── model-serving
│   ├── training-pipeline
│   └── feature-store
├── data-platform (namespace)
│   ├── data-lake
│   └── etl-pipelines
```

**Benefits:**
- Logical grouping of microservices
- Easier to manage related resources
- Application-specific resource quotas
**Simplified monitoring per application**

### 4. Multi-Tenant

```
├── tenant-a (namespace)
├── tenant-b (namespace)
└── tenant-c (namespace)
```

**Benefits:**
- Complete isolation between tenants
- Per-tenant resource quotas
- Tenant-specific security policies
- Billing and chargeback

## Common Commands

```bash
# List all namespaces
kubectl get namespaces
kubectl get ns

# Describe namespace
kubectl describe namespace ml-apps

# List resources in namespace
kubectl get all -n ml-apps
kubectl get pods,deployments,services -n ml-apps

# List resources across all namespaces
kubectl get pods --all-namespaces
kubectl get pods -A

# Delete namespace (deletes all resources in it)
kubectl delete namespace ml-apps

# Set default namespace
kubectl config set-context --current --namespace=ml-apps

# Get namespace from pod
kubectl get pod <pod-name> -o jsonpath='{.metadata.namespace}'
```

## Resource Scoping

### Namespaced Resources

These resources belong to a namespace:

- Pod
- Deployment
- Service
- ConfigMap
- Secret
- PersistentVolumeClaim
- ServiceAccount
- Role
- RoleBinding

### Cluster-Scoped Resources

These resources exist cluster-wide (not in a namespace):

- Node
- Namespace
- PersistentVolume
- ClusterRole
- ClusterRoleBinding
- CustomResourceDefinition

## Namespace Best Practices

### 1. Always Use Namespaces for Production

```yaml
# Bad: Resources in default namespace
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  # No namespace specified → goes to default

# Good: Resources in dedicated namespace
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  namespace: production
```

### 2. Set Resource Quotas

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: production-quota
  namespace: production
spec:
  hard:
    requests.cpu: "100"
    requests.memory: 200Gi
    limits.cpu: "200"
    limits.memory: 400Gi
```

### 3. Use Labels for Organization

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ml-apps
  labels:
    environment: production
    team: data-science
    cost-center: ml-ops
```

### 4. Implement Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ml-apps-policy
  namespace: ml-apps
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
```

### 5. Use RBAC per Namespace

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: ml-apps
  name: developer
rules:
- apiGroups: ["", "apps"]
  resources: ["pods", "deployments", "services"]
  verbs: ["get", "list", "create", "update", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: ml-apps
subjects:
- kind: User
  name: jane@company.com
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

## Examples

### MLOps Namespace Structure

```yaml
# 1. Create namespaces
---
apiVersion: v1
kind: Namespace
metadata:
  name: ml-dev
  labels:
    environment: development
---
apiVersion: v1
kind: Namespace
metadata:
  name: ml-staging
  labels:
    environment: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: ml-production
  labels:
    environment: production

# 2. Set resource quotas for production
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ml-production-quota
  namespace: ml-production
spec:
  hard:
    requests.cpu: "50"
    requests.memory: 100Gi
    requests.nvidia.com/gpu: "10"
    limits.cpu: "100"
    limits.memory: 200Gi
    limits.nvidia.com/gpu: "10"
    persistentvolumeclaims: "20"

# 3. Set network policy
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ml-production-netpol
  namespace: ml-production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: database
    - namespaceSelector:
        matchLabels:
          name: ml-production
```

## Troubleshooting

### Issue: Can't Find Resource

```bash
# Check current namespace
kubectl config view --minify | grep namespace

# List all namespaces
kubectl get ns

# Search for resource across all namespaces
kubectl get pods --all-namespaces | grep <pod-name>
```

### Issue: Service Not Reachable

```bash
# Check service and pod are in same namespace
kubectl get svc,po -n <namespace>

# Use full DNS name
<service-name>.<namespace>.svc.cluster.local
```

### Issue: Quota Exceeded

```bash
# Check quota usage
kubectl describe quota <quota-name> -n <namespace>

# Check resource usage
kubectl top pods -n <namespace>

# Delete unused resources
kubectl delete pods -l app=old-app -n <namespace>
```

## Summary

| Aspect | Key Point |
|--------|-----------|
| **Purpose** | Resource isolation and organization |
| **Scope** | Virtual cluster within physical cluster |
| **Default** | 4 namespaces (default, kube-system, kube-public, kube-node-lease) |
| **Best Practice** | Use for all production workloads |
| **Resource Limits** | Use ResourceQuota and LimitRange |
| **Security** | Implement RBAC and NetworkPolicy |

## Next Steps

1. **Learn Services**: [Services Overview](../services-networking/README.md)
2. **Understand ConfigMaps**: [ConfigMaps & Secrets](../storage/configmaps-secrets.md)
3. **Practice**: [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

---

**Continue Learning:**
- [Services & Networking](../services-networking/README.md)
- [ConfigMaps & Secrets](../storage/configmaps-secrets.md)

**Practice:** [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

**Return to:** [Core Concepts](README.md) | [Kubernetes Module](../README.md)
