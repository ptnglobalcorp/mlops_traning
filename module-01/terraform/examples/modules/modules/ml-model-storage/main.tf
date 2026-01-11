# =============================================================================
# ML Model Storage Module
# =============================================================================
# This module creates a complete S3 bucket setup for storing ML models
# with versioning, encryption, lifecycle policies, and security.
# =============================================================================

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "models" {
  bucket_prefix = "${var.project_name}-${var.environment}-${var.bucket_prefix}-${random_string.suffix.result}-"

  tags = {
    Purpose = "ml-model-storage"
  }
}

resource "aws_s3_bucket_versioning" "models" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.models.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "models" {
  bucket = aws_s3_bucket.models.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_type
    }
  }
}

resource "aws_s3_bucket_public_access_block" "models" {
  bucket = aws_s3_bucket.models.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "models" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.models.id

  rule {
    id     = "ml-model-lifecycle"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_expiration_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
