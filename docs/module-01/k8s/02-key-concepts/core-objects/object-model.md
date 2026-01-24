# Kubernetes Object Model

**Understanding how Kubernetes objects work**

## Overview

Kubernetes uses a declarative object model. You describe the desired state of your cluster, and Kubernetes works to make that state a reality. Understanding this model is fundamental to working with Kubernetes effectively.

## What is a Kubernetes Object?

A Kubernetes object is a **record of intent** - a persistent representation of your cluster's desired state.

Once you create an object, Kubernetes:
1. **Validates** the object
2. **Stores** it in etcd (the cluster database)
3. **Reconciles** the actual state to match your desired state

```
┌─────────────────────────────────────────────────────────────────┐
│                     Kubernetes Object Model                     │
│                                                                 │
│  Your Intent (YAML) → K8s API Server → etcd (Store)            │
│                             ↓                                   │
│                     Controllers                                 │
│                             ↓                                   │
│                     Actual State                                │
│                                                                 │
│  Controllers continuously work to make:                        │
│      Actual State == Desired State                              │
└─────────────────────────────────────────────────────────────────┘
```

## Object Structure

Every Kubernetes object contains two nested object fields:
1. **ObjectSpec** - The desired state (what you want)
2. **ObjectStatus** - The current state (what K8s observes)

### Complete Object Schema

```yaml
apiVersion: v1              # API version for the object
kind: Pod                   # Type of object
metadata:                   # Metadata about the object
  name: nginx-pod
  namespace: default
  uid: 12345678-1234-1234-1234-123456789abc
  resourceVersion: "12345"
  generation: 1
  creationTimestamp: "2025-01-15T10:00:00Z"
  labels:
    app: nginx
    environment: production
  annotations:
    description: "Web server pod"
spec:                       # DESIRED STATE (what you define)
  containers:
  - name: nginx
    image: nginx:1.25
    ports:
    - containerPort: 80
  restartPolicy: Always
status:                     # CURRENT STATE (kubernetes maintains)
  phase: Running
  podIP: 10.244.1.5
  hostIP: 192.168.1.100
  startTime: "2025-01-15T10:00:00Z"
  conditions:
  - type: Ready
    status: "True"
    lastTransitionTime: "2025-01-15T10:00:30Z"
```

## API Versions

Kubernetes objects are organized into API groups:

| API Group | Version | Objects |
|-----------|---------|---------|
| **Core (v1)** | v1 | Pod, Service, Namespace, ConfigMap, Secret, PVC |
| **Apps** | v1 | Deployment, StatefulSet, DaemonSet, ReplicaSet |
| **Batch** | v1 | Job, CronJob |
| **Networking** | v1 | Ingress, NetworkPolicy |
| **Storage** | v1 | StorageClass, VolumeAttachment |
| **RBAC** | v1 | Role, ClusterRole, RoleBinding, ClusterRoleBinding |

### API Version Conventions

```yaml
# Core objects (no group name)
apiVersion: v1
kind: Pod
kind: Service
kind: Namespace

# Apps group
apiVersion: apps/v1
kind: Deployment
kind: StatefulSet

# Batch group
apiVersion: batch/v1
kind: Job
kind: CronJob
```

## Object Kinds

### Workload Objects

| Kind | Purpose | API Version |
|------|---------|-------------|
| **Pod** | Smallest deployable unit | v1 |
| **Deployment** | Stateless applications | apps/v1 |
| **StatefulSet** | Stateful applications | apps/v1 |
| **DaemonSet** | One pod per node | apps/v1 |
| **ReplicaSet** | Maintains pod replicas | apps/v1 |
| **Job** | Run to completion | batch/v1 |
| **CronJob** | Scheduled jobs | batch/v1 |

### Discovery & Load Balancing

| Kind | Purpose | API Version |
|------|---------|-------------|
| **Service** | Stable network endpoint | v1 |
| **Ingress** | HTTP/HTTPS routing | networking.k8s.io/v1 |
| **EndpointSlice** | Network endpoints | discovery.k8s.io/v1 |

### Config & Storage

| Kind | Purpose | API Version |
|------|---------|-------------|
| **ConfigMap** | Configuration data | v1 |
| **Secret** | Sensitive data | v1 |
| **PersistentVolume** | Storage resource | v1 |
| **PersistentVolumeClaim** | Storage request | v1 |
| **StorageClass** | Storage profile | v1 |

### Cluster

| Kind | Purpose | API Version |
|------|---------|-------------|
| **Namespace** | Resource isolation | v1 |
| **Node** | Worker machine | v1 |
| **PersistentVolume** | Cluster storage | v1 |
| **ClusterRole** | Cluster permissions | rbac.authorization.k8s.io/v1 |

## Object Names

### Naming Rules

- **Maximum length**: 253 characters
- **Valid characters**: lowercase alphanumeric, `-`, `.`
- **Must start and end with**: alphanumeric character
- **DNS subdomain format**: recommended

```yaml
# Valid names
metadata:
  name: nginx-pod
  name: ml.model.v2
  name: web-123

# Invalid names
metadata:
  name: Nginx_Pod           # Underscores not allowed
  name: nginx-pod-         # Cannot end with hyphen
  name: 123nginx           # Cannot start with number
```

### Namespaces

Objects live in namespaces, which provide virtual clusters:

