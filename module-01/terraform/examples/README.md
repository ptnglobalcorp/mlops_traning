# Terraform Examples for MLOps Training

This directory contains practical examples demonstrating various Terraform concepts from basic to intermediate levels.

## Available Examples

| Example | Description | Difficulty |
|---------|-------------|------------|
| [data-sources](./data-sources/) | Query existing AWS resources and data | Beginner |
| [for-each](./for-each/) | Create multiple resources with `for_each` and `count` | Intermediate |
| [locals](./locals/) | Use local values for reusable expressions | Intermediate |
| [outputs](./outputs/) | Define and format outputs for various use cases | Beginner |
| [remote-state](./remote-state/) | S3 backend with modern lock file configuration | Intermediate |
| [modules](./modules/) | Create reusable infrastructure components | Intermediate |
| [conditionals](./conditionals/) | Environment-specific configurations with logic | Intermediate |
| [lifecycle](./lifecycle/) | Safe resource updates and protection | Intermediate |

---

## How to Use These Examples

### Prerequisites

1. Terraform 1.14+ installed
2. AWS account with credentials configured
3. Basic understanding of Terraform from the main README

### Running an Example

```bash
# Navigate to the example directory
cd module-01/terraform/examples/data-sources

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (only if you want to create resources)
terraform apply

# Clean up when done
terraform destroy
```

---

## Example Descriptions

### 1. Data Sources (`data-sources/`)

**Learn how to:**
- Query AWS account and region information
- Find existing VPCs, subnets, and security groups
- Get the latest AMI IDs dynamically
- Query S3 buckets and IAM roles
- Filter resources by tags and attributes

**Key Concepts:**
- `data` blocks
- Filtering with `filter` blocks
- Referencing data sources in resources
- Using `try()` for safe access

---

### 2. For Each & Count (`for-each/`)

**Learn how to:**
- Create multiple resources from a list using `count`
- Create resources from maps using `for_each`
- Use dynamic blocks with `for_each`
- Handle nested configurations
- Choose between `count` and `for_each`

**Key Concepts:**
- `count` meta-argument
- `for_each` meta-argument
- Dynamic blocks
- Resource references with indices and keys
- Flattening nested structures

---

### 3. Locals (`locals/`)

**Learn how to:**
- Define reusable values within a module
- Create naming conventions
- Build complex tag combinations
- Use conditionals in locals
- Transform and filter data with locals

