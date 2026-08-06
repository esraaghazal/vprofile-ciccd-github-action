###############################################################################
# OIDC Provider (Required for IRSA)
###############################################################################

# Read the TLS certificate from the EKS OIDC issuer
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

# Register the EKS OIDC provider in IAM
resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
}

###############################################################################
# IRSA Role for Amazon EBS CSI Driver
###############################################################################

# Trust policy
data "aws_iam_policy_document" "ebs_csi_assume" {

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

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }

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
# IAM Role used by the EBS CSI Controller
###############################################################################

resource "aws_iam_role" "ebs_csi_irsa" {

  name = "${var.cluster_name}-ebs-csi-irsa"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json

  tags = {
    Name = "${var.cluster_name}-ebs-csi-irsa"
  }
}

###############################################################################
# Attach AWS Managed Policy
###############################################################################

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {

  role = aws_iam_role.ebs_csi_irsa.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}