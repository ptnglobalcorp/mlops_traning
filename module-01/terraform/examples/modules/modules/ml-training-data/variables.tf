# =============================================================================
# Variables for ML Training Data Module
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
  default     = true
}

variable "data_retention_days" {
  description = "Days to retain training data before transition"
  type        = number
  default     = 90
}

variable "enable_intelligent_tiering" {
  description = "Enable S3 Intelligent Tiering"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
}
