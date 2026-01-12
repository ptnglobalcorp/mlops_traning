# =============================================================================
# Outputs for ML Artifacts Module
# =============================================================================

output "bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.id
}

output "bucket_arn" {
  description = "ARN of the artifacts S3 bucket"
  value       = aws_s3_bucket.artifacts.arn
}