```yaml
# Same name, different namespace
metadata:
  name: nginx
  namespace: development    # development/nginx

metadata:
  name: nginx
  namespace: production     # production/nginx
```

## Object Lifecycle

### Creation Flow

```
1. kubectl apply -f pod.yaml
          ↓
2. API Server validates and accepts
          ↓
3. Stored in etcd
          ↓
4. Controller detects new object
          ↓
5. Controller creates resources
          ↓
6. Status updated to reflect actual state
```

### Update Flow

```
1. kubectl apply -f updated-pod.yaml
          ↓
2. API Server validates and updates etcd
          ↓
3. Controller detects change
          ↓
4. Controller reconciles (makes changes)
          ↓
5. Status updated continuously
```

### Deletion Flow

```
1. kubectl delete pod nginx
          ↓
2. API Server processes deletion (grace period)
          ↓
3. Controller deletes resources
          ↓
4. Finalizers executed (cleanup)
          ↓
5. Object removed from etcd
```

## Object Spec vs Status

### Spec (Desired State)

**You define this:** What you want the cluster to do.

```yaml
spec:
  replicas: 3                    # I want 3 replicas
  template:
    spec:
      containers:
      - image: nginx:1.25         # Using this image
      restartPolicy: Always       # Always restart
```

### Status (Current State)

**Kubernetes maintains this:** What's actually happening.

```yaml
status:
  replicas: 3                    # 3 replicas running
  readyReplicas: 3               # All 3 are ready
  updatedReplicas: 3             # All have latest config
  availableReplicas: 3           # All are available
  observedGeneration: 2          # K8s has seen gen 2
  conditions:
  - type: Available
    status: "True"               # Deployment is available
    lastUpdateTime: "2025-01-15T10:00:00Z"
    reason: MinimumReplicasAvailable
    message: Deployment has minimum availability
```

## Desired State Pattern

The core pattern in Kubernetes is:

```yaml
# 1. Define desired state (what you want)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3                    # I want 3 replicas
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.25         # Using this image
# 2. Kubernetes makes it happen
# 3. Kubernetes maintains it (self-healing)
```

## Working with Objects

### Creating Objects

```bash
# Imperative
kubectl run nginx --image=nginx

# Declarative (recommended)
kubectl apply -f deployment.yaml

# Dry run (see what would happen)
kubectl apply -f deployment.yaml --dry-run=client
```

### Viewing Objects

```bash
# List objects
kubectl get pods
kubectl get deployments
kubectl get all

# Get specific object
kubectl get pod nginx-pod

# Get with details
kubectl describe pod nginx-pod

# Get as YAML
kubectl get pod nginx-pod -o yaml

# Get specific fields
kubectl get pod nginx-pod -o jsonpath='{.status.podIP}'
```

### Updating Objects

```bash
# Imperative edit
kubectl edit deployment nginx

# Imperative update
kubectl set image deployment/nginx nginx=nginx:1.26

# Declarative update (recommended)
kubectl apply -f updated-deployment.yaml
```

### Deleting Objects

```bash
# By name
kubectl delete pod nginx-pod

# By type
kubectl delete pods --all

# By file
kubectl delete -f deployment.yaml

# By label selector
kubectl delete pods -l app=nginx

# With grace period
kubectl delete pod nginx-pod --grace-period=60
```

## Object Relationships

### Ownership

Some objects own other objects:

```yaml
# Deployment owns ReplicaSet
# ReplicaSet owns Pods

kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  template:
    # Creates ReplicaSet
    # ReplicaSet creates Pods
```

### Owner References

```yaml
metadata:
  name: nginx-pod-abc123
  ownerReferences:
  - apiVersion: apps/v1
    kind: ReplicaSet
    name: nginx-5d4f6c
    uid: 5d4f6c-1234-5678-90ab-123456789abc
    controller: true
    blockOwnerDeletion: true
```

## Labels and Annotations

### Labels (Used for Selection)

```yaml
metadata:
  labels:
    app: nginx
    version: v1.25
    environment: production
```

### Annotations (Not Used for Selection)

```yaml
metadata:
  annotations:
    description: "Web server"
    contact: "team@company.com"
    git-commit: "abc123"
```

## Best Practices

### 1. Always Use Declarative Configuration

```yaml
# Good: Declarative
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec: ...
```

### 2. Pin Image Versions

```yaml
# Bad
image: nginx:latest

# Good
image: nginx:1.25.3
```

### 3. Use Meaningful Names

```yaml
# Bad
metadata:
  name: app-123

# Good
metadata:
  name: ml-inference-api-v2
```

### 4. Add Labels and Annotations

```yaml
metadata:
  name: nginx
  labels:
    app: nginx
    tier: frontend
    environment: production
  annotations:
    description: "Web frontend"
    contact: "platform-team@company.com"
```

### 5. Set Resource Limits

```yaml
spec:
  containers:
  - name: nginx
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "200m"
```

## Next Steps

1. **Learn Namespaces**: [Namespaces](namespaces.md)
2. **Understand Pods**: [Pods](pods.md)
3. **Master Labels & Selectors**: [Labels & Selectors](labels-selectors.md)
4. **Practice**: [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

---

**Continue Learning:**
- [Namespaces](namespaces.md)
- [Pods](pods.md)
- [Labels & Selectors](labels-selectors.md)

**Practice:** [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

**Return to:** [Core Objects](README.md) | [Key Concepts](../README.md)
