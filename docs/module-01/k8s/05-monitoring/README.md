# Monitoring

**Observability for Kubernetes: Metrics, Logs, and Traces**

## Overview

Monitoring is crucial for operating Kubernetes clusters effectively. This section covers the key monitoring concepts and tools for Kubernetes observability.

## Three Pillars of Observability

| Pillar | Purpose | Tools |
|--------|---------|-------|
| **Metrics** | Numerical time-series data | Prometheus, Metrics Server |
| **Logs** | Event records and debugging | Loki, ELK, Fluentd |
| **Traces** | Request paths through systems | Jaeger, Tempo, OpenTelemetry |

## Monitoring Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                     Monitoring Stack                            │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Applications & Services                       │  │
│  │  • Emit Metrics • Generate Logs • Propagate Traces     │  │
│  └───────────────────────────────────────────────────────────┘  │
│                           ↓                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Collection Agents                             │  │
│  │  • Metrics Exporter • Log Collector • Trace Agent       │  │
│  └───────────────────────────────────────────────────────────┘  │
│                           ↓                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Storage & Backend                            │  │
│  │  • Prometheus (Metrics) • Loki (Logs) • Tempo (Traces)   │  │
│  └───────────────────────────────────────────────────────────┘  │
│                           ↓                                    │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │              Visualization & Alerting                      │  │
│  │  • Grafana (Dashboards) • AlertManager (Alerts)         │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

### Install Metrics Server

```bash
# Check if metrics-server is installed
kubectl get pods -n kube-system | grep metrics-server

# Install (if not present)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Verify
kubectl top nodes
kubectl top pods
```

### Install Prometheus Stack

```bash
# Add kube-prometheus-stack repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Open http://localhost:3000
# Default credentials: admin/prom-operator
```

## Metrics

### Key Metrics to Monitor

| Type | Metrics |
|------|---------|
| **Cluster** | Node health, resource usage, pod counts |
| **Pod** | CPU, Memory, Restarts, Uptime |
| **Application** | Custom business metrics (requests, latency) |
| **Network** | Traffic, Errors, Latency |

### Using Metrics Server

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -A

# Check pods in namespace
kubectl top pods -n kube-system
```

### Using Prometheus

```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-k8s 9090:9090

# Query metrics (PromQL)
# Example queries:
# - CPU usage: rate(container_cpu_usage_seconds_total[5m])
# - Memory usage: container_memory_working_set_bytes
# - Pod restarts: rate(kube_pod_container_status_restarts_total[1h])
```

## Logging

### Kubernetes Logging Architecture

```
Application Logs
       ↓
stdout/stderr (Container)
       ↓
 kubelet (Node)
       ↓
Log Collector (Fluentd/Fluent Bit)
       ↓
Central Logging (Loki/ELK)
       ↓
Visualization (Grafana/Kibana)
```

### View Pod Logs

```bash
# View logs
kubectl logs <pod-name>

# Follow logs (stream)
kubectl logs -f <pod-name>

# View logs from previous container
kubectl logs <pod-name> --previous

# View logs for all pods in deployment
kubectl logs -l app=nginx --tail=100 -f
```

### Logs from Multiple Pods

```bash
# Logs from all replicas
kubectl logs -l app=ml-model --tail=50

# Logs with timestamps
kubectl logs -f <pod-name> --timestamps=true

# Logs since time
kubectl logs --since-time=2025-01-15T10:00:00Z <pod-name>
```

## Tracing

### Distributed Tracing Concepts

| Concept | Description |
|---------|-------------|
| **Trace** | End-to-end journey of a request |
| **Span** | Single operation within a trace |
| **Trace ID** | Unique identifier for a trace |
| **Span ID** | Unique identifier for a span |

### Installing Jaeger

```bash
# Install Jaeger operator
kubectl create namespace observability
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/crds/jaegertracing.io_jaegers_crd.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/service_account.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/role.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/main/deploy/operator.yaml

# Create Jaeger instance
kubectl apply -f - <<EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
  namespace: observability
spec:
  strategy: allInOne
  allInOne:
    image: jaegertracing/all-in-one:latest
  ui:
    options:
      logLevel: info
EOF

# Access UI
kubectl port-forward -n observability svc/jaeger-query 16686:16686
# Open http://localhost:16686
```

## Alerts

### AlertManager

```bash
# Check alerts
kubectl get prometheus -n monitoring

# Port forward
kubectl port-forward -n monitoring svc/prometheus-k8s 9093:9093
```

### Alert Example

```yaml
# Example alert rule
groups:
- name: ml-model-alerts
  rules:
  - alert: HighErrorRate
    expr: rate(http_requests_total{status="500"}[5m]) > 0.05
    for: 5m
    labels:
      severity: critical
      team: ml-ops
    annotations:
      summary: "High error rate on ML model API"
      description: "Error rate is {{ $value }} errors/sec"
```

## Dashboards

### Key Dashboards to Create

1. **Cluster Overview** - Node health, resource usage
2. **Pod Overview** - Pod status, restarts, resource usage
3. **Application Metrics** - Custom business metrics
4. **ML Model Metrics** - Inference latency, throughput, error rates

### Sample Grafana Queries

```promql
# CPU Usage by Pod
sum(rate(container_cpu_usage_seconds_total{namespace="ml-apps"}[5m])) by (pod)

# Memory Usage by Pod
sum(container_memory_working_set_bytes{namespace="ml-apps"}) by (pod)

# Pod Restart Count
increase(kube_pod_container_status_restarts_total{namespace="ml-apps"}[1h])

# HTTP Request Rate
rate(http_requests_total{namespace="ml-apps"}[5m])

# P95 Latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Best Practices

1. **Enable metrics server** for basic resource monitoring
2. **Use labels effectively** for grouping metrics
3. **Set up alerts** for critical failures
4. **Create dashboards** for quick visualization
5. **Centralize logs** for analysis
6. **Implement tracing** for microservices
7. **Monitor the monitoring stack** itself

## Monitoring Tools Comparison

| Tool | Purpose | Complexity |
|------|---------|------------|
| **Metrics Server** | Basic resource metrics | Low |
| **Prometheus** | Full metrics stack | Medium |
| **Grafana** | Visualization | Low |
| **Loki** | Log aggregation | Medium |
| **Jaeger** | Distributed tracing | High |
| **Elastic Stack** | Logs + Metrics | High |

## Next Steps

1. **Install Metrics Server**: [Metrics Server Docs](https://github.com/kubernetes-sigs/metrics-server)
2. **Deploy Prometheus Stack**: [kube-prometheus-stack](https://github.com/prometheus-community/helm/charts/tree/main/charts/kube-prometheus-stack)
3. **Create Dashboards**: [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

## Additional Resources

- [Kubernetes Monitoring](https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-usage-monitoring/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)

---

**Return to:** [Overview](../01-overview/README.md) | [K8s for MLOps](../README.md)
