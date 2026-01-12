# =============================================================================
# Output Values for Remote State Example
# =============================================================================

output "account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}

output "bucket_name" {
  description = "Name of the example S3 bucket"
  value       = aws_s3_bucket.example.id
}

output "bucket_arn" {
  description = "ARN of the example S3 bucket"
  value       = aws_s3_bucket.example.arn
}

# =============================================================================
# Remote State Information
# =============================================================================

output "state_backend" {
  description = "Information about the remote state backend"
  value = {
    backend = var.use_localstack ? "local" : "s3"
    key     = "mlops-training/remote-state/terraform.tfstate"
    region  = data.aws_region.current.name
  }
}
