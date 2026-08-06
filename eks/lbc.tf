###############################################################################
# AWS Load Balancer Controller
#
# This file performs the following:
# 1. Downloads the official IAM policy from AWS.
# 2. Creates an IAM Policy.
# 3. Creates an IAM Role using IRSA.
# 4. Creates a Kubernetes ServiceAccount.
# 5. Installs the AWS Load Balancer Controller using Helm.
###############################################################################

###############################################################################
# Download the official IAM policy
###############################################################################

# The AWS Load Balancer Controller requires many AWS permissions
# (ELB, Target Groups, Security Groups, EC2 networking, etc.).
#
# Instead of manually writing hundreds of IAM actions,
# Terraform downloads the official policy maintained by AWS.

data "http" "alb_controller_iam_policy" {

  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"

}

###############################################################################
# Create IAM Policy
###############################################################################

resource "aws_iam_policy" "alb_controller" {

  name = "${var.cluster_name}-alb-controller-policy"

  policy = data.http.alb_controller_iam_policy.response_body

}

###############################################################################
# IAM Trust Policy (IRSA)
###############################################################################

data "aws_iam_policy_document" "alb_controller_assume" {

  statement {

    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {

      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]

    }

    #
    # Only the AWS Load Balancer Controller ServiceAccount
    # is allowed to assume this role.
    #
    condition {

      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]

    }

    #
    # The token audience must be AWS STS.
    #
    condition {

      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:aud"

      values = [
        "sts.amazonaws.com"
      ]

    }

  }

}

###############################################################################
# IAM Role
###############################################################################

resource "aws_iam_role" "alb_controller" {

  name = "${var.cluster_name}-alb-controller-irsa"

  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume.json

  tags = {

    Name = "${var.cluster_name}-alb-controller-irsa"

  }

}

###############################################################################
# Attach IAM Policy
###############################################################################

resource "aws_iam_role_policy_attachment" "alb_controller" {

  role = aws_iam_role.alb_controller.name

  policy_arn = aws_iam_policy.alb_controller.arn

}

###############################################################################
# Kubernetes Service Account
###############################################################################

resource "kubernetes_service_account" "alb_controller" {

  metadata {

    name = "aws-load-balancer-controller"

    namespace = "kube-system"

    annotations = {

      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn

    }

    labels = {

      "app.kubernetes.io/name" = "aws-load-balancer-controller"

      "app.kubernetes.io/component" = "controller"

    }

  }

  depends_on = [
    aws_eks_node_group.main
  ]

}

###############################################################################
# Install AWS Load Balancer Controller
###############################################################################

resource "helm_release" "alb_controller" {

  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  namespace = "kube-system"

  version = "1.8.1"

  #
  # We already created the ServiceAccount.
  #
  set {

    name = "serviceAccount.create"

    value = "false"

  }

  #
  # Use our ServiceAccount.
  #
  set {

    name = "serviceAccount.name"

    value = kubernetes_service_account.alb_controller.metadata[0].name

  }

  #
  # Cluster Name
  #
  set {

    name = "clusterName"

    value = aws_eks_cluster.main.name

  }

  #
  # AWS Region
  #
  set {

    name = "region"

    value = var.aws_region

  }

  #
  # VPC ID
  #
  set {

    name = "vpcId"

    value = aws_vpc.main.id

  }

  depends_on = [

    kubernetes_service_account.alb_controller,

    aws_eks_node_group.main

  ]

}
