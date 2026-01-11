# =============================================================================
# ML Training Data Module
# =============================================================================
# This module creates an S3 bucket for training datasets with
# intelligent tiering and data retention policies.
# =============================================================================

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "training_data" {
  bucket_prefix = "${var.project_name}-${var.environment}-${var.bucket_prefix}-${random_string.suffix.result}-"

  tags = {
    Purpose = "ml-training-data"
  }
}

resource "aws_s3_bucket_versioning" "training_data" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.training_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "training_data" {
  bucket = aws_s3_bucket.training_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_type
    }
  }
}

resource "aws_s3_bucket_public_access_block" "training_data" {
  bucket = aws_s3_bucket.training_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "training_data" {
  bucket = aws_s3_bucket.training_data.id

  rule {
    id     = "training-data-lifecycle"
    status = "Enabled"

    # Intelligent Tiering for cost optimization
    transition {
      days          = var.data_retention_days
      storage_class = var.enable_intelligent_tiering ? "INTELLIGENT_TIERING" : "GLACIER"
    }

    expiration {
      days = var.data_retention_days * 2
    }
  }
}
