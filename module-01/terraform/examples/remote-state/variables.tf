# =============================================================================
# Variables for Remote State Example
# =============================================================================

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "mlops-training"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

# =============================================================================
# LocalStack Configuration
# =============================================================================

variable "use_localstack" {
  description = "Use LocalStack for local development instead of AWS"
  type        = bool
  default     = false
}

variable "localstack_endpoint" {
  description = "LocalStack endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}

variable "localstack_aws_region" {
  description = "AWS region to use with LocalStack"
  type        = string
  default     = "us-east-1"
}
