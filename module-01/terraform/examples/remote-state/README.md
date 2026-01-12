# Remote State Backend with S3 Lock File

This example demonstrates **Terraform remote state backend** with modern S3 native locking.

## What You'll Learn

- How to configure S3 as a remote state backend
- Modern S3 state locking (no DynamoDB table required)
- State security with server-side encryption
- State versioning for recovery

## Modern S3 Locking

Starting with Terraform 1.14+, S3 remote state uses **S3 Object Lock** for state locking:

- No DynamoDB table required
- Simpler architecture
- Better performance
- Native AWS locking mechanism

## Quick Start

### Option 1: Local Development (LocalStack)

```bash
# Navigate to the example directory
cd module-01/terraform/examples/remote-state

# Start LocalStack (from module-01/aws/localstack)
docker compose -f ../../../aws/localstack/docker-compose.yml up -d

# Wait for LocalStack to be ready
curl http://localhost:4566/_localstack/health

# Create a terraform.tfvars file with LocalStack configuration
cat > terraform.tfvars << EOF
use_localstack        = true
project_name          = "mlops-training"
environment           = "local"
aws_region            = "us-east-1"
localstack_endpoint   = "http://localhost:4566"
localstack_aws_region = "us-east-1"
EOF

# Initialize Terraform (uses local state)
terraform init

# Plan and apply
terraform plan
terraform apply
```

**Note:** When using LocalStack, Terraform state is stored locally in `terraform.tfstate`. Remote state configuration is commented out since LocalStack S3 backend has limited support.

### Option 2: AWS Cloud

#### Step 1: Create State Bucket

First, create an S3 bucket to store your Terraform state:

```bash
# Create a unique S3 bucket for Terraform state
# Replace YOUR-NAME with your name or identifier
aws s3api create-bucket \
  --bucket terraform-state-YOUR-NAME-$(date +%s) \
  --region us-east-1

# Note your bucket name for the next step
```

#### Step 2: Enable Versioning and Encryption

```bash
# Replace YOUR-BUCKET-NAME with the bucket name from step 1
BUCKET="terraform-state-YOUR-NAME-1234567890"

# Enable versioning (for state recovery)
aws s3api put-bucket-versioning \
  --bucket $BUCKET \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket $BUCKET \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET \
  --public-access-block-configuration '{
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }'
```

#### Step 3: Configure Backend

Edit `main.tf` and uncomment the backend block:

```hcl
backend "s3" {
  bucket         = "terraform-state-YOUR-BUCKET-NAME"  # Your bucket name
  key            = "mlops-training/remote-state/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  use_lockfile   = true
}
```

#### Step 4: Initialize and Apply

```bash
# Navigate to the example directory
cd module-01/terraform/examples/remote-state

# Create terraform.tfvars for AWS
cat > terraform.tfvars << EOF
project_name = "mlops-training"
environment  = "dev"
aws_region   = "us-east-1"
EOF

# Initialize Terraform (configures the backend)
terraform init

# Review the plan
terraform plan

# Apply changes
terraform apply
```

## Configuration Files

| File | Purpose |
|------|---------|
| `main.tf` | Backend configuration + example resources |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output value definitions |
| `terraform.tfvars.example` | Template for configuration |

## Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-YOUR-BUCKET-NAME"
    key            = "mlops-training/remote-state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}
```

### Backend Options

| Option | Description | Required |
|--------|-------------|----------|
| `bucket` | S3 bucket name | Yes |
| `key` | State file path | Yes |
| `region` | AWS region | Yes |
| `encrypt` | Enable encryption | Recommended |
| `use_lockfile` | Use modern lock file | Recommended (Terraform 1.14+) |

## LocalStack vs AWS

| Feature | LocalStack | AWS |
|---------|-----------|-----|
| **State Storage** | Local (`terraform.tfstate`) | S3 backend |
| **Locking** | File-based | S3 Object Lock |
| **Use Case** | Development/Testing | Production |
| **Cost** | Free | S3 charges apply |

## State Management Commands

```bash
# View state
terraform show

# List resources in state
terraform state list

# Refresh state (query actual infrastructure)
terraform refresh

# Pull state from backend
terraform state pull

# Push state to backend (use carefully)
terraform state push

# View state backend configuration
terraform show | grep -A 10 "backend"
```

## How S3 Locking Works

```
+----------------------------------------------------------------+
|                    S3 Remote State with Locking               |
+----------------------------------------------------------------+
|                                                                |
|  terraform apply --> +--------------+                         |
|                      | Terraform    |                         |
|                      +--------------+                         |
|                             |                                 |
|                             v                                 |
|  +-----------------------------------------------------+       |
|  |  S3 Backend                                          |       |
|  |  +---------------------------+                      |       |
|  |  | State File                | <--- Lock/Unlock    |       |
|  |  | terraform.tfstate        |       (via API)      |       |
|  |  +---------------------------+                      |       |
|  |  +---------------------------+                      |       |
|  |  | State Lock (Object Lock)  |                      |       |
|  |  | .tfstate.lock             |                      |       |
|  |  +---------------------------+                      |       |
|  +-----------------------------------------------------+       |
|                             |                                 |
|                             v                                 |
|  +-----------------------------------------------------+       |
|  |  Features:                                          |       |
|  |  - Versioning (history)                              |       |
|  |  - Encryption (AES256)                               |       |
|  |  - Object Lock (no DynamoDB needed)                  |       |
|  +-----------------------------------------------------+       |
+----------------------------------------------------------------+
```

## State Locking Behavior

| Scenario | Behavior |
|----------|----------|
| **First apply** | Creates lock, applies changes, releases lock |
| **Concurrent apply** | Second run waits for lock |
| **Force unlock** | `terraform force-unlock <LOCK_ID>` (use carefully) |
| **Stale lock** | Locks expire after a timeout |

## Security Best Practices

1. **Enable encryption** - Use `encrypt = true`
2. **Block public access** - Prevent accidental exposure
3. **Enable versioning** - For state recovery
4. **Use IAM roles** - For cross-account access
5. **Limit bucket access** - Use bucket policies

## Cleanup

### LocalStack

```bash
# Destroy all resources
terraform destroy

# Stop LocalStack
docker compose -f ../../../aws/localstack/docker-compose.yml down -v

# Remove local state files
rm terraform.tfstate terraform.tfstate.backup
```

### AWS

```bash
# Destroy all resources
terraform destroy

# Delete the state bucket (optional)
# Replace YOUR-BUCKET-NAME with your bucket name
aws s3 rb s3://terraform-state-YOUR-BUCKET-NAME --force
```

## Troubleshooting

### Lock Already Held

```bash
# View lock info
terraform force-unlock <LOCK_ID> --help

# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>
```

### State Mismatch

```bash
# Refresh state from actual infrastructure
terraform refresh

# Reconcile state manually if needed
terraform state rm <resource>
terraform import <resource> <resource-id>
```

### Backend Configuration Change

```bash
# Re-initialize when backend config changes
terraform init -reconfigure

# Migrate state to new backend
terraform init -migrate-state
```

### LocalStack Issues

```bash
# Verify LocalStack is running
curl http://localhost:4566/_localstack/health

# Restart LocalStack
docker compose -f ../../../aws/localstack/docker-compose.yml restart

# View LocalStack logs
docker compose -f ../../../aws/localstack/docker-compose.yml logs -f
```

## Next Steps

- Explore other examples in the parent directory
- Learn about [Terraform workspaces](https://www.terraform.io/docs/cloud/workspaces.html)
- Implement [CI/CD with Terraform](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
