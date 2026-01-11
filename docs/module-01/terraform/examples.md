# Terraform Examples for MLOps Training

This directory contains practical examples demonstrating various Terraform concepts from basic to intermediate levels.

## Available Examples

| Example | Description | Difficulty |
|---------|-------------|------------|
| [data-sources](./data-sources/) | Query existing AWS resources and data | Beginner |
| [for-each](./for-each/) | Create multiple resources with `for_each` and `count` | Intermediate |
| [locals](./locals/) | Use local values for reusable expressions | Intermediate |
| [outputs](./outputs/) | Define and format outputs for various use cases | Beginner |

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

---

## Practice Exercises

### Exercise 1: Create Multi-Environment S3 Buckets

Using the `for-each` example as reference:
- Create S3 buckets for dev, staging, and prod
- Apply different lifecycle rules for each environment
- Output all bucket names and ARNs

### Exercise 2: Build a Naming Convention

Using the `locals` example as reference:
- Create a locals block with naming conventions
- Apply the naming convention to multiple resources
- Ensure all resources have consistent tags

### Exercise 3: Query and Use Existing Resources

Using the `data-sources` example as reference:
- Find an existing VPC in your account
- Query the latest Amazon Linux AMI
- Create an EC2 instance in the VPC with the AMI

---

## Tips for Success

1. **Start with `terraform plan`** - Always review before applying
2. **Use descriptions** - Document your outputs and variables
3. **Check the state** - Use `terraform show` to inspect results
4. **Clean up** - Run `terraform destroy` when done practicing
5. **Experiment** - Modify the examples and see what happens

---

## Next Steps

After mastering these examples:
1. Complete the main [basics exercises](../basics/README.md#exercises)
2. Explore [Terraform modules](../modules/)
3. Learn about [state management](../state/)
4. Build your own MLOps infrastructure

---

**Need Help?** Refer to the main [Terraform Basics guide](../basics/README.md)
