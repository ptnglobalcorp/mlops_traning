# =============================================================================
# Modules Example - Root Configuration
# =============================================================================
# This example demonstrates how to use Terraform modules to create
# reusable infrastructure components for ML workloads.
#
# A module is a container for multiple resources that are used together.
# Modules help you:
# - Organize and reuse code
# - Abstract complexity
# - Enforce consistency across environments
# =============================================================================

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

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# =============================================================================
# Using the ML Model Storage Module
# =============================================================================
# This module creates a complete S3 bucket setup for ML models with:
# - Bucket with versioning
# - Server-side encryption
# - Lifecycle policies
# - Public access blocking
# =============================================================================

module "ml_models_storage" {
  source = "./modules/ml-model-storage"

  # Input variables for the module
  project_name = var.project_name
  environment  = var.environment

  # Module-specific configuration
  bucket_prefix = "ml-models"

  # Lifecycle configuration
  enable_versioning             = true
  enable_lifecycle_rules        = true
  noncurrent_version_transition_days = 30
  noncurrent_version_expiration_days = 365

  # Encryption
  encryption_type = "AES256"
}

# =============================================================================
# Using the ML Training Data Module
# =============================================================================
# This module creates a bucket for training datasets with different
# lifecycle policies optimized for data retention.
# =============================================================================

module "ml_training_data" {
  source = "./modules/ml-training-data"

  project_name = var.project_name
  environment  = var.environment

  bucket_prefix = "training-data"

  # Training data has different retention needs
  enable_versioning        = true
  data_retention_days      = 90
  enable_intelligent_tiering = true

  encryption_type = "AES256"
}

# =============================================================================
# Using the ML Artifacts Module
# =============================================================================
# This module creates storage for ML pipeline artifacts including
# logs, metrics, and intermediate results.
# =============================================================================

module "ml_artifacts" {
  source = "./modules/ml-artifacts"

  project_name = var.project_name
  environment  = var.environment

  bucket_prefix = "ml-artifacts"

  # Artifacts have short retention
  enable_versioning   = false
  artifact_retention_days = 30

  encryption_type = "AES256"
}
