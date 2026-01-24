# Core Objects

**Understanding Kubernetes object model, namespaces, pods, labels, and selectors**

## Overview

Core objects are the fundamental building blocks of Kubernetes. This section covers the essential objects you'll work with every day: the Kubernetes object model, namespaces, pods, labels, and selectors.

## Study Path

1. **[Object Model](object-model.md)** - How Kubernetes objects work
2. **[Namespaces](namespaces.md)** - Resource isolation and organization
3. **[Pods](pods.md)** - The smallest deployable unit
4. **[Labels & Selectors](labels-selectors.md)** - Identifying and grouping objects

## Key Concepts Overview

| Concept | Purpose | Docker Equivalent |
|---------|---------|-------------------|
| **Object Model** | Declarative configuration | N/A |
| **Namespace** | Resource isolation | Docker context |
| **Pod** | Smallest deployable unit | docker run |
| **Labels** | Identify objects | Docker labels |
| **Selectors** | Group and select objects | N/A |

## Relationship Between Objects

```
┌─────────────────────────────────────────────────────────────────┐
│                      Namespace (ml-apps)                        │
│                                                               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  Deployment (model-api)                   │ │
│  │  Labels: app=ml-model, version=v2                        │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │ │
│  │  │    Pod     │  │    Pod     │  │    Pod     │      │ │
│  │  │  replica 1 │  │  replica 2 │  │  replica 3 │      │ │
│  │  │ Labels:    │  │ Labels:    │  │ Labels:    │      │ │
│  │  │ app=model  │  │ app=model  │  │ app=model  │      │ │
│  │  │ ┌─────────┐│  │ ┌─────────┐│  │ ┌─────────┐│      │ │
│  │  │ │Container││  │ │Container││  │ │Container││      │ │
│  │  │ │: ML     ││  │ │: ML     ││  │ │: ML     ││      │ │
│  │  │ │  Model  ││  │ │  Model  ││  │ │  Model  ││      │ │
│  │  │ └─────────┘│  │ └─────────┘│  │ └─────────┘│      │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘      │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │               Service (model-api-svc)                     │ │
│  │  Selector: app=ml-model                                   │ │
│  │  Load Balancer → Routes traffic to all 3 pods            │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Reference

### Common Commands

```bash
# Namespaces
kubectl get namespaces
kubectl create namespace <name>
kubectl get pods -n <namespace>

# Pods
kubectl get pods
kubectl describe pod <name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- bash

# Labels & Selectors
kubectl get pods -l app=ml-model
kubectl get pods --show-labels
kubectl label pod <name> key=value

# All resources in namespace
kubectl get all -n <namespace>
```

## Imperative vs Declarative

**Imperative (Do this):**
```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
```

**Declarative (Make it so):**
```bash
kubectl apply -f deployment.yaml
# Kubernetes makes actual state match desired state
```

**Best Practice:** Always use declarative (YAML) for production.

## Object YAML Structure

All Kubernetes objects follow this pattern:

```yaml
apiVersion: apps/v1           # API version
kind: Deployment              # Type of object
metadata:                     # Object metadata
  name: nginx-deployment
  labels:
    app: nginx
spec:                         # Desired state
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:                   # Pod template
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

## Next Steps

1. **Learn Object Model**: [Object Model](object-model.md)
2. **Understand Namespaces**: [Namespaces](namespaces.md)
3. **Study Pods**: [Pods](pods.md)
4. **Master Labels & Selectors**: [Labels & Selectors](labels-selectors.md)
5. **Practice**: [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

---

**Continue Learning:**
- [Object Model](object-model.md)
- [Namespaces](namespaces.md)
- [Pods](pods.md)
- [Labels & Selectors](labels-selectors.md)

**Practice:** [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

**Return to:** [Overview](../01-overview/README.md) | [K8s for MLOps](../README.md)
