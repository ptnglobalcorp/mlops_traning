# Network

**Services, Ingress, and Ingress Gateway for Kubernetes networking**

## Overview

Kubernetes networking enables communication between Pods, Services, and external traffic. This section covers Services, Ingress, and Ingress Gateway.

## Study Path

1. **[Services](services.md)** - ClusterIP, NodePort, LoadBalancer
2. **[Service Discovery](service-discovery.md)** - DNS and environment variables
3. **[Ingress](ingress.md)** - HTTP/HTTPS routing
4. **[Ingress Gateway](ingress-gateway.md)** - Advanced API Gateway patterns

## Quick Comparison

| Type | Scope | Use Case |
|------|-------|----------|
| **ClusterIP** | Cluster internal | Internal microservice communication |
| **NodePort** | Node-level access | Development, testing |
| **LoadBalancer** | External access | Production external access |
| **Ingress** | HTTP/HTTPS routing | Host/path-based routing |
| **Ingress Gateway** | Advanced routing | API Gateway, rate limiting, auth |

## Quick Reference

### Common Commands

```bash
# Services
kubectl get services
kubectl expose deployment nginx --port=80
kubectl describe service nginx

# Ingress
kubectl get ingress
kubectl describe ingress my-ingress

# Service discovery
kubectl run test --image=busybox -it -- wget http://service-name
```

### Service Types

```yaml
# ClusterIP (default)
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080

---
# NodePort
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080

---
# LoadBalancer
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 8080
```

### Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

## Best Practices

1. **Use ClusterIP for internal services**
2. **Use Ingress for external HTTP/HTTPS access**
3. **Configure health checks on Services**
4. **Use NetworkPolicies for security**
5. **Implement proper TLS termination**

## Next Steps

1. **Learn Services**: [Services](services.md)
2. **Understand Ingress**: [Ingress](ingress.md)
3. **Practice**: [Lab 03: Services & Networking](../../../module-01/k8s/03-services/)

---

**Continue Learning:**
- [Services](services.md)
- [Ingress](ingress.md)
- [Ingress Gateway](ingress-gateway.md)

**Practice:** [Lab 03: Services](../../../module-01/k8s/03-services/)

**Return to:** [Key Concepts](../README.md) | [Overview](../../01-overview/README.md)
