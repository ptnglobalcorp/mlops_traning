# Kubernetes Architecture

**Understanding control plane components, node components, and networking**

## Overview

Kubernetes is a distributed system composed of multiple components working together. This section covers the architecture of a Kubernetes cluster, including the control plane, node components, optional services, and networking model.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      Kubernetes Cluster                         │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Control Plane                         │  │
│  │  ┌──────────┐ ┌────────────┐ ┌─────────────┐            │  │
│  │  │  API     │ │ etcd       │ │  Scheduler  │            │  │
│  │  │  Server  │ │ (Key-Value)│ │             │            │  │
│  │  └──────────┘ └────────────┘ └─────────────┘            │  │
│  │  ┌──────────────┐  ┌──────────────┐                     │  │
│  │  │  Controller  │ │  Cloud       │                     │  │
│  │  │  Manager     │ │  Controller  │                     │  │
│  │  └──────────────┘  └──────────────┘                     │  │
│  └──────────────────────────────────────────────────────────┘  │
│                            ↓                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Worker Nodes                          │  │
│  │  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐│  │
│  │  │   Node 1      │  │   Node 2      │  │   Node 3      ││  │
│  │  │ ┌───────────┐  │  │ ┌───────────┐  │  │ ┌───────────┐  ││  │
│  │  │ │  Kubelet  │  │  │ │  Kubelet  │  │  │ │  Kubelet  │  ││  │
│  │  │ └───────────┘  │  │ └───────────┘  │  │ └───────────┘  ││  │
│  │  │ ┌───────────┐  │  │ ┌───────────┐  │  │ ┌───────────┐  ││  │
│  │  │ │kube-proxy│  │  │ │kube-proxy│  │  │ │kube-proxy│  ││  │
│  │  │ └───────────┘  │  │ └───────────┘  │  │ └───────────┘  ││  │
│  │  │ ┌───────────┐  │  │ ┌───────────┐  │  │ ┌───────────┐  ││  │
│  │  │ │Container │  │  │ │Container │  │  │ │Container │  ││  │
│  │  │ │ Runtime  │  │  │ │ Runtime  │  │  │ │ Runtime  │  ││  │
│  │  │ └───────────┘  │  │ └───────────┘  │  │ └───────────┘  ││  │
│  │  └───────────────┘  └───────────────┘  └───────────────┘│  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Study Path

1. **[Control Plane](control-plane.md)** - API Server, etcd, Scheduler, Controller Manager
2. **[Node Components](node-components.md)** - Kubelet, kube-proxy, Container Runtime
3. **[Optional Services](optional-services.md)** - DNS, Dashboard, Ingress Controller
4. **[Networking Model](networking-model.md)** - Pod networking, Services, Network Policies

## Control Plane Components

| Component | Purpose |
|-----------|---------|
| **kube-apiserver** | Front-end for all API operations |
| **etcd** | Consistent key-value store for cluster data |
| **kube-scheduler** | Assigns pods to nodes |
| **kube-controller-manager** | Runs controller processes |

## Node Components

| Component | Purpose |
|-----------|---------|
| **kubelet** | Agent that runs on each node |
| **kube-proxy** | Network proxy on each node |
| **Container Runtime** | Runs containers (Docker, containerd, CRI-O) |

## Quick Reference

### Check Cluster Components

```bash
# Check all control plane pods
kubectl get pods -n kube-system

# Check nodes
kubectl get nodes -o wide

# Check cluster info
kubectl cluster-info

# Check component status
kubectl get componentstatuses
```

### Check Control Plane

```bash
# API server
kubectl get pods -n kube-system -l component=kube-apiserver

# Scheduler
kubectl get pods -n kube-system -l component=kube-scheduler

# Controller manager
kubectl get pods -n kube-system -l component=kube-controller-manager

# etcd
kubectl get pods -n kube-system -l component=etcd
```

## Next Steps

1. **Learn Control Plane**: [Control Plane](control-plane.md)
2. **Understand Node Components**: [Node Components](node-components.md)
3. **Study Networking**: [Networking Model](networking-model.md)

---

**Continue Learning:**
- [Control Plane](control-plane.md)
- [Node Components](node-components.md)
- [Networking Model](networking-model.md)

**Return to:** [Overview](../01-overview/README.md) | [K8s for MLOps](../README.md)
