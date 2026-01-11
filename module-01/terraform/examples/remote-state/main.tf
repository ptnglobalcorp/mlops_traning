# =============================================================================
# Terraform Remote State Backend Example
# =============================================================================

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 6.0"
    }
  }

  # =============================================================================
  # S3 Remote State Backend with Modern Locking
  # =============================================================================
  # For AWS: Uses S3 with native locking (no DynamoDB needed)
  # For LocalStack: Uses LocalStack S3 service
  #
  # To enable for AWS:
  # 1. Uncomment the backend block below
  # 2. Create the S3 bucket first (see README.md)
  # 3. Run: terraform init
  #
  # For LocalStack: State is stored locally by default
  # =============================================================================

  backend "s3" {
    # bucket         = "terraform-state-YOUR-UNIQUE-NAME"  # Replace with your bucket
    # key            = "mlops-training/remote-state/terraform.tfstate"
    # region         = "us-east-1"
    # encrypt        = true
    # use_lockfile   = true

    # Optional: For OIDC/GitHub Actions authentication
    # role_arn = "arn:aws:iam::ACCOUNT_ID:role/TerraformExecutionRole"
  }
}

# =============================================================================
# AWS Provider (supports both AWS and LocalStack)
# =============================================================================

provider "aws" {
  region = var.use_localstack ? var.localstack_aws_region : var.aws_region

  # LocalStack endpoint configuration
  endpoints = var.use_localstack ? {
    s3  = var.localstack_endpoint
    iam = var.localstack_endpoint
    sts = var.localstack_endpoint
  } : {}

  # Skip validations for LocalStack
  skip_credentials_api_check = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  # For LocalStack, use test credentials
  access_key = var.use_localstack ? "test" : null
  secret_key = var.use_localstack ? "test" : null

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# =============================================================================
# Locals - Reusable values
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# Data Sources - Query existing AWS resources
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# =============================================================================
# Random Resources - Generate unique identifiers
# =============================================================================

resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# Example S3 Bucket
# =============================================================================
# This is a simple S3 bucket to demonstrate remote state working.
# =============================================================================

resource "aws_s3_bucket" "example" {
  bucket_prefix = "${local.name_prefix}-example-${random_string.unique_suffix.result}-"

  tags = merge(local.common_tags, {
    Purpose = "remote-state-demo"
  })
}

# Enable versioning
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
