# Terraform Basics for MLOps

**From Beginner to Intermediate: Infrastructure as Code with Terraform**

This guide covers Terraform fundamentals through intermediate concepts, specifically tailored for MLOps workflows on AWS. You'll learn to provision and manage infrastructure for machine learning pipelines, model storage, and deployment environments.

---

## Learning Objectives

By the end of this module, you will be able to:

- Understand Terraform's declarative configuration language (HCL)
- Master the core Terraform workflow: `init` → `plan` → `apply` → `destroy`
- Provision AWS resources for ML workloads (S3, EC2, Lambda, IAM)
- Use variables, outputs, and locals for reusable configurations
- Implement data sources to query existing infrastructure
- Understand state management and remote backends
- Create and use Terraform modules for reusability
- Apply modern Terraform features (checks, imports, testing)

**Practice Resources**:
- Run examples from the `examples/` directory (data-sources, for-each, locals, outputs)
- Complete 7 progressive exercises in `exercises/exercises.md`
- Use the provided configuration files (`main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`) as templates

---

## Table of Contents

1. [What is Terraform?](#what-is-terraform)
2. [Terraform Architecture](#terraform-architecture)
3. [Core Concepts](#core-concepts)
4. [The Terraform Workflow](#the-terraform-workflow)
5. [Basic Configuration](#basic-configuration)
6. [Variables and Outputs](#variables-and-outputs)
7. [Data Sources](#data-sources)
8. [Resource Dependencies](#resource-dependencies)
9. [Provisioners (When to Avoid)](#provisioners-when-to-avoid)
10. [State Management](#state-management)
11. [Modules](#modules)
12. [Modern Terraform Features](#modern-terraform-features)
13. [Best Practices for MLOps](#best-practices-for-mlops)
14. [Hands-On Examples](#hands-on-examples)
15. [Practice Exercises](#practice-exercises)
16. [Additional Resources](#additional-resources)

---

## What is Terraform?

**Terraform** is an Infrastructure as Code (IaC) tool by HashiCorp that lets you define, provision, and manage infrastructure across multiple cloud providers (AWS, Azure, GCP, etc.) using a declarative configuration language called **HCL** (HashiCorp Configuration Language).

### Key Benefits for MLOps

| Benefit | MLOps Use Case |
|---------|----------------|
| **Reproducibility** | Recreate identical ML environments across dev/staging/prod |
| **Version Control** | Track infrastructure changes alongside ML code |
| **Automation** | Provision training pipelines, model registries, endpoints automatically |
| **Multi-Cloud** | Deploy ML models across AWS, Azure, GCP from one configuration |
| **Drift Detection** | Ensure actual infrastructure matches declared state |

### Declarative vs Imperative

```hcl
# Declarative (Terraform) - "What" you want
resource "aws_s3_bucket" "models" {
  bucket = "ml-models-bucket"
  versioning {
    status = "Enabled"
  }
}

# Terraform figures out "How" to create it
```

---

## Terraform Architecture

```
+-------------------------------------------------------------------------+
|                         Terraform Architecture                          |
+-------------------------------------------------------------------------+
|                                                                         |
|  +-------------+     +-------------+     +-----------------------+     |
|  |  HCL Files  |---->| Terraform   |---->|  State File           |     |
|  |  *.tf       |     | CLI/Core    |     |  (.tfstate)           |     |
|  +-------------+     +-------------+     +-----------------------+     |
|         |                    |                     |                   |
|         |                    |                     |                   |
|         v                    v                     v                   |
|  +-------------+     +-------------+     +-----------------------+     |
|  |  Providers  |     |    Plan     |     |  Remote Backend       |     |
|  |  (AWS, AZ,  |     |  (Diff)     |     |  (S3 with Locking)    |     |
|  |   GCP...)   |     |             |     |                       |     |
|  +-------------+     +-------------+     +-----------------------+     |
|         |                    |                                     |
|         +--------------------+-------------------------------------+     |
|                              v                                     |
|                    +-----------------------+                        |
|                    |   Cloud APIs          |                        |
|                    |   (Create/Update/     |                        |
|                    |    Delete)            |                        |
|                    +-----------------------+                        |
|                                                                      |
+----------------------------------------------------------------------+
```

---

## Core Concepts

### 1. Providers

Plugins that interact with cloud APIs. Each cloud (AWS, Azure, GCP) has its own provider.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"  # AWS Provider (latest as of 2026)
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

### 2. Resources

The most important element. Represents a single infrastructure component (VM, bucket, database).

```hcl
resource "aws_s3_bucket" "models" {
  bucket = "my-ml-models"
}
```

**Naming convention:** `resource "<provider>_<resource_type>" "<local_name>"`

### 3. Data Sources

Read-only references to existing infrastructure. Useful for querying data created outside Terraform.

```hcl
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
```

### 4. Variables

Input parameters for your configuration. Enable reusability.

### 5. Outputs

Values exposed after `apply`. Useful for sharing data between modules or showing important info.

### 6. State

Terraform's mapping of real-world resources to your configuration. Stored in `.tfstate` file.

---

## The Terraform Workflow

```
+-----------------------------------------------------------------------+
|                      Terraform Workflow                               |
+-----------------------------------------------------------------------+
|                                                                       |
|  +----------+    +----------+    +----------+    +----------+         |
|  |  Write   | -> |   Init   | -> |   Plan   | -> |  Apply   |         |
|  |  *.tf    |    |          |    |          |    |          |         |
|  +----------+    +----------+    +----------+    +----------+         |
|                                                        |             |
|                                                 +------+            |
|                                                 | Destroy          |
|                                                 +-------------------+     |
|                                                                      |
+----------------------------------------------------------------------+
```

### Step-by-Step

| Command | Description |
|---------|-------------|
| `terraform init` | Download providers, initialize backend, set up state |
| `terraform plan` | Preview changes (diff between config and state) |
| `terraform apply` | Execute changes to create/update infrastructure |
| `terraform destroy` | Remove all managed resources |
| `terraform fmt` | Format HCL files consistently |
| `terraform validate` | Check syntax and configuration validity |
| `terraform show` | Display current state or plan output |

---

## Basic Configuration

### File Structure

```
terraform/
├── main.tf              # Primary configuration
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values (gitignored)
├── provider.tf          # Provider configuration (optional)
└── .terraform/          # Created by init (providers, cache)
```

### main.tf - Core Configuration

```hcl
terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Remote state backend (recommended for teams)
  # Uses S3 with native locking - no DynamoDB table required
  backend "s3" {
    bucket         = "terraform-state-123456789012"
    key            = "mlops-training/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "mlops-training"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

# S3 Bucket for ML Model Storage
resource "aws_s3_bucket" "models" {
  bucket_prefix = "ml-models-"

  tags = {
    Purpose = "model-storage"
  }
}

# Enable versioning for model lineage
resource "aws_s3_bucket_versioning" "models_versioning" {
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "models_encryption" {
  bucket = aws_s3_bucket.models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

---

## Variables and Outputs

### Defining Variables (variables.tf)

```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^us-", var.aws_region))
    error_message = "Region must start with 'us-'."
  }
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "model_types" {
  description = "Supported model types"
  type        = list(string)
  default     = ["sklearn", "tensorflow", "pytorch", "xgboost"]
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = map(string)
  default = {
    "dev"     = "cc-100"
    "staging" = "cc-200"
    "prod"    = "cc-300"
  }
}
```

### Using Variables (terraform.tfvars)

```hcl
aws_region  = "us-east-1"
environment = "dev"

# Override defaults in your terraform.tfvars file
```

### Outputs (outputs.tf)

```hcl
output "models_bucket_name" {
  description = "Name of the ML models S3 bucket"
  value       = aws_s3_bucket.models.id
}

output "models_bucket_arn" {
  description = "ARN of the ML models S3 bucket"
  value       = aws_s3_bucket.models.arn
}

output "models_bucket_endpoint" {
  description = "S3 bucket endpoint for model access"
  value       = "${aws_s3_bucket.models.id}.s3-website-${var.aws_region}.amazonaws.com"
}
```

### Local Values

Similar to variables, but only used within a module. Great for DRY (Don't Repeat Yourself) code.

```hcl
locals {
  project_name     = "mlops-training"
  common_tags = {
    Project     = local.project_name
    ManagedBy   = "terraform"
    Environment = var.environment
  }
  model_bucket_name = "${local.project_name}-models-${var.environment}"
}

resource "aws_s3_bucket" "models" {
  bucket = local.model_bucket_name
  tags   = local.common_tags
}
```

---

## Data Sources

Data sources let you query existing infrastructure. Essential for hybrid setups.

```hcl
# Get current AWS account info
data "aws_caller_identity" "current" {}

# Get current region
data "aws_region" "current" {}

# Get existing VPC
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}

# Get existing subnet
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  tags = {
    Tier = "private"
  }
}

# Get latest Amazon Linux AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2024.*-x86_64"]
  }
}

# Use data source in resource
resource "aws_instance" "ml_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.medium"
  subnet_id     = data.aws_subnets.private.ids[0]

  tags = {
    Name = "ml-training-server"
  }
}
```

---

## Resource Dependencies

### Implicit Dependencies

Terraform automatically detects dependencies through references.

```hcl
resource "aws_s3_bucket" "data" {
  bucket = "ml-data-bucket"
}

resource "aws_s3_bucket_versioning" "data_versioning" {
  bucket = aws_s3_bucket.data.id  # Implicit dependency
  # Terraform creates the bucket first
}
```

### Explicit Dependencies

Use `depends_on` when dependency isn't visible from references.

```hcl
resource "aws_iam_role_policy" "s3_access" {
  name = "s3_access_policy"
  role = aws_iam_role.ml_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_instance" "ml_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.medium"

  # Explicitly wait for IAM policy to be attached
  depends_on = [aws_iam_role_policy.s3_access]
}
```

### `for_each` and `count`

#### Using `count` for Simple Lists

```hcl
resource "aws_s3_bucket" "data_buckets" {
  count  = length(var.model_types)
  bucket = "${var.project_name}-${var.model_types[count.index]}-data"

  tags = {
    ModelType = var.model_types[count.index]
  }
}

# With var.model_types = ["sklearn", "tensorflow"]
# Creates buckets:
# - mlops-training-sklearn-data
# - mlops-training-tensorflow-data
```

#### Using `for_each` for Maps and Sets

```hcl
resource "aws_s3_bucket" "env_buckets" {
  for_each = tomap({
    dev     = "ml-dev-data"
    staging = "ml-staging-data"
    prod    = "ml-prod-data"
  })

  bucket = each.value

  tags = {
    Environment = each.key
  }
}

# Access created resources:
# aws_s3_bucket.env_buckets["dev"]
# aws_s3_bucket.env_buckets["staging"]
# aws_s3_bucket.env_buckets["prod"]
```

---

## Provisioners (When to Avoid)

Provisioners execute actions on the local machine or remote resource. **Use sparingly**.

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  # File provisioner - copy file to instance
  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

  # Remote-exec provisioner - run commands on instance
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }

    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh",
    ]
  }

  # Local-exec provisioner - run commands locally
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> inventory.ini"
  }
}
```

### Better Alternatives to Provisioners

| Instead of Provisioners | Use |
|------------------------|-----|
| remote-exec scripts | User data scripts, cloud-init |
| local-exec scripts | CI/CD pipelines, separate scripts |
| File copying | S3, CodeDeploy, container images |

---

## State Management

### Local vs Remote State

```
+-------------------------------------------------------------------------+
|                    State Management Options                              |
+-------------------------------------------------------------------------+
|                                                                         |
|  +-----------------------+     +-----------------------------------+    |
|  |    Local State        |     |      Remote State                 |    |
|  |  (Default, Solo)      |     |   (Recommended, Teams)            |    |
|  +-----------------------+     +-----------------------------------+    |
|  | ✓ Quick start         |     | ✓ Team collaboration              |    |
|  | ✓ No setup            |     | ✓ Secure storage                  |    |
|  | ✗ No collaboration    |     | ✓ State locking                   |    |
|  | ✗ Security risk       |     | ✓ Version history                 |    |
|  | ✗ Single machine      |     | ✓ CI/CD friendly                  |    |
|  +-----------------------+     +-----------------------------------+    |
|                                                                         |
+-------------------------------------------------------------------------+
```

### Configuring Remote State (S3 with Native Locking)

Terraform's S3 backend now supports state locking using S3's built-in capabilities. No DynamoDB table required.

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-123456789012"  # Your unique bucket
    key            = "mlops-training/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true                            # Enable server-side encryption

    # S3-native locking (using object lock or versioning)
    # No DynamoDB table needed for basic state management
  }
}
```

**Note:** For team collaboration with concurrent runs, you can enable S3 Object Lock for stronger consistency guarantees. For most use cases, S3 versioning combined with Terraform's built-in state file management provides sufficient protection.

### Bootstrap Script for State Backend

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket terraform-state-123456789012 \
  --region us-east-1

# Enable versioning (provides state history and recovery)
aws s3api put-bucket-versioning \
  --bucket terraform-state-123456789012 \
  --versioning-configuration Status=Enabled

# Enable default encryption
aws s3api put-bucket-encryption \
  --bucket terraform-state-123456789012 \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Optional: Enable S3 Object Lock for enhanced locking
# This provides stronger guarantees for team collaboration
aws s3api put-object-lock-configuration \
  --bucket terraform-state-123456789012 \
  --object-lock-configuration '{
    "ObjectLockEnabled": "Enabled"
  }'

# Block public access for security
aws s3api put-public-access-block \
  --bucket terraform-state-123456789012 \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'
```

### State Commands

```bash
# View current state
terraform show

# Refresh state (query actual infrastructure)
terraform refresh

# List resources in state
terraform state list

# Show specific resource details
terraform state show aws_s3_bucket.models

# Move resource in state
terraform state mv aws_s3_bucket.old aws_s3_bucket.new

# Remove resource from state (keeps resource)
terraform state rm aws_instance.old_server

# Import existing resource
terraform import aws_s3_bucket.existing bucket-name

# Taint resource (force replace on next apply)
terraform taint aws_s3_bucket.models

# Untaint resource
terraform untaint aws_s3_bucket.models
```

---

## Modules

Modules are reusable Terraform configurations. Think of them as functions in programming.

### Module Structure

```
modules/
└── s3-model-storage/
    ├── main.tf              # Module resources
    ├── variables.tf         # Module inputs
    ├── outputs.tf           # Module outputs
    └── README.md            # Module documentation
```

### Creating a Module

**modules/s3-model-storage/main.tf**
```hcl
resource "aws_s3_bucket" "models" {
  bucket_prefix = "${var.project_name}-${var.environment}-models-"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "models" {
  bucket = aws_s3_bucket.models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "models" {
  bucket = aws_s3_bucket.models.id

  rule {
    id     = "delete-old-versions"
    status = var.enable_lifecycle ? "Enabled" : "Disabled"

    noncurrent_version_expiration {
      noncurrent_days = var.retention_days
    }
  }
}
```

**modules/s3-model-storage/variables.tf**
```hcl
variable "project_name" {
  description = "Project name for bucket naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Must be AES256 or aws:kms."
  }
}

variable "enable_lifecycle" {
  description = "Enable lifecycle policy"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Days to retain non-current versions"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
```

**modules/s3-model-storage/outputs.tf**
```hcl
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.models.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.models.arn
}
```

### Using a Module

**main.tf**
```hcl
module "dev_models" {
  source = "./modules/s3-model-storage"

  project_name = "mlops-training"
  environment  = "dev"

  tags = {
    Owner       = "ml-team"
    CostCenter  = "cc-100"
    Compliance  = "hipaa"
  }
}

module "prod_models" {
  source = "./modules/s3-model-storage"

  project_name       = "mlops-training"
  environment        = "prod"
  retention_days     = 365
  encryption_algorithm = "aws:kms"

  tags = {
    Owner       = "ml-team"
    CostCenter  = "cc-300"
    Compliance  = "hipaa"
  }
}
```

### Module Sources

```hcl
# Local module
module "example" {
  source = "./modules/example"
}

# Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = "ml-vpc"
  cidr = "10.0.0.0/16"
}

# GitHub
module "example" {
  source = "github.com/org/repo//modules/example"
}

# S3 (private)
module "example" {
  source = "s3::https://s3.amazonaws.com/bucket/path/to/module.zip"
}
```

---

## Modern Terraform Features

### 1. Import Blocks (Terraform 1.5+)

Import existing resources without CLI commands.

```hcl
import {
  to = aws_s3_bucket.existing_bucket
  id = "my-existing-bucket-name"
}

resource "aws_s3_bucket" "existing_bucket" {
  # Configuration will be filled from existing resource
  bucket = "my-existing-bucket-name"
}
```

After running `terraform plan`, Terraform generates the configuration.

### 2. Check Blocks (Terraform 1.5+)

Validate invariants in your infrastructure.

```hcl
check "health_check" {
  data "http" "api_endpoint" {
    url = "https://${aws_lb.api.dns_name}/health"
  }

  assert {
    condition     = data.http.api_endpoint.status_code == 200
    error_message = "API health check failed for ${aws_lb.api.dns_name}"
  }
}
```

### 3. Removed Blocks (Terraform 1.7+)

Safely remove resources from state.

```hcl
removed {
  from = aws_s3_bucket.old_deprecated_bucket

  # Provide lifecycle guidance
  lifecycle {
    create = false
  }
}
```

### 4. Testing (Terraform 1.6+)

Write tests for your modules.

**tests/main.tftest.hcl**
```hcl
terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "main" {
  source = "../.."
}

run "test_bucket_creation" {
  assert {
    condition     = can(regex("^ml-models-", module.main.bucket_name))
    error_message = "Bucket name must start with ml-models-"
  }
}

run "test_versioning_enabled" {
  command = plan

  assert {
    condition     = module.main.versioning_enabled == true
    error_message = "Versioning must be enabled for ML models"
  }
}
```

Run tests: `terraform test`

### 5. Variable Validation

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"

  validation {
    condition     = can(regex("^t[23]\\.(micro|small|medium|large|xlarge|2xlarge)$", var.instance_type))
    error_message = "Instance type must be a valid t2 or t3 size."
  }

  validation {
    condition     = var.instance_type != "t2.micro"
    error_message = "t2.micro is too small for ML workloads."
  }
}
```

### 6. Preconditions and Postconditions

```hcl
resource "aws_s3_bucket" "important_data" {
  bucket = "important-ml-data"

  # Precondition: Check before creating
  precondition {
    condition     = var.environment != "prod" || var.encrypted == true
    error_message = "Production buckets must be encrypted."
  }

  # Postcondition: Verify after creation
  postcondition {
    condition     = self.versioning[0].status == "Enabled"
    error_message = "Versioning must be enabled."
  }
}
```

### 7. Simplified Provider Configuration

```hcl
# Old way
provider "aws" {
  region = "us-east-1"
}

module "example" {
  source   = "./module"
  providers = {
    aws = aws
  }
}

# New way (implicit provider passing)
provider "aws" {
  region = "us-east-1"
}

module "example" {
  source = "./module"
  # Providers inherited automatically
}
```

---

## Best Practices for MLOps

Based on industry standards from [terraform-best-practices.com](https://www.terraform-best-practices.com/) and [AWS Terraform Provider Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html).

### 1. Standard Repository Structure

Follow this consistent structure across all Terraform projects:

```
.
├── main.tf              # Primary entry point, module calls, locals
├── variables.tf         # Variable declarations
├── outputs.tf           # Output values
├── locals.tf            # Local values for reusable expressions
├── data.tf              # Data sources (if numerous)
├── providers.tf         # Provider configurations (root modules only)
├── versions.tf          # Terraform and provider version requirements
├── terraform.tfvars     # Variable values for root modules (gitignored)
├── README.md            # Module documentation
├── examples/            # Example usage (for reusable modules)
├── modules/             # Nested modules (if applicable)
├── scripts/             # Custom scripts called by Terraform
├── templates/           # Template files (.tftpl extension)
└── files/               # Static files referenced by Terraform
```

**Key Principles:**
- **Avoid service-named files** (e.g., `s3.tf`, `ec2.tf`) - keep resources in `main.tf`
- Only create service-specific files when resources exceed 150 lines
- Place data sources near resources that use them, not in separate files

### 2. Naming Conventions

Follow consistent naming patterns:

```hcl
# Resource naming - use snake_case
resource "aws_s3_bucket" "models" {
  bucket = "${local.project_name}-models"
}

# Use "main" or "this" for single resources of their type
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

# Variables - add units for numeric values
variable "instance_count" {}
variable "volume_size_gb" {}
variable "timeout_seconds" {}

# Boolean variables - use positive names
variable "enable_monitoring" {}
variable "use_kms_encryption" {}
variable "allow_public_access" {}

# Local values - descriptive and reusable
locals {
  project_name = "${var.project_name}-${var.environment}"
}
```

**Rules:**
- Use `snake_case` for all resource names
- Use singular, not plural names
- Don't repeat resource type in resource name
- Add units to numeric variables (e.g., `_gb`, `_mb`, `_seconds`)
- Use positive names for Boolean variables

### 3. Modularity Guidelines

**DO:**
- Create modules for logical resource groupings (networking, data tiers, applications)
- Keep module inheritance flat (max 1-2 levels deep)
- Include outputs that reference all resources in modules
- Declare required providers in `versions.tf`
- Use local paths for closely related modules

**DON'T:**
- Wrap single resources in modules (use the resource directly)
- Create deeply nested module structures
- Configure providers inside modules (only in root modules)
- Over-parameterize - only expose variables with concrete use cases

### 4. File Structure Best Practices

**Root Module vs Reusable Module:**

```hcl
# Root module structure (environments/)
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf          # Provider configs here
├── versions.tf
├── terraform.tfvars
└── envs/
    ├── dev/
    │   └── terraform.tfvars
    ├── staging/
    │   └── terraform.tfvars
    └── prod/
        └── terraform.tfvars

# Reusable module structure (modules/)
├── main.tf               # Module implementation
├── variables.tf          # Module inputs
├── outputs.tf            # Module outputs
├── versions.tf           # Required providers
├── README.md             # Module documentation
└── examples/
    ├── simple/
    │   ├── main.tf
    │   └── terraform.tfvars
    └── advanced/
        └── ...
```

### 5. Variable and Output Standards

```hcl
# All variables must have types and descriptions
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

# Optional variables - provide defaults
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

# Required variables - no default
variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# All outputs must have descriptions
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.models.id
}
```

**Best Practices:**
- Every variable/output requires a description
- Provide defaults for environment-independent values
- Omit defaults for environment-specific values
- Use validation blocks for constrained values
- Don't pass outputs directly through input variables

### 6. Use Attachment Resources

Avoid embedded resource attributes - use attachment resources instead:

```hcl
# AVOID: Embedded security group rules
resource "aws_security_group" "allow_tls" {
  name = "allow_tls"

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# PREFERRED: Attachment resources
resource "aws_security_group" "allow_tls" {
  name = "allow_tls"
}

resource "aws_security_group_rule" "allow_tls" {
  type              = "ingress"
  description       = "TLS from VPC"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.allow_tls.id
}
```

### 7. Comprehensive Tagging Strategy

Use `aws_default_tags` provider block for consistent tagging:

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      # Identification
      Name        = "${local.project_name}-${var.environment}"
      Project     = var.project_name
      Environment = var.environment

      # Operational
      ManagedBy   = "terraform"
      Owner       = var.owner_email
      CostCenter  = var.cost_center

      # ML Specific
      DataClassification = var.data_classification
      ModelType         = var.model_type
      ComplianceLevel   = var.compliance_level
    }
  }
}
```

### 8. State Isolation Strategy

| Approach | Use Case |
|----------|----------|
| **File Layout** | Different environments (dev/staging/prod) |
| **Workspaces** | Similar environments (dev-feature branches) |
| **Single State** | Non-production, small projects only |

**Recommended:** Use file layout with environment-specific directories:
```
terraform/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── modules/
```

### 9. Secrets Management

**NEVER store secrets in Terraform code or state!**

```hcl
# BAD - Never do this
variable "api_key" {
  default = "hardcoded-secret-key"
}

# GOOD - Mark sensitive
variable "api_key" {
  type      = string
  sensitive = true
}

# BEST - Use AWS Secrets Manager
data "aws_secretsmanager_secret" "api_key" {
  name = "${var.environment}/api/key"
}

data "aws_secretsmanager_secret_version" "api_key" {
  secret_id = data.aws_secretsmanager_secret.api_key.id
}

resource "aws_lambda_function" "app" {
  environment {
    variables = {
      API_KEY = data.aws_secretsmanager_secret_version.api_key.secret_string
    }
  }
}
```

### 10. CI/CD Integration with Terraform 1.14

**.github/workflows/terraform-apply.yml**
```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.14.0"
          terraform_wrapper: true

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: us-east-1
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        id: plan
        run: terraform plan -out=tfplan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
```

### 11. Pre-commit Hooks

Configure `.pre-commit-config.yaml` for automatic quality checks:

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.96.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
        args:
          - --args=--only=terraform_deprecated_interpolation
          - --args=--only=terraform_deprecated_index
      - id: terraform_checkov
        args:
          - --args=--framework=aws
          - --args=--skip-check=CKV_AWS_157
```

### 12. Coding Standards

**Run these commands before committing:**
```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Static analysis
tflint --init
tflint

# Security scanning
checkov -d .
```

**Use in CI/CD:**
- `terraform fmt -check` - Fail if formatting needed
- `terraform validate` - Catch syntax errors
- `tflint` - Catch best practice violations
- `checkov` - Security and compliance scanning

### 13. MLOps-Specific Best Practices

```hcl
# Model versioning with S3 versioning
resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policies for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "models" {
  bucket = aws_s3_bucket.models.id

  rule {
    id     = "model-version-lifecycle"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# Consistent naming for ML resources
locals {
  ml_naming = {
    models = "${var.project_name}-${var.environment}-ml-models"
    data   = "${var.project_name}-${var.environment}-ml-data"
    logs   = "${var.project_name}-${var.environment}-ml-logs"
  }
}

# Environment-specific configurations
locals {
  env_config = {
    dev = {
      instance_count = 1
      instance_type  = "t3.medium"
      log_retention  = 7
    }
    staging = {
      instance_count = 2
      instance_type  = "t3.large"
      log_retention  = 30
    }
    prod = {
      instance_count = 3
      instance_type  = "t3.xlarge"
      log_retention  = 365
    }
  }

  config = local.env_config[var.environment]
}
```

---

## Local Development with LocalStack

**LocalStack** is a fully functional local AWS cloud stack that enables you to develop and test your Terraform configurations locally without connecting to AWS. It's perfect for:

- Rapid development and testing
- Cost-free experimentation
- CI/CD pipeline testing
- Offline development

### Quick Start with LocalStack

**Method 1: Using the pre-configured LocalStack variable file (Recommended)**

```bash
# Navigate to the Terraform basics directory
cd module-01/terraform/basics

# Start LocalStack using Docker Compose (from module-01/aws/localstack)
docker-compose -f ../../aws/localstack/docker-compose.yml up -d

# Wait for LocalStack to be ready (usually 10-20 seconds)
docker-compose -f ../../aws/localstack/docker-compose.yml logs -f localstack

# Initialize and apply using the LocalStack configuration
terraform init
terraform apply -var-file="terraform.tfvars.localstack"

# View LocalStack UI (optional)
open http://localhost:8080
```

**Method 2: Using environment variables**

```bash
# Navigate to the Terraform basics directory
cd module-01/terraform/basics

# Start LocalStack using Docker Compose (from module-01/aws/localstack)
docker-compose -f ../../aws/localstack/docker-compose.yml up -d

# Wait for LocalStack to be ready (usually 10-20 seconds)
docker-compose -f ../../aws/localstack/docker-compose.yml logs -f localstack

# In another terminal, set environment variable to use LocalStack
export TF_VAR_use_localstack=true

# Initialize Terraform
terraform init

# Plan and apply (creates resources in LocalStack, not AWS)
terraform plan
terraform apply

# View LocalStack UI (optional)
open http://localhost:8080
```

### LocalStack Configuration

The `providers.tf` file contains provider configuration for both LocalStack and AWS:

```hcl
provider "aws" {
  region = var.use_localstack ? var.localstack_aws_region : var.aws_region

  # LocalStack endpoint configuration
  endpoints = var.use_localstack ? {
    s3              = "http://localhost:4566"
    dynamodb        = "http://localhost:4566"
    iam             = "http://localhost:4566"
    lambda          = "http://localhost:4566"
    # ... more endpoints
  } : {}

  # Skip AWS validations for LocalStack
  skip_credentials_api_check = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack
}
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TF_VAR_use_localstack` | Enable LocalStack mode | `false` |
| `TF_VAR_localstack_endpoint` | LocalStack endpoint URL | `http://localhost:4566` |
| `TF_VAR_localstack_aws_region` | Region for LocalStack | `us-east-1` |
| `TF_VAR_project_name` | Project name | `mlops-training` |
| `TF_VAR_environment` | Environment name | `dev` |

### LocalStack Commands

```bash
# Start LocalStack
docker-compose -f ../../aws/localstack/docker-compose.yml up -d

# Stop LocalStack
docker-compose -f ../../aws/localstack/docker-compose.yml down

# View LocalStack logs
docker-compose -f ../../aws/localstack/docker-compose.yml logs -f

# Check LocalStack health
curl -s http://localhost:4566/health | jq

# List S3 buckets via AWS CLI (using LocalStack endpoint)
aws --endpoint-url=http://localhost:4566 s3 ls

# List S3 bucket contents
aws --endpoint-url=http://localhost:4566 s3 ls s3://mlops-training-local-ml-models-localstack --recursive
```

### LocalStack Limitations

LocalStack supports most AWS services but has some limitations:

- **S3**: Basic operations supported; some advanced features limited
- **IAM**: Most features supported; policies may work differently
- **Lambda**: Supported with limitations (requires Docker)
- **DynamoDB**: Full support
- **KMS**: Limited support; use `AES256` encryption instead
- **CloudWatch**: Basic logs supported
- **SNS/SQS**: Full support
- **EC2**: Limited support; mainly metadata operations

### Switching Between LocalStack and AWS

```bash
# Use LocalStack for development
export TF_VAR_use_localstack=true
terraform apply

# Switch to AWS for production
unset TF_VAR_use_localstack
export TF_VAR_environment=prod
terraform apply

# Use terraform.tfvars for configuration
cat > terraform.tfvars <<EOF
use_localstack = true
environment     = "dev"
project_name    = "mlops-training"
EOF
```

### LocalStack UI

Access the LocalStack Web UI at `http://localhost:8080` to visualize:

- Created resources (S3 buckets, DynamoDB tables, etc.)
- API calls made to LocalStack
- Service configurations
- Logs and metrics

### Troubleshooting LocalStack

**Issue: Connection refused**
```bash
# Verify LocalStack is running
curl http://localhost:4566/health

# Restart LocalStack
docker-compose -f ../../aws/localstack/docker-compose.yml restart
```

**Issue: Resources not creating**
```bash
# Check LocalStack logs
docker-compose -f ../../aws/localstack/docker-compose.yml logs localstack

# Verify environment variable is set
echo $TF_VAR_use_localstack

# Re-initialize Terraform
terraform init -reconfigure
```

**Issue: Service not available in LocalStack**
- Check [LocalStack Feature Coverage](https://docs.localstack.cloud/aws/service-coverage/)
- Some features require LocalStack Pro

### Docker Compose Configuration

The Docker Compose file at `module-01/aws/localstack/docker-compose.yml` includes:

- **LocalStack container**: Main AWS emulator
- **LocalStack UI**: Web interface for visualization
- **Persistent data**: Data survives container restarts
- **Network isolation**: Separate network for LocalStack services

This shared LocalStack setup is used across multiple modules in the training.

### Best Practices for LocalStack

1. **Always use different environments** for LocalStack and AWS
2. **Never commit `terraform.tfvars`** with `use_localstack=true` to production
3. **Clean up LocalStack regularly**: `docker-compose down -v`
4. **Use environment-specific variables**: `terraform.tfvars.localstack`
5. **Test thoroughly in LocalStack before deploying to AWS**
6. **Mock external dependencies** in LocalStack environment

### Environment-Specific Configuration

The `terraform.tfvars.localstack` file provides pre-configured variables for LocalStack development:

```bash
# Apply using the LocalStack variable file
terraform apply -var-file="terraform.tfvars.localstack"
```

This file includes:
- `use_localstack = true` to enable LocalStack mode
- `environment = "local"` for proper resource naming
- Relaxed security settings for local development
- No notification email configured
- Shorter log retention (7 days)

**File Structure:**
```
terraform/
├── .gitignore                    # Excludes *.tfvars but keeps examples
├── terraform.tfvars.example      # Template for production
├── terraform.tfvars.localstack   # LocalStack configuration (tracked)
└── terraform.tfvars              # Your local overrides (not tracked)
```

---

## Hands-On Examples

To reinforce the concepts covered in this guide, explore the practical examples in the `examples/` directory:

| Example | Description | Concepts Covered |
|---------|-------------|------------------|
| [data-sources](../examples/data-sources/) | Query existing AWS resources | Data sources, filters, AMI lookup |
| [for-each](../examples/for-each/) | Create multiple resources | `count`, `for_each`, dynamic blocks |
| [locals](../examples/locals/) | Reusable local values | Naming conventions, tag combinations |
| [outputs](../examples/outputs/) | Format and display outputs | Nested outputs, sensitive values, templates |

Each example includes a complete `main.tf` file that you can run directly:
```bash
cd module-01/terraform/examples/data-sources
terraform init
terraform plan
terraform apply  # Only if you want to create resources
```

---

## Practice Exercises

Comprehensive hands-on exercises are available in the `exercises/` directory. Each exercise includes objectives, requirements, acceptance criteria, hints, and solutions.

### Exercise 1: Your First S3 Bucket with Terraform

**Goal**: Create your first Terraform configuration for ML model storage.

**Requirements**:
- Provision an S3 bucket for ML model storage
- Enable versioning on the bucket
- Enable default encryption (AES256)
- Use variables for bucket name prefix and environment
- Output the bucket name, ARN, and endpoint URL

**Steps**:
1. Create the directory structure
2. Write main.tf with required_providers block
3. Add variables.tf with input variables
4. Add outputs.tf
5. Run `terraform init`
6. Run `terraform plan`
7. Run `terraform apply`
8. Verify the bucket in AWS Console

### Exercise 2: Multiple Environments with for_each

**Goal**: Use `for_each` to create resources for multiple environments.

**Requirements**:
- Create S3 buckets for dev, staging, and prod
- Each bucket should have environment-specific lifecycle rules
- Use `for_each` with a map variable
- Output all bucket names as a map

### Exercise 3: Query Existing Infrastructure with Data Sources

**Goal**: Use data sources to query and use existing AWS resources.

**Requirements**:
- Query the default VPC in your AWS account
- Query the latest Amazon Linux AMI dynamically
- Create a security group allowing SSH and HTTP
- Output the VPC ID, AMI ID, and security group ID

### Exercise 4: Creating Reusable Modules

**Goal**: Structure a Terraform module properly.

**Requirements**:
- Create a reusable S3 module with inputs/outputs
- Module should create: bucket, versioning, encryption, block public access
- Use the module to create resources for different environments

### Exercise 5-7: Advanced Topics

- Exercise 5: ML Infrastructure Stack (combine multiple concepts)
- Exercise 6: Modern Terraform Features (check blocks, validation)
- Exercise 7: Terraform Testing (write tests for modules)

**To access all exercises with detailed requirements, hints, and solutions:**
```bash
cd module-01/terraform/exercises
cat exercises.md
```

Or view the exercises directly in [exercises/exercises.md](../exercises/exercises.md)

---

## Additional Resources

### Official Documentation
- [Terraform Language Docs](https://developer.hashicorp.com/terraform/language)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Module Registry](https://registry.terraform.io/)

### AWS MLOps with Terraform
- [AWS MLOps Platform with Terraform](https://aws.amazon.com/blogs/machine-learning/implement-a-secure-mlops-platform-based-on-terraform-and-github/)
- [Terraform AWS Provider Best Practices](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/introduction.html)

### Learning Resources
- [Terraform Interactive Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [Terraform Certified Associate Certification](https://www.hashicorp.com/certification/terraform-associate)

---

## Next Steps

After completing this module:

1. **Practice with Examples**: Run the examples in the `examples/` directory to reinforce each concept
   - `data-sources/` - Learn to query existing AWS resources
   - `for-each/` - Master creating multiple resources efficiently
   - `locals/` - Build reusable naming conventions and tags
   - `outputs/` - Format and display infrastructure information

2. **Complete the Exercises**: Work through all 7 comprehensive exercises in `exercises/exercises.md`
   - Start with Exercise 1 (basic S3 bucket)
   - Progress through to Exercise 7 (Terraform testing)

3. **Build ML Infrastructure**: Use the provided `main.tf`, `variables.tf`, `outputs.tf`, and `terraform.tfvars` files as a starting point for your own MLOps infrastructure

4. **Advanced Topics**: Explore [Terraform Cloud/Enterprise](https://developer.hashicorp.com/terraform/cloud-docs) for team collaboration and state management

---

**Version**: 1.2 | **Last Updated**: January 2026 | **Terraform Version**: 1.14+ | **AWS Provider**: 6.0+
