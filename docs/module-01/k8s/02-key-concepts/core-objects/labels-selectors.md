# Labels and Selectors

**Organizing and selecting Kubernetes objects**

## Overview

Labels are key-value pairs attached to Kubernetes objects (like Pods, Deployments, Services). Selectors are used to identify and group objects based on their labels. This is the primary way Kubernetes organizes and manages resources.

## What Are Labels?

Labels are metadata attached to objects:
- Used to identify, select, and group objects
- Not unique - multiple objects can have the same labels
- Can be modified at any time
- Key-value pairs with specific constraints

### Label Syntax Rules

```yaml
# Valid label keys
app: ml-model                                    # Simple key
kubernetes.io/name: ml-model                      # Prefixed key
app.example.com/version: v2.1                     # Domain prefix

# Valid label values
version: v2.1.0                                 # Simple value
environment: production                         # Simple value
tier: backend                                   # Simple value

# Invalid keys (cannot use)
- invalid-key                                    # Cannot start with -
- Invalid_Key                                    # Cannot use underscores
- invalid key                                    # Cannot contain spaces
```

### Label Constraints

| Constraint | Rule | Example |
|------------|------|---------|
| **Key prefix** | Optional DNS subdomain | `app.example.com/` |
| **Key name** | Alphanumeric, `-`, `.`, `_` | `app_name`, `tier` |
| **Key length** | Max 253 characters (with prefix) | |
| **Value length** | Max 63 characters | |
| **Valid characters** | Alphanumeric, `-`, `.`, `_` | `v1.2.3`, `frontend` |

## Common Label Patterns

### Recommended Label Keys

```yaml
# Standard labels
metadata:
  labels:
    app: ml-inference-api           # Application name
    version: v2.1.0                 # Application version
    component: backend              # Component (frontend/backend/database)
    environment: production         # Environment (dev/staging/prod)
    team: data-science             # Team responsible
    owner: platform-team           # Owner
```

### App Labels

```yaml
metadata:
  labels:
    app: ml-inference-api
    app.kubernetes.io/name: ml-inference-api
    app.kubernetes.io/component: inference
    app.kubernetes.io/version: v2.1.0
```

### Environment Labels

```yaml
metadata:
  labels:
    environment: production
    env: prod
    tier: backend
```

### Team Labels

```yaml
metadata:
  labels:
    team: data-science
    cost-center: ml-ops
    department: engineering
```

## What Are Selectors?

Selectors are used to query objects based on labels. Kubernetes uses selectors for:
- **Services** select which Pods to route traffic to
- **Deployments** select which Pods to manage
- **ReplicaSets** select which Pods to maintain
- **Network policies** select which Pods to apply rules to

### Selector Types

#### 1. Equality-Based Selectors

```yaml
# Match specific labels
selector:
  matchLabels:
    app: ml-model
    version: v2
```

#### 2. Set-Based Selectors

```yaml
# Match using set operations
selector:
  matchExpressions:
  - key: environment
    operator: In
    values: [staging, production]
  - key: tier
    operator: NotIn
    values: [frontend]
  - key: version
    operator: Exists
  - key: deprecated
    operator: DoesNotExist
```

### Selector Operators

| Operator | Description | Example |
|----------|-------------|---------|
| **=**, **==**, **eq** | Equal | `app=ml-model` |
| **!=**, **ne** | Not equal | `environment!=dev` |
| **In** | In set of values | `tier in (backend, database)` |
| **NotIn** | Not in set of values | `tier notin (frontend)` |
| **Exists** | Key exists | `version` |
| **DoesNotExist** | Key does not exist | `!deprecated` |

## Labels in Action

### Example 1: Service Selector

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ml-model-service
spec:
  selector:
    app: ml-model                    # Select pods with this label
    version: v2                      # And this label
  ports:
  - port: 80
    targetPort: 8080
---
# Pods that match
apiVersion: v1
kind: Pod
metadata:
  name: ml-model-pod-1
  labels:
    app: ml-model                    # Matches
    version: v2                      # Matches
---
apiVersion: v1
kind: Pod
metadata:
  name: ml-model-pod-2
  labels:
    app: ml-model                    # Matches
    version: v1                      # Does NOT match (version is v1)
