# Terraform Practice Exercises

**Hands-on exercises to reinforce Terraform concepts for MLOps**

These exercises align with the [basics](../basics/) and [examples](../examples/) to provide practical, hands-on experience. Each exercise includes objectives, requirements, hints, and references to relevant examples.

---

## Exercise Roadmap

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Terraform Learning Path                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Basics              Examples              Exercises                 │
│  ──────              ────────              ─────────                 │
│                                                                     │
│  ✓ Providers          data-sources    →    Exercise 1: Data Sources │
│  ✓ Resources          for-each        →    Exercise 2: For Each    │
│  ✓ Variables          locals          →    Exercise 3: Locals      │
│  ✓ Outputs            modules         →    Exercise 4: Modules      │
│  ✓ Basic workflow     conditionals    →    Exercise 5: Conditionals │
│                       lifecycle       →    Exercise 6: Lifecycle    │
│                       remote-state    →    Exercise 7: Remote State │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Exercise 1: Query AWS Resources with Data Sources

**Prerequisite:** Complete [basics/](../basics/) and review [data-sources example](../examples/data-sources/)

### Objectives
- Use data sources to query existing AWS infrastructure
- Reference data source outputs in new resources
- Filter resources by tags and attributes

### Requirements
Create a Terraform configuration that:

1. **Query existing infrastructure:**
   - Get AWS caller identity (account ID, region, ARN)
   - Find the default VPC
   - Query the latest Amazon Linux 2023 AMI
   - Get all subnets in the default VPC

2. **Create a security group:**
   - Place it in the default VPC (from data source)
   - Allow SSH (port 22) from your IP
   - Allow HTTPS (port 443) from anywhere
   - Use tags for identification

3. **Create an S3 bucket:**
   - Use a unique prefix with your account ID
   - Include the region in tags

4. **Outputs:**
   - Account ID and region
   - Default VPC ID and CIDR
   - Latest AMI ID
   - Security group ID
   - S3 bucket name and ARN

### Acceptance Criteria
- [ ] `terraform validate` passes without errors
- [ ] `terraform plan` shows correct data source queries
- [ ] Security group is created in the default VPC
- [ ] All outputs display correct information
- [ ] Configuration works in any AWS account

### Starter Template

```hcl
# providers.tf
terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# variables.tf
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "my_ip_address" {
  description = "Your IP address for SSH access (CIDR notation)"
  type        = string
  default     = "0.0.0.0/0"
}

# TODO: Add main.tf with data sources and resources
# TODO: Add outputs.tf with all required outputs
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **Data sources needed:**
   - `data "aws_caller_identity" "current"`
   - `data "aws_region" "current"`
   - `data "aws_vpc" "default"` with `default = true`
   - `data "aws_ami"` with filters for Amazon Linux 2023
   - `data "aws_subnets"` with VPC filter

2. **Security group reference:**
   - Use `data.aws_vpc.default.id` for the VPC

3. **AMIs filter:**
   - `owners = ["amazon"]`
   - Filter by name pattern: `al2023-ami-2023.*-x86_64`

4. **Outputs:**
   - Reference data source values like `data.aws_caller_identity.current.account_id`
</details>

### Solution Reference
See [data-sources example](../examples/data-sources/) for similar patterns.

---

## Exercise 2: Multi-Environment S3 Buckets with for_each

**Prerequisite:** Review [for-each example](../examples/for-each/)

### Objectives
- Use `for_each` to create multiple resources from a map
- Use `count` to create resources from a list
- Access resource instances with indices and keys

### Requirements
Create a Terraform configuration that:

1. **Create environment buckets with `for_each`:**
   - Define a map with environments: dev, staging, prod
   - Each environment has a lifecycle retention period (dev: 30, staging: 90, prod: 365 days)
   - Each bucket should have:
     - Name pattern: `{project}-{env}-ml-data`
     - Environment-specific tag
     - Appropriate lifecycle rule

2. **Create model type buckets with `count`:**
   - Create buckets for: ["tensorflow", "pytorch", "sklearn", "xgboost"]
   - Each bucket name: `{project}-models-{type}`

3. **Create a models bucket with dynamic blocks:**
   - Use `for_each` to add lifecycle rules for different prefix transitions
   - Rules: training-data → IA after 30 days, artifacts → Glacier after 90 days

4. **Outputs:**
   - All environment buckets as a map
   - All model type buckets as a list
   - Models bucket with all lifecycle rules

### Acceptance Criteria
- [ ] Creates exactly 3 environment buckets
- [ ] Creates exactly 4 model type buckets
- [ ] Each bucket has correct naming and tags
- [ ] Lifecycle rules are properly configured
- [ ] Outputs show all resources correctly

### Starter Template

```hcl
# variables.tf
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mlops-training"
}

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    retention_days = number
  }))
  default = {
    dev = {
      retention_days = 30
    }
    staging = {
      retention_days = 90
    }
    prod = {
      retention_days = 365
    }
  }
}

