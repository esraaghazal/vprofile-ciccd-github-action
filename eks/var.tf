###############################################################################
# General Configuration
###############################################################################

variable "aws_region" {
  description = "AWS region where all resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the Amazon EKS cluster."
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version used by the EKS control plane."
  type        = string
  default     = "1.30"
}

###############################################################################
# Networking
###############################################################################

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability Zones used by the VPC."

  type = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {

  description = "CIDR blocks for the public subnets."

  type = list(string)

  default = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]
}

variable "private_subnet_cidrs" {

  description = "CIDR blocks for the private subnets."

  type = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

###############################################################################
# EKS API Server
###############################################################################

variable "cluster_endpoint_public_access" {

  description = "Enable public access to the Kubernetes API Server."

  type = bool

  default = true

}

variable "cluster_endpoint_public_access_cidrs" {

  description = "CIDR ranges allowed to access the EKS API endpoint."

  type = list(string)

  default = [
    "0.0.0.0/0"
  ]
}

###############################################################################
# Managed Node Group
###############################################################################

variable "node_instance_types" {

  description = "EC2 instance types used by the managed node group."

  type = list(string)

  default = [
    "t3.medium"
  ]
}

variable "node_disk_size" {

  description = "Root volume size (GiB) for worker nodes."

  type = number

  default = 20

}

variable "node_desired_size" {

  description = "Desired number of worker nodes."

  type = number

  default = 2

}

variable "node_min_size" {

  description = "Minimum number of worker nodes."

  type = number

  default = 2

}

variable "node_max_size" {

  description = "Maximum number of worker nodes."

  type = number

  default = 4

}

###############################################################################
# Amazon ECR
###############################################################################

variable "ecr_repository_name" {

  description = "Name of the Amazon ECR repository."

  type = string

  default = "my-app"

}

###############################################################################
# Common Resource Tags
###############################################################################

variable "tags" {

  description = "Common tags applied to all AWS resources."

  type = map(string)

  default = {

    Project = "eks-terraform-project"

    Environment = "dev"

    ManagedBy = "Terraform"

  }

}