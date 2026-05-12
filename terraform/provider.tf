terraform {
  required_version = ">= 1.0"

  # Backend S3 intentionally left empty.
  # Configure values at init time using -backend-config during migration.

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.50.0"
    }
  }
}

provider "aws" {
  profile = "testing"
  region  = "us-east-1"

  default_tags {
    tags = {
      Project     = "TechnoAWS"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
