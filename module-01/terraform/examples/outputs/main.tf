# =============================================================================
# Terraform Outputs Example
# This example demonstrates various ways to define and use outputs
# for sharing information between modules and displaying important values
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
# Example Resources
# =============================================================================

resource "aws_s3_bucket" "models" {
  bucket_prefix = "ml-models-"
}

resource "aws_s3_bucket_versioning" "models" {
  bucket = aws_s3_bucket.models.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_instance" "ml_server" {
  count           = 2
  ami             = "ami-0c55b159cbfafe1f0"  # Example AMI
  instance_type   = "t3.medium"
  availability_zone = "us-east-1${count.index == 0 ? "a" : "b"}"

  tags = {
    Name = "ml-server-${count.index}"
  }
}

resource "aws_db_instance" "ml_database" {
  identifier     = "ml-database"
  engine         = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20

  # Skip final snapshot for this example
  skip_final_snapshot = true
  publicly_accessible = false
}

# =============================================================================
# Example 1: Simple String Outputs
# =============================================================================

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.models.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.models.arn
}

output "bucket_region" {
  description = "The AWS region of the bucket"
  value       = aws_s3_bucket.models.region
}

# =============================================================================
# Example 2: Boolean and Numeric Outputs
# =============================================================================

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = aws_s3_bucket_versioning.models.versioning_configuration[0].status == "Enabled"
}

output "instance_count" {
  description = "Number of ML instances created"
  value       = length(aws_instance.ml_server)
}

output "total_storage_gb" {
  description = "Total storage allocated in GB"
  value       = aws_db_instance.ml_database.allocated_storage
}

# =============================================================================
# Example 3: List and Map Outputs
# =============================================================================

output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.ml_server[*].id
}

output "instance_private_ips" {
  description = "List of private IPs"
  value       = aws_instance.ml_server[*].private_ip
}

output "instance_names" {
  description = "List of instance names"
  value = [
    for instance in aws_instance.ml_server :
    instance.tags["Name"]
  ]
}

output "instances_map" {
  description = "Map of instance information"
  value = {
    for instance in aws_instance.ml_server :
    instance.tags["Name"] => {
      id         = instance.id
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
      az         = instance.availability_zone
    }
  }
}

# =============================================================================
# Example 4: Complex Nested Outputs
# =============================================================================

output "bucket_details" {
  description = "Comprehensive bucket information"
  value = {
    basic = {
      name  = aws_s3_bucket.models.id
      arn   = aws_s3_bucket.models.arn
      region = aws_s3_bucket.models.region
    }
    versioning = {
      enabled = aws_s3_bucket_versioning.models.versioning_configuration[0].status
      mfa_delete = try(
        aws_s3_bucket_versioning.models.versioning_configuration[0].mfa_delete,
        "Disabled"
      )
    }
    hosted_zone = aws_s3_bucket.models.hosted_zone_id
    website_endpoint = "${aws_s3_bucket.models.id}.s3-website-${aws_s3_bucket.models.region}.amazonaws.com"
  }
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    endpoint = aws_db_instance.ml_database.endpoint
    port     = aws_db_instance.ml_database.port
    database = aws_db_instance.ml_database.db_name
    username = aws_db_instance.ml_database.username
    # Note: password is sensitive and should not be output
  }
  sensitive = false  # Set to true if this contains sensitive info
}

# =============================================================================
# Example 5: Computed Outputs with Expressions
# =============================================================================

output "ssh_command" {
  description = "SSH command to connect to the first instance"
  value = "ssh -i ~/.ssh/id_rsa ec2-user@${aws_instance.ml_server[0].public_ip}"
}

output "s3_sync_commands" {
  description = "Commands for syncing data to S3"
  value = {
    upload_models   = "aws s3 sync ./models s3://${aws_s3_bucket.models.id}/models"
    download_models = "aws s3 sync s3://${aws_s3_bucket.models.id}/models ./models"
    list_models     = "aws s3 ls s3://${aws_s3_bucket.models.id}/models"
  }
}

output "instance_availability_zones" {
  description = "Count of instances per availability zone"
  value = {
    for instance in aws_instance.ml_server :
    instance.availability_zone => length([
      for i in aws_instance.ml_server : i.id
      if i.availability_zone == instance.availability_zone
    ])
  }
}

# =============================================================================
# Example 6: Conditional Outputs
# =============================================================================

variable "production" {
  description = "Whether this is a production environment"
  type        = bool
  default     = false
}

