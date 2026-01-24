# Configuration

**ConfigMaps and Secrets for application configuration**

## Overview

Kubernetes provides two primary mechanisms for configuration: ConfigMaps for non-sensitive data and Secrets for sensitive data. This section covers how to manage application configuration in Kubernetes.

## Study Path

1. **[ConfigMaps](configmaps.md)** - Non-sensitive configuration
2. **[Secrets](secrets.md)** - Sensitive data management
3. **[Configuration Patterns](patterns.md)** - Best practices

## Quick Comparison

| Aspect | ConfigMap | Secret |
|--------|-----------|--------|
| **Purpose** | Non-sensitive config | Sensitive data |
| **Encoding** | Plain text | Base64 (not encrypted by default) |
| **Visibility** | Visible to anyone with access | Should be RBAC-protected |
| **Use Case** | Config files, environment variables | Passwords, keys, tokens |

## Quick Reference

### Common Commands

```bash
# ConfigMaps
kubectl create configmap my-config --from-file=config.yaml
kubectl get configmaps
kubectl describe configmap my-config
kubectl delete configmap my-config

# Secrets
kubectl create secret generic my-secret --from-literal=password=mypass
kubectl get secrets
kubectl describe secret my-secret
kubectl delete secret my-secret
```

### Using in Pods

```yaml
# As environment variables
envFrom:
- configMapRef:
    name: app-config
- secretRef:
    name: app-secret

# As volumes
volumes:
- name: config
  configMap:
    name: app-config
- name: secrets
  secret:
    secretName: app-secret
```

## Best Practices

1. **Never commit Secrets to git**
2. **Use volume mounts for Secrets** (not environment variables)
3. **Encrypt Secrets at rest** (enable KMS encryption)
4. **Rotate Secrets regularly**
5. **Use RBAC to restrict access**

## Next Steps

1. **Learn ConfigMaps**: [ConfigMaps](configmaps.md)
2. **Understand Secrets**: [Secrets](secrets.md)
3. **Practice**: [Lab 04: Configuration](../../../module-01/k8s/04-configmaps-secrets/)

---

**Continue Learning:**
- [ConfigMaps](configmaps.md)
- [Secrets](secrets.md)

**Return to:** [Key Concepts](../README.md) | [Overview](../../01-overview/README.md)