```

### Example 2: Deployment Selector

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ml-model-deployment
spec:
  selector:
    matchLabels:
      app: ml-model
  template:
    metadata:
      labels:
        app: ml-model                # Must match selector
        version: v2.1
```

**Important:** The `selector.matchLabels` must match the labels in `template.metadata.labels`.

### Example 3: Set-Based Selector

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ml-service
spec:
  selector:
    matchExpressions:
    - key: app
      operator: In
      values: [ml-model, ml-api]      # app is ml-model OR ml-api
    - key: environment
      operator: In
      values: [staging, production]   # environment is staging OR production
    - key: version
      operator: Exists               # version key must exist
  ports:
  - port: 80
```

## Using Labels with kubectl

### List Objects by Labels

```bash
# List all pods with label app=ml-model
kubectl get pods -l app=ml-model

# List pods with multiple labels
kubectl get pods -l app=ml-model,version=v2

# List pods where environment is staging or production
kubectl get pods -l 'environment in (staging,production)'

# List pods where tier is NOT frontend
kubectl get pods -l 'tier notin (frontend)'

# List pods with version label (any value)
kubectl get pods -l version

# List pods without version label
kubectl get pods -l '!version'
```

### Get All Labels

```bash
# Show labels for pods
kubectl get pods --show-labels

# Show specific labels
kubectl get pods -L app,version,environment

# Get pods with their labels
kubectl get pods -o custom-columns=NAME:.metadata.name,APP:.metadata.labels.app,VERSION:.metadata.labels.version
```

### Label Objects

```bash
# Add labels to existing pod
kubectl label pod ml-model-pod-1 app=ml-model

# Add multiple labels
kubectl label pod ml-model-pod-1 app=ml-model version=v2.1 environment=production

# Update label
kubectl label pod ml-model-pod-1 version=v2.2 --overwrite

# Remove label
kubectl label pod ml-model-pod-1 version-

# Label all pods in namespace
kubectl label pods -n ml-apps -l app=ml-model tier=backend
```

### Delete Objects by Labels

```bash
# Delete pods with specific label
kubectl delete pod -l app=ml-model

# Delete all pods in staging
kubectl delete pod -l environment=staging

# Delete pods with multiple labels
kubectl delete pod -l app=ml-model,version=v1
```

## Labels and Annotations

### Labels vs Annotations

| Aspect | Labels | Annotations |
|--------|--------|-------------|
| **Purpose** | Identify and select objects | Store arbitrary metadata |
| **Used in selectors?** | Yes | No |
| **Size limit** | Smaller (~63 chars per value) | Larger (~256 KB total) |
| **Example** | `app: ml-model` | `description: "ML model serving API"` |

### When to Use Each

```yaml
metadata:
  labels:
    # Use labels for selection
    app: ml-model
    version: v2.1
    environment: production
  annotations:
    # Use annotations for non-identifying metadata
    description: "ML model serving API for recommendations"
    monitoring: "prometheus"
    contact: "team@company.com"
    deployment-date: "2025-01-15"
    git-commit: "abc123def"
```

## Common Labeling Best Practices

### 1. Standard Labels

```yaml
metadata:
  labels:
    # Kubernetes recommended labels
    app.kubernetes.io/name: ml-inference-api
    app.kubernetes.io/instance: ml-inference-001
    app.kubernetes.io/version: v2.1.0
    app.kubernetes.io/component: inference
    app.kubernetes.io/part-of: ml-platform
    app.kubernetes.io/managed-by: kubectl
```

### 2. Environment Labels

```yaml
metadata:
  labels:
    environment: production          # dev, staging, production
    tier: backend                    # frontend, backend, database
    workload-type: serving           # serving, training, batch
```

### 3. Organizational Labels

```yaml
metadata:
  labels:
    team: data-science
    cost-center: ml-ops
    department: engineering
    owner: platform-team
```

### 4. Version Labels

```yaml
metadata:
  labels:
    version: v2.1.0                  # Specific version
    track: stable                    # stable, canary, beta
    release-channel: production      # production, preview
```

## Selector Patterns

### Pattern 1: Application Components

```yaml
# Frontend
metadata:
  labels:
    app: web-app
    component: frontend
    tier: web

