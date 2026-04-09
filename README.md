# Credit Card Platform

A cloud-native credit card processing platform built on AWS, following enterprise-grade architecture and security practices.

## Overview

This project implements a full-stack credit card platform with:
- **Multi-region AWS infrastructure** (us-east-1 non-prod, us-west-2 prod)
- **Infrastructure as Code** using Terraform
- **Remote state management** via S3 + DynamoDB locking
- **Secure backend API** (coming soon)
- **React frontend** (coming soon)

## Repository Structure

```
credit-card-platform/
├── README.md               # This file
├── LEARNING_PATH.md        # Learning roadmap and progress tracker
├── .gitignore              # Git ignore rules
├── docs/                   # Architecture and setup documentation
│   ├── ARCHITECTURE.md     # System architecture overview
│   ├── IAM_POLICIES.md     # AWS IAM policies and roles
│   ├── TERRAFORM_GUIDE.md  # Terraform workflow guide
│   └── AWS_SETUP.md        # AWS account setup steps
├── infrastructure/         # Terraform IaC
│   ├── provider.tf         # AWS provider config (multi-region)
│   ├── variables.tf        # Input variables
│   ├── backend.tf          # Remote state backend (S3)
│   └── s3_backend.tf       # S3 bucket + DynamoDB lock resources
├── backend/                # API service (coming soon)
├── frontend/               # React UI (coming soon)
└── scripts/                # Utility and automation scripts
```

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | >= 1.0 | Infrastructure provisioning |
| AWS CLI | >= 2.0 | AWS account interaction |
| Node.js | >= 18 | Frontend development |
| Python | >= 3.11 | Backend / scripts |

## Quick Start

### 1. Configure AWS credentials

```bash
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output (json)
```

### 2. Initialize Terraform

```bash
cd infrastructure/
terraform init
```

### 3. Plan infrastructure changes

```bash
terraform plan
```

### 4. Apply infrastructure

```bash
terraform apply
```

## Environments

| Environment | AWS Region | Purpose |
|-------------|-----------|---------|
| non-prod | us-east-1 | Development & Staging |
| prod | us-west-2 | Production (Live + Failover) |

## Remote State

Terraform state is stored remotely in S3 with DynamoDB locking:
- **S3 Bucket:** `credit-card-platform-tfstate-<account-id>`
- **DynamoDB Table:** `terraform-locks`
- **Encryption:** AES-256 at rest

## Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [AWS Setup Guide](docs/AWS_SETUP.md)
- [Terraform Guide](docs/TERRAFORM_GUIDE.md)
- [IAM Policies](docs/IAM_POLICIES.md)
- [Learning Path](LEARNING_PATH.md)

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make changes and test locally
3. Run `terraform fmt` and `terraform validate` before committing
4. Submit a pull request with a clear description

## License

Private repository — all rights reserved.
