# =============================================================================
# Variables for ML Artifacts Module
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
  description = "Enable S3 versioning"
  type        = bool
  default     = false
}

variable "artifact_retention_days" {
  description = "Days to retain artifacts"
  type        = number
  default     = 30
}

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}
