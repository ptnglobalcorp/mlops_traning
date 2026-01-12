# =============================================================================
# Provider Configuration
# This file contains provider configuration.
# =============================================================================

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

# =============================================================================
# AWS Provider
# =============================================================================

locals {
  localstack_endpoint = "http://localhost:4566"
}

provider "aws" {
  region = var.aws_region

  # LocalStack - all services point to the same endpoint
  endpoints {
    apigateway     = local.localstack_endpoint
    cloudformation = local.localstack_endpoint
    cloudwatch     = local.localstack_endpoint
    dynamodb       = local.localstack_endpoint
    ec2            = local.localstack_endpoint
    es             = local.localstack_endpoint
    events         = local.localstack_endpoint
    firehose       = local.localstack_endpoint
    iam            = local.localstack_endpoint
    kinesis        = local.localstack_endpoint
    kms            = local.localstack_endpoint
    lambda         = local.localstack_endpoint
    logs           = local.localstack_endpoint
    redshift       = local.localstack_endpoint
    route53        = local.localstack_endpoint
    s3             = local.localstack_endpoint
    secretsmanager = local.localstack_endpoint
    ses            = local.localstack_endpoint
    sns            = local.localstack_endpoint
    sqs            = local.localstack_endpoint
    ssm            = local.localstack_endpoint
    stepfunctions  = local.localstack_endpoint
    sts            = local.localstack_endpoint
  }

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Use path-style S3 requests for LocalStack compatibility
  s3_use_path_style           = true

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
