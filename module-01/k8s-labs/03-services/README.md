# Lab 03: Services & Networking

**Exposing applications and managing network traffic**

## Overview

In this lab, you'll learn how to expose your applications using different service types, understand service discovery, and implement network policies.

## Prerequisites

- Completed Lab 02 (First Deployment)
- Working Kubernetes cluster
- Understanding of Pods and Deployments

## Task 1: Create Sample Applications

First, let's deploy two applications to work with:

```bash
# Create namespace
kubectl create namespace networking-lab

# Deploy application 1
kubectl create deployment web-app --image=nginx:1.25 -n networking-lab
kubectl scale deployment web-app --replicas=3 -n networking-lab

# Deploy application 2
kubectl create deployment api-app --image=hashicorp/http-echo -n networking-lab \
  -- -text="API Version 2.0" -listen=:8080

# Verify
kubectl get pods -n networking-lab
```

## Task 2: ClusterIP Service (Internal)

### Step 1: Create ClusterIP service

```bash
# Create service
kubectl expose deployment web-app --port=80 --type=ClusterIP -n networking-lab

# Get service details
kubectl get svc web-app -n networking-lab

# Describe service
kubectl describe svc web-app -n networking-lab

# Check endpoints
kubectl get endpoints web-app -n networking-lab
```

### Step 2: Test ClusterIP service

```bash
# Create a test pod to access the service
kubectl run test-pod --image=busybox -n networking-lab -- sleep=3600

# Access the service from test pod
kubectl exec -n networking-lab test-pod -- wget -qO- http://web-app

# Access using full DNS name
kubectl exec -n networking-lab test-pod -- wget -qO- http://web-app.networking-lab.svc.cluster.local

# Clean up test pod
kubectl delete pod test-pod -n networking-lab
```

## Task 3: NodePort Service

### Step 1: Create NodePort service

```bash
# Create NodePort service
kubectl expose deployment api-app --port=8080 --type=NodePort -n networking-lab

# Get service (note the NodePort assigned)
kubectl get svc api-app -n networking-lab

# Get node information
kubectl get nodes -o wide
```

### Step 2: Access NodePort service

```bash
# Get the node port
NODE_PORT=$(kubectl get svc api-app -n networking-lab -o jsonpath='{.spec.ports[0].nodePort}')
echo "Node Port: $NODE_PORT"

# For minikube
minikube service api-app -n networking-lab --url

# Access via node port (use your node IP)
curl http://<node-ip>:$NODE_PORT

# For local testing with minikube tunnel (another terminal)
minikube tunnel
# Then access via LoadBalancer IP
```

## Task 4: Headless Service

### Step 1: Create headless service

```yaml
# Create headless-service.yaml
cat > headless-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: web-app-headless
  namespace: networking-lab
spec:
  clusterIP: None  # Makes it headless
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
EOF

kubectl apply -f headless-service.yaml
```

### Step 2: Test headless service DNS

```bash
# Create test pod
kubectl run dns-test --image=busybox -n networking-lab -- sleep=3600

# Query DNS for headless service (returns all pod IPs)
kubectl exec -n networking-lab dns-test -- nslookup web-app-headless

# Compare with ClusterIP service (returns service IP)
kubectl exec -n networking-lab dns-test -- nslookup web-app

# Clean up
kubectl delete pod dns-test -n networking-lab
```

## Task 5: Multi-Port Service

### Step 1: Create deployment with multiple ports

```yaml
# Create multi-port-app.yaml
cat > multi-port-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-port-app
  namespace: networking-lab
spec:
  replicas: 1
  selector:
    matchLabels:
      app: multi-port
  template:
    metadata:
      labels:
        app: multi-port
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
EOF

kubectl apply -f multi-port-app.yaml
```

### Step 2: Create multi-port service

```yaml
# Create multi-port-service.yaml
cat > multi-port-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: multi-port-service
  namespace: networking-lab
spec:
  selector:
    app: multi-port
  ports:
  - name: http
    port: 80
    targetPort: http
  - name: https
    port: 443
    targetPort: https
EOF

kubectl apply -f multi-port-service.yaml

# Verify
kubectl describe svc multi-port-service -n networking-lab
```

## Task 6: Service Discovery

### Step 1: Environment variables

```bash
# Create a new pod and check environment variables
kubectl run env-test --image=nginx -n networking-lab -- sleep=3600

# Exec into pod and check environment
kubectl exec -n networking-lab env-test -- env | grep SERVICE

# You should see environment variables for all services
# Example output:
# WEB_APP_SERVICE_HOST=10.96.0.10
# WEB_APP_SERVICE_PORT=80
```

### Step 2: DNS resolution

