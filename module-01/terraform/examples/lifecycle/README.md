# Lifecycle Example

This example demonstrates **Terraform lifecycle management** for safe ML infrastructure updates.

## What You'll Learn

- `create_before_destroy` - Zero-downtime resource updates
- `prevent_destroy` - Protect critical ML resources from deletion
- `ignore_changes` - Ignore dynamic parameter updates
- `replace_triggered_by` - Force resource replacement on dependency changes

## Quick Start

```bash
# Navigate to this directory
cd module-01/terraform/examples/lifecycle

# Review the plan
terraform plan

# Apply changes
terraform apply
```

## Lifecycle Rules Overview

```
+--------------------------------------------------------------------------+
|                        Terraform Lifecycle                              |
+--------------------------------------------------------------------------+
|                                                                          |
|  Resource Creation Flow:                                                |
|                                                                          |
|  1. Plan Phase                                                          |
|     ├── Check lifecycle rules                                          |
|     ├── Determine create/destroy/update needs                           |
|     └── Create dependency graph                                         |
|                                                                          |
|  2. Apply Phase                                                         |
|     ├── create_before_destroy (if set)                                  |
|     │   ├── Create NEW resource                                         |
|     │   ├── Update dependencies                                          |
|     │   └── Destroy OLD resource                                        |
|     │                                                                  |
|     ├── prevent_destroy (if set)                                        |
|     │   └── Block deletion of resource                                  |
|     │                                                                  |
|     ├── ignore_changes (if set)                                         |
|     │   └── Skip specific attributes in diff                             |
|     │                                                                  |
|     └── replace_triggered_by (if triggered)                             |
|         └── Force resource replacement                                  |
|                                                                          |
+--------------------------------------------------------------------------+
```

## 1. create_before_destroy

**Use Case:** Zero-downtime updates for ML inference endpoints

When updating resources that other resources depend on (like security groups), Terraform normally destroys the old resource before creating the new one. This causes downtime.

```hcl
resource "aws_security_group" "ml_inference" {
  name_prefix = "${var.project_name}-ml-inference-"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    # Create NEW SG before destroying OLD SG
    create_before_destroy = true
  }
}
```

**Flow:**
```
1. Create ml-inference-NEW
2. Update resources to use ml-inference-NEW
3. Destroy ml-inference-OLD
```

## 2. prevent_destroy

**Use Case:** Protect production ML model storage

Production model buckets should never be accidentally deleted.

```hcl
resource "aws_s3_bucket" "production_models" {
  bucket = "production-ml-models"

  lifecycle {
    # Block terraform destroy for this resource
    prevent_destroy = true
  }
}
```

**To destroy a protected resource:**
1. Remove `prevent_destroy` from code
2. Run `terraform apply`
3. Run `terraform destroy`

**Error message when attempting to destroy:**
```
Error: plan would destroy production-ml-models
but resource has lifecycle.prevent_destroy set to true
```

## 3. ignore_changes

**Use Case:** Ignore tags/parameters updated by ML pipelines

ML pipelines often add dynamic tags (run IDs, timestamps). These cause drift detection noise.

```hcl
resource "aws_s3_bucket" "ml_artifacts" {
  bucket = "ml-artifacts"

  tags = {
    Purpose = "ml-artifacts"
  }

  lifecycle {
    # Ignore ALL tag changes
    ignore_changes = [tags]

    # Or ignore specific tag keys
    ignore_changes = [
      tags.LastModifiedBy,
      tags.PipelineRunID,
      tags.BuildNumber,
    ]
  }
}
```

**Result:** Terraform won't show drift for ignored attributes.

## 4. replace_triggered_by

**Use Case:** Replace resource when dependency changes

When ML model version changes, replace the cache bucket to ensure consistency.

```hcl
resource "aws_s3_bucket" "model_cache" {
  bucket = "model-cache"
}

resource "aws_s3_bucket" "model_storage" {
  bucket = "model-storage"

  lifecycle {
    # Replace this bucket when cache bucket ID changes
    replace_triggered_by = [aws_s3_bucket.model_cache.id]
  }
}
```

**Result:** When `model_cache` changes, `model_storage` is recreated.

## Practical ML Examples

### Zero-Downtime Model Deployment

