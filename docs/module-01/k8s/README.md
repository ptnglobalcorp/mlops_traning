# Kubernetes for MLOps

**Master container orchestration for production ML workloads**

## Quick Start

1. **Read the conceptual guides** in this folder
2. **Practice with labs** in [`../../../module-01/k8s/`](../../../module-01/k8s/)

```
Learn:  docs/module-01/k8s/       →  Theory and concepts
Do:     module-01/k8s/             →  Hands-on practice
```

## Learning Objectives

By the end of this section, you will be able to:
- Understand why Kubernetes is essential for production MLOps workloads
- Set up a local Kubernetes development environment
- Deploy and manage containerized applications using Kubernetes
- Configure networking, storage, and load balancing
- Manage application configuration and secrets
- Use Helm for package management
- Deploy ML models as scalable microservices

## Prerequisites

- **Completion of Docker fundamentals**
- Basic Linux command line familiarity
- Understanding of microservices architecture
- YAML syntax basics

## Study Path

### 1. Overview
**Read:** [Overview](01-overview/README.md) - Why Kubernetes for MLOps

### 2. Key Concepts

**Core Objects:**
- [Overview](02-key-concepts/core-objects/README.md)
- [Object Model](02-key-concepts/core-objects/object-model.md)
- [Namespaces](02-key-concepts/core-objects/namespaces.md)
- [Pods](02-key-concepts/core-objects/pods.md)
- [Labels & Selectors](02-key-concepts/core-objects/labels-selectors.md)

**Workloads:**
- [Overview](02-key-concepts/workloads/README.md)
- [ReplicaSet](02-key-concepts/workloads/replicaset.md)
- [Deployment](02-key-concepts/workloads/deployment.md)
- [StatefulSet](02-key-concepts/workloads/statefulset.md)
- [DaemonSet](02-key-concepts/workloads/daemonset.md)
- [Job](02-key-concepts/workloads/job.md)
- [CronJob](02-key-concepts/workloads/cronjob.md)

**Storage:**
- [Overview](02-key-concepts/storage/README.md)
- [Storage Classes](02-key-concepts/storage/storage-classes.md)
- [PersistentVolumes](02-key-concepts/storage/persistent-volumes.md)
- [PersistentVolumeClaims](02-key-concepts/storage/persistent-volume-claims.md)

**Configuration:**
- [Overview](02-key-concepts/configuration/README.md)
- [ConfigMaps](02-key-concepts/configuration/configmaps.md)
- [Secrets](02-key-concepts/configuration/secrets.md)

**Network:**
- [Overview](02-key-concepts/network/README.md)
- [Services](02-key-concepts/network/services.md)
- [Service Discovery](02-key-concepts/network/service-discovery.md)
- [Ingress](02-key-concepts/network/ingress.md)
- [Ingress Gateway](02-key-concepts/network/ingress-gateway.md)

### 3. Architecture
**Read:** [Architecture Overview](03-architecture/README.md)

### 4. Helm
**Read:** [Helm Package Manager](04-helm/README.md)

### 5. Monitoring
**Read:** [Monitoring & Observability](05-monitoring/README.md)

## Kubernetes Versions

This module uses **Kubernetes v1.32 "Penelope"** (current stable release as of 2025).

### Tool Versions Used

| Tool | Version | Purpose |
|------|---------|---------|
| kubectl | v1.32.x | Kubernetes CLI |
| minikube | v1.37.0+ | Local K8s cluster |
| kind | v0.24.0+ | Docker-based K8s |
| helm | v3.16.x | Package manager |

## Why This Module Matters

### Docker is Great, But...

After completing Docker training, you can:
- Build and run containers locally
- Use Docker Compose for multi-container apps
- Share images via registries

### Why You Need Kubernetes

**Production Realities:**
- What happens when a container fails?
- How do you scale to handle 10x traffic?
- How do you deploy without downtime?
- How do you manage secrets securely?
- How do you run across multiple nodes/servers?

**Kubernetes Solves These By:**
- Auto-restart failed containers
- Scale applications automatically
- Rolling updates with zero downtime
- Built-in secrets management
- Multi-node orchestration

### MLOps-Specific Benefits

- **Model Serving**: Deploy ML models as scalable microservices
- **Batch Jobs**: Run training jobs as Kubernetes Jobs/CronJobs
- **Resource Management**: Allocate GPU/TPU resources for ML workloads
- **A/B Testing**: Run multiple model versions simultaneously
- **Hybrid Cloud**: Run on-prem, AWS EKS, GCP GKE, Azure AKS

## Quick Reference

### Essential kubectl Commands

```bash
# Cluster info
kubectl cluster-info
kubectl version

# Pod operations
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/bash

# Deployment operations
kubectl get deployments
kubectl apply -f deployment.yaml
kubectl rollout status deployment/<name>
kubectl scale deployment/<name> --replicas=3

# Service operations
kubectl get services
kubectl port-forward <pod-name> 8080:80

# Debugging
kubectl logs <pod-name> --previous
kubectl describe pod <pod-name>
kubectl get events
```

## Best Practices Summary

1. **Always use declarative YAML** - Don't use imperative commands
2. **Set resource requests/limits** - Prevent resource starvation
3. **Use liveness and readiness probes** - Enable self-healing
4. **Namespaces separation** - Dev/staging/prod isolation
5. **Secrets management** - Never commit secrets to git
6. **Health checks** - Always define startup, readiness, liveness probes
7. **Rollback strategy** - Keep deployment history
8. **Monitor everything** - Metrics, logs, and traces

## Common Pitfalls

| Pitfall | Why It's Bad | Solution |
|---------|--------------|----------|
| Running as root | Security risk | Use security contexts |
| No resource limits | Noisy neighbors | Set requests/limits |
| :latest tag | Unpredictable updates | Pin specific versions |
| Hardcoded config | Not portable | Use ConfigMaps/Secrets |
| Monolithic pods | Poor scaling | One container per pod |
| Ignoring probes | Failed pods restart forever | Add health checks |

## Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [kubectl Command Reference](https://kubernetes.io/docs/reference/kubectl/)
- [API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

### Books
- [Mastering Kubernetes (4th Edition)](https://www.packtpub.com/product/mastering-kubernetes-fourth-edition/9781804611964) - Our primary reference
- [Kubernetes Up & Running](https://www.oreilly.com/library/view/kubernetes-up-and/9781492046530/)

### Communities
- [Kubernetes Slack](https://slack.k8s.io/)
- [r/kubernetes](https://reddit.com/r/kubernetes)
- [Stack Overflow - Kubernetes Tag](https://stackoverflow.com/questions/tagged/kubernetes)

## Next Steps

After completing this section:
1. Practice with real-world scenarios in [`../../../module-01/k8s/`](../../../module-01/k8s/)
2. Deploy an ML model as a Kubernetes service
3. Explore Kubernetes monitoring and observability
4. Learn about GitOps with ArgoCD/Flux

---

**Practice Labs:** [../../../module-01/k8s/](../../../module-01/k8s/)

**Return to:** [Module 1](./README.md) | [Study Guide](../../README.md)
