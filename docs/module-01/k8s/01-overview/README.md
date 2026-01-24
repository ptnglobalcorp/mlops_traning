# Kubernetes Overview

**Understanding why Kubernetes is essential for MLOps**

## Overview

You've completed Docker training and can containerize applications. But containers alone aren't enough for production. Kubernetes (K8s) is what makes containers viable at scale - it's the orchestration layer that transforms containers from a development tool into a production-ready platform.

## Docker vs Kubernetes: What's the Difference?

Docker and Kubernetes are often compared as if they're competitors, but they solve different problems:

- **Docker** creates and runs containers
- **Kubernetes** orchestrates and manages containers at scale

```
┌─────────────────────────────────────────────────────────────┐
│                     Your Application                        │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │              Docker (Container Runtime)             │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐            │    │
│  │  │   App   │  │  Model  │  │   DB    │            │    │
│  │  │Container│  │Container│  │Container│            │    │
│  │  └─────────┘  └─────────┘  └─────────┘            │    │
│  └────────────────────────────────────────────────────┘    │
│                         ↓                                    │
│  ┌────────────────────────────────────────────────────┐    │
│  │           Kubernetes (Orchestration Layer)          │    │
│  │  • Scheduling  • Scaling  • Healing  • Networking  │    │
│  └────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Quick Comparison

| Aspect | Docker | Docker Compose | Kubernetes |
|--------|--------|----------------|------------|
| **Scope** | Single host | Single host | Multi-host cluster |
| **Scalability** | Manual | Manual | Auto-scaling |
| **Self-healing** | No | No | Yes (auto-restart) |
| **Load Balancing** | Manual | Basic | Built-in Service discovery |
| **Rolling Updates** | Manual | Basic | Zero-downtime deployments |
| **Resource Limits** | Per container | Per container | Per pod + quotas |
| **Service Discovery** | No | Basic | Built-in DNS |
| **Secrets Management** | Swarm only | Env vars | Built-in Secrets |
| **Storage Management** | Volumes | Volumes | PersistentVolumes |
| **Health Checks** | Depends | Depends | Probes (liveness/readiness) |
| **Declarative Config** | No | Limited | Yes (YAML manifests) |

## What Problems Does Kubernetes Solve?

### Problem 1: Container Failures

**Scenario:** Your ML model container crashes at 3 AM.

```
Without K8s: Application is down until someone manually restarts it.
With K8s:    K8s detects crash → Immediately restarts container → Alerts on repeated failures.
```

### Problem 2: Scaling

**Scenario:** Traffic spike hits your recommendation service.

```
Without K8s: SSH into servers → Run docker commands manually → Hope for the best.
With K8s:    kubectl scale deployment ml-model --replicas=50 → Done in seconds.
```

### Problem 3: Zero-Downtime Deployments

**Scenario:** Deploying new model version.

```
Without K8s: Stop old containers → Start new ones → Users see errors during gap.
With K8s:    Rolling update → Start new pods → Verify health → Stop old pods → No downtime.
```

### Problem 4: Resource Management

**Scenario:** One training job consumes all server memory.

```
Without K8s: Other applications crash → Server becomes unresponsive.
With K8s:    Resource limits prevent starvation → OOMKilled only affects offending pod.
```

### Problem 5: Multi-Node Management

**Scenario:** You have 10 servers.

```
Without K8s: Manually track which containers run on which server → Manual rebalancing.
With K8s:    Scheduler places pods optimally → Automatic rebalancing → No manual intervention.
```

## When Do You Need Kubernetes?

### Kubernetes is Overkill When:

- Single developer working alone
- Simple applications with containers
- Development environments only
- Homelab/personal projects
- Prototype/MVP stage

### Kubernetes is Essential When:

- Team-based production deployments
- Applications requiring high availability
- Need for auto-scaling
- Multi-cloud or hybrid cloud strategy
- Regulatory/compliance requirements
- 99.9%+ uptime SLAs
- Complex microservices (>5 services)

## Kubernetes for MLOps

### Key Benefits for ML Workloads

| Benefit | Description |
|---------|-------------|
| **Model Serving** | Deploy ML models as scalable microservices |
| **Batch Jobs** | Run training jobs as Kubernetes Jobs/CronJobs |
| **Resource Management** | Allocate GPU/TPU resources for ML workloads |
| **A/B Testing** | Run multiple model versions simultaneously |
| **Hybrid Cloud** | Run on-prem, AWS EKS, GCP GKE, Azure AKS |

### ML-Specific Use Cases

- **Model Serving**: Deploy inference APIs with auto-scaling
- **Batch Training**: Run overnight training jobs with retry logic
- **Distributed Training**: Multi-GPU/Multi-node training orchestration
- **Feature Store**: StatefulSets for distributed feature storage
- **Pipeline Orchestration**: Argo/Kubeflow for ML pipelines

## Learning Path

1. **[Key Concepts - Core Objects](../02-key-concepts/core-objects/README.md)** - Object model, namespaces, pods, labels, selectors
2. **[Key Concepts - Workloads](../02-key-concepts/workloads/README.md)** - Deployments, StatefulSets, Jobs, CronJobs
3. **[Key Concepts - Storage](../02-key-concepts/storage/README.md)** - Storage classes, PVs, PVCs
4. **[Key Concepts - Configuration](../02-key-concepts/configuration/README.md)** - ConfigMaps, Secrets
5. **[Key Concepts - Network](../02-key-concepts/network/README.md)** - Services, Ingress, Gateways
6. **[Architecture Overview](../03-architecture/README.md)** - Control plane, nodes, networking
7. **[Helm](../04-helm/README.md)** - Package management
8. **[Monitoring](../05-monitoring/README.md)** - Observability

## Next Steps

1. **Learn Core Objects**: [Key Concepts - Core Objects](../02-key-concepts/core-objects/README.md)
2. **Practice Setup**: [Lab 01: Environment Setup](../../../module-01/k8s/01-setup/)

---

**Continue Learning:**
- [Key Concepts - Core Objects](../02-key-concepts/core-objects/README.md)
- [Key Concepts - Workloads](../02-key-concepts/workloads/README.md)

**Practice:** [Lab 01: Environment Setup](../../../module-01/k8s/01-setup/)

**Return to:** [Module 1](../README.md) | [Study Guide](../../../README.md)