variable "model_types" {
  description = "ML model types"
  type        = list(string)
  default     = ["tensorflow", "pytorch", "sklearn", "xgboost"]
}

# TODO: Add main.tf with for_each and count resources
# TODO: Add outputs.tf
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **For-each with map:**
   ```hcl
   resource "aws_s3_bucket" "env_buckets" {
     for_each = var.environments
     bucket_prefix = "${var.project_name}-${each.key}-ml-data-"
   }
   ```

2. **Count with list:**
   ```hcl
   resource "aws_s3_bucket" "model_buckets" {
     count = length(var.model_types)
     bucket_prefix = "${var.project_name}-models-${var.model_types[count.index]}-"
   }
   ```

3. **Dynamic blocks:**
   ```hcl
   dynamic "rule" {
     for_each = var.lifecycle_rules
     content {
       id     = rule.value.id
       status = "Enabled"
       # ... rule configuration
     }
   }
   ```

4. **Accessing resources:**
   - `aws_s3_bucket.env_buckets["dev"].id`
   - `aws_s3_bucket.model_buckets[0].id`
</details>

### Solution Reference
See [for-each example](../examples/for-each/) for similar patterns.

---

## Exercise 3: ML Infrastructure with Locals

**Prerequisite:** Review [locals example](../examples/locals/)

### Objectives
- Use locals for reusable values and expressions
- Create naming conventions with locals
- Build complex tag combinations
- Transform and filter data with locals

### Requirements
Create an ML infrastructure configuration that:

1. **Define local values:**
   - `name_prefix`: Combines project and environment
   - `common_tags`: Standard tags (Project, Environment, ManagedBy)
   - `bucket_names`: Map of bucket purposes to names
   - `lifecycle_rules`: Common lifecycle configurations

2. **Create resources using locals:**
   - S3 buckets for models, data, and artifacts
   - Security group for ML inference
   - CloudWatch log groups

3. **Use local expressions:**
   - String interpolation for naming
   - Merge function for combining tags
   - Conditional expressions for environment differences

4. **Outputs:**
   - All resource identifiers
   - Combined information using local expressions

