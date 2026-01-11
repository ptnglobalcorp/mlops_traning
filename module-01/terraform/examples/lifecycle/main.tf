# =============================================================================
# Lifecycle Example
# =============================================================================
# This example demonstrates Terraform lifecycle management for ML resources:
# - create_before_destroy - Zero-downtime updates
# - prevent_destroy - Protect critical resources
# - ignore_changes - Ignore specific parameter changes
# - replace_triggered_by - Force resource replacement
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
# Random Resource for Unique Naming
# =============================================================================

resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# 1. create_before_destroy - Zero Downtime Updates
# =============================================================================
# This pattern is critical for ML inference endpoints where you need
# to update resources without downtime. Terraform creates the new
# resource before destroying the old one.
# =============================================================================

resource "aws_security_group" "ml_inference" {
  name_prefix = "${var.project_name}-${var.environment}-ml-inference-"
  description = "Security group for ML inference endpoints"

  # Allow HTTPS traffic
  ingress {
    description = "HTTPS API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Purpose = "ml-inference"
  }

  # CRITICAL: Create new SG before destroying old one
  # This prevents temporary connection failures
  lifecycle {
    create_before_destroy = true
  }
}

# =============================================================================
# 2. prevent_destroy - Protect Critical ML Resources
# =============================================================================
# Production model storage should NEVER be accidentally destroyed.
# This lifecycle rule prevents terraform destroy from removing it.
# =============================================================================

resource "aws_s3_bucket" "production_models" {
  # Only create in production environment
  count = var.environment == "prod" ? 1 : 0

  bucket_prefix = "${var.project_name}-prod-models-${random_string.unique_suffix.result}-"

  tags = {
    Purpose        = "production-ml-models"
    DataClassification = "critical"
  }

  # CRITICAL: Prevent accidental deletion in production
  # To destroy, you must:
  # 1. Remove this lifecycle block from code
  # 2. Run terraform apply
  # 3. Then run terraform destroy
  lifecycle {
    prevent_destroy = true
  }
}

# =============================================================================
# 3. ignore_changes - Ignore Dynamic/Runtime Updates
# =============================================================================
# ML services often have tags or parameters that are updated dynamically
# by the ML pipeline. Use ignore_changes to prevent Terraform drift.
# =============================================================================

resource "aws_s3_bucket" "ml_artifacts" {
  bucket_prefix = "${var.project_name}-ml-artifacts-"

  tags = {
    Purpose = "ml-artifacts"
  }

  # Ignore changes to tags added by ML pipeline
  lifecycle {
    ignore_changes = [
      tags,
      # Ignore specific tag keys only
      # tags.LastModifiedBy,
      # tags.PipelineRunID,
    ]
  }
}

# Example: Ignore changes to autoscaling group desired capacity
# which is adjusted dynamically based on ML workload
resource "aws_autoscaling_group" "ml_training" {
  # ... autoscaling group configuration ...

  # Ignore changes made by the ML scaling service
  lifecycle {
    ignore_changes = [
      desired_capacity,
      # min_size,
      # max_size,
    ]
  }
}

# =============================================================================
# 4. replace_triggered_by - Force Resource Replacement
# =============================================================================
# Some ML resources need to be replaced when dependencies change.
# Use replace_triggered_by to force recreation.
# =============================================================================

# Random pet name for illustration
resource "random_pet" "model_config" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "model_cache" {
  bucket_prefix = "${var.project_name}-model-cache-${random_pet.model_config.id}-"

  tags = {
    Purpose = "model-cache"
  }
}

# When model version changes, replace the cache bucket
resource "aws_s3_bucket" "model_version_storage" {
  bucket_prefix = "${var.project_name}-models-v${var.model_version}-"

  tags = {
    ModelVersion = var.model_version
  }

  # Replace bucket when model version changes
  lifecycle {
    replace_triggered_by = [
      aws_s3_bucket.model_cache.id
    ]
  }
}

# =============================================================================
# 5. Combined Lifecycle Rules
# =============================================================================
# Resources can have multiple lifecycle rules
# =============================================================================

resource "aws_s3_bucket" "critical_ml_data" {
  count = var.enable_critical_storage ? 1 : 0

  bucket_prefix = "${var.project_name}-critical-ml-data-"

  tags = {
    Purpose = "critical-ml-data"
  }

  # Combine multiple lifecycle rules
  lifecycle {
    # Prevent accidental deletion
    prevent_destroy = true

    # Ignore tag changes from external systems
    ignore_changes = [tags]

    # Create before destroy for safe updates
    create_before_destroy = true
  }
}

# =============================================================================
# Practical ML Examples
# =============================================================================

# Example: ML Model Endpoint with Safe Updates
resource "aws_lambda_function" "ml_inference" {
  function_name = "${var.project_name}-ml-inference"
  role          = aws_iam_role.lambda_execution.arn
  handler       = "index.handler"
  runtime       = "python3.11"

  # Assume S3 bucket and filename are created elsewhere

  tags = {
    Environment = var.environment
    Purpose     = "ml-inference"
  }

  # Safe deployment: create new version before old one is removed
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Ignore last_modified tag set by deployment system
      tags["LastModified"],
      # Ignore version tag if using version aliases
      tags["Version"],
    ]
  }
}

# Example: ML Training Job Configuration
resource "aws_s3_bucket" "training_configs" {
  bucket_prefix = "${var.project_name}-training-configs-"

  tags = {
    Purpose = "training-configs"
  }

  lifecycle {
    # Replace bucket when training framework changes
    replace_triggered_by = [var.training_framework]

    # Ignore dynamic tags added by training pipeline
    ignore_changes = [tags]
  }
}

# =============================================================================
# IAM Role for Lambda
# =============================================================================

resource "aws_iam_role" "lambda_execution" {
  name = "${var.project_name}-lambda-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  lifecycle {
    # IAM roles have unique names, need create_before_destroy
    create_before_destroy = true
  }
}
