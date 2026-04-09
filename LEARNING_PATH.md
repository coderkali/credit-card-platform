# Learning Path — Credit Card Platform

A structured roadmap for building this platform from scratch, tracking progress and key concepts learned.

---

## Phase 1: AWS & Terraform Foundations
**Goal:** Understand AWS core services and manage infrastructure as code.

### Completed
- [x] Create AWS account and configure IAM admin user
- [x] Install and configure AWS CLI
- [x] Install Terraform >= 1.0
- [x] Write `provider.tf` — multi-region AWS provider (us-east-1 + us-west-2)
- [x] Write `variables.tf` — environment and region variables
- [x] Write `s3_backend.tf` — S3 bucket with versioning + DynamoDB lock table
- [x] Write `backend.tf` — remote state configuration
- [x] Successfully run `terraform init`, `plan`, and `apply`
- [x] Verify S3 bucket and DynamoDB table created in AWS console

### Key Concepts Learned
- Terraform provider aliases for multi-region deployments
- Remote state storage: why S3 over local state
- State locking with DynamoDB to prevent concurrent applies
- Terraform lifecycle: `init` → `plan` → `apply` → `destroy`

---

## Phase 2: Networking & Security
**Goal:** Build a production-grade VPC with proper segmentation.

### To Do
- [ ] Create VPC with public and private subnets (multi-AZ)
- [ ] Configure Internet Gateway and NAT Gateway
- [ ] Set up Security Groups for each tier
- [ ] Create Network ACLs for defense-in-depth
- [ ] Enable VPC Flow Logs
- [ ] Set up AWS WAF for API protection

### Key Concepts to Learn
- CIDR block planning for scalable subnets
- Public vs private subnet routing
- Security Group vs Network ACL differences
- Least-privilege network access patterns

---

## Phase 3: IAM & Security Hardening
**Goal:** Implement zero-trust IAM policies across all services.

### To Do
- [ ] Define IAM roles for each application tier
- [ ] Create IAM policies following least-privilege principle
- [ ] Enable MFA enforcement for all human users
- [ ] Set up AWS Secrets Manager for credentials
- [ ] Configure AWS KMS for encryption key management
- [ ] Enable AWS CloudTrail for audit logging
- [ ] Set up AWS Config for compliance monitoring

### Key Concepts to Learn
- IAM roles vs users vs groups
- Resource-based vs identity-based policies
- AWS Secrets Manager rotation
- KMS key policies and grants

---

## Phase 4: Backend API
**Goal:** Build a secure REST API for card processing.

### To Do
- [ ] Design API endpoints (cards, transactions, auth)
- [ ] Set up AWS API Gateway
- [ ] Create Lambda functions (or ECS containers)
- [ ] Connect to RDS (PostgreSQL) for card data
- [ ] Implement JWT authentication
- [ ] Add request validation and rate limiting
- [ ] Write unit and integration tests

### Key Concepts to Learn
- Serverless vs containerized backend trade-offs
- API Gateway stages and deployment
- RDS vs DynamoDB for relational data
- PCI DSS compliance basics for card data

---

## Phase 5: Frontend
**Goal:** Build a React UI for card management.

### To Do
- [ ] Scaffold React app with TypeScript
- [ ] Set up AWS Amplify or S3 + CloudFront hosting
- [ ] Implement authentication UI (Cognito)
- [ ] Build card dashboard and transaction views
- [ ] Add form validation and error handling
- [ ] Configure CI/CD pipeline

### Key Concepts to Learn
- AWS Cognito user pools and identity pools
- CloudFront distributions and caching
- React state management patterns
- Secure token storage in the browser

---

## Phase 6: Observability & Operations
**Goal:** Full visibility into platform health and performance.

### To Do
- [ ] Set up CloudWatch dashboards and alarms
- [ ] Configure structured logging across all services
- [ ] Implement distributed tracing with X-Ray
- [ ] Set up SNS/PagerDuty alerts
- [ ] Create runbooks for common incidents
- [ ] Configure automated backups and recovery tests

---

## Resources

| Topic | Resource |
|-------|---------|
| Terraform | [terraform.io/docs](https://developer.hashicorp.com/terraform/docs) |
| AWS Free Tier | [aws.amazon.com/free](https://aws.amazon.com/free/) |
| AWS Well-Architected | [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/) |
| PCI DSS Basics | [AWS PCI DSS Compliance](https://aws.amazon.com/compliance/pci-dss-level-1-faqs/) |

---

## Progress Summary

| Phase | Status | Completion |
|-------|--------|-----------|
| Phase 1: Foundations | In Progress | 100% |
| Phase 2: Networking | Not Started | 0% |
| Phase 3: IAM | Not Started | 0% |
| Phase 4: Backend API | Not Started | 0% |
| Phase 5: Frontend | Not Started | 0% |
| Phase 6: Observability | Not Started | 0% |
