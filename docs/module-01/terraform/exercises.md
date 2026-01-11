# Terraform Practice Exercises

**Hands-on exercises to practice Terraform from beginner to intermediate**

These exercises are designed to reinforce the concepts learned in the Terraform Basics guide. Each exercise includes objectives, requirements, hints, and solutions.

---

## Exercise 1: Your First S3 Bucket with Terraform

### Objectives
- Create your first Terraform configuration
- Use variables for configurability
- Apply outputs to display important information

### Requirements
Create a Terraform configuration that:
1. Provisions an S3 bucket for ML model storage
2. Enables versioning on the bucket
3. Enables default encryption (AES256)
4. Uses variables for bucket name prefix and environment
5. Outputs the bucket name, ARN, and endpoint URL

### Acceptance Criteria
- [ ] Terraform configuration validates without errors
- [ ] `terraform plan` shows the bucket will be created
- [ ] `terraform apply` successfully creates the bucket
- [ ] Bucket has versioning enabled
- [ ] Bucket has encryption enabled
- [ ] Outputs display correct information

### Hints
<details>
<summary>Click to reveal hints</summary>

1. Start with the `terraform` block specifying required providers
2. Create a `provider` block for AWS
3. Use `resource "aws_s3_bucket"` for the bucket
4. Use `resource "aws_s3_bucket_versioning"` for versioning
5. Use `resource "aws_s3_bucket_server_side_encryption_configuration"` for encryption
6. Create variables in `variables.tf`
7. Create outputs in `outputs.tf`
</details>

### Solution Structure
```
exercise-1/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

---

## Exercise 2: Multiple Environments with for_each

### Objectives
- Use `for_each` to create multiple resources
- Understand map-based resource creation
- Apply different configurations per environment

### Requirements
Create a Terraform configuration that:
1. Creates S3 buckets for dev, staging, and prod environments
2. Each bucket should have:
   - A unique name following the pattern: `ml-{env}-data`
   - Environment-specific tag
   - Different lifecycle rules (dev: 30 days, staging: 90 days, prod: 365 days)
3. Outputs all bucket names as a map

### Acceptance Criteria
- [ ] Creates exactly 3 buckets
- [ ] Each bucket has correct naming pattern
- [ ] Each bucket has appropriate lifecycle rules
- [ ] Outputs show all buckets with environment keys

### Hints
<details>
<summary>Click to reveal hints</summary>

1. Define a map variable for environments
2. Use `for_each` with the map
3. Access each key-value pair with `each.key` and `each.value`
4. Use `each.key` in bucket names and tags
5. Reference lifecycle days from the map value
</details>

### Starter Code
```hcl
variable "environments" {
  type = map(object({
    lifecycle_days = number
  }))
  default = {
    dev = {
      lifecycle_days = 30
    }
    staging = {
      lifecycle_days = 90
    }
    prod = {
      lifecycle_days = 365
    }
  }
}

resource "aws_s3_bucket" "env_buckets" {
  # TODO: Add for_each configuration
  # TODO: Configure bucket name
}
```

---

## Exercise 3: Query Existing Infrastructure with Data Sources

### Objectives
- Use data sources to query existing AWS resources
- Reference data source outputs in new resources
- Understand when to use data sources vs. resources

### Requirements
Create a Terraform configuration that:
1. Queries the default VPC in your AWS account
2. Queries the latest Amazon Linux AMI
3. Queries available subnets in the VPC
4. Creates a security group in the VPC allowing:
   - SSH (port 22) from your IP
   - HTTP (port 80) from anywhere
5. Outputs the VPC ID, AMI ID, and security group ID

### Acceptance Criteria
- [ ] Successfully queries the default VPC
- [ ] Gets the latest Amazon Linux AMI dynamically
- [ ] Creates security group with correct rules
- [ ] All outputs display correct values
- [ ] Configuration works in any AWS account

### Hints
<details>
<summary>Click to reveal hints</summary>

1. Use `data "aws_vpc"` to get the default VPC
2. Use `data "aws_ami"` with filters for Amazon Linux
3. Use `data "aws_subnets"` with VPC filter
4. Reference data source values like `data.aws_vpc.default.id`
5. Use CIDR blocks for security group rules
</details>

---

## Exercise 4: Creating Reusable Modules

### Objectives
- Structure a Terraform module properly
- Define module inputs and outputs
- Use a module to create resources

### Requirements
Create a reusable S3 module:
1. Module should accept:
   - `project_name` (string)
   - `environment` (string)
   - `versioning_enabled` (bool, default: true)
   - `tags` (map, default: {})
2. Module should create:
   - An S3 bucket with prefix: `{project}-{environment}-models`
   - Versioning (conditional on input)
   - Server-side encryption (always enabled)
   - Block public access (always enabled)
3. Module should output:
   - Bucket name
   - Bucket ARN

### Acceptance Criteria
- [ ] Module structure is correct
- [ ] Module creates bucket with correct naming
- [ ] Versioning is conditional based on input
- [ ] All security features are enabled
- [ ] Outputs work correctly

### Module Structure
```
modules/
└── s3-model-storage/
    ├── main.tf      # Resources
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    └── README.md     # Module documentation
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. Use `bucket_prefix` for unique naming
2. Use conditional expression for versioning status
3. Use `merge()` to combine user tags with default tags
4. Keep module focused on single responsibility
5. Document each variable with description
</details>