### Acceptance Criteria
- [ ] All locals are properly defined and used
- [ ] Resources follow consistent naming convention
- [ ] Tags are applied correctly using merge()
- [ ] No hardcoded values in resources
- [ ] Configuration is DRY (Don't Repeat Yourself)

### Starter Template

```hcl
# TODO: Define locals for:
# - name_prefix
# - common_tags
# - bucket_configs
# - lifecycle_rules
# - environment_overrides

locals {
  # Your locals here
}

# TODO: Create resources using locals
resource "aws_s3_bucket" "models" {
  bucket_prefix = local.name_prefix
  # Use local configs
}
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **Name prefix:**
   ```hcl
   locals {
     name_prefix = "${var.project_name}-${var.environment}"
   }
   ```

2. **Merging tags:**
   ```hcl
   resource "aws_s3_bucket" "example" {
     tags = merge(local.common_tags, {
       Purpose = "ml-models"
     })
   }
   ```

3. **Bucket configurations:**
   ```hcl
   locals {
     bucket_configs = {
       models = {
         prefix = "ml-models"
         versioning = true
       }
       data = {
         prefix = "ml-data"
         versioning = true
       }
     }
   }
   ```

4. **Conditional locals:**
   ```hcl
   locals {
     is_production = var.environment == "prod"
     retention_days = local.is_production ? 365 : 90
   }
   ```
</details>

### Solution Reference
See [locals example](../examples/locals/) for similar patterns.

---

## Exercise 4: Build a Reusable ML Storage Module

**Prerequisite:** Review [modules example](../examples/modules/)

### Objectives
- Structure a Terraform module properly
- Define module inputs and outputs
- Use a module to create resources
- Understand module composition

### Requirements

**Part 1: Create the Module**

Create a module at `modules/ml-storage/` with:

1. **Inputs (variables.tf):**
   - `project_name` (string, required)
   - `environment` (string, required)
   - `bucket_prefix` (string, required)
   - `enable_versioning` (bool, default: true)
   - `enable_lifecycle_rules` (bool, default: false)
   - `retention_days` (number, default: 90)
   - `custom_tags` (map, default: {})

2. **Resources (main.tf):**
   - S3 bucket with unique naming
   - Optional versioning configuration
   - Optional lifecycle rules
   - Block public access enabled
   - Server-side encryption

3. **Outputs (outputs.tf):**
   - `bucket_name` - Bucket name/ID
   - `bucket_arn` - Bucket ARN
   - `bucket_region` - Bucket region
   - `versioning_enabled` - Whether versioning is enabled

**Part 2: Use the Module**

Create a root configuration that:

1. Uses the module to create three buckets:
   - Models (with versioning and lifecycle)
   - Data (with versioning, no lifecycle)
   - Artifacts (no versioning, with lifecycle)

2. Outputs combined information about all buckets

### Acceptance Criteria
- [ ] Module structure follows best practices
- [ ] All variables have descriptions and types
- [ ] Module works independently
- [ ] Root configuration creates all buckets
- [ ] Outputs display correct information

### Module Structure

```
exercise-4/
├── main.tf                 # Root configuration using modules
├── variables.tf            # Root variables
├── outputs.tf              # Root outputs
└── modules/
    └── ml-storage/
        ├── main.tf         # Module resources
        ├── variables.tf    # Module inputs
        ├── outputs.tf      # Module outputs
        └── README.md       # Module documentation
```

### Starter Template

```hcl
# modules/ml-storage/variables.tf
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# TODO: Add remaining variables

# modules/ml-storage/main.tf
resource "aws_s3_bucket" "storage" {
  # TODO: Configure bucket using variables
}

# TODO: Add optional resources based on variables

# modules/ml-storage/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.storage.id
}

# TODO: Add remaining outputs
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **Module usage:**
   ```hcl
   module "ml_models" {
     source = "./modules/ml-storage"
     project_name = var.project_name
     environment = var.environment
     bucket_prefix = "ml-models"
     enable_versioning = true
     enable_lifecycle_rules = true
   }
   ```

2. **Conditional resources:**
   ```hcl
   resource "aws_s3_bucket_versioning" "this" {
     count  = var.enable_versioning ? 1 : 0
     bucket = aws_s3_bucket.storage.id
     # ...
   }
   ```

3. **Merging tags:**
   ```hcl
   locals {
     default_tags = {
       Project     = var.project_name
       Environment = var.environment
     }
   }

   tags = merge(local.default_tags, var.custom_tags)
   ```

4. **Module outputs:**
   ```hcl
   output "bucket_name" {
     value       = aws_s3_bucket.storage.id
     description = "S3 bucket name"
   }
   ```
</details>

### Solution Reference
See [modules example](../examples/modules/) for complete module patterns.

---

## Exercise 5: Environment-Specific Configurations with Conditionals

**Prerequisite:** Review [conditionals example](../examples/conditionals/)

### Objectives
- Use ternary operators for value selection
- Conditionally create resources with `count`
- Filter resources with `for_each` conditionals
- Use dynamic blocks with conditionals

### Requirements

1. **Ternary Operators:**
   - Instance type: `t3.xlarge` for prod, `t3.medium` otherwise
   - Compliance level: `high` for prod, `standard` otherwise
   - Retention days: 365 for prod, 90 for staging, 30 for dev

2. **Conditional Resource Creation:**
   - Versioning: only for prod/staging
   - KMS encryption: only for prod
   - Requester pays: only for dev environment

3. **Filtered For-Each:**
   - Create monitoring buckets only where `monitoring.enabled == true`
   - Filter model types based on environment

4. **Dynamic Blocks:**
   - Add grant configurations only when specified
   - Add lifecycle rules based on conditions

