###############################################################################
# Outputs
#
# These outputs expose useful information after the infrastructure
# has been successfully created.
#
# View them using:
#   terraform output
#
# Or a specific value:
#   terraform output cluster_name
###############################################################################

###############################################################################
# EKS Cluster
###############################################################################

output "cluster_name" {

  description = "Name of the EKS cluster"

  value = aws_eks_cluster.main.name

}

output "cluster_endpoint" {

  description = "API Server endpoint"

  value = aws_eks_cluster.main.endpoint

}

output "cluster_certificate_authority_data" {

  description = "Base64 encoded certificate authority"

  value = aws_eks_cluster.main.certificate_authority[0].data

  sensitive = true

}

output "cluster_oidc_issuer_url" {

  description = "OIDC issuer URL used by IRSA"

  value = aws_eks_cluster.main.identity[0].oidc[0].issuer

}

###############################################################################
# Networking
###############################################################################

output "vpc_id" {

  description = "VPC ID"

  value = aws_vpc.main.id

}

output "public_subnet_ids" {

  description = "Public subnet IDs"

  value = aws_subnet.public[*].id

}

output "private_subnet_ids" {

  description = "Private subnet IDs"

  value = aws_subnet.private[*].id

}

###############################################################################
# Worker Nodes
###############################################################################

output "node_group_name" {

  description = "Managed Node Group Name"

  value = aws_eks_node_group.main.node_group_name

}

output "node_group_role_arn" {

  description = "IAM Role used by Worker Nodes"

  value = aws_iam_role.eks_node.arn

}

###############################################################################
# IAM Roles (IRSA)
###############################################################################

output "ebs_csi_role_arn" {

  description = "IAM Role ARN used by the EBS CSI Driver"

  value = aws_iam_role.ebs_csi_irsa.arn

}

output "alb_controller_role_arn" {

  description = "IAM Role ARN used by the AWS Load Balancer Controller"

  value = aws_iam_role.alb_controller.arn

}

###############################################################################
# Amazon ECR
###############################################################################

output "ecr_repository_name" {

  description = "Amazon ECR Repository Name"

  value = aws_ecr_repository.app.name

}

output "ecr_repository_url" {

  description = "Amazon ECR Repository URL"

  value = aws_ecr_repository.app.repository_url

}

###############################################################################
# Kubectl Configuration
###############################################################################

output "configure_kubectl" {

  description = "Command used to configure kubectl"

  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"

}

###############################################################################
# Helpful AWS Console Links
###############################################################################

output "aws_region" {

  description = "AWS Region"

  value = var.aws_region

}