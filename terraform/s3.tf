# S3 Bucket for Terraform State
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_prefix}-terraform-state"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_prefix}-terraform-state"
    }
  )
}

# Block public access to state bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on state bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption on state bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket for Application Images
resource "aws_s3_bucket" "app_images" {
  bucket = "${var.project_prefix}-app-images"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_prefix}-app-images"
    }
  )
}

# Enable versioning on app bucket
resource "aws_s3_bucket_versioning" "app_images" {
  bucket = aws_s3_bucket.app_images.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption on app bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "app_images" {
  bucket = aws_s3_bucket.app_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle rule - Delete old images after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "app_images" {
  bucket = aws_s3_bucket.app_images.id

  rule {
    id     = "delete-old-images"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      days = 90
    }
  }
}

# DynamoDB Table for Terraform State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_prefix}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_prefix}-terraform-locks"
    }
  )
}

# Output S3 bucket names
output "terraform_state_bucket" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "app_images_bucket" {
  description = "S3 bucket for application images"
  value       = aws_s3_bucket.app_images.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}
