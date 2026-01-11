# =============================================================================
# Conditionals Example
# =============================================================================
# This example demonstrates various conditional patterns in Terraform:
# - Ternary operators for value selection
# - count meta-argument for conditional resource creation
# - for_each with conditional logic
# - Dynamic blocks with conditionals
# - Variable validation with conditionals
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
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# =============================================================================
# Locals - Demonstrating Conditional Expressions
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Ternary operator: value ? true_value : false_value
  is_production = var.environment == "prod"

  # Conditional based on environment
  instance_type = var.environment == "prod" ? "t3.xlarge" : "t3.medium"

  # Nested conditional for ML model size
  model_size_gb = var.model_type == "tensorflow" ? 500 : (
    var.model_type == "pytorch" ? 500 : 10
  )

  # Conditional tags
  additional_tags = var.environment == "prod" ? {
    ComplianceLevel = "high"
    DataClassification = "confidential"
  } : {
    ComplianceLevel = "basic"
    DataClassification = "internal"
  }

  # Merge common tags with conditional additional tags
  all_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    local.additional_tags
  )
}

# =============================================================================
# Conditional Resource Creation with count
# =============================================================================

# S3 Bucket for models - Always created
resource "aws_s3_bucket" "models" {
  bucket_prefix = "${local.name_prefix}-ml-models-"

  tags = local.all_tags
}

# Versioning - Only in production
resource "aws_s3_bucket_versioning" "models" {
  # count = 0 skips resource creation, count = 1 creates it
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rules - Conditional based on environment
resource "aws_s3_bucket_lifecycle_configuration" "models" {
  count  = var.environment == "prod" ? 1 : 0
  bucket = aws_s3_bucket.models.id

  rule {
    id     = "production-lifecycle"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

# =============================================================================
# Conditional with for_each
# =============================================================================

# Create S3 buckets for different ML model types
# Uses a map with conditional filtering
locals {
  model_types = {
    sklearn = {
      size_gb  = 10
      create   = true
    }
    tensorflow = {
      size_gb  = 500
      create   = var.environment == "prod"
    }
    pytorch = {
      size_gb  = 500
      create   = var.environment == "prod"
    }
  }
}

# Filter the map to only include items where create = true
resource "aws_s3_bucket" "model_type_buckets" {
  # for_each only creates resources for enabled model types
  for_each = {
    for k, v in local.model_types : k => v
    if v.create == true
  }

  bucket_prefix = "${local.name_prefix}-models-${each.key}-"

  tags = merge(local.all_tags, {
    ModelType = each.key
  })
}

# =============================================================================
# Dynamic Blocks with Conditionals
# =============================================================================

resource "aws_security_group" "ml_training" {
  name_prefix = "${local.name_prefix}-ml-training-"
  description = "Security group for ML training instances"

  # Dynamic ingress rules based on environment
  dynamic "ingress" {
    # Only create production-restricted rules in prod
    for_each = var.environment == "prod" ? [
      {
        port        = 22
        description = "SSH from VPN only"
        cidr        = var.vpn_cidr
      }
    ] : []

    content {
      description = ingress.value.description
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  # Always allow HTTPS
  ingress {
    description = "HTTPS API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.environment == "prod" ? var.vpc_cidr : ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.all_tags

  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# Conditional IAM Policy
# =============================================================================

resource "aws_iam_role" "ml_pipeline" {
  name = "${local.name_prefix}-ml-pipeline"

  # Conditional assume role policy based on use case
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = var.enable_oidc ? {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${var.oidc_provider_id}"
        } : {
          Service = ["lambda.amazonaws.com", "sagemaker.amazonaws.com"]
        }
      }
    ]
  })

  tags = local.all_tags
}

# =============================================================================
# Conditional Notification Setup
# =============================================================================

# SNS Topic for notifications
resource "aws_sns_topic" "ml_notifications" {
  name = "${local.name_prefix}-ml-notifications"

  tags = local.all_tags
}

# Email subscription - Only if email is provided
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.ml_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# =============================================================================
# Conditional Data Source Query
# =============================================================================

# Only query VPC data if using existing VPC
data "aws_vpc" "existing" {
  count  = var.use_existing_vpc ? 1 : 0
  vpc_id = var.vpc_id
}

data "aws_subnets" "existing" {
  count  = var.use_existing_vpc ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.use_existing_vpc ? data.aws_vpc.existing[0].id : ""]
  }
}

# =============================================================================
# Conditional based on account ID
# =============================================================================

locals {
  # Get current account info
  current_account_id = data.aws_caller_identity.current.account_id

  # Check if this is the production account
  is_production_account = contains(var.production_account_ids, local.current_account_id)

  # Set compliance level based on account
  compliance_level = local.is_production_account ? "strict" : "standard"

  # Set additional safeguards for production
  enable_safeguards = local.is_production_account ? true : false
}

# Data source for caller identity
data "aws_caller_identity" "current" {}

# =============================================================================
# Conditional Resource Locking
# =============================================================================

resource "aws_s3_bucket" "critical_models" {
  # Only create in non-production (for safety)
  count = local.is_production_account ? 0 : 1

  bucket_prefix = "${local.name_prefix}-critical-models-"

  # Prevent accidental deletion in production
  lifecycle {
    prevent_destroy = local.enable_safeguards
  }

  tags = merge(local.all_tags, {
    Sensitivity = "critical"
  })
}

# =============================================================================
# Output Values with Conditionals
# =============================================================================

output "instance_config" {
  description = "Instance configuration based on environment"
  value = {
    type        = local.instance_type
    is_production = local.is_production
    compliance   = local.compliance_level
  }
}

output "vpc_info" {
  description = "VPC information (only if using existing VPC)"
  value = var.use_existing_vpc ? {
    vpc_id   = data.aws_vpc.existing[0].id
    subnet_ids = data.aws_subnets.existing[0].ids
  } : null
}

output "notification_status" {
  description = "Notification status"
  value = var.notification_email != "" ? {
    enabled = true
    topic   = aws_sns_topic.ml_notifications.arn
  } : {
    enabled = false
    topic   = null
  }
}
