# Terraform Guide — Credit Card Platform

## Core Concepts

### What is Terraform?
Terraform is Infrastructure as Code (IaC) — you describe your infrastructure in `.tf` files and Terraform creates/updates/destroys real cloud resources to match.

### Key Files in This Project

| File | Purpose |
|------|---------|
| `provider.tf` | Declares AWS provider and required Terraform version |
| `variables.tf` | Input variables (environment names, regions, etc.) |
| `backend.tf` | Where Terraform stores its state (S3 bucket) |
| `s3_backend.tf` | Creates the S3 bucket and DynamoDB table for state |

## Terraform Workflow

```
terraform init     # Download providers, configure backend
    ↓
terraform validate # Check syntax and config errors
    ↓
terraform fmt      # Auto-format .tf files
    ↓
terraform plan     # Preview changes (what will be created/modified/destroyed)
    ↓
terraform apply    # Apply the changes to AWS
    ↓
terraform destroy  # (when needed) Tear down all resources
```

## Daily Commands

```bash
# Always run from the infrastructure/ directory
cd infrastructure/

# Initialize (run once, or after adding new providers/modules)
terraform init

# Format all .tf files
terraform fmt

# Check for errors
terraform validate

# See what will change
terraform plan

# Apply changes (prompts for confirmation)
terraform apply

# Apply without confirmation prompt (use carefully)
terraform apply -auto-approve

# Target a specific resource
terraform apply -target=aws_s3_bucket.terraform_state

# Destroy specific resource
terraform destroy -target=aws_dynamodb_table.terraform_locks

# Show current state
terraform show

# List all resources in state
terraform state list

# Import an existing AWS resource into state
terraform import aws_s3_bucket.my_bucket my-existing-bucket-name
```

## Remote State (S3 Backend)

This project stores Terraform state in S3 instead of locally.

**Why remote state?**
- Shared across teammates — everyone sees the same infrastructure state
- S3 versioning lets you recover from accidental state corruption
- DynamoDB locking prevents two people applying at the same time

**backend.tf configuration:**
```hcl
terraform {
  backend "s3" {
    bucket         = "credit-card-platform-tfstate-<account-id>"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## Multi-Region Provider Aliases

This project uses provider aliases to manage resources in multiple regions:

```hcl
# provider.tf
provider "aws" {
  alias  = "non-prod"
  region = "us-east-1"
}

provider "aws" {
  alias  = "prod"
  region = "us-west-2"
}
```

To use a specific region in a resource:
```hcl
resource "aws_vpc" "main" {
  provider = aws.non-prod
  cidr_block = "10.0.0.0/16"
}
```

## Variables

Define in `variables.tf`, override in `terraform.tfvars` (never commit secrets):

```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "non-prod"
}
```

```hcl
# terraform.tfvars (gitignored)
environment = "prod"
```

Pass on CLI:
```bash
terraform apply -var="environment=prod"
```

## Best Practices

1. **Always run `plan` before `apply`** — review every change
2. **Use `-target` carefully** — partial applies can leave state inconsistent
3. **Never edit state files directly** — use `terraform state` commands
4. **Commit `.tf` files, never `.tfstate`** — state is in S3
5. **Run `terraform fmt`** before every commit
6. **Use workspaces or separate state keys** for different environments

## Troubleshooting

### "Error acquiring the state lock"
Another process is applying, or a previous apply crashed.
```bash
# Only if you're certain no apply is running
terraform force-unlock <lock-id>
```

### "Provider produced inconsistent result after apply"
Usually a provider bug or race condition. Re-run `terraform apply`.

### "No valid credential sources found"
AWS credentials not configured.
```bash
aws configure
# or
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
```

### Backend init fails
The S3 bucket doesn't exist yet. Bootstrap it first (see `AWS_SETUP.md`).
