# Kubernetes Architecture

**Understanding how Kubernetes clusters work under the hood**

## Overview

Kubernetes is a distributed system composed of multiple components working together. Understanding this architecture is crucial for troubleshooting, debugging, and operating production clusters.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                               │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                    Control Plane (Master Node)                   │    │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │    │
│  │  │  API Server      │  │  etcd           │  │  Scheduler   │  │    │
│  │  │  (kube-apiserver)│  │  (Key-Value DB) │  │              │  │    │
│  │  │  Front-end       │  │  Cluster state  │  │  Pod         │  │    │
│  │  │  All operations  │  │  Configuration  │  │  placement   │  │    │
│  │  └──────────────────┘  └──────────────────┘  └──────────────┘  │    │
│  │  ┌──────────────────┐  ┌──────────────────┐                     │    │
│  │  │  Controller      │  │  Cloud           │                     │    │
│  │  │  Manager         │  │  Controller      │                     │    │
│  │  │  (kube-controller│  │  Manager         │                     │    │
│  │  │   -manager)      │  │  (cloud-provider)│                    │    │
│  │  │  Desired state   │  │  Cloud API       │                     │    │
│  │  │  enforcement     │  │  integration     │                     │    │
│  │  └──────────────────┘  └──────────────────┘                     │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐              │
│  │   Worker      │  │   Worker      │  │   Worker      │              │
│  │   Node 1      │  │   Node 2      │  │   Node 3      │              │
│  │  ┌─────────┐  │  │  ┌─────────┐  │  │  ┌─────────┐  │              │
│  │  │ Kubelet │  │  │  │ Kubelet │  │  │  │ Kubelet │  │              │
│  │  └─────────┘  │  │  └─────────┘  │  │  └─────────┘  │              │
│  │  ┌─────────┐  │  │  ┌─────────┐  │  │  ┌─────────┐  │              │
│  │  │kube-proxy│ │  │  │kube-proxy│ │  │  │kube-proxy│ │              │
│  │  └─────────┘  │  │  └─────────┘  │  │  └─────────┘  │              │
│  │  ┌─────────┐  │  │  ┌─────────┐  │  │  ┌─────────┐  │              │
│  │  │Container│  │  │  │Container│  │  │  │Container│  │              │
│  │  │Runtime  │  │  │  │Runtime  │  │  │  │Runtime  │  │              │
│  │  │(Docker/ │  │  │  │(Docker/ │  │  │  │(Docker/ │  │              │
│  │  │containerd)│ │  │  │containerd)│ │  │  │containerd)│ │              │
│  │  └─────────┘  │  │  └─────────┘  │  │  └─────────┘  │              │
│  │  Pods:        │  │  Pods:        │  │  Pods:        │              │
│  │  ┌─────────┐  │  │  ┌─────────┐  │  │  ┌─────────┐  │              │
│  │  │Pod: API │  │  │  │Pod: DB  │  │  │  │Pod: ML  │  │              │
│  │  │Pod: Web │  │  │  │         │  │  │  │         │  │              │
│  │  └─────────┘  │  │  └─────────┘  │  │  └─────────┘  │              │
│  └───────────────┘  └───────────────┘  └───────────────┘              │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                     Services (Networking)                       │    │
│  │  • ClusterIP  • NodePort  • LoadBalancer  • ExternalDNS         │    │
│  └─────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

## Control Plane Components

The control plane manages the cluster state. It's the "brain" of Kubernetes.

### 1. API Server (kube-apiserver)

**Purpose:** Front-end for the Kubernetes control plane.

**Key Functions:**
- All operations (create, read, update, delete) go through API Server
- Authenticates and validates requests
- Stores state in etcd
- Provides REST APIs for kubectl, dashboard, and other clients

**How it works:**
```
kubectl get pods
    ↓
HTTP GET /api/v1/namespaces/default/pods
    ↓
kube-apiserver authenticates request
    ↓
kube-apiserver validates request
    ↓
kube-apiserver queries etcd
    ↓
Returns pod list to kubectl
```

