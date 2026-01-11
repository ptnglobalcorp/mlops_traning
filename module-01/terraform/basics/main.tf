# =============================================================================
# Locals - Reusable values within this configuration
# =============================================================================

locals {
  # Naming convention for consistency
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags for resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# =============================================================================
# Data Sources - Query existing AWS resources
# =============================================================================

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# =============================================================================
# Random Resources - Generate unique identifiers
# =============================================================================

resource "random_string" "unique_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# S3 Bucket for ML Models
# =============================================================================

resource "aws_s3_bucket" "models" {
  bucket_prefix = "${local.name_prefix}-ml-models-${random_string.unique_suffix.result}-"

  tags = merge(local.common_tags, {
    Purpose = "ml-model-storage"
  })
}

# Bucket policy to allow all access (for lab/learning purposes only)
resource "aws_s3_bucket_policy" "models_allow_all" {
  bucket = aws_s3_bucket.models.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAllAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:*"]
        Resource  = [
          aws_s3_bucket.models.arn,
          "${aws_s3_bucket.models.arn}/*"
        ]
      }
    ]
  })
}
