# Amazon EKS Cluster Deployment Documentation

## Project Overview

This document describes the deployment of an Amazon EKS cluster using Terraform and explains every infrastructure component that was created during the deployment.

---

# Deployment Steps

## Step 1 - Configure Terraform Backend

### Objective

Store Terraform state remotely in Amazon S3.

### Resources

- S3 Bucket
- State Locking

### Files

backend.tf

### Commands

```bash
terraform init
```

### Result

Terraform state is stored remotely.

---

## Step 2 - Configure Providers

### Objective

Configure Terraform providers.

Providers used

- AWS
- Kubernetes
- Helm
- HTTP
- TLS

Files

provider.tf

---

## Step 3 - Create VPC

### Resources Created

- VPC

CIDR

10.0.0.0/16

Why?

Provides network isolation for the EKS cluster.

Terraform Resource

```hcl
resource "aws_vpc" "main"
```

Verification

```bash
aws ec2 describe-vpcs
```

---

## Step 4 - Create Public Subnets

Resources

- Public Subnet A
- Public Subnet B

Purpose

Host:

- NAT Gateway
- Application Load Balancer

Tags

```text
kubernetes.io/role/elb=1
```

---

## Step 5 - Create Private Subnets

Purpose

Host:

- Worker Nodes
- Kubernetes Pods

Tags

```text
kubernetes.io/role/internal-elb=1
```

---

## Step 6 - Internet Gateway

Purpose

Allow Internet connectivity for public resources.

---

## Step 7 - NAT Gateway

Purpose

Allow private worker nodes to access the Internet without exposing them publicly.

Used for:

- Pulling Docker Images
- Installing Helm Charts
- Downloading Packages

---

## Step 8 - Route Tables

Public Route Table

```
0.0.0.0/0
↓

Internet Gateway
```

Private Route Table

```
0.0.0.0/0
↓

NAT Gateway
```

---

## Step 9 - Amazon ECR

Created

- ECR Repository

Configuration

- Immutable Tags
- Image Scanning
- AES256 Encryption
- Lifecycle Policy

Verification

```bash
aws ecr describe-repositories
```

---

## Step 10 - Create EKS Control Plane

Terraform Resource

```hcl
aws_eks_cluster.main
```

Created

- Managed Control Plane

Version

1.30

Verification

```bash
kubectl cluster-info
```

---

## Step 11 - Configure Cluster Access

Resources

- Access Entry
- Cluster Admin Policy

Purpose

Allow the Terraform user to manage the cluster.

---

## Step 12 - Configure OIDC Provider

Purpose

Enable IAM Roles for Service Accounts (IRSA).

Verification

```bash
aws iam list-open-id-connect-providers
```

---

## Step 13 - Create Worker Node IAM Role

Policies Attached

- AmazonEKSWorkerNodePolicy
- AmazonEKS_CNI_Policy
- AmazonEC2ContainerRegistryReadOnly
- AmazonSSMManagedInstanceCore

---

## Step 14 - Create Managed Node Group

Configuration

- t3.medium
- Desired: 2
- Min: 2
- Max: 4

Verification

```bash
kubectl get nodes
```

---

## Step 15 - Install EKS Add-ons

Installed

- VPC CNI
- CoreDNS
- kube-proxy
- Amazon EBS CSI Driver

Verification

```bash
kubectl get pods -n kube-system
```

---

## Step 16 - Configure IRSA for EBS CSI Driver

Resources

- IAM Role
- IAM Policy
- OIDC Trust Policy

Purpose

Allow the EBS CSI Driver to create and manage EBS volumes securely without using node IAM permissions.

---

## Step 17 - Install AWS Load Balancer Controller

Resources

- IAM Policy
- IAM Role
- Service Account
- Helm Release

Purpose

Automatically provision AWS Application Load Balancers from Kubernetes Ingress resources.

Verification

```bash
kubectl get pods -n kube-system
```

---

# Final Infrastructure

- VPC
- Internet Gateway
- NAT Gateway
- Public Subnets
- Private Subnets
- Route Tables
- Amazon ECR
- Amazon EKS
- Managed Node Group
- OIDC Provider
- IRSA
- EBS CSI Driver
- AWS Load Balancer Controller

---

# Deployment Verification

```bash
terraform output

kubectl get nodes

kubectl get pods -A

kubectl get ingress

kubectl get svc
```

---

# Lessons Learned

- Why private subnets are recommended for worker nodes.
- Why NAT Gateway is required.
- Why OIDC is needed for IRSA.
- Why the EBS CSI Driver requires a dedicated IAM role.
- Why the AWS Load Balancer Controller is required for Ingress.
- Difference between the EKS Control Plane and Worker Nodes.
- Difference between IAM Roles for EC2 and IAM Roles for Service Accounts.

---

# Troubleshooting

| Problem | Cause | Resolution |
|----------|-------|------------|
| Worker nodes not joining | IAM role or subnet issue | Verify node IAM policies and private subnet configuration |
| ImagePullBackOff | Missing ECR access | Attach AmazonEC2ContainerRegistryReadOnly policy |
| PVC Pending | Missing EBS CSI Driver | Install the EBS CSI add-on and IRSA role |
| ALB not created | AWS Load Balancer Controller not installed | Install the controller and verify ServiceAccount annotation |
| AccessDenied | Incorrect IRSA configuration | Check OIDC provider and IAM trust policy |
| kubectl unauthorized | kubeconfig not updated | Run `aws eks update-kubeconfig` |