**Example:**
```bash
# Direct API access (without kubectl)
curl https://kubernetes.default.svc/api/v1/namespaces/default/pods \
  --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt \
  --header "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
```

### 2. etcd

**Purpose:** Consistent and highly-available key-value store for all cluster data.

**Key Functions:**
- Stores the entire cluster state
- Configuration data
- Stateful data for all resources
- Used by all control plane components

**What's stored:**
- Node information
- Pod specifications
- Service definitions
- ConfigMaps and Secrets
- Deployment state
- All Kubernetes resources

**Data example:**
```
/registry/namespaces/default
/registry/pods/default/web-pod-123
/registry/services/default/web-service
/registry/configmaps/default/app-config
```

### 3. Scheduler (kube-scheduler)

**Purpose:** Assigns pods to nodes.

**Key Functions:**
- Watches for unscheduled pods
- Selects optimal node for each pod
- Considers resource requirements, constraints, and policies

**Scheduling decision factors:**
- Resource requests (CPU, memory)
- Resource limits
- Node affinity/anti-affinity
- Taints and tolerations
- Pod affinity/anti-affinity
- Data locality
- Hardware constraints (GPU, SSD)

**Scheduling flow:**
```
1. Pod created (no node assigned)
2. Scheduler detects unscheduled pod
3. Scheduler filters suitable nodes
4. Scheduler scores remaining nodes
5. Scheduler binds pod to best node
6. Kubelet on that node creates pod
```

### 4. Controller Manager (kube-controller-manager)

**Purpose:** Runs controller processes that regulate cluster state.

**Key Controllers:**

| Controller | Function |
|------------|----------|
| **Node Controller** | Monitors node health, marks unreachable nodes |
| **Replication Controller** | Ensures correct number of pod replicas |
| **Endpoint Controller** | Populates endpoint objects (Services ↔ Pods) |
| **Service Account Controller** | Creates default service accounts |
| **Token Controller** | Creates API tokens for service accounts |

**How it works:**
```
Desired State: 3 replicas of web-app
Actual State:   2 replicas (one crashed)
    ↓
Controller detects mismatch
    ↓
Controller creates new pod
    ↓
Actual State: 3 replicas (matches desired)
```

### 5. Cloud Controller Manager

**Purpose:** Links cluster to cloud provider's API.

**Key Functions:**
- Manages cloud-specific resources (LoadBalancers, Storage)
- Node lifecycle management (for cloud VMs)
- Routing configuration

**Separates:**
- Cloud-specific logic from core Kubernetes
- Allows Kubernetes to work with any cloud provider

## Worker Node Components

Worker nodes run your applications. They're the "muscle" of Kubernetes.

### 1. Kubelet

**Purpose:** Primary agent on each node.

**Key Functions:**
- Watches for pods assigned to its node
- Ensures containers described in pod specs are running
- Reports node and pod status to API server
- Communicates with API server

**Kubelet responsibilities:**
- Starting/stopping containers
- Reporting resource usage
- Health checking probes
- Mounting volumes

### 2. kube-proxy

**Purpose:** Network proxy on each node.

**Key Functions:**
- Maintains network rules on nodes
- Implements Services abstraction (load balancing)
- Handles packet forwarding to pods

**How Services work:**
```
Client → Service IP (ClusterIP)
    ↓
kube-proxy on each node
    ↓
iptables/IPVS rules
    ↓
Forwards to backend pod IP
    ↓
Pod receives traffic
```

### 3. Container Runtime

**Purpose:** Runs containers.

**Supported runtimes:**
- **containerd** (default in newer K8s versions)
- **CRI-O**
- **Docker Engine** (via dockershim, deprecated)

**How it works:**
```
Kubelet: "Create a pod with container X"
    ↓
Container Runtime: "Pull image, start container"
    ↓
Container Runtime: "Report status back to kubelet"
```

## Kubernetes Objects

### Workload Resources

