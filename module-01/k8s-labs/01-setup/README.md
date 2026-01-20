# Lab 01: Environment Setup

**Set up your local Kubernetes development environment**

## Overview

In this lab, you'll set up a local Kubernetes development environment. This includes installing kubectl, setting up a local cluster (minikube or kind), and verifying everything works.

## Prerequisites

- Docker installed (from Module 1)
- Basic command line familiarity
- Internet connection

## Tasks

### Task 1: Install kubectl

Install the Kubernetes command-line tool.

#### macOS

```bash
# Install using Homebrew
brew install kubectl

# Verify installation
kubectl version --client
```

#### Linux

```bash
# Download the latest version
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

#### Windows (WSL2)

```bash
# Inside WSL2 Ubuntu/Debian
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

### Task 2: Install Minikube or Kind

Choose ONE option for your local cluster.

#### Option A: Minikube (Recommended for beginners)

**macOS:**
```bash
brew install minikube
minikube version
```

**Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```

**Windows (Chocolatey):**
```powershell
choco install minikube
minikube version
```

#### Option B: Kind (Lightweight option)

**macOS/Linux:**
```bash
go install sigs.k8s.io/kind@latest
# OR
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

**Windows:**
```powershell
choco install kind
kind version
```

### Task 3: Start Your Cluster

#### If using Minikube:

```bash
# Start with default settings
minikube start

# OR start with more resources (recommended for ML workloads)
minikube start --cpus=4 --memory=8192 --disk-size=50g

# Check status
minikube status

# Enable useful addons
minikube addons enable dashboard
minikube addons enable metrics-server
```

#### If using Kind:

```bash
# Create a cluster
kind create cluster

# Check status
kubectl cluster-info

# List nodes
kubectl get nodes
```

### Task 4: Verify Your Setup

```bash
# Check cluster connection
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check all namespaces
kubectl get namespaces

# Check your version
kubectl version
```

**Expected output for `kubectl get nodes`:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   5m    v1.32.0
```

### Task 5: Run Your First Deployment

```bash
# Create a simple deployment
kubectl create deployment hello-kubernetes --image=hello-world

# Check the deployment
kubectl get deployments

# Check the pods
kubectl get pods

# Get more details
kubectl describe deployment hello-kubernetes
```

### Task 6: Expose Your Deployment

```bash
# Expose the deployment
kubectl expose deployment hello-kubernetes --port=80 --type=NodePort

# Get the service
kubectl get services

# Access the service (minikube only)
minikube service hello-kubernetes

# OR port forward
kubectl port-forward svc/hello-kubernetes 8080:80
# Open http://localhost:8080
```

### Task 7: Clean Up

```bash
# Delete the deployment and service
kubectl delete deployment hello-kubernetes
kubectl delete service hello-kubernetes

# Verify cleanup
kubectl get all
```

## Optional: Enable Shell Autocompletion

### Bash

```bash
# Add to ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
source ~/.bashrc
```

### Zsh (macOS default)

```bash
# Add to ~/.zshrc
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc
```

## Verification Checklist

- [ ] kubectl is installed and returns version
- [ ] minikube or kind is installed
- [ ] Cluster is running (`kubectl get nodes` shows Ready)
- [ ] System pods are running (`kubectl get pods -n kube-system`)
- [ ] You can create and access a deployment

## Common Issues

### Issue: "kubectl: command not found"

**Solution:** kubectl is not in your PATH.
```bash
# Check if installed
which kubectl

# Add to PATH (Linux/macOS)
export PATH=$PATH:/usr/local/bin
```

### Issue: "minikube start" fails

**Solution:** Check if virtualization is enabled and Docker is running.
```bash
# Check Docker
docker ps

# Try with Docker driver
minikube start --driver=docker
```

### Issue: "The connection to the server was refused"

**Solution:** Start your cluster.
```bash
minikube start
# OR
kind create cluster
```

## Next Steps

Once your environment is set up:
1. Learn about [Pods](../../docs/module-k8s/core-concepts/pods.md)
2. Practice with [Lab 02: First Deployment](../02-first-deployment/)

## Additional Resources

- [Minikube Documentation](https://minikube.sigs.k8s.io/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)

---

**Next Lab:** [Lab 02: First Deployment](../02-first-deployment/)

**Return to:** [Kubernetes Module](../../docs/module-k8s/README.md)
