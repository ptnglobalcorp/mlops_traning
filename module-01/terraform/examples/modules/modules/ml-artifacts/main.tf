# =============================================================================
# ML Artifacts Module
# =============================================================================
# This module creates an S3 bucket for ML pipeline artifacts including
# logs, metrics, and intermediate results with short retention.
# =============================================================================

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.project_name}-${var.environment}-${var.bucket_prefix}-${random_string.suffix.result}-"

  tags = {
    Purpose = "ml-artifacts"
  }
}

resource "aws_s3_bucket_versioning" "artifacts" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_type
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "artifacts-lifecycle"
    status = "Enabled"

    expiration {
      days = var.artifact_retention_days
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
