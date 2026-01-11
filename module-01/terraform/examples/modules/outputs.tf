# =============================================================================
# Output Values for Modules Example
# =============================================================================

# =============================================================================
# Module Outputs
# =============================================================================
# Modules can define outputs that are exposed to the root configuration.
# These outputs are accessed using: module.MODULE_NAME.OUTPUT_NAME
# =============================================================================

output "models_bucket" {
  description = "ML Models storage bucket information"
  value = {
    name       = module.ml_models_storage.bucket_name
    arn        = module.ml_models_storage.bucket_arn
    versioning = module.ml_models_storage.versioning_status
  }
}

output "training_data_bucket" {
  description = "Training Data storage bucket information"
  value = {
    name = module.ml_training_data.bucket_name
    arn  = module.ml_training_data.bucket_arn
  }
}

output "artifacts_bucket" {
  description = "ML Artifacts storage bucket information"
  value = {
    name = module.ml_artifacts.bucket_name
    arn  = module.ml_artifacts.bucket_arn
  }
}

# =============================================================================
# Combined Outputs
# =============================================================================

output "all_buckets" {
  description = "All ML storage buckets"
  value = {
    models        = module.ml_models_storage.bucket_name
    training_data = module.ml_training_data.bucket_name
    artifacts     = module.ml_artifacts.bucket_name
  }
}
