# Terraform Basics Lab

**Practice Infrastructure as Code with Terraform**

## Quick Start

```bash
# Navigate to this directory
cd module-01/terraform/basics

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply
```

## Lab Exercises

### Exercise 1: Create S3 Bucket for ML Models

```bash
# Navigate to this directory
cd module-01/terraform/basics

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

### Exercise 2: View Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output bucket_name
```

### Exercise 3: Modify Configuration

```bash
# Edit main.tf to add a new resource
# Example: Add another S3 bucket

# Re-run plan to see changes
terraform plan

# Apply changes
terraform apply
```

### Exercise 4: Destroy Resources

```bash
# Destroy all resources
terraform destroy

# Confirm with 'yes'
```

## Configuration Files

| File | Purpose |
|------|---------|
| `providers.tf` | Terraform and provider configuration |
| `main.tf` | Locals, data sources, and resources |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output value definitions |
| `terraform.tfvars` | Variable values (gitignored) |

## What You'll Learn

This lab demonstrates:
- **Terraform block**: Version and provider requirements
- **Provider configuration**: AWS provider with default tags
- **Locals**: Reusable values for naming and tags
- **Data sources**: Query AWS account and region information
- **Resources**: S3 bucket with bucket policy
- **Outputs**: Display important values after apply

## Common Commands

```bash
# Initialize Terraform (download providers)
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# Apply without confirmation
terraform apply -auto-approve

# Destroy resources
terraform destroy

# Show current state
terraform show

# List resources in state
terraform state list

# Refresh state (query actual infrastructure)
terraform refresh
```

## Customization

Edit `terraform.tfvars` to customize your deployment:

```hcl
project_name = "mlops-training"
environment  = "dev"
aws_region   = "us-east-1"
```

## Cleanup

```bash
# Destroy Terraform resources
terraform destroy
```

## Documentation

For detailed Terraform concepts, theory, and best practices, see:
- **[Remote State Example](../examples/remote-state/)** - Advanced configuration with S3 backend
- **[Data Sources Example](../examples/data-sources/)** - Query existing AWS resources
- **[For Each Example](../examples/for-each/)** - Create multiple resources
- **[Locals Example](../examples/locals/)** - Reusable local values
- **[Outputs Example](../examples/outputs/)** - Format and display outputs

## Troubleshooting

### State file issues

```bash
# Reinitialize if state is corrupted
terraform init -reconfigure
```

### Provider issues

```bash
# Update providers
terraform init -upgrade
```

### Validation errors

```bash
# Validate configuration
terraform validate

# Format files
terraform fmt
```

## Learning Path

1. **Start here** with the lab exercises in this folder
2. **Explore examples** in the `examples/` directory
3. **Try remote state** configuration in `examples/remote-state/`
