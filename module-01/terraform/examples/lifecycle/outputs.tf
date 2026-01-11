# =============================================================================
# Output Values for Lifecycle Example
# =============================================================================

output "security_group_lifecycle" {
  description = "Security group with create_before_destroy"
  value = {
    id          = aws_security_group.ml_inference.id
    name        = aws_security_group.ml_inference.name
    description = aws_security_group.ml_inference.description
  }
}

output "production_models_protection" {
  description = "Production models bucket status"
  value = var.environment == "prod" ? {
    bucket_name       = aws_s3_bucket.production_models[0].id
    prevent_destroy   = true
    protected         = true
    warning           = "This bucket is protected from accidental deletion"
  } : {
    bucket_name     = null
    prevent_destroy = false
    protected       = false
    warning         = "Not in production environment"
  }
}

output "artifacts_ignore_changes" {
  description = "Artifacts bucket with ignored tag changes"
  value = {
    bucket_name           = aws_s3_bucket.ml_artifacts.id
    ignored_changes       = ["tags"]
    behavior              = "Tag changes by ML pipeline are ignored"
  }
}

output "model_cache_replacement" {
  description = "Model cache bucket that replaces on config change"
  value = {
    bucket_name          = aws_s3_bucket.model_cache.id
    replace_triggered_by = "Model configuration changes"
  }
}

output "model_version_storage" {
  description = "Model version storage that replaces on version change"
  value = {
    bucket_name     = aws_s3_bucket.model_version_storage.id
    model_version   = var.model_version
    behavior        = "Bucket replaced when model_version variable changes"
  }
}

output "critical_storage_rules" {
  description = "Critical storage with combined lifecycle rules"
  value = var.enable_critical_storage ? {
    bucket_name         = aws_s3_bucket.critical_ml_data[0].id
    prevent_destroy     = true
    ignore_changes      = ["tags"]
    create_before_destroy = true
    rules                = ["Protected from deletion", "Ignores external tag changes", "Creates before destroys"]
  } : {
    enabled = false
    message = "Critical storage not enabled"
  }
}

output "lifecycle_summary" {
  description = "Summary of all lifecycle rules in this configuration"
  value = {
    create_before_destroy_resources = [
      aws_security_group.ml_inference.name,
      aws_iam_role.lambda_execution.name,
      var.enable_critical_storage ? aws_s3_bucket.critical_ml_data[0].id : null
    ]

    prevent_destroy_resources = var.environment == "prod" ? [
      aws_s3_bucket.production_models[0].id
    ] : []

    ignore_changes_resources = [
      aws_s3_bucket.ml_artifacts.id,
      aws_autoscaling_group.ml_training.name
    ]

    replace_triggered_resources = [
      aws_s3_bucket.model_version_storage.id
    ]
  }
}

# Get caller identity for display
data "aws_caller_identity" "current" {}
