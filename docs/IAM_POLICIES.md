# IAM Policies — Credit Card Platform

## Overview

This document defines the IAM roles, users, and policies for the platform. All access follows the **least-privilege principle**: every entity has only the permissions required for its specific function.

## IAM Structure

```
AWS Account
├── Root (locked down, MFA only)
├── IAM Users
│   └── admin-user (human, AdministratorAccess, MFA required)
└── IAM Roles (assumed by services, no long-lived keys)
    ├── terraform-deployment-role
    ├── api-lambda-role
    ├── frontend-deploy-role
    └── ci-cd-role
```

## Roles (Planned)

### terraform-deployment-role
Used by CI/CD pipelines to apply Terraform changes.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject", "s3:PutObject", "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::credit-card-platform-tfstate-*",
        "arn:aws:s3:::credit-card-platform-tfstate-*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:*:table/terraform-locks"
    }
  ]
}
```

### api-lambda-role
Assumed by Lambda functions running the API.

**Permissions needed:**
- `secretsmanager:GetSecretValue` — fetch DB credentials
- `rds-db:connect` — connect to RDS via IAM auth
- `dynamodb:PutItem`, `GetItem`, `Query` — audit log table
- `logs:CreateLogGroup`, `logs:PutLogEvents` — CloudWatch Logs
- `xray:PutTraceSegments` — distributed tracing

### frontend-deploy-role
Used to deploy frontend assets.

**Permissions needed:**
- `s3:PutObject`, `s3:DeleteObject` — update static assets
- `cloudfront:CreateInvalidation` — bust CDN cache after deploy

### ci-cd-role
Assumed by GitHub Actions (OIDC, no static keys).

**Permissions needed:**
- Assume `terraform-deployment-role`
- Assume `frontend-deploy-role`
- `ecr:GetAuthorizationToken` — push Docker images (if using ECS)

## Security Rules

### No Long-Lived Keys for Services
All service-to-service authentication uses **IAM roles**, not access keys. This eliminates the risk of leaked credentials.

### MFA Enforcement Policy
Attach this to all human IAM users:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyAllExceptListedIfNoMFA",
      "Effect": "Deny",
      "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
      ],
      "Resource": "*",
      "Condition": {
        "BoolIfExists": {
          "aws:MultiFactorAuthPresent": "false"
        }
      }
    }
  ]
}
```

### S3 State Bucket Policy
Deny non-HTTPS requests and restrict access to authorized roles only:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::credit-card-platform-tfstate-*/*",
      "Condition": {
        "Bool": { "aws:SecureTransport": "false" }
      }
    }
  ]
}
```

## Compliance Notes

For PCI DSS Level 1 (required for card processing):
- All IAM activity must be logged via CloudTrail
- Access reviews required quarterly
- No shared IAM user accounts
- All console access requires MFA
- Root account must never be used for regular operations
