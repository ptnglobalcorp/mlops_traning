# =============================================================================
# Outputs for ML Model Storage Module
# =============================================================================

output "bucket_name" {
  description = "Name of the ML models S3 bucket"
  value       = aws_s3_bucket.models.id
}

output "bucket_arn" {
  description = "ARN of the ML models S3 bucket"
  value       = aws_s3_bucket.models.arn
}

output "versioning_status" {
  description = "Versioning status of the bucket"
  value = var.enable_versioning ? (
    aws_s3_bucket_versioning.models[0].versioning_configuration[0].status
  ) : "Disabled"
}