```hcl
resource "aws_lambda_function" "ml_inference" {
  function_name = "ml-inference"
  runtime       = "python3.11"

  lifecycle {
    # Create new version before destroying old one
    create_before_destroy = true

    # Ignore deployment system tags
    ignore_changes = [
      tags["LastModified"],
      tags["Version"],
    ]
  }
}
```

### Protected Production Storage

```hcl
resource "aws_s3_bucket" "prod_models" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "production-ml-models"

  lifecycle {
    prevent_destroy = true
  }
}
```

### Dynamic ML Configuration

```hcl
resource "aws_s3_bucket" "training_configs" {
  bucket = "training-configs"

  lifecycle {
    # Replace when framework changes
    replace_triggered_by = [var.training_framework]

    # Ignore pipeline tags
    ignore_changes = [tags]
  }
}
```

## Combined Lifecycle Rules

Resources can have multiple lifecycle rules:

```hcl
resource "aws_s3_bucket" "critical_ml_data" {
  bucket = "critical-ml-data"

  lifecycle {
    prevent_destroy       = true  # Protect from deletion
    ignore_changes        = [tags]  # Ignore dynamic tags
    create_before_destroy = true  # Safe updates
  }
}
```

## Testing Lifecycle Rules

### Test create_before_destroy

```bash
# Make a change to the security group
# Edit main.tf and add a new ingress rule

# Plan shows: create before destroy
terraform plan

# Apply: new SG created first
terraform apply
```

### Test prevent_destroy

```bash
# Try to destroy protected resource
terraform destroy

# Expected error:
# Error: Resource has lifecycle.prevent_destroy set
```

### Test ignore_changes

```bash
# Manually add a tag to the bucket
aws s3api put-bucket-tagging \
  --bucket ml-artifacts \
  --tagging 'TagSet=[{Key=DynamicTag,Value=Test}]'

# Run plan - tag change is ignored
terraform plan

# No changes shown for tags
```

### Test replace_triggered_by

```bash
# Change the triggering variable
terraform apply -var="model_version=v2.0"

# Model storage bucket is replaced
```

## Lifecycle Best Practices for MLOps

### 1. Production Model Storage

```hcl
resource "aws_s3_bucket" "production_models" {
  bucket = "prod-ml-models"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastModified"]]
  }
}
```

### 2. Inference Endpoints

```hcl
resource "aws_lambda_function" "inference" {
  function_name = "ml-inference"

  lifecycle {
    create_before_destroy = true
    ignore_changes      = [tags["DeploymentId"]]
  }
}
```

### 3. Training Infrastructure

```hcl
resource "aws_autoscaling_group" "training_cluster" {
  # ... configuration ...

  lifecycle {
    create_before_destroy = true
    ignore_changes      = [desired_capacity, min_size, max_size]
  }
}
```

## Lifecycle Rule Decision Tree

```
                              +-------------------+
                              | Need to update     |
                              | a resource?        |
                              +-------------------+
                                         |
                    +------------------------+
                    |
           +--------v--------+
           | Does resource have |
           | dependencies?     |
           +--------+--------+
                    |
           +--------v--------+
           | YES              | NO
           |                  |
   +-------v-------+    +------v------+
   | create_before |    | Standard     |
   | _destroy      |    | update flow |
   +---------------+    +--------------+
   |
   +--v---+
   | Is it   | NO  +------v------+
   | critical?  |    | Replace when |
   |           +--->| dependency   |
   +-v--+           | changes?      |
   |YES|           +---------------+
   +---+                    |
   | use                +--v---+
   | prevent_destroy     | YES  |
   +---------------------+      |
                              | use
                              | replace_triggered_by
```

## Outputs

```bash
# View all lifecycle rules
terraform output lifecycle_summary

# Check if production storage is protected
terraform output production_models_protection

# View ignored changes
terraform output artifacts_ignore_changes
```

## Cleanup

```bash
# Destroy unprotected resources only
terraform destroy

# Note: production_models bucket won't be destroyed
# unless prevent_destroy is removed from code
```

## Next Steps

- Explore [Modules Example](../modules/) - Reusable components
- Explore [Conditionals Example](../conditionals/) - Environment logic
- Explore [Remote State Example](../remote-state/) - S3 backend