output "environment_message" {
  description = "Environment-specific message"
  value = var.production ? "Production deployment - high availability enabled" : "Development deployment - single instance"
}

output "backup_recommendation" {
  description = "Backup recommendation based on environment"
  value = var.production ? "Enable automated daily backups with 30-day retention" : "Manual backups only"
}

# =============================================================================
# Example 7: Sensitive Outputs
# =============================================================================

resource "aws_db_instance" "sensitive_db" {
  identifier     = "sensitive-database"
  engine         = "postgres"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  username       = "admin"
  password       = "SuperSecret123"  # Don't do this! Use var or secret
  skip_final_snapshot = true
}

output "db_password" {
  description = "Database password (sensitive)"
  value       = aws_db_instance.sensitive_db.password
  sensitive   = true  # This will hide the value in output
}

output "db_connection_string" {
  description = "Full connection string (sensitive)"
  value       = "postgresql://${aws_db_instance.sensitive_db.username}:${aws_db_instance.sensitive_db.password}@${aws_db_instance.sensitive_db.endpoint}:${aws_db_instance.sensitive_db.port}/${aws_db_instance.sensitive_db.db_name}"
  sensitive   = true
}

# =============================================================================
# Example 8: Output Dependencies
# =============================================================================

output "depends_on_example" {
  description = "Output that explicitly depends on resources"
  value       = "All resources created successfully"

  # Explicit dependency (rarely needed, usually implicit)
  depends_on = [
    aws_s3_bucket.models,
    aws_instance.ml_server,
    aws_db_instance.ml_database
  ]
}

# =============================================================================
# Example 9: Formatted Outputs
# =============================================================================

output "formatted_instance_info" {
  description = "Human-readable instance information"
  value = templatefile("${path.module}/instance_info.tpl", {
    instances = aws_instance.ml_server
    bucket    = aws_s3_bucket.models.id
  })
}

# =============================================================================
# Example 10: Outputs for Cross-Module Reference
# =============================================================================

output "module_outputs" {
  description = "Structured outputs for use by other modules"
  value = {
    storage = {
      bucket_id   = aws_s3_bucket.models.id
      bucket_arn  = aws_s3_bucket.models.arn
      bucket_region = aws_s3_bucket.models.region
    }
    compute = {
      instance_ids = aws_instance.ml_server[*].id
      instance_ips = aws_instance.ml_server[*].private_ip
      instance_count = length(aws_instance.ml_server)
    }
    database = {
      endpoint = aws_db_instance.ml_database.endpoint
      port     = aws_db_instance.ml_database.port
    }
  }
}

# =============================================================================
# Example 11: Output Validation
# =============================================================================

output "instance_status_check" {
  description = "Check if all instances are in the same AZ"
  value = length({
    for az in aws_instance.ml_server[*].availability_zone :
    az => az
  }) == 1 ? "All instances in same AZ" : "Instances distributed across AZs"
}

# =============================================================================
# Example 12: JSON Output for Programmatic Access
# =============================================================================

output "infrastructure_config_json" {
  description = "Infrastructure configuration as JSON"
  value = jsonencode({
    storage = {
      bucket = aws_s3_bucket.models.id
      versioning = aws_s3_bucket_versioning.models.versioning_configuration[0].status
    }
    compute = {
      instances = [
        for instance in aws_instance.ml_server : {
          id = instance.id
          name = instance.tags["Name"]
          type = instance.instance_type
          az = instance.availability_zone
        }
      ]
    }
    database = {
      endpoint = aws_db_instance.ml_database.endpoint
      engine = aws_db_instance.ml_database.engine
    }
  })
}

# =============================================================================
# Example 13: Output with File Content
# =============================================================================

output "inventory_file_content" {
  description = "Ansible inventory file content"
  value = templatefile("${path.module}/inventory.tpl", {
    instances = aws_instance.ml_server
  })
}

# =============================================================================
# Best Practices for Outputs
# =============================================================================

output "output_best_practices" {
  description = "Best practices for using outputs"
  value = [
    "1. Always provide a description for your outputs",
    "2. Use meaningful names that explain what the output contains",
    "3. Structure complex outputs as maps/lists for easier consumption",
    "4. Mark sensitive outputs with 'sensitive = true'",
    "5. Use expressions to compute derived values in outputs",
    "6. Consider the output consumer (CLI, modules, automation)",
    "7. Don't output sensitive data unless absolutely necessary",
    "8. Use templatefile() for generating formatted output"
  ]
}
