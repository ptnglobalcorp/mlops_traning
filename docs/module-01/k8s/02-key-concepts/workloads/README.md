# Workloads

**Understanding Kubernetes workload resources: ReplicaSet, Deployment, DaemonSet, StatefulSet, Job, CronJob**

## Overview

Workload resources manage the lifecycle of Pods. Kubernetes provides several workload controllers, each designed for specific use cases. This section covers the different workload types and when to use each one.

## Workload Comparison

| Workload | Use Case | Scaling | Storage | Updates |
|----------|----------|---------|---------|---------|
| **ReplicaSet** | Maintain N identical pods | Manual | No | No |
| **Deployment** | Stateless apps | Yes (auto) | No | Yes (rolling) |
| **StatefulSet** | Stateful apps | Yes (auto) | Yes (unique) | Yes (rolling) |
| **DaemonSet** | One pod per node | N/A | No | Yes (rolling) |
| **Job** | Run to completion | No | Optional | No |
| **CronJob** | Scheduled jobs | No | Optional | No |

## Study Path

1. **[ReplicaSet](replicaset.md)** - Maintain N identical pods
2. **[Deployment](deployment.md)** - Stateless applications
3. **[DaemonSet](daemonset.md)** - One pod per node
4. **[StatefulSet](statefulset.md)** - Stateful applications
5. **[Job](job.md)** - Run to completion
6. **[CronJob](cronjob.md)** - Scheduled jobs

## Quick Reference

### Choosing a Workload Type

```
┌─────────────────────────────────────────────────────────────────┐
│                    Need to Deploy Pods?                        │
└─────────────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────────┬───────────────────────┐
        │ Run once to completion? │                      │
        │ YES → Job/CronJob       │ NO                   │
        └───────────────────────┴───────────────────────┘
                            ↓
        ┌───────────────────────┬───────────────────────┐
        │ One pod per node?      │                       │
        │ YES → DaemonSet        │ NO                    │
        └───────────────────────┴───────────────────────┘
                            ↓
        ┌───────────────────────┬───────────────────────┐
        │ Needs stable identity? │                       │
        │ + Persistent storage?  │                       │
        │ YES → StatefulSet      │ NO → Deployment       │
        └───────────────────────┴───────────────────────┘
```

### Common Commands

```bash
# Deployments
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl set image deployment/nginx nginx=nginx:1.26
kubectl rollout undo deployment/nginx

# StatefulSets
kubectl get statefulsets
kubectl scale statefulset mongodb --replicas=5
kubectl rollout status statefulset/mongodb

# DaemonSets
kubectl get daemonsets
kubectl rollout restart daemonset/fluentd

# Jobs
kubectl create job my-job --image=busybox -- echo "Hello"
kubectl create cronjob my-cron --image=busybox --schedule="*/5 * * * *"
kubectl get jobs
kubectl delete job my-job
```

## Workload Specifications

### ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

### DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.16
```

### StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongodb
spec:
  serviceName: mongodb
  replicas: 3
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:6.0
        ports:
        - containerPort: 27017
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: batch-job
spec:
  completions: 1
  backoffLimit: 4
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo 'Hello World'"]
```

### CronJob

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: scheduled-job
spec:
  schedule: "0 */6 * * *"  # Every 6 hours
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: cron-worker
            image: busybox
            command: ["sh", "-c", "echo 'Running scheduled job'"]
```

## Common Patterns

### Stateless Application (Deployment)

```yaml
# Web servers, APIs, microservices
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-api
  template:
    metadata:
      labels:
        app: web-api
    spec:
      containers:
      - name: api
        image: my-api:v2.1
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

### Stateful Application (StatefulSet)

```yaml
# Databases, message queues, distributed systems
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres-db
spec:
  serviceName: postgres-db
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        env:
        - name: POSTGRES_PASSWORD
          value: "secret123"
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

### Batch Processing (Job)

```yaml
# ML training, data processing, backups
apiVersion: batch/v1
kind: Job
metadata:
  name: ml-training-job
spec:
  completions: 1
  parallelism: 1
  backoffLimit: 4
  activeDeadlineSeconds: 3600  # 1 hour max
  template:
    spec:
      restartPolicy: Never
      containers:
      - name: trainer
        image: ml-trainer:latest
        command: ["python", "train.py"]
        resources:
          limits:
            nvidia.com/gpu: 1
```

### Cluster-Level Agent (DaemonSet)

```yaml
# Monitoring agents, log collectors, network plugins
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: monitoring-agent
spec:
  selector:
    matchLabels:
      app: monitoring-agent
  template:
    metadata:
      labels:
        app: monitoring-agent
    spec:
      containers:
      - name: agent
        image: monitoring-agent:v1.0
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
```

### Scheduled Task (CronJob)

```yaml
# Periodic backups, reports, maintenance tasks
apiVersion: batch/v1
kind: CronJob
metadata:
  name: daily-backup
spec:
  schedule: "0 2 * * *"  # 2 AM daily
  concurrencyPolicy: Forbid  # Don't overlap
  successfulJobsHistoryLimit: 7
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: backup-tool:latest
            command: ["./backup.sh"]
```

## Update Strategies

### RollingUpdate (Deployment, DaemonSet)

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 25%  # Max 25% can be down during update
      maxSurge: 25%        # Max 25% extra pods during update
```

### RollingUpdate (StatefulSet)

```yaml
spec:
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      partition: 0  # Update pods with ordinal >= partition
```

### OnDelete (Manual Control)

```yaml
spec:
  updateStrategy:
    type: OnDelete  # Only update when pod is deleted
```

## Scaling

### Manual Scaling

```bash
kubectl scale deployment nginx --replicas=10
kubectl scale statefulset mongodb --replicas=5
```

### Horizontal Pod Autoscaler (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Best Practices

### 1. Use Deployments for Stateful Apps Only When Necessary

- Deployments: Simpler, faster, better for most cases
- StatefulSets: Required only when you need:
  - Stable network identities
  - Stable persistent storage
  - Ordered deployment and scaling

### 2. Always Set Resource Limits

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### 3. Use Probes for Self-Healing

```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
```

### 4. Pin Image Versions

```yaml
# Bad
image: myapp:latest

# Good
image: myapp:v2.1.0
```

### 5. Set Appropriate Restart Policies

| Workload | Recommended Policy |
|----------|-------------------|
| Deployment | Always (default) |
| DaemonSet | Always (default) |
| StatefulSet | Always (default) |
| Job | OnFailure or Never |
| CronJob | OnFailure or Never |

## Next Steps

1. **Learn ReplicaSet**: [ReplicaSet](replicaset.md)
2. **Understand Deployment**: [Deployment](deployment.md)
3. **Study StatefulSet**: [StatefulSet](statefulset.md)
4. **Explore Jobs**: [Job](job.md)
5. **Practice**: [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

---

**Continue Learning:**
- [ReplicaSet](replicaset.md)
- [Deployment](deployment.md)
- [DaemonSet](daemonset.md)
- [StatefulSet](statefulset.md)
- [Job](job.md)
- [CronJob](cronjob.md)

**Practice:** [Lab 02: First Deployment](../../../module-01/k8s/02-first-deployment/)

**Return to:** [Key Concepts](../README.md) | [Overview](../../01-overview/README.md)