```bash
# Test DNS resolution from pod
kubectl exec -n networking-lab env-test -- nslookup web-app
kubectl exec -n networking-lab env-test -- nslookup web-app.networking-lab
kubectl exec -n networking-lab env-test -- nslookup web-app.networking-lab.svc.cluster.local

# Clean up
kubectl delete pod env-test -n networking-lab
```

## Task 7: Network Policy (Optional)

### Step 1: Check if network policy is supported

```bash
# Check if CNI supports NetworkPolicy
kubectl get svc -n kube-system | grep network

# If using Calico, Cilium, or similar, NetworkPolicy is supported
```

### Step 2: Create deny-all network policy

```yaml
# Create deny-all.yaml
cat > deny-all.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: networking-lab
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

kubectl apply -f deny-all.yaml

# Test: Traffic should be blocked
kubectl run test-pod --image=busybox -n networking-lab --rm -it -- wget --timeout=2 http://web-app
# Should fail or timeout
```

### Step 3: Create allow-specific network policy

```yaml
# Create allow-web-app.yaml
cat > allow-web-app.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-web-app
  namespace: networking-lab
spec:
  podSelector:
    matchLabels:
      app: web-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: networking-lab
    ports:
    - protocol: TCP
      port: 80
EOF

kubectl apply -f allow-web-app.yaml

# Test: Traffic should now work
kubectl run test-pod --image=busybox -n networking-lab --rm -it -- wget -qO- http://web-app
```

## Task 8: Service Session Affinity

```bash
# Create service with session affinity
kubectl patch svc web-app -n networking-lab -p '{"spec":{"sessionAffinity":"ClientIP","sessionAffinityConfig":{"clientIP":{"timeoutSeconds":10800}}}}'

# Verify
kubectl describe svc web-app -n networking-lab | grep -i affinity
```

## Task 9: Clean Up

```bash
# Delete all resources
kubectl delete namespace networking-lab

# Or delete resources individually
kubectl delete deployment web-app api-app multi-port-app -n networking-lab
kubectl delete service web-app api-app web-app-headless multi-port-service -n networking-lab
kubectl delete networkpolicy deny-all allow-web-app -n networking-lab

# Verify cleanup
kubectl get all -n networking-lab
```

## Challenge Exercises

### Challenge 1: LoadBalancer Service (Cloud or Metallb)

If running in a cloud or with Metallb installed:

```bash
# Create LoadBalancer service
kubectl expose deployment web-app --port=80 --type=LoadBalancer -n networking-lab

# Get external IP
kubectl get svc web-app -n networking-lab

# Access via external IP
curl http://<external-ip>
```

### Challenge 2: ExternalName Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-db
  namespace: networking-lab
spec:
  type: ExternalName
  externalName: database.example.com
```

### Challenge 3: Service with Endpoints (Without Selector)

Create a service that points to external IP:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-api
  namespace: networking-lab
spec:
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-api
  namespace: networking-lab
subsets:
  - addresses:
    - ip: 1.2.3.4  # External IP
    ports:
    - port: 8080
```

## Verification Checklist

- [ ] Created ClusterIP service
- [ ] Tested service from pod
- [ ] Created and accessed NodePort service
- [ ] Created headless service
- [ ] Tested DNS resolution
- [ ] Created multi-port service
- [ ] Tested environment variable service discovery
- [ ] Created network policies (optional)

## What You Learned

- Different service types (ClusterIP, NodePort, Headless)
- Service discovery (DNS and environment variables)
- Multi-port services
- Network policies for traffic control
- Service session affinity

## Common Commands Reference

```bash
# Create services
kubectl expose deployment <name> --port=80 --type=ClusterIP
kubectl apply -f service.yaml

# List services
kubectl get svc
kubectl get svc -n <namespace>

# Describe service
kubectl describe svc <service-name>

# Get endpoints
kubectl get endpoints <service-name>

# Test service from pod
kubectl run test --image=busybox -it -- rm -- wget -qO- http://<service-name>

# Port forward
kubectl port-forward svc/<service-name> 8080:80

# Delete service
kubectl delete svc <service-name>
```

## Next Steps

1. Learn about [ConfigMaps & Secrets](../../docs/module-k8s/storage/README.md)
2. Practice with [Lab 04: ConfigMaps & Secrets](../04-configmaps-secrets/)

## Additional Resources

- [Service Documentation](https://kubernetes.io/docs/concepts/services-networking/service/)
- [DNS for Services and Pods](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)

---

**Next Lab:** [Lab 04: ConfigMaps & Secrets](../04-configmaps-secrets/)

**Return to:** [Kubernetes Module](../../docs/module-k8s/README.md)
