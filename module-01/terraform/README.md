# Terraform for MLOps

**Infrastructure as Code for Machine Learning Operations**

This module introduces Terraform for provisioning and managing cloud infrastructure for MLOps workloads. You'll learn from basic concepts to advanced patterns for building scalable ML infrastructure.

---

## Overview

Terraform is an Infrastructure as Code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language. For MLOps, Terraform enables you to:

- **Reproducibly** provision ML training environments
- **Version control** your infrastructure alongside your code
- **Automate** infrastructure deployment in CI/CD pipelines
- **Manage** multi-environment deployments (dev, staging, prod)

---

## Module Structure

```
terraform/
├── basics/           # Beginner-friendly starting point
│   ├── main.tf       # Main resource configuration
│   ├── providers.tf  # Terraform and provider blocks
│   ├── variables.tf  # Input variables
│   ├── outputs.tf    # Output values
│   └── README.md     # Learning guide
│
├── examples/         # Advanced examples by topic
│   ├── data-sources/     # Query existing AWS resources
│   ├── for-each/         # Multiple resource creation
│   ├── locals/           # Reusable local values
│   ├── outputs/          # Output formatting
│   ├── remote-state/     # S3 backend configuration
│   ├── modules/          # Reusable components
│   ├── conditionals/     # Environment-specific logic
│   ├── lifecycle/        # Safe resource updates
│   └── README.md
│
└── exercises/        # Practice exercises
    └── exercises.md
```

---

## Prerequisites

### Required Tools

| Tool | Version | Description |
|------|---------|-------------|
| [Terraform](https://developer.hashicorp.com/terraform/downloads) | 1.14+ | Infrastructure provisioning |
| [AWS CLI](https://aws.amazon.com/cli/) | 2.x+ | AWS command-line interface |
| [Git](https://git-scm.com/) | Any | Version control |

### AWS Account Setup

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Verify credentials:
   ```bash
   aws sts get-caller-identity
   ```

3. (Optional) For local development, set up [LocalStack](../aws/localstack/)

---

## Learning Path

### Step 1: Start with Basics

**Beginner** | 30-45 minutes

Begin with the [`basics/`](./basics/) directory to learn fundamental Terraform concepts:

- Terraform block and provider configuration
- Variables and outputs
- Basic resource creation
- State management (local)
- Core Terraform workflow: init → plan → apply → destroy

```bash
cd module-01/terraform/basics
terraform init
terraform plan
terraform apply
```

### Step 2: Explore Examples

**Beginner to Intermediate** | 2-4 hours

After completing basics, explore individual examples based on what you want to learn:

| Example | Topic | Difficulty |
|---------|-------|------------|
| [data-sources](./examples/data-sources/) | Query existing AWS resources | Beginner |
| [outputs](./examples/outputs/) | Format and display outputs | Beginner |
| [locals](./examples/locals/) | Reusable values within modules | Intermediate |
| [for-each](./examples/for-each/) | Create multiple resources | Intermediate |
| [modules](./examples/modules/) | Reusable infrastructure components | Intermediate |
| [conditionals](./examples/conditionals/) | Environment-specific logic | Intermediate |
| [lifecycle](./examples/lifecycle/) | Safe resource updates | Intermediate |
| [remote-state](./examples/remote-state/) | S3 backend for teams | Intermediate |

**Recommended order:** data-sources → outputs → locals → for-each → modules → conditionals → lifecycle → remote-state

### Step 3: Practice with Exercises

**Intermediate** | 2-3 hours

Complete hands-on exercises in [`exercises/`](./exercises/exercises.md) to reinforce your learning:

1. Your First S3 Bucket
2. Multiple Environments with for_each
3. Query Existing Infrastructure
4. Creating Reusable Modules
5. ML Infrastructure Stack
6. Modern Terraform Features
7. Terraform Testing

---

## Quick Reference

### Basic Commands

```bash
# Initialize working directory
terraform init

# Check configuration validity
terraform validate

# Format configuration files
terraform fmt

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Show current state
terraform show

# Import existing resources
terraform import <resource> <resource-id>
```

### Common Patterns

#### Pattern 1: Local Values for Naming

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "example" {
  bucket_prefix = "${local.name_prefix}-ml-models-"
  tags          = local.common_tags
}
```

#### Pattern 2: Data Sources for Existing Resources

```hcl
data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
```

#### Pattern 3: Conditional Resource Creation

```hcl
resource "aws_s3_bucket_versioning" "example" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

#### Pattern 4: Module Usage

```hcl
module "ml_storage" {
  source        = "./modules/ml-storage"
  project_name  = var.project_name
  environment   = var.environment
  versioning_enabled = true
}
```

---

## MLOps-Specific Use Cases

### 1. ML Model Storage

Store trained models with versioning and lifecycle rules:

```hcl
resource "aws_s3_bucket" "models" {
  bucket_prefix = "${local.name_prefix}-ml-models-"
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### 2. Training Data with Tiering

Optimize costs with intelligent storage tiering:

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.training_data.id

  rule {
    id     = "archive-old-data"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
```

### 3. Multi-Environment Deployments

Use workspaces or variable files for environments:

```bash
# Development
terraform apply -var-file="dev.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

### 4. Safe ML Deployments

Use lifecycle rules for zero-downtime updates:

```hcl
resource "aws_lambda_function" "inference" {
  function_name = "ml-inference"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [tags["LastModified"]]
  }
}
```

---

## Best Practices

### 1. State Management

- **Local development:** Use local state (default)
- **Team collaboration:** Use S3 backend with locking
- **Production:** Enable state encryption and versioning

### 2. Module Structure

```
modules/
└── ml-component/
    ├── main.tf       # Resources
    ├── variables.tf  # Inputs
    ├── outputs.tf    # Outputs
    └── README.md     # Documentation
```

### 3. Variable Naming

- Use `snake_case` for all names
- Prefix lists/maps with their type: `var.bucket_map`
- Provide descriptions for all variables

### 4. Output Design

- Output important identifiers (IDs, ARNs, names)
- Group related outputs in nested maps
- Add descriptions for all outputs

### 5. Tagging Strategy

```hcl
locals {
  standard_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    CostCenter  = var.cost_center
  }
}
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `Backend configuration changed` | Run `terraform init -migrate-state` |
| `Resource already managed` | Use `terraform import` or remove from state |
| `Invalid for_each argument` | Ensure map keys are unique and known |
| `Provider not found` | Run `terraform init` |
| `Credentials error` | Verify AWS credentials with `aws sts get-caller-identity` |

### Getting Help

- Check the [examples README](./examples/README.md) for detailed guides
- Review [Terraform documentation](https://developer.hashicorp.com/terraform)
- Ask questions in team channels

---

## Additional Resources

### Official Documentation
- [Terraform Language](https://developer.hashicorp.com/terraform/language)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Community Resources
- [Terraform Module Registry](https://registry.terraform.io/)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)

---

## Next Steps in MLOps Training

After mastering Terraform basics:

1. **Module 2:** Docker containerization for ML models
2. **Module 3:** CI/CD pipelines for ML deployments
3. **Module 4:** Kubernetes for ML workloads

---

**Ready to start?** Begin with [Terraform Basics](./basics/README.md)