### Acceptance Criteria
- [ ] Ternary operators select correct values per environment
- [ ] Conditional resources create/don't create as expected
- [ ] Filtered for-each creates only matching items
- [ ] Dynamic blocks conditionally iterate
- [ ] Configuration works for all environments

### Starter Template

```hcl
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "model_types" {
  description = "Model types with creation flags"
  type = map(object({
    create     = bool
    size_gb    = number
  }))
  default = {
    tensorflow = { create = true,  size_gb = 500 }
    pytorch    = { create = true,  size_gb = 200 }
    sklearn    = { create = false, size_gb = 10 }
  }
}

# TODO: Use conditionals throughout
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **Ternary operator:**
   ```hcl
   locals {
     instance_type = var.environment == "prod" ? "t3.xlarge" : "t3.medium"
   }
   ```

2. **Conditional count:**
   ```hcl
   resource "aws_s3_bucket_versioning" "this" {
     count = var.environment != "dev" ? 1 : 0
     # ...
   }
   ```

3. **Filtered for-each:**
   ```hcl
   resource "aws_s3_bucket" "filtered" {
     for_each = {
       for k, v in var.model_types : k => v
       if v.create == true
     }
     # ...
   }
   ```

4. **Dynamic with condition:**
   ```hcl
   dynamic "grant" {
     for_each = var.enable_grants ? var.grants : []
     content {
       # ... grant configuration
     }
   }
   ```
</details>

### Solution Reference
See [conditionals example](../examples/conditionals/) for similar patterns.

---

## Exercise 6: Safe ML Infrastructure with Lifecycle Rules

**Prerequisite:** Review [lifecycle example](../examples/lifecycle/)

### Objectives
- Use `create_before_destroy` for zero-downtime updates
- Use `prevent_destroy` to protect critical resources
- Use `ignore_changes` to handle dynamic updates
- Use `replace_triggered_by` for dependency-driven replacement

### Requirements

1. **Zero-Downtime Updates:**
   - Security group for ML inference (create_before_destroy)
   - IAM role for Lambda execution (create_before_destroy)

2. **Critical Resource Protection:**
   - Production models bucket with `prevent_destroy`
   - Only apply when environment is "prod"

3. **Ignore External Changes:**
   - Artifacts bucket ignores tag changes from ML pipeline
   - Training log group ignores retention changes

4. **Conditional Replacement:**
   - Model cache bucket replacement triggers config bucket replacement
   - Model version variable changes trigger model storage replacement

### Acceptance Criteria
- [ ] Security groups update without downtime
- [ ] Production bucket is protected from deletion
- [ ] Tag changes don't cause drift detection
- [ ] Dependencies trigger proper replacements
- [ ] Configuration works across environments

### Starter Template

```hcl
variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "model_version" {
  description = "Current model version"
  type        = string
  default     = "v1.0"
}

# TODO: Add lifecycle rules to resources
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **create_before_destroy:**
   ```hcl
   resource "aws_security_group" "ml_inference" {
     lifecycle {
       create_before_destroy = true
     }
   }
   ```

2. **prevent_destroy:**
   ```hcl
   resource "aws_s3_bucket" "prod_models" {
     count = var.environment == "prod" ? 1 : 0
     lifecycle {
       prevent_destroy = true
     }
   }
   ```

3. **ignore_changes:**
   ```hcl
   lifecycle {
     ignore_changes = [
       tags,
       tags["LastModified"],
       tags["PipelineRunID"]
     ]
   }
   ```

4. **replace_triggered_by:**
   ```hcl
   resource "aws_s3_bucket" "dependent" {
     lifecycle {
       replace_triggered_by = [
         aws_s3_bucket.trigger.id
       ]
     }
   }
   ```
</details>

### Solution Reference
See [lifecycle example](../examples/lifecycle/) for complete patterns.

---

## Exercise 7: Configure Remote State with S3 Backend

**Prerequisite:** Review [remote-state example](../examples/remote-state/)

### Objectives
- Configure S3 backend for remote state storage
- Enable state locking with modern lock file
- Support both AWS and LocalStack
- Handle state encryption and versioning

### Requirements

1. **S3 Backend Configuration:**
   - Create an S3 bucket for state storage
   - Enable versioning on the state bucket
   - Enable default encryption
   - Configure backend in `terraform` block

