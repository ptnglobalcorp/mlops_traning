# =============================================================================
# Variables for Conditionals Example
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "mlops-training"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "aws_region" {
  description = "AWS region for deploying resources"
  type        = string
  default     = "us-east-1"
}

variable "model_type" {
  description = "ML model type (affects storage size)"
  type        = string
  default     = "sklearn"

  validation {
    condition     = contains(["sklearn", "tensorflow", "pytorch"], var.model_type)
    error_message = "Model type must be sklearn, tensorflow, or pytorch."
  }
}

variable "enable_versioning" {
  description = "Enable S3 versioning for model storage"
  type        = bool
  default     = true
}

variable "vpn_cidr" {
  description = "VPN CIDR block for production SSH access"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr" {
  description = "VPC CIDR block for production access"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

variable "enable_oidc" {
  description = "Enable OIDC for IAM role"
  type        = bool
  default     = false
}

variable "oidc_provider_id" {
  description = "OIDC provider ID (required if enable_oidc is true)"
  type        = string
  default     = ""
}

variable "notification_email" {
  description = "Email for SNS notifications (empty to disable)"
  type        = string
  default     = ""
}

variable "use_existing_vpc" {
  description = "Use existing VPC instead of creating new resources"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "Existing VPC ID (required if use_existing_vpc is true)"
  type        = string
  default     = ""
}

variable "production_account_ids" {
  description = "List of AWS account IDs considered production"
  type        = list(string)
  default     = []
}
