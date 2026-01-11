# =============================================================================
# Variables for Lifecycle Example
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mlops-training"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_critical_storage" {
  description = "Enable critical ML data storage with protection"
  type        = bool
  default     = false
}

variable "model_version" {
  description = "Current ML model version (triggers cache replacement)"
  type        = string
  default     = "v1.0"
}

variable "training_framework" {
  description = "ML training framework (triggers config bucket replacement)"
  type        = string
  default     = "tensorflow"

  validation {
    condition     = contains(["tensorflow", "pytorch", "sklearn"], var.training_framework)
    error_message = "Framework must be tensorflow, pytorch, or sklearn."
  }
}
