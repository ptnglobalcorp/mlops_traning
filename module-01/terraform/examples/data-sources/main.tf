# =============================================================================
# Terraform Data Sources Example
# This example demonstrates how to use data sources to query existing AWS resources
# =============================================================================

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# =============================================================================
# Example 1: Query AWS Account Information
# =============================================================================

data "aws_caller_identity" "current" {}

output "account_id" {
  description = "The AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "user_id" {
  description = "The AWS User ID"
  value       = data.aws_caller_identity.current.user_id
}

output "arn" {
  description = "The AWS ARN of the caller"
  value       = data.aws_caller_identity.current.arn
}

# =============================================================================
# Example 2: Query Current Region
# =============================================================================

data "aws_region" "current" {}

output "current_region" {
  description = "The current AWS region"
  value       = data.aws_region.current.name
}

output "current_region_description" {
  description = "The description of the current region"
  value       = data.aws_region.current.description
}

# =============================================================================
# Example 3: Get Available Availability Zones
# =============================================================================

data "aws_availability_zones" "available" {
  state = "available"

  # Filter by region (optional, for multi-region setups)
  # filter {
  #   name   = "region-name"
  #   values = ["us-east-1"]
  # }
}

output "available_azs" {
  description = "List of available availability zones"
  value       = data.aws_availability_zones.available.names
}

output "available_azs_count" {
  description = "Number of available availability zones"
  value       = data.aws_availability_zones.available.names
}

# =============================================================================
# Example 4: Find an Existing VPC by Tag
# =============================================================================

# Find a VPC with a specific tag
data "aws_vpc" "existing_by_tag" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]  # Change this to your VPC name
  }

  # If no VPC is found with the tag, this will fail
  # In production, you might want to handle this differently
}

output "found_vpc_id" {
  description = "The VPC ID found by tag"
  value       = try(data.aws_vpc.existing_by_tag.id, "No VPC found with tag 'main-vpc'")
}

output "found_vpc_cidr" {
  description = "The VPC CIDR block"
  value       = try(data.aws_vpc.existing_by_tag.cidr_block, "N/A")
}

# =============================================================================
# Example 5: Get the Latest Amazon Linux AMI
# =============================================================================

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2024.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "latest_ami_id" {
  description = "The latest Amazon Linux AMI ID"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "latest_ami_name" {
  description = "The latest Amazon Linux AMI name"
  value       = data.aws_ami.amazon_linux_2023.name
}

output "latest_ami_creation_date" {
  description = "The creation date of the AMI"
  value       = data.aws_ami.amazon_linux_2023.creation_date
}

# =============================================================================
# Example 6: Get Subnets by VPC and Tags
# =============================================================================

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [try(data.aws_vpc.existing_by_tag.id, "")]
  }

  tags = {
    Tier = "private"
  }
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = try(data.aws_subnets.private.ids, [])
}

# =============================================================================
# Example 7: Query EC2 Key Pairs
# =============================================================================

data "aws_key_pairs" "existing" {
  # You can filter by tags
  tags = {
    Environment = "dev"
  }
}

output "key_pair_names" {
  description = "List of key pair names"
  value       = data.aws_key_pairs.existing.key_names
}

# =============================================================================
# Example 8: Get S3 Bucket Information
# =============================================================================

# Get a specific S3 bucket by name
data "aws_s3_bucket" "existing_bucket" {
  bucket = "my-existing-bucket"  # Change this to your bucket name
}

output "bucket_location" {
  description = "The AWS region of the bucket"
  value       = try(data.aws_s3_bucket.existing_bucket.region, "N/A")
}

output "bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for the bucket"
  value       = try(data.aws_s3_bucket.existing_bucket.hosted_zone_id, "N/A")
}

# =============================================================================
# Example 9: Query IAM Information
# =============================================================================

# Get the current user's information
data "aws_iam_role" "terraform_role" {
  name = "TerraformRole"  # Change to your role name
}

output "role_arn" {
  description = "The ARN of the IAM role"
  value       = try(data.aws_iam_role.terraform_role.arn, "Role not found")
}

output "role_create_date" {
  description = "The creation date of the role"
  value       = try(data.aws_iam_role.terraform_role.create_date, "N/A")
}

# =============================================================================
# Example 10: Complex Data Source with Multiple Filters
# =============================================================================

# Find EC2 instances with specific tags and state
data "aws_instances" "running_ml_instances" {
  instance_tags = {
    Project     = "mlops-training"
    Environment = "dev"
  }

  # Filter by instance state
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

output "running_ml_instance_ids" {
  description = "IDs of running ML instances"
  value       = data.aws_instances.running_ml_instances.ids
}

output "running_ml_instance_private_ips" {
  description = "Private IPs of running ML instances"
  value       = data.aws_instances.running_ml_instances.private_ips
}
