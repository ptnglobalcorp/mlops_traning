# =============================================================================
# Outputs for ML Training Data Module
# =============================================================================

output "bucket_name" {
  description = "Name of the training data S3 bucket"
  value       = aws_s3_bucket.training_data.id
}

output "bucket_arn" {
  description = "ARN of the training data S3 bucket"
  value       = aws_s3_bucket.training_data.arn
}
