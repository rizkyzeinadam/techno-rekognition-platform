# Outputs for VPC
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"

  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"

  value = [
    aws_subnet.public_1.cidr_block,
    aws_subnet.public_2.cidr_block
  ]
}

# Outputs for Security Groups
output "eks_cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "EKS nodes security group ID"
  value       = aws_security_group.eks_nodes.id
}

# Outputs for EKS
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = aws_eks_cluster.main.version
}

# Outputs for IAM
output "eks_cluster_role_arn" {
  description = "EKS cluster role ARN"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  description = "EKS node role ARN"
  value       = aws_iam_role.eks_node_role.arn
}

output "app_service_account_role_arn" {
  description = "Application service account role ARN"
  value       = aws_iam_role.app_service_account.arn
}

# Outputs for S3
output "terraform_state_bucket_name" {
  description = "Terraform state bucket name"
  value       = aws_s3_bucket.terraform_state.id
}

output "app_images_bucket_name" {
  description = "Application images bucket name"
  value       = aws_s3_bucket.app_images.id
}

# Outputs for ECR
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_registry_id" {
  description = "ECR registry ID"
  value       = aws_ecr_repository.app.registry_id
}

# Outputs for OIDC
output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

# Summary Output
output "deployment_summary" {
  description = "Deployment summary"
  value = {
    cluster_name                = aws_eks_cluster.main.name
    cluster_endpoint            = aws_eks_cluster.main.endpoint
    ecr_repository_url          = aws_ecr_repository.app.repository_url
    frontend_ecr_repository_url = aws_ecr_repository.frontend.repository_url
    terraform_state_bucket      = aws_s3_bucket.terraform_state.id
    app_images_bucket           = aws_s3_bucket.app_images.id
    region                      = var.aws_region
    instance_type               = var.eks_instance_type
    kubernetes_version          = aws_eks_cluster.main.version
  }
}
