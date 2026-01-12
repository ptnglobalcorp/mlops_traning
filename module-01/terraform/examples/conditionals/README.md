# Conditionals Example

This example demonstrates **conditional patterns** in Terraform for environment-specific ML infrastructure.

## What You'll Learn

- Ternary operators for value selection
- Conditional resource creation with `count`
- Filtering with `for_each` and conditionals
- Dynamic blocks with conditional logic
- Variable validation with conditionals

## Quick Start

```bash
# Navigate to this directory
cd module-01/terraform/examples/conditionals

# Try different environments
terraform plan -var="environment=dev"
terraform plan -var="environment=prod"

# Apply with specific environment
terraform apply -var="environment=dev"
```

## Conditional Patterns

### 1. Ternary Operators

Select between two values based on a condition:

```hcl
locals {
  # Syntax: condition ? true_value : false_value
  instance_type = var.environment == "prod" ? "t3.xlarge" : "t3.medium"

  # Nested conditionals
  model_size_gb = var.model_type == "tensorflow" ? 500 : (
    var.model_type == "pytorch" ? 500 : 10
  )
}
```

### 2. Conditional Resource Creation

Use `count` with a boolean to create resources conditionally:

```hcl
resource "aws_s3_bucket_versioning" "models" {
  # count = 1 creates resource, count = 0 skips it
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

### 3. Conditional for_each

Filter maps to create only certain resources:

```hcl
locals {
  model_types = {
    sklearn = {
      size_gb = 10
      create  = true
    }
    tensorflow = {
      size_gb = 500
      create  = var.environment == "prod"  # Only in prod
    }
  }
}

resource "aws_s3_bucket" "model_type_buckets" {
  # Only create where create = true
  for_each = {
    for k, v in local.model_types : k => v
    if v.create == true
  }

  bucket_prefix = "${var.project_name}-models-${each.key}-"
}
```

### 4. Dynamic Blocks with Conditionals

Use `dynamic` blocks with conditional `for_each`:

```hcl
resource "aws_security_group" "ml_training" {
  name_prefix = "${var.project_name}-ml-training-"

  # Only add production rules in prod environment
  dynamic "ingress" {
    for_each = var.environment == "prod" ? [
      {
        port     = 22
        cidr     = var.vpn_cidr
      }
    ] : []

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      cidr_blocks = [ingress.value.cidr]
    }
  }
}
```

### 5. Conditional Based on Account

```hcl
locals {
  is_production_account = contains(
    var.production_account_ids,
    data.aws_caller_identity.current.account_id
  )

  compliance_level = local.is_production_account ? "strict" : "standard"
}

resource "aws_s3_bucket" "critical" {
  count = local.is_production_account ? 0 : 1  # Skip in prod

  lifecycle {
    prevent_destroy = local.is_production_account
  }
}
```

## Environment-Specific Behavior

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| **Instance Type** | t3.medium | t3.medium | t3.xlarge |
| **Model Size** | 10 GB | 10 GB | 500 GB |
| **Versioning** | Enabled | Enabled | Enabled |
| **Lifecycle Rules** | Disabled | Disabled | Enabled |
| **SSH Access** | None | None | VPN only |
| **Compliance** | Standard | Standard | Strict |

## Testing Different Scenarios

### Development Environment

```bash
# Default configuration
terraform apply

# Or explicitly
terraform apply -var="environment=dev"
```

Creates:
- Small instance type
- Basic model storage
- No lifecycle rules
- Open HTTPS access

### Production Environment

```bash
terraform apply -var="environment=prod" \
  -var="production_account_ids=[123456789012]"
```

Creates:
- Large instance type
- Lifecycle rules for old model versions
- VPN-only SSH access
- VPC-restricted HTTPS
- Strict compliance settings

### With OIDC Authentication

```bash
terraform apply \
  -var="enable_oidc=true" \
  -var="oidc_provider_id=A3DSAEXAMPLE"
```

Creates IAM role that can be assumed by EKS via OIDC.

### With Email Notifications

```bash
terraform apply \
  -var="notification_email=team@example.com"
```

Creates SNS topic with email subscription.

## Conditional Expression Reference

| Pattern | Syntax | Example |
|---------|--------|---------|
| **Ternary** | `condition ? true_val : false_val` | `var.env == "prod" ? "large" : "small"` |
| **Boolean** | `condition ? 1 : 0` | `var.enabled ? 1 : 0` |
| **String check** | `var.str != "" ? ... : null` | `var.email != "" ? [var.email] : []` |
| **Contains** | `contains(list, value)` | `contains(["prod"], var.env)` |
| **Coalesce** | `coalesce(val1, val2)` | `coalesce(var.custom, "default")` |

## Common Conditional Patterns for MLOps

### Pattern 1: Environment-Specific Instance Types

```hcl
locals {
  instance_types = {
    dev     = "t3.medium"
    staging = "t3.large"
    prod    = "t3.xlarge"
  }

  instance_type = lookup(
    local.instance_types,
    var.environment,
    "t3.medium"  # default
  )
}
```

### Pattern 2: Conditional Resource Features

```hcl
resource "aws_s3_bucket" "models" {
  bucket = "${var.project_name}-models"

  # Conditional tags
  tags = merge(
    {"Project" = var.project_name},
    var.environment == "prod" ? {"Compliance" = "high"} : {}
  )
}
```

### Pattern 3: Conditional Module Usage

```hcl
module "monitoring" {
  # Only in production
  count = var.environment == "prod" ? 1 : 0
  source = "./modules/monitoring"
}
```

### Pattern 4: Multi-Value Conditionals

```hcl
locals {
  config = {
    dev = {
      instances = 1
      size      = "small"
    }
    prod = {
      instances = 3
      size      = "large"
    }
  }

  # Select config based on environment
  current = local.config[var.environment]
}
```

## Outputs

```bash
# View conditional outputs
terraform output environment_config

# View which resources were created
terraform state list

# See if versioning was enabled
terraform output models_bucket
```

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Destroy with specific environment
terraform destroy -var="environment=prod"
```

## Next Steps

- Explore [Lifecycle Example](../lifecycle/) - Safe resource updates
- Explore [Modules Example](../modules/) - Reusable components
- Explore [Outputs Example](../outputs/) - Advanced formatting
