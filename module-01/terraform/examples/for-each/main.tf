# =============================================================================
# Terraform for_each and count Examples
# This example demonstrates how to use for_each and count for creating
# multiple resources from a single resource block
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
# Example 1: Simple count for List Values
# =============================================================================

variable "model_types" {
  description = "List of ML model types"
  type        = list(string)
  default     = ["sklearn", "tensorflow", "pytorch"]
}

# Create an S3 bucket for each model type using count
resource "aws_s3_bucket" "model_buckets_count" {
  count  = length(var.model_types)
  bucket = "ml-models-${var.model_types[count.index]}-${count.index}"

  tags = {
    ModelType = var.model_types[count.index]
    Index     = count.index
  }
}

output "count_bucket_names" {
  description = "Bucket names created using count"
  value       = aws_s3_bucket.model_buckets_count[*].id
}

output "count_first_bucket" {
  description = "First bucket (using index 0)"
  value       = aws_s3_bucket.model_buckets_count[0].id
}

# =============================================================================
# Example 2: Using for_each with Map
# =============================================================================

variable "environments" {
  description = "Map of environment configurations"
  type = map(object({
    lifecycle_days = number
    encryption     = string
  }))
  default = {
    dev = {
      lifecycle_days = 30
      encryption     = "AES256"
    }
    staging = {
      lifecycle_days = 90
      encryption     = "AES256"
    }
    prod = {
      lifecycle_days = 365
      encryption     = "aws:kms"
    }
  }
}

# Create S3 buckets using for_each with a map
resource "aws_s3_bucket" "env_buckets" {
  for_each = var.environments

  bucket = "ml-data-${each.key}"

  tags = {
    Environment = each.key
    Lifecycle   = each.value.lifecycle_days
    Encryption  = each.value.encryption
  }
}

output "for_each_buckets" {
  description = "Buckets created using for_each"
  value = {
    for k, v in aws_s3_bucket.env_buckets : k => v.id
  }
}

# Access specific buckets using the map key
output "prod_bucket_name" {
  description = "Production bucket name"
  value       = aws_s3_bucket.env_buckets["prod"].id
}

output "dev_bucket_name" {
  description = "Development bucket name"
  value       = aws_s3_bucket.env_buckets["dev"].id
}

# =============================================================================
# Example 3: for_each with Set (Unique Values)
# =============================================================================

variable "availability_zones" {
  description = "Set of availability zones"
  type        = set(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Create subnets for each AZ using a set
resource "aws_subnet" "example_subnets" {
  count = 3  # Placeholder - would need VPC to actually create

  # This won't actually work without a VPC, just for demonstration
  # availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "subnet-${count.index}"
  }
}

# =============================================================================
# Example 4: Complex for_each with Multiple Maps
# =============================================================================

variable "project_config" {
  description = "Project configuration map"
  type = map(object({
    team_name  = string
    cost_center = string
    compliance = string
  }))
  default = {
    "ml-recommendation" = {
      team_name   = "data-science"
      cost_center = "cc-ml-001"
      compliance  = "gdpr"
    }
    "ml-classification" = {
      team_name   = "data-science"
      cost_center = "cc-ml-002"
      compliance  = "hipaa"
    }
    "ml-forecasting" = {
      team_name   = "analytics"
      cost_center = "cc-ml-003"
      compliance  = "none"
    }
  }
}

# Create IAM policies for each project
resource "aws_iam_policy" "project_policies" {
  for_each = var.project_config

  name   = "${each.key}-policy"
  path   = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ml-${each.key}",
          "arn:aws:s3:::ml-${each.key}/*"
        ]
      }
    ]
  })

  tags = {
    Project    = each.key
    Team       = each.value.team_name
    CostCenter = each.value.cost_center
    Compliance = each.value.compliance
  }
}

output "project_policy_arns" {
  description = "IAM policy ARNs created using for_each"
  value = {
    for k, v in aws_iam_policy.project_policies : k => v.arn
  }
}

# =============================================================================
# Example 5: Dynamic Block with for_each
# =============================================================================

variable "security_group_rules" {
  description = "Security group rules configuration"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
    cidr_blocks = list(string)
  }))
  default = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
      cidr_blocks = ["0.0.0.0/0"]
    }
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP access"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS access"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

# Create security group with dynamic ingress rules
resource "aws_security_group" "dynamic_rules" {
  name        = "dynamic-rules-example"
  description = "Security group with dynamic rules"

  # Dynamic block for ingress rules
  dynamic "ingress" {
    for_each = var.security_group_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "dynamic_sg_id" {
  description = "Security group ID with dynamic rules"
  value       = aws_security_group.dynamic_rules.id
}

# =============================================================================
# Example 6: Nested for_each with Module Pattern
# =============================================================================

variable "multi_region_config" {
  description = "Multi-region configuration"
  type = map(map(object({
    instance_count = number
    instance_type  = string
  })))
  default = {
    "us-east-1" = {
      "dev" = {
        instance_count = 1
        instance_type  = "t3.medium"
      }
      "prod" = {
        instance_count = 3
        instance_type  = "t3.xlarge"
      }
    }
    "us-west-2" = {
      "dev" = {
        instance_count = 1
        instance_type  = "t3.medium"
      }
      "prod" = {
        instance_count = 3
        instance_type  = "t3.xlarge"
      }
    }
  }
}

# This demonstrates the concept, though you can't actually create
# resources across regions in a single provider without alias
locals {
  flattened_config = flatten([
    for region, envs in var.multi_region_config : [
      for env, config in envs : {
        region         = region
        environment    = env
        instance_count = config.instance_count
        instance_type  = config.instance_type
        key            = "${region}-${env}"
      }
    ]
  ])
}

output "flattened_config" {
  description = "Flattened configuration for nested for_each"
  value = {
    for item in local.flattened_config : item.key => item
  }
}

# =============================================================================
# Example 7: Conditional count with ternary operator
# =============================================================================

variable "create_monitoring_resources" {
  description = "Whether to create monitoring resources"
  type        = bool
  default     = true
}

variable "create_logging_resources" {
  description = "Whether to create logging resources"
  type        = bool
  default     = false
}

# Create CloudWatch Log Groups based on condition
resource "aws_cloudwatch_log_group" "conditional" {
  count = var.create_logging_resources ? 1 : 0

  name = "/aws/ml/conditional-logs"

  tags = {
    CreatedBy = "conditional-count"
  }
}

output "conditional_log_group" {
  description = "Log group (created only if create_logging_resources is true)"
  value       = try(aws_cloudwatch_log_group.conditional[0].name, "Not created")
}

# =============================================================================
# Key Differences Between count and for_each
# =============================================================================

locals {
  explanation = {
    count = {
      when_to_use    = "For simple lists where order matters"
      access_pattern = "resource_name[index]"
      limitations   = "Can't add/remove items from middle of list without recreating"
    }
    for_each = {
      when_to_use    = "For maps and sets where key uniqueness matters"
      access_pattern = "resource_name[key]"
      benefits       = "Can add/remove items without affecting other resources"
    }
  }
}

output "count_vs_for_each" {
  description = "Explanation of when to use count vs for_each"
  value       = local.explanation
}
