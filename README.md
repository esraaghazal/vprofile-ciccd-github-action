#  End-to-End DevSecOps CI/CD Pipeline on AWS EKS

##  Project Overview

This project demonstrates a complete **DevSecOps CI/CD pipeline** for deploying a containerized application to **Amazon EKS** using **GitHub Actions**, **Helm**, and AWS services.

The pipeline automates code validation, security scanning, container image management, and Kubernetes deployment while following security and backup best practices.

---

#  Architecture

```
<img width="1280" height="853" alt="photo_2026-08-05_13-58-08" src="https://github.com/user-attachments/assets/8faae162-6af1-4c49-8e81-aa84dad6444a" />


```

---

#  Objectives

- Automate application deployment
- Implement DevSecOps practices
- Secure Kubernetes workloads
- Manage secrets using HashiCorp Vault
- Backup and restore Kubernetes resources using Velero
- Deploy applications on Amazon EKS using Helm

---

# ☁️ AWS Services Used

- Amazon EKS
- Amazon ECR
- IAM
- VPC
- EC2
- Elastic Load Balancer
- CloudWatch (optional)

---

#  Technologies

- GitHub
- GitHub Actions
- Docker
- Amazon ECR
- Amazon EKS
- Kubernetes
- Helm
- SonarQube
- Trivy
- HashiCorp Vault
- Velero
- Network Policies

---

#  Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── kubernetes/
│   ├── deployments/
│   ├── services/
│   ├── networkpolicy.yaml
│   ├── vault/
│   └── secrets/
├── Dockerfile
├── README.md
└── application source
```

---

# ⚙️ CI/CD Pipeline Workflow

## 1. Trigger

The pipeline starts automatically whenever code is pushed to the **main** branch.

```
Push to main
      │
      ▼
GitHub Actions
```

---

## 2. Checkout Source Code

The latest version of the application is downloaded from GitHub.

---

## 3. Build the Application

Compile and package the application.

---

## 4. Static Code Analysis (SonarQube)

The source code is analyzed for:

- Bugs
- Vulnerabilities
- Code Smells
- Maintainability
- Security Hotspots

The pipeline fails if the Quality Gate is not passed.

---

## 5. Build Docker Image

A Docker image is created using the application's Dockerfile.

---

## 6. Container Security Scan (Trivy)

The Docker image is scanned for:

- Critical vulnerabilities
- High vulnerabilities
- Operating system packages
- Application dependencies
- Misconfigurations

Only secure images continue through the pipeline.

---

## 7. Push Image to Amazon ECR

The validated image is pushed to a private Amazon Elastic Container Registry repository.

```
Docker Build
      │
      ▼
Trivy Scan
      │
      ▼
Amazon ECR
```

---

## 8. Deploy to Amazon EKS

Helm updates the Kubernetes deployment using the latest image stored in Amazon ECR.

Deployment includes:

- Deployments
- Services
- ConfigMaps
- Secrets
- Ingress (if configured)
- Persistent Volumes

---

#  Security Implementation

## Network Policies

Kubernetes Network Policies are used to control pod-to-pod communication and enforce least-privilege networking.

Benefits:

- Restrict unauthorized traffic
- Isolate workloads
- Improve cluster security

---

## HashiCorp Vault

Sensitive information is managed securely using Vault.

Secrets such as:

- Database credentials
- API Keys
- Tokens

are injected dynamically into application pods using the Vault Agent Injector.

Benefits:

- No hardcoded secrets
- Automatic secret rotation
- Secure secret management

---

#  Backup & Disaster Recovery

## Velero

Velero provides backup and recovery for Kubernetes resources.

Features:

- Cluster backup
- Namespace backup
- Persistent Volume backup
- Restore applications
- Disaster recovery

---

#  Amazon EKS Cluster

The application is deployed on Amazon Elastic Kubernetes Service.

Cluster features include:

- Managed Kubernetes
- Worker Nodes
- Auto Scaling
- Load Balancer
- IAM Roles for Service Accounts (IRSA)
- High Availability
- Rolling Updates

---

#  Complete Pipeline Flow

```
Developer
      │
      ▼
Push Code
      │
      ▼
GitHub Actions
      │
      ▼
Checkout Repository
      │
      ▼
Build Application
      │
      ▼
SonarQube Scan
      │
      ▼
Docker Build
      │
      ▼
Trivy Scan
      │
      ▼
Push Image to Amazon ECR
      │
      ▼
Helm Upgrade / Install
      │
      ▼
Amazon EKS
      │
      ├── Network Policies
      ├── Vault Secrets
      └── Velero Backups
```

---

#  Features

- Automated CI/CD
- Static Code Analysis
- Container Vulnerability Scanning
- Secure Image Registry
- Kubernetes Deployment with Helm
- Amazon EKS Deployment
- Network Isolation
- Dynamic Secret Management
- Kubernetes Backup & Restore
- Infrastructure Security Best Practices

---

#  DevSecOps Tools Summary

| Tool | Purpose |
|------|---------|
| GitHub | Source Code Management |
| GitHub Actions | CI/CD Automation |
| SonarQube | Static Code Analysis |
| Docker | Containerization |
| Trivy | Container Security Scanning |
| Amazon ECR | Container Registry |
| Helm | Kubernetes Package Manager |
| Amazon EKS | Kubernetes Platform |
| Vault | Secret Management |
| Network Policies | Pod Network Security |
| Velero | Backup & Disaster Recovery |

---

#  Key Learning Outcomes

- Build an automated DevSecOps pipeline
- Integrate security into CI/CD
- Deploy applications to Amazon EKS
- Manage Kubernetes deployments with Helm
- Secure workloads using Network Policies
- Inject secrets securely using Vault
- Implement backup and disaster recovery with Velero
- Follow cloud-native deployment best practices

---

