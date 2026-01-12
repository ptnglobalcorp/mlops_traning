# =============================================================================
# Terraform Variables Example - Remote State Backend
# =============================================================================

# For AWS (default)
project_name = "mlops-training"
environment  = "dev"
aws_region   = "us-east-1"

# For LocalStack (set use_localstack = true)
use_localstack        = true
localstack_endpoint   = "http://localhost:4566"
localstack_aws_region = "us-east-1"