2. **State Locking:**
   - Enable `use_lockfile = true` (modern approach)
   - No DynamoDB table needed

3. **Dual Support:**
   - Support both AWS and LocalStack
   - Use variables to switch between providers
   - Conditional backend configuration

4. **State Management:**
   - Create a state management guide
   - Document state migration from local to remote
   - Document state recovery procedures

### Acceptance Criteria
- [ ] S3 bucket is created for state storage
- [ ] Backend configuration works with AWS
- [ ] Backend configuration works with LocalStack
- [ ] State persists across runs
- [ ] Lock file prevents concurrent modifications

### Starter Template

```hcl
terraform {
  required_version = ">= 1.14.0"

  backend "s3" {
    # TODO: Configure backend
    # Note: Some values must use -backend-config
    # bucket         = "..."
    # key            = "..."
    # region         = "..."
    # encrypt        = true
    # use_lockfile   = true
  }
}

# TODO: Create state bucket resource
# TODO: Configure provider with LocalStack support
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. **Backend with variables:**
   ```bash
   terraform init \
     -backend-config="bucket=${STATE_BUCKET}" \
     -backend-config="key=mlops-training/terraform.tfstate" \
     -backend-config="region=us-east-1"
   ```

2. **State bucket resource:**
   ```hcl
   resource "aws_s3_bucket" "terraform_state" {
     bucket_prefix = "terraform-state-"
   }

   resource "aws_s3_bucket_versioning" "state" {
     bucket = aws_s3_bucket.terraform_state.id
     versioning_configuration {
       status = "Enabled"
     }
   }
   ```

3. **LocalStack provider:**
   ```hcl
   provider "aws" {
     region = var.use_localstack ? var.localstack_region : var.aws_region
     endpoints = var.use_localstack ? {
       s3 = var.localstack_endpoint
     } : {}
   }
   ```

4. **State migration:**
   ```bash
   # Migrate local state to remote
   terraform init -migrate-state
   ```
</details>

### Solution Reference
See [remote-state example](../examples/remote-state/) for complete configuration.

---

## General Guidelines

### Before Starting an Exercise
1. Complete the related basics section and example
2. Ensure Terraform is installed: `terraform version`
3. Ensure AWS credentials are configured: `aws sts get-caller-identity`
4. Create a new directory for each exercise
5. Always start with `terraform plan` before `terraform apply`

### During an Exercise
1. Organize code into: `main.tf`, `variables.tf`, `outputs.tf`
2. Run `terraform validate` frequently
3. Run `terraform fmt` to keep code clean
4. Use descriptive names for resources and variables
5. Add comments explaining complex logic

### After Completing an Exercise
1. Always clean up: `terraform destroy`
2. Verify resources are deleted in AWS Console
3. Review what you learned
4. Try variations of the exercise
5. Move to the next exercise

### Troubleshooting

| Error | Solution |
|-------|----------|
| `configuration conflicts` | Run `terraform fmt` and check for duplicate blocks |
| `Failed to load provider` | Run `terraform init` |
| `Invalid for_each argument` | Ensure your map has unique keys |
| `Invalid count argument` | Ensure count value is known at apply time |
| `Resource already managed` | Check state with `terraform show` |
| `Backend configuration changed` | Run `terraform init -migrate-state` |
| `Credentials error` | Verify AWS credentials with `aws sts get-caller-identity` |

---

## Progress Tracking

Track your progress:

| Exercise | Status | Completed Date |
|----------|--------|----------------|
| Exercise 1: Data Sources | Not Started | |
| Exercise 2: For Each | Not Started | |
| Exercise 3: Locals | Not Started | |
| Exercise 4: Modules | Not Started | |
| Exercise 5: Conditionals | Not Started | |
| Exercise 6: Lifecycle | Not Started | |
| Exercise 7: Remote State | Not Started | |

---

## Next Steps

After completing these exercises:

1. **Build your own ML infrastructure** from scratch
2. **Explore CI/CD integration** with Terraform
3. **Learn about Terraform Cloud/Enterprise** for team collaboration
4. **Study advanced topics**: workspaces, state operations, testing

---

**Need Help?** Refer to:
- Main [Terraform README](../README.md)
- [Terraform Basics](../basics/README.md)
- [Examples README](../examples/README.md)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/language)
