# =============================================================================
# Variables for ML Model Storage Module
# =============================================================================

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the bucket name"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 versioning for model lineage"
  type        = bool
  default     = true
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "noncurrent_version_transition_days" {
  description = "Days before transitioning old versions to IA"
  type        = number
  default     = 30
}

variable "noncurrent_version_expiration_days" {
  description = "Days before expiring old model versions"
  type        = number
  default     = 365
}

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_type)
    error_message = "Must be AES256 or aws:kms."
  }
}