**Key Concepts:**
- `locals` blocks
- DRY (Don't Repeat Yourself) principle
- String manipulation and regex
- Merge and transform functions
- Environment-specific configurations

---

### 4. Outputs (`outputs/`)

**Learn how to:**
- Define basic outputs
- Create complex nested outputs
- Format outputs for human consumption
- Mark sensitive outputs
- Generate JSON and file outputs

**Key Concepts:**
- `output` blocks
- Descriptions and formatting
- Sensitive outputs
- Template rendering
- Cross-module outputs

---

### 5. Remote State (`remote-state/`)

**Learn how to:**
- Configure S3 as a remote state backend
- Use modern S3 lock file (no DynamoDB needed)
- Enable state encryption and versioning
- Work with both AWS and LocalStack

**Key Concepts:**
- S3 remote state backend
- `use_lockfile` option
- State security and recovery
- LocalStack for local development

---

### 6. Modules (`modules/`)

**Learn how to:**
- Organize code into reusable modules
- Define module inputs and outputs
- Compose multiple modules
- Use modules for ML infrastructure patterns

**Key Concepts:**
- Module structure and files
- Module inputs (variables)
- Module outputs
- Module composition for ML workloads

**ML Use Cases:**
- Reusable ML model storage module
- Training data module with intelligent tiering
- Artifacts module for pipeline outputs

---

### 7. Conditionals (`conditionals/`)

**Learn how to:**
- Use ternary operators for value selection
- Conditionally create resources with `count`
- Filter resources with `for_each` conditionals
- Use dynamic blocks with conditionals
- Validate inputs with conditionals

**Key Concepts:**
- Ternary operator: `condition ? true_value : false_value`
- Conditional count: `condition ? 1 : 0`
- Filtered for_each: `for_each = {for k, v in map : k => v if v.condition}`
- Dynamic blocks with conditional iteration

**ML Use Cases:**
- Environment-specific instance types
- Production-only lifecycle rules
- Conditional monitoring and alerts
- Account-based compliance levels

---

### 8. Lifecycle (`lifecycle/`)

**Learn how to:**
- Use `create_before_destroy` for zero-downtime updates
- Protect critical resources with `prevent_destroy`
- Ignore dynamic changes with `ignore_changes`
- Force replacement with `replace_triggered_by`

**Key Concepts:**
- `create_before_destroy` - Safe updates
- `prevent_destroy` - Deletion protection
- `ignore_changes` - Skip drift detection
- `replace_triggered_by` - Conditional replacement

**ML Use Cases:**
- Zero-downtime model deployment
- Production model storage protection
- Ignoring ML pipeline tags
- Replacing resources on model version change

---

## Common Patterns

### Pattern 1: Dynamic Resource Naming

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_s3_bucket" "example" {
  bucket = "${local.name_prefix}-models"
}
```

### Pattern 2: Conditional Resource Creation

```hcl
resource "aws_cloudwatch_log_group" "example" {
  count = var.enable_logging ? 1 : 0
  name  = "/aws/ml/example"
}
```

### Pattern 3: Iterating Over a Map

```hcl
resource "aws_s3_bucket" "buckets" {
  for_each = {
    "dev" = "ml-dev-data"
    "prod" = "ml-prod-data"
  }
  bucket = each.value
}
```

### Pattern 4: Combining Tags

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  specific_tags = {
    Purpose = "ml-storage"
  }

  all_tags = merge(local.common_tags, local.specific_tags)
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
  tags   = local.all_tags
}
```

### Pattern 5: Module Usage

```hcl
module "ml_storage" {
  source = "./modules/ml-storage"

  project_name = var.project_name
  environment  = var.environment
}

# Access module outputs
output "bucket_name" {
  value = module.ml_storage.bucket_name
}
```

---

## Practice Exercises

### Exercise 1: Create Multi-Environment S3 Buckets

Using the `for-each` example as reference:
- Create S3 buckets for dev, staging, and prod
- Apply different lifecycle rules for each environment
- Output all bucket names and ARNs

### Exercise 2: Build a Reusable Module

Using the `modules` example as reference:
- Create a simple module for ML model storage
- Define input variables for customization
- Output the bucket name and ARN
- Use the module in your root configuration

### Exercise 3: Environment-Specific Configuration

Using the `conditionals` example as reference:
- Create different instance types per environment
- Add production-only monitoring resources
- Implement conditional tagging

### Exercise 4: Safe Resource Updates

Using the `lifecycle` example as reference:
- Create a resource with `create_before_destroy`
- Add `prevent_destroy` to critical storage
- Use `ignore_changes` for dynamic tags

---

## Tips for Success

1. **Start with `terraform plan`** - Always review before applying
2. **Use descriptions** - Document your outputs and variables
3. **Check the state** - Use `terraform show` to inspect results
4. **Clean up** - Run `terraform destroy` when done practicing
5. **Experiment** - Modify the examples and see what happens

---

## Learning Path

Recommended order for learning:

1. **Beginner** → `data-sources`, `outputs`
2. **Intermediate** → `locals`, `for-each`
3. **Advanced** → `modules`, `conditionals`, `lifecycle`
4. **Production** → `remote-state`

---

## Next Steps

After mastering these examples:
1. Complete the main [basics exercises](../basics/)
2. Build your own MLOps infrastructure
3. Explore [Terraform best practices](https://www.terraform-best-practices.com/)

---

**Need Help?** Refer to the main [Terraform Basics guide](../basics/)
