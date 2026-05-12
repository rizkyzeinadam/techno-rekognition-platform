# Backend configuration file
# Note: Update this with actual bucket name, table name after initial apply
# This file should be uncommented and configured after initial infrastructure setup

# terraform {
#   backend "s3" {
#     bucket         = "techno-terraform-state"
#     key            = "eks/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     use_lockfile   = true
#   }
# }

# For initial setup, use local backend (commented out above)
# After creating S3 bucket and DynamoDB table, run:
# terraform init -backend-config="bucket=techno-terraform-state" \
#   -backend-config="key=eks/terraform.tfstate" \
#   -backend-config="region=us-east-1" \
#   -backend-config="encrypt=true" \
#   -backend-config="use_lockfile=true"