# Backend API
metadata:
  labels:
    app: web-app
    component: api
    tier: backend

# Database
metadata:
  labels:
    app: web-app
    component: database
    tier: database

# Service selects all backend components
kind: Service
metadata:
  name: backend-service
spec:
  selector:
    app: web-app
    tier: backend                    # Matches api, but not frontend or database
```

### Pattern 2: A/B Testing

```yaml
# Version A (70% traffic)
metadata:
  labels:
    app: ml-model
    version: v2
    track: stable

# Version B (30% traffic - canary)
metadata:
  labels:
    app: ml-model
    version: v3
    track: canary

# Service selector
kind: Service
spec:
  selector:
    app: ml-model                    # Selects both v2 and v3
```

### Pattern 3: Multi-Environment

```yaml
# Development
metadata:
  labels:
    app: ml-model
    environment: dev
    tier: backend

# Staging
metadata:
  labels:
    app: ml-model
    environment: staging
    tier: backend

# Production
metadata:
  labels:
    app: ml-model
    environment: production
    tier: backend

# Namespace-scoped selector
kind: Service
metadata:
  namespace: production
spec:
  selector:
    app: ml-model                    # Only selects production pods
```

## Label Selector Examples

### Example 1: Select All ML Workloads

```bash
# Select all ML model serving pods
kubectl get pods -l app=ml-model,workload-type=serving

# Select all training jobs
kubectl get pods -l workload-type=training

# Select all batch processing
kubectl get pods -l workload-type=batch
```

### Example 2: Select by Team

```bash
# Get all resources owned by data-science team
kubectl get all -l team=data-science

# Get all resources in production
kubectl get all -l environment=production

# Get all production resources for data-science
kubectl get all -l team=data-science,environment=production
```

### Example 3: Select by Version

```bash
# Get specific version
kubectl get pods -l app=ml-model,version=v2.1.0

# Get all except v1
kubectl get pods -l app=ml-model,'version notin (v1)'

# Get stable versions (not canary or beta)
kubectl get pods -l app=ml-model,'track notin (canary,beta)'
```

## Troubleshooting

### Issue: Pods Not Selected by Service

**Problem:** Service has no endpoints.

```bash
# Check service selector
kubectl get svc ml-service -o yaml | grep -A 5 selector

# Check pod labels
kubectl get pods -o wide --show-labels

# Find mismatch
kubectl get pods -l app=ml-model --show-labels
```

**Solution:** Ensure pod labels match service selector exactly.

### Issue: Deployment Not Managing Pods

**Problem:** Deployment shows 0 replicas.

```bash
# Check deployment selector
kubectl get deployment ml-model -o yaml | grep -A 5 selector

# Check pod labels
kubectl get pods --show-labels

# Match must be exact
```

**Solution:** The `selector.matchLabels` must match `template.metadata.labels`.

## Best Practices Summary

1. **Always label your objects** - Makes management easier
2. **Use standard labels** - Follow Kubernetes conventions
3. **Be consistent** - Use same labels across environments
4. **Use meaningful labels** - `app`, `version`, `environment`, `tier`
5. **Avoid sensitive data** - Don't put secrets in labels
6. **Keep labels simple** - Don't overcomplicate
7. **Document your labels** - Team conventions

## Quick Reference

```bash
# Label objects
kubectl label pod <pod-name> key=value
kubectl label deployment <name> app=ml-model version=v2

# List by labels
kubectl get pods -l app=ml-model
kubectl get all -l environment=production

# Show labels
kubectl get pods --show-labels
kubectl get pods -L app,version

# Update labels
kubectl label pod <pod-name> version=v2.2 --overwrite

# Remove labels
kubectl label pod <pod-name> version-
```

## Next Steps

1. **Learn Deployments**: [Deployments](deployments.md)
2. **Understand Services**: [Services & Networking](../services-networking/README.md)
3. **Practice**: [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

---

**Continue Learning:**
- [Deployments](deployments.md)
- [Services & Networking](../services-networking/README.md)

**Practice:** [Lab 02: First Deployment](../../module-k8s/02-first-deployment/)

**Return to:** [Core Concepts](README.md) | [Kubernetes Module](../README.md)
