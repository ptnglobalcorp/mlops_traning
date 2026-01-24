# Storage

**Storage classes, PersistentVolumes, and PersistentVolumeClaims**

## Overview

Kubernetes provides an abstraction for storage that enables decoupling storage from Pod lifecycle. This section covers storage concepts: StorageClasses, PersistentVolumes (PV), and PersistentVolumeClaims (PVC).

## Storage Hierarchy

```
StorageClass (Storage Profile)
    ↓
PersistentVolume (Cluster Resource)
    ↓
PersistentVolumeClaim (User Request)
    ↓
Pod (Uses PVC)
```

## Study Path

1. **[Storage Concepts](storage-concepts.md)** - Understanding PV, PVC, StorageClass
2. **[Storage Classes](storage-classes.md)** - Storage profiles and provisioning
3. **[Persistent Volumes](persistent-volumes.md)** - Cluster storage resources
4. **[Persistent Volume Claims](persistent-volume-claims.md)** - User storage requests

## Storage Comparison

| Type | Scope | Lifecycle | Use Case |
|------|-------|------------|----------|
| **emptyDir** | Pod | Deleted with pod | Temporary storage, shared data |
| **hostPath** | Node | Manual | Node access, testing |
| **ConfigMap** | Pod | Managed | Configuration files |
| **Secret** | Pod | Managed | Sensitive files |
| **PVC** | Namespace | Managed | Persistent data |
| **PV** | Cluster | Managed | Storage resources |

## Quick Reference

### Common Commands

```bash
# StorageClasses
kubectl get storageclasses
kubectl describe storageclass fast-ssd

# PersistentVolumes
kubectl get pv
kubectl describe pv pv-001

# PersistentVolumeClaims
kubectl get pvc
kubectl describe pvc data-pvc
kubectl delete pvc data-pvc
```

### Storage in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: storage-pod
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: data-pvc
```

## Storage Modes

| Access Mode | Description |
|-------------|-------------|
| **ReadWriteOnce** | Single node read-write (RWO) |
| **ReadOnlyMany** | Multiple nodes read-only (ROX) |
| **ReadWriteMany** | Multiple nodes read-write (RWX) |
| **ReadWriteOncePod** | Single pod read-write (RWX) |

## Reclaim Policies

| Policy | Description |
|---------|-------------|
| **Retain** | Manual reclamation, data preserved |
| **Delete** | Automatic deletion when PVC deleted |
| **Recycle** | Deprecated: Runs rm -rf on volume |

## Next Steps

1. **Learn Storage Concepts**: [Storage Concepts](storage-concepts.md)
2. **Understand Storage Classes**: [Storage Classes](storage-classes.md)
3. **Practice**: [Lab 04: Storage Labs](../../../module-01/k8s/04-storage/)

---

**Continue Learning:**
- [Storage Concepts](storage-concepts.md)
- [Storage Classes](storage-classes.md)

**Return to:** [Key Concepts](../README.md) | [Overview](../../01-overview/README.md)