| Type | Purpose |
|------|---------|
| **Pod** | Smallest deployable unit (1+ containers) |
| **Deployment** | Declarative updates for Pods |
| **StatefulSet** | Stateful applications (stable identity) |
| **DaemonSet** | Pod on every node |
| **Job** | Run to completion |
| **CronJob** | Scheduled jobs |

### Discovery & Load Balancing

| Type | Purpose |
|------|---------|
| **Service** | Stable network endpoint for pods |
| **Ingress** | HTTP/HTTPS routing rules |

### Config & Storage

| Type | Purpose |
|------|---------|
| **ConfigMap** | Configuration data |
| **Secret** | Sensitive data |
| **PersistentVolume** | Storage resource |
| **PersistentVolumeClaim** | Storage request |

## Communication Flow

### Creating a Deployment

```bash
kubectl create deployment nginx --image=nginx
```

**What happens:**

1. **kubectl** sends HTTP request to **API Server**
2. **API Server** validates request and stores in **etcd**
3. **Controller Manager** detects new deployment
4. **Controller Manager** creates replica set
5. **Scheduler** assigns pods to nodes
6. **Kubelet** on each node starts containers
7. **kube-proxy** configures networking rules
8. **Controller Manager** continuously reconciles state

### Accessing a Service

```bash
kubectl expose deployment nginx --port=80
```

**What happens:**

1. **API Server** creates service object
2. **Controller Manager** creates endpoints (pods IPs)
3. **kube-proxy** on each node configures iptables rules
4. Service IP is now accessible from any node
5. Traffic is load balanced to backend pods

## Namespaces

**Purpose:** Virtual clusters within a physical cluster.

**Benefits:**
- Resource isolation
- Team separation
- Environment separation (dev/staging/prod)
- Resource quotas per team

**Default namespaces:**
```
default          # Default namespace for user objects
kube-system      # System components (control plane)
kube-public      # Publicly readable data
kube-node-lease  # Node lease data
```

## Kubernetes API

**REST API:** All operations go through the API.

**Authentication methods:**
- X.509 client certificates
- Bearer tokens
- Authentication proxy
- OIDC/Identity providers

**Authorization methods:**
- RBAC (Role-Based Access Control)
- ABAC (Attribute-Based Access Control)
- Node authorization
- Webhook mode

## Summary Diagram

```
User (kubectl)
    ↓
API Server (authenticates, validates)
    ↓
etcd (stores state)
    ↓
┌─────────────┬──────────────┬────────────────┐
│ Scheduler   │ Controllers  │ Cloud Manager  │
│ (assign     │ (maintain    │ (cloud         │
│  pods to    │  desired     │  resources)    │
│  nodes)     │  state)      │                │
└─────────────┴──────────────┴────────────────┘
    ↓
Worker Nodes (Kubelet)
    ↓
Container Runtime (Docker/containerd)
    ↓
Pods (Your applications)
```

## Quick Reference

### Check Control Plane Components

```bash
# Check control plane pods
kubectl get pods -n kube-system

# Check all nodes
kubectl get nodes -o wide

# Describe a node
kubectl describe node <node-name>

# Check cluster info
kubectl cluster-info

# Check API server endpoints
kubectl get endpoints
```

### Check Worker Node Components

```bash
# Check kubelet (on worker node)
systemctl status kubelet

# Check kube-proxy pods
kubectl get pods -n kube-system | grep kube-proxy

# Check container runtime
docker ps  # or
crictl ps  # or
runc -l
```

## Next Steps

1. **Practice setup**: [Lab 01: Environment Setup](../../module-k8s/01-setup/)
2. **Learn core concepts**: [Core Concepts Overview](../core-concepts/README.md)
3. **Understand pods**: [Pods](../core-concepts/pods.md)

## Additional Resources

- [Kubernetes Architecture Documentation](https://kubernetes.io/docs/concepts/architecture/)
- [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
- [Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)

---

**Continue Learning:**
- [Core Concepts](../core-concepts/README.md)
- [Pods](../core-concepts/pods.md)

**Practice:** [Lab 01: Environment Setup](../../module-k8s/01-setup/)

**Return to:** [Getting Started](README.md) | [Kubernetes Module](../README.md)
