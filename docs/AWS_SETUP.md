# AWS Account Setup Guide

Step-by-step instructions for configuring your AWS account for this project.

## 1. Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com) and sign up
2. Provide billing information (Free Tier available for 12 months)
3. Complete identity verification

## 2. Secure the Root Account

**Never use root for day-to-day work.**

1. Log in as root → IAM → Security recommendations
2. Enable MFA on root account:
   - IAM → My Security Credentials → Multi-factor authentication
   - Use an authenticator app (Google Authenticator, Authy)
3. Create an IAM admin user for all future work

## 3. Create IAM Admin User

```
IAM → Users → Add users
  Username: your-name-admin
  Access type: Programmatic + Console
  Permissions: Attach "AdministratorAccess" policy
  Tags: Environment=non-prod
```

Save the:
- Access Key ID
- Secret Access Key
- Console login URL

## 4. Install AWS CLI

```bash
# macOS
brew install awscli

# Verify
aws --version
# aws-cli/2.x.x
```

## 5. Configure AWS CLI

```bash
aws configure
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region name: us-east-1
# Default output format: json
```

Verify it works:
```bash
aws sts get-caller-identity
# Should return your account ID and user ARN
```

## 6. Install Terraform

```bash
# macOS with Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify
terraform version
# Terraform v1.x.x
```

## 7. Bootstrap Terraform State

The S3 bucket and DynamoDB table must exist before configuring the S3 backend.

**First run (bootstrap):**
```bash
cd infrastructure/

# Temporarily comment out backend.tf contents
# Then run:
terraform init
terraform apply -target=aws_s3_bucket.terraform_state
terraform apply -target=aws_s3_bucket_versioning.terraform_state
terraform apply -target=aws_s3_bucket_public_access_block.terraform_state
terraform apply -target=aws_dynamodb_table.terraform_locks
```

**Then enable the backend:**
```bash
# Uncomment backend.tf
terraform init -migrate-state
# Answer "yes" to migrate local state to S3
```

## 8. Verify Setup

```bash
# Check S3 bucket exists
aws s3 ls | grep tfstate

# Check DynamoDB table exists
aws dynamodb list-tables | grep terraform-locks

# Check Terraform state in S3
aws s3 ls s3://credit-card-platform-tfstate-<your-account-id>/
```

## AWS Free Tier Limits (Key Services)

| Service | Free Tier | Notes |
|---------|-----------|-------|
| EC2 | 750 hrs/mo (t2.micro) | 12 months |
| RDS | 750 hrs/mo (db.t2/t3.micro) | 12 months |
| Lambda | 1M requests/mo | Always free |
| DynamoDB | 25 GB storage | Always free |
| S3 | 5 GB storage | 12 months |
| CloudFront | 1 TB transfer/mo | 12 months |

## Cost Monitoring

Set up a billing alarm to avoid surprise charges:

```
AWS Console → Billing → Budgets → Create Budget
  Budget type: Cost budget
  Amount: $10/month
  Alert: 80% of budget
  Email: your@email.com
```
