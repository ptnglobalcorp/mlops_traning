# Helm

**Kubernetes package manager for application deployment**

## Overview

Helm is the package manager for Kubernetes. It helps you manage Kubernetes applications through Helm Charts - packages of pre-configured Kubernetes resources.

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Chart** | A package of pre-configured Kubernetes resources |
| **Repository** | A collection of charts |
| **Release** | A specific instance of a chart running in the cluster |
| **Values** | Configuration values that override chart defaults |

## Helm Architecture

```
Helm Client (CLI)
        ↓
Helm Chart (Package)
        ↓
Kubernetes API Server
        ↓
Chart Resources Deployed
```

## Quick Start

### Install Helm

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows (Chocolatey)
choco install kubernetes-helm

# Verify
helm version
```

### Basic Commands

```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# Update repositories
helm repo update

# Search for charts
helm search repo nginx

# Install chart
helm install my-release bitnami/nginx

# List releases
helm list

# Uninstall release
helm uninstall my-release

# Upgrade release
helm upgrade my-release bitnami/nginx
```

## Chart Structure

```
my-chart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default configuration values
├── values.schema.json  # Values schema (optional)
├── charts/             # Chart dependencies
├── templates/           # Kubernetes manifest templates
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── ...
└── templates/NOTES.txt # Usage notes (optional)
```

## Using Charts

### Installing from Repository

```bash
# Install with default values
helm install my-nginx bitnami/nginx

# Install with custom values
helm install my-nginx bitnami/nginx --set replicaCount=3

# Install with values file
helm install my-nginx bitnami/nginx -f custom-values.yaml

# Install in specific namespace
helm install my-nginx bitnami/nginx -n my-apps --create-namespace
```

### Creating Custom Chart

```bash
# Create new chart
helm create my-chart

# Package chart
helm package my-chart

# Install local chart
helm install my-release ./my-chart-1.0.0.tgz
```

## Values File

### Default values.yaml

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.25"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: "nginx"
  hosts:
    - host: chart-example.local
      paths:
      - path: /
        pathType: Prefix

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

### Custom values override

```yaml
# custom-values.yaml
replicaCount: 3

image:
  tag: "1.26"

service:
  type: LoadBalancer

ingress:
  enabled: true

resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

```bash
helm install my-release ./my-chart -f custom-values.yaml
```

## Template Example

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
        readinessProbe:
          httpGet:
            path: /
            port: http
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
```

## Popular Charts

| Chart | Description |
|-------|-------------|
| **nginx-ingress** | Ingress controller |
| **cert-manager** | TLS certificate management |
| **prometheus** | Monitoring system |
| **grafana** | Visualization dashboard |
| **postgresql** | Database |
| **redis** | Key-value store |
| **mlflow** | ML platform |

## Best Practices

1. **Use official or trusted charts**
2. **Pin chart versions in production**
3. **Review chart manifests before installing**
4. **Use values files for configuration**
5. **Version control your values files**
6. **Test in non-production first**

## Next Steps

1. **Explore Helm Charts**: [Artifact Hub](https://artifacthub.io/)
2. **Create Custom Chart**: [Helm Docs](https://helm.sh/docs/)
3. **Practice**: Deploy an application using Helm

## Additional Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/)
- [Helm Charts Guide](https://helm.sh/docs/topics/charts/)

---

**Return to:** [Overview](../01-overview/README.md) | [K8s for MLOps](../README.md)
