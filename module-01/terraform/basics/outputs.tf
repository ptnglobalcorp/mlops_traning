# =============================================================================
# General Information
# =============================================================================

output "account_id" {
  description = "AWS Account ID where resources were created"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region where resources were created"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# =============================================================================
# S3 Bucket
# =============================================================================

output "bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.models.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket created"
  value       = aws_s3_bucket.models.arn
}

# =============================================================================
# Quick Start Commands
# =============================================================================

output "quick_start_commands" {
  description = "Useful commands for getting started"
  value = {
    list_bucket   = "aws s3 ls s3://${aws_s3_bucket.models.id}"
    upload_file   = "aws s3 cp ./myfile.txt s3://${aws_s3_bucket.models.id}/"
    create_folder = "aws s3api put-object --bucket ${aws_s3_bucket.models.id} --key models/"
  }
}
