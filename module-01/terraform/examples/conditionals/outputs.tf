# =============================================================================
# Output Values for Conditionals Example
# =============================================================================

output "environment_config" {
  description = "Environment-specific configuration"
  value = {
    name                = var.environment
    is_production       = var.environment == "prod"
    instance_type       = var.environment == "prod" ? "t3.xlarge" : "t3.medium"
    model_size_gb       = var.model_type == "tensorflow" ? 500 : 10
    enable_versioning   = var.enable_versioning
    compliance_level    = var.environment == "prod" ? "strict" : "standard"
  }
}

output "models_bucket" {
  description = "Models S3 bucket (always created)"
  value = {
    name       = aws_s3_bucket.models[0].id
    versioning = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

output "model_type_buckets" {
  description = "Model type-specific buckets created"
  value = {
    for k, v in aws_s3_bucket.model_type_buckets : k => v.id
  }
}

output "notification_setup" {
  description = "Notification configuration"
  value = var.notification_email != "" ? {
    enabled    = true
    email      = var.notification_email
    topic_arn  = aws_sns_topic.ml_notifications.arn
    subscribed = length(aws_sns_topic_subscription.email_alerts) > 0
  } : {
    enabled    = false
    email      = null
    topic_arn   = aws_sns_topic.ml_notifications.arn
    subscribed = false
  }
}

output "security_group" {
  description = "Security group configuration"
  value = {
    id           = aws_security_group.ml_training.id
    name         = aws_security_group.ml_training.name
    ingress_rules = var.environment == "prod" ? "VPN-only SSH + HTTPS" : "HTTPS only"
  }
}

output "iam_role_config" {
  description = "IAM role configuration"
  value = {
    name       = aws_iam_role.ml_pipeline.name
    arn        = aws_iam_role.ml_pipeline.arn
    auth_type  = var.enable_oidc ? "OIDC" : "Service-based"
  }
}
