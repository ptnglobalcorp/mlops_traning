# Modules Example

This example demonstrates **Terraform modules** for creating reusable ML infrastructure components.

## What You'll Learn

- How to organize code into reusable modules
- Module inputs (variables) and outputs
- How to use modules in root configuration
- Module composition patterns for ML workloads

## What are Modules?

A module is a container for multiple resources that are used together. Modules help you:

- **Organize** - Group related resources together
- **Reuse** - Use the same code across environments
- **Abstract** - Hide complexity behind simple interfaces
- **Consistency** - Enforce standards across teams

## Quick Start

```bash
# Navigate to this directory
cd module-01/terraform/examples/modules

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply
```

## Directory Structure

```
modules/
├── main.tf                      # Root configuration
├── variables.tf                 # Root variables
├── outputs.tf                   # Root outputs
└── modules/                     # Child modules
    ├── ml-model-storage/        # Module for ML model storage
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ml-training-data/        # Module for training data
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ml-artifacts/            # Module for artifacts
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Module Usage Pattern

### 1. Define the Module

```hcl
# modules/ml-model-storage/main.tf
resource "aws_s3_bucket" "models" {
  bucket_prefix = "${var.project_name}-${var.environment}-${var.bucket_prefix}-"

  tags = {
    Purpose = "ml-model-storage"
  }
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

### 2. Define Module Inputs and Outputs

```hcl
# modules/ml-model-storage/variables.tf
variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

# modules/ml-model-storage/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.models.id
}

output "bucket_arn" {
  value = aws_s3_bucket.models.arn
}
```

### 3. Use the Module

```hcl
# main.tf (root configuration)
module "ml_models_storage" {
  source = "./modules/ml-model-storage"

  project_name = var.project_name
  environment  = var.environment
  bucket_prefix = "ml-models"
}

# Access module outputs
output "models_bucket" {
  value = module.ml_models_storage.bucket_name
}
```

## Module Examples

### 1. ML Model Storage Module

Creates a complete S3 bucket setup for ML models:

```hcl
module "ml_models_storage" {
  source = "./modules/ml-model-storage"

  project_name     = "mlops-training"
  environment      = "dev"
  bucket_prefix    = "ml-models"

  enable_versioning              = true
  enable_lifecycle_rules         = true
  noncurrent_version_transition_days = 30
  noncurrent_version_expiration_days = 365
  encryption_type                = "AES256"
}
```

### 2. ML Training Data Module

Creates storage for training datasets with intelligent tiering:

```hcl
module "ml_training_data" {
  source = "./modules/ml-training-data"

  project_name              = "mlops-training"
  environment               = "dev"
  bucket_prefix             = "training-data"

  enable_versioning         = true
  data_retention_days       = 90
  enable_intelligent_tiering = true
}
```

### 3. ML Artifacts Module

Creates storage for pipeline artifacts with short retention:

```hcl
module "ml_artifacts" {
  source = "./modules/ml-artifacts"

  project_name          = "mlops-training"
  environment           = "dev"
  bucket_prefix         = "ml-artifacts"

  artifact_retention_days = 30
}
```

## Module Best Practices

### 1. Module Naming

- Use descriptive names that reflect the module's purpose
- Use hyphens for multi-word names: `ml-model-storage`
- Avoid generic names like `common` or `utils`

### 2. Module Inputs

- Required parameters first, optional parameters last
- Use `description` for all variables
- Provide sensible `default` values
- Use `validation` blocks for constraints

```hcl
variable "project_name" {
  type        = string
  description = "Project name for resource naming"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable S3 versioning"
  default     = true
}
```

### 3. Module Outputs

- Output useful information for consumers
- Use `description` for all outputs
- Export computed values, not input variables

```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.models.id
}
```

### 4. Module Documentation

- Always include a README in each module
- Document required providers and Terraform version
- Provide usage examples
- List all inputs and outputs

## Module Sources

Modules can be sourced from:

| Source | Syntax | Use Case |
|--------|--------|----------|
| **Local** | `"./modules/name"` | Local development |
| **Git** | `"github.com/user/repo//path"` | Public repositories |
| **Registry** | `"terraform-aws-modules/s3-bucket/aws"` | Terraform Registry |

## Module Composition

Modules can call other modules, enabling powerful composition:

```hcl
module "ml_platform" {
  source = "./modules/ml-platform"

  project_name = "mlops-training"
  environment  = "prod"
}

# The ml_platform module internally uses:
# - ml-model-storage module
# - ml-training-data module
# - ml-artifacts module
```

## Accessing Module Outputs

```bash
# View all outputs
terraform output

# View specific module output
terraform output module.ml_models_storage.bucket_name

# Or via Terraform syntax
output "models_bucket" {
  value = module.ml_models_storage.bucket_name
}
```

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

## Next Steps

- Explore [Conditionals Example](../conditionals/) - Environment-specific configurations
- Explore [Lifecycle Example](../lifecycle/) - Safe resource updates
- Explore [Outputs Example](../outputs/) - Advanced output formatting
