# =============================================================================
# Terraform Locals Example
# This example demonstrates how to use local values for DRY (Don't Repeat Yourself)
# code, complex expressions, and reusable values within a module
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
  region = "us-east-1"
}

# =============================================================================
# Input Variables
# =============================================================================

variable "project_name" {
  description = "Base project name"
  type        = string
  default     = "ml-platform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Resource owner"
  type        = string
  default     = "mlops-team"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# Example 1: Simple Locals for Reusability
# =============================================================================

locals {
  # Naming convention helper
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

output "name_prefix" {
  description = "Consistent name prefix for all resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Standard tags applied to all resources"
  value       = local.common_tags
}

# =============================================================================
# Example 2: Computed Locals from Variables
# =============================================================================

locals {
  # Compute bucket names based on environment
  models_bucket_name      = "${local.name_prefix}-ml-models"
  data_bucket_name        = "${local.name_prefix}-training-data"
  artifacts_bucket_name   = "${local.name_prefix}-artifacts"
  logs_bucket_name        = "${local.name_prefix}-logs"

  # List of all bucket names
  all_bucket_names = [
    local.models_bucket_name,
    local.data_bucket_name,
    local.artifacts_bucket_name,
    local.logs_bucket_name
  ]
}

output "bucket_names" {
  description = "Computed bucket names"
  value = {
    models    = local.models_bucket_name
    data      = local.data_bucket_name
    artifacts = local.artifacts_bucket_name
    logs      = local.logs_bucket_name
  }
}

output "all_bucket_names" {
  description = "List of all bucket names"
  value       = local.all_bucket_names
}

# =============================================================================
# Example 3: Conditional Locals
# =============================================================================

variable "production" {
  description = "Whether this is a production environment"
  type        = bool
  default     = false
}

locals {
  # Conditional values based on environment
  instance_count = var.production ? 3 : 1
  instance_type  = var.production ? "t3.xlarge" : "t3.medium"

  # Multi-tier conditional
  log_retention_days = var.production ? 365 : var.environment == "staging" ? 90 : 30

  # Nested conditional for encryption
  encryption_type = var.production ? "aws:kms" : "AES256"
}

output "computed_instance_config" {
  description = "Instance configuration based on environment"
  value = {
    count = local.instance_count
    type  = local.instance_type
  }
}

output "computed_encryption" {
  description = "Encryption based on production status"
  value = {
    type           = local.encryption_type
    log_retention  = local.log_retention_days
  }
}

# =============================================================================
# Example 4: Complex Locals with Functions
# =============================================================================

locals {
  # Transform and map data
  model_types = ["sklearn", "tensorflow", "pytorch", "xgboost"]

  # Create a map from a list
  model_sizes = {
    for type in local.model_types : type => (
      type == "tensorflow" || type == "pytorch" ? "large" : "small"
    )
  }

  # Filter and transform
  large_models = [
    for type, size in local.model_sizes : type
    if size == "large"
  ]

  # Merge multiple tags
  ml_specific_tags = {
    DataClassification = var.production ? "confidential" : "internal"
    ComplianceLevel    = var.production ? "hipaa" : "none"
    ModelTypes         = join(",", local.model_types)
  }

  # Combine all tags
  all_tags = merge(local.common_tags, local.ml_specific_tags)
}

output "model_sizes" {
  description = "Model type to size mapping"
  value       = local.model_sizes
}

output "large_models" {
  description = "List of large model types"
  value       = local.large_models
}

output "all_tags" {
  description = "Combined tags from multiple sources"
  value       = local.all_tags
}

# =============================================================================
# Example 5: Locals for Resource Configuration
# =============================================================================

locals {
  # S3 lifecycle configuration
  lifecycle_rules = {
    models = {
      id                                   = "model-version-lifecycle"
      enabled                              = true
      noncurrent_version_transition_days    = 30
      noncurrent_version_glacier_days       = 90
      noncurrent_version_expiration_days    = 365
    }
    data = {
      id                                   = "data-lifecycle"
      enabled                              = true
      transition_days                      = 30
      glacier_days                         = 90
      expiration_days                      = 365
    }
    logs = {
      id                                   = "log-lifecycle"
      enabled                              = true
      expiration_days                      = var.production ? 90 : 30
    }
  }

  # Security group rules
  ingress_rules = [
    {
      description = "SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.production ? ["10.0.0.0/8"] : ["0.0.0.0/0"]
    },
    {
      description = "HTTPS API"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "ML API endpoint"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

output "models_lifecycle" {
  description = "Lifecycle configuration for models bucket"
  value       = local.lifecycle_rules.models
}

output "security_ingress_rules" {
  description = "Ingress rules configuration"
  value       = local.ingress_rules
}

# =============================================================================
# Example 6: Locals with Regex and String Manipulation
# =============================================================================

variable "raw_bucket_names" {
  description = "Raw bucket names that need normalization"
  type        = list(string)
  default     = ["My-ML-Bucket", "Training_Data", "Model-Artifacts"]
}

locals {
  # Normalize bucket names (lowercase, replace underscores with hyphens)
  normalized_bucket_names = [
    for name in var.raw_bucket_names : lower(replace(name, "_", "-"))
  ]

  # Extract parts from strings
  project_parts = regex("^(?P<project>.+)-(?P<env>.+)-(?P<component>.+)$", "${var.project_name}-${var.environment}-models")

  # Build resource names with pattern
  resource_names = {
    for type in local.model_types : "${local.name_prefix}-${type}-bucket"
  }
}

output "normalized_bucket_names" {
  description = "Normalized bucket names"
  value       = local.normalized_bucket_names
}

output "regex_captured_groups" {
  description = "Captured groups from regex"
  value = {
    project   = try(local.project_parts.project, "")
    env       = try(local.project_parts.env, "")
    component = try(local.project_parts.component, "")
  }
}

output "pattern_based_names" {
  description = "Resource names created with pattern"
  value       = local.resource_names
}

# =============================================================================
# Example 7: Locals for Environment-Specific Configuration
# =============================================================================

locals {
  # Environment-specific settings
  environment_config = {
    dev = {
      instance_count          = 1
      instance_type           = "t3.medium"
      enable_monitoring       = false
      log_retention_days      = 7
      backup_retention_days   = 7
      min_instances           = 1
      max_instances           = 2
    }
    staging = {
      instance_count          = 2
      instance_type           = "t3.large"
      enable_monitoring       = true
      log_retention_days      = 30
      backup_retention_days   = 30
      min_instances           = 2
      max_instances           = 4
    }
    prod = {
      instance_count          = 3
      instance_type           = "t3.xlarge"
      enable_monitoring       = true
      log_retention_days      = 365
      backup_retention_days   = 90
      min_instances           = 3
      max_instances           = 10
    }
  }

  # Get current environment config (with fallback)
  config = try(
    local.environment_config[var.environment],
    local.environment_config["dev"]
  )

  # Auto-scaling configuration
  autoscaling = {
    min_size = local.config.min_instances
    max_size = local.config.max_instances
    desired_capacity = local.config.instance_count
  }
}

output "current_environment_config" {
  description = "Configuration for current environment"
  value       = local.config
}

output "autoscaling_config" {
  description = "Auto-scaling configuration derived from environment"
  value       = local.autoscaling
}

# =============================================================================
# Example 8: Using Locals in Resources
# =============================================================================

resource "aws_s3_bucket" "example" {
  # Using local for bucket name
  bucket = local.models_bucket_name

  # Using local for tags
  tags = local.all_tags

  # Using lifecycle config from locals
  lifecycle {
    prevent_destroy = var.production
  }
}

output "example_bucket_name" {
  description = "Bucket created using locals"
  value       = aws_s3_bucket.example.bucket
}

output "example_bucket_tags" {
  description = "Tags applied from locals"
  value       = aws_s3_bucket.example.tags
}

# =============================================================================
# Example 9: Local Values with Expressions
# =============================================================================

locals {
  # Mathematical expressions
  total_storage_gb = sum([
    100,  # models
    500,  # data
    50,   # artifacts
    10    # logs
  ])

  # Estimated monthly cost (simplified)
  estimated_monthly_cost = {
    s3_storage = local.total_storage_gb * 0.023  # $0.023 per GB
    ec2_compute = local.config.instance_count * (
      local.config.instance_type == "t3.medium" ? 20 :
      local.config.instance_type == "t3.large" ? 40 :
      local.config.instance_type == "t3.xlarge" ? 80 : 20
    )
  }

  # Total estimated cost
  total_monthly_cost = local.estimated_monthly_cost.s3_storage +
                       local.estimated_monthly_cost.ec2_compute
}

output "estimated_costs" {
  description = "Estimated monthly AWS costs"
  value = {
    s3_storage = local.estimated_monthly_cost.s3_storage
    ec2_compute = local.estimated_monthly_cost.ec2_compute
    total       = local.total_monthly_cost
  }
}

# =============================================================================
# Key Takeaways for Using Locals
# =============================================================================

output "locals_best_practices" {
  description = "Best practices for using locals"
  value = [
    "1. Use locals to DRY up your code - avoid repeating values",
    "2. Name locals descriptively to improve readability",
    "3. Use locals for complex computations and transformations",
    "4. Combine locals with merge() for flexible tag combinations",
    "5. Use conditionals in locals for environment-specific logic",
    "6. Keep locals simple and testable - break complex ones down",
    "7. Remember: locals are evaluated at load time, not apply time",
    "8. Use locals for naming conventions to ensure consistency"
  ]
}
