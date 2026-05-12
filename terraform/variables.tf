variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "demo"
}

variable "project_prefix" {
  description = "Project prefix for all resources"
  type        = string
  default     = "techno"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "eks_cluster_version" {
  description = "EKS cluster Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "eks_instance_type" {
  description = "EC2 instance type for EKS node group"
  type        = string
  default     = "t3.small"
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "ecr_repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "techno-rekognition-app"
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default = {
    Project     = "TechnoAWS"
    Environment = "demo"
    ManagedBy   = "Terraform"
  }
}