---

## Exercise 5: Advanced - ML Infrastructure Stack

### Objectives
- Combine multiple Terraform concepts
- Build a complete ML infrastructure
- Use locals, data sources, and modules together

### Requirements
Build an ML infrastructure stack:
1. **S3 Buckets** (using your module from Exercise 4):
   - Models bucket (with versioning)
   - Data bucket (with versioning)
   - Artifacts bucket (without versioning)

2. **IAM Resources**:
   - IAM role for Lambda execution
   - IAM policy allowing S3 access to all buckets
   - Outputs role ARN and policy ARN

3. **Security Group**:
   - Allows SSH from your IP
   - Allows HTTPS for API endpoints
   - Uses locals for consistent tagging

4. **CloudWatch**:
   - Log group for models (`/aws/ml/models`)
   - Log group for training (`/aws/ml/training`)
   - 30-day retention for both

5. **Outputs**:
   - S3 bucket information
   - IAM role ARN
   - Security group ID
   - CloudWatch log group names

### Acceptance Criteria
- [ ] All resources created successfully
- [ ] All outputs display correct information
- [ ] Resources have consistent tagging
- [ ] Configuration follows DRY principles
- [ ] Terraform validates and applies cleanly

### Bonus Challenges
- [ ] Add KMS encryption with customer-managed key
- [ ] Add lifecycle policies for cost optimization
- [ ] Add SNS topic for ML pipeline notifications
- [ ] Use data sources to query existing VPC and subnets

---

## Exercise 6: Modern Terraform Features

### Objectives
- Use modern Terraform 1.5+ features
- Implement check blocks for validation
- Use import blocks for existing resources

### Requirements
1. **Check Block**:
   - Create a check block that validates an S3 bucket
   - Verify the bucket is accessible (returns 4xx or 3xx)
   - Display meaningful error if check fails

2. **Variable Validation**:
   - Add validation for environment variable (must be dev/staging/prod)
   - Add validation for retention days (must be between 1-365)
   - Add validation for encryption type (AES256 or aws:kms)

3. **Removed Block**:
   - Create a removed block example for a deprecated resource

### Acceptance Criteria
- [ ] Check block validates bucket access
- [ ] All variable validations work correctly
- [ ] Invalid inputs produce helpful error messages
- [ ] Removed block is properly configured

---

## Exercise 7: Terraform Testing

### Objectives
- Write tests for Terraform modules
- Use mock data for testing
- Validate module behavior

### Requirements
Create a test file for your S3 module:
1. Test that bucket name starts with correct prefix
2. Test that versioning is enabled when requested
3. Test that tags are applied correctly
4. Test that encryption is always enabled

### Acceptance Criteria
- [ ] Test file is in `tests/` directory
- [ ] All tests pass with `terraform test`
- [ ] Tests cover main functionality
- [ ] Tests have clear descriptions

### Test File Structure
```
s3-model-storage/
└── tests/
    └── module_test.tftest.hcl
```

### Hints
<details>
<summary>Click to reveal hints</summary>

1. Use the `test` provider from `terraform.io/builtin/test`
2. Use `run` blocks for test cases
3. Use `assert` blocks for validations
4. Use `condition` expressions for checks
5. Provide meaningful `error_message` values
</details>

---

## General Exercise Guidelines

### Before Starting
1. Ensure Terraform is installed: `terraform version`
2. Ensure AWS credentials are configured: `aws sts get-caller-identity`
3. Create a new directory for each exercise
4. Always use `terraform plan` before `terraform apply`

### During Exercise
1. Start with `main.tf`, then add `variables.tf` and `outputs.tf`
2. Run `terraform validate` frequently
3. Run `terraform fmt` to keep code clean
4. Use `terraform show` to inspect state after apply

### After Exercise
1. Always clean up: `terraform destroy`
2. Verify resources are deleted in AWS Console
3. Review what you learned
4. Try variations of the exercise

### Troubleshooting
- **Error: "configuration conflicts"** → Run `terraform fmt` and check for duplicates
- **Error: "Failed to load provider"** → Run `terraform init`
- **Error: "Invalid for_each argument"** → Ensure your map has unique keys
- **Resources not creating** → Check AWS permissions and quotas

---

## Solutions

Solutions are available in the `solutions/` directory. Try to complete each exercise before looking at the solution!

```
solutions/
├── exercise-1/
├── exercise-2/
├── exercise-3/
└── ...
```

---

## Progress Tracking

Track your progress:

| Exercise | Status | Completed Date |
|----------|--------|----------------|
| Exercise 1: Your First S3 Bucket | Not Started | |
| Exercise 2: Multiple Environments | Not Started | |
| Exercise 3: Data Sources | Not Started | |
| Exercise 4: Reusable Modules | Not Started | |
| Exercise 5: ML Infrastructure Stack | Not Started | |
| Exercise 6: Modern Features | Not Started | |
| Exercise 7: Terraform Testing | Not Started | |

---

## Next Steps

After completing these exercises:
1. Build your own ML infrastructure from scratch
2. Explore the [examples directory](../examples/) for more patterns
3. Learn about advanced topics: workspaces, state management, CI/CD
4. Contribute your own examples to the repository

---

**Need Help?** Refer to:
- Main [Terraform Basics guide](../basics/README.md)
- [Examples README](../examples/README.md)
- [Terraform Documentation](https://developer.hashicorp.com/terraform/language)
