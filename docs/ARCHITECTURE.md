# Architecture Overview — Credit Card Platform

## High-Level Design

```
                        ┌─────────────────────────────────────────────────────┐
                        │                    AWS Cloud                         │
                        │                                                      │
  Users ──── HTTPS ──►  │  CloudFront ──► API Gateway ──► Lambda / ECS        │
                        │                                       │              │
                        │                               RDS PostgreSQL         │
                        │                               DynamoDB               │
                        │                               Secrets Manager        │
                        └─────────────────────────────────────────────────────┘
```

## Multi-Region Strategy

| Environment | Region | Purpose |
|-------------|--------|---------|
| Non-Prod | us-east-1 | Development, Staging, Testing |
| Prod | us-west-2 | Production workloads, Live traffic |

Separate regions provide:
- Environment isolation (no accidental prod impact from dev)
- Geographic redundancy for production
- Independent blast radius per environment

## Infrastructure Layers

### Layer 1: State Management (Completed)
- **S3 Bucket** — stores Terraform state files with versioning enabled
- **DynamoDB Table** — provides state locking to prevent concurrent modifications
- **Encryption** — AES-256 server-side encryption on all state files

### Layer 2: Networking (Planned)
- VPC with `/16` CIDR block
- Public subnets (load balancers, NAT gateways) across 2+ AZs
- Private subnets (application tier, databases) across 2+ AZs
- Internet Gateway for public traffic
- NAT Gateways for outbound private subnet traffic

### Layer 3: Security (Planned)
- IAM roles with least-privilege policies
- Security Groups as virtual firewalls per service
- WAF rules on API Gateway
- KMS encryption for data at rest
- Secrets Manager for credentials rotation

### Layer 4: Compute (Planned)
- **API:** AWS Lambda (serverless) or ECS Fargate (containerized)
- **Frontend:** S3 + CloudFront CDN

### Layer 5: Data (Planned)
- **Primary DB:** RDS PostgreSQL (card and account data)
- **Sessions/Cache:** ElastiCache Redis
- **NoSQL:** DynamoDB (transactions, audit logs)

### Layer 6: Observability (Planned)
- CloudWatch Logs, Metrics, Dashboards
- AWS X-Ray distributed tracing
- CloudTrail for API audit logging

## Security Principles

1. **Defense in depth** — multiple security layers; no single point of failure
2. **Least privilege** — every IAM role has only the permissions it needs
3. **Encryption everywhere** — data encrypted in transit (TLS) and at rest (KMS)
4. **Immutable infrastructure** — no manual changes; everything through Terraform
5. **Audit trail** — all API calls logged via CloudTrail

## Data Flow (Card Transaction)

```
1. User submits card → Frontend (HTTPS)
2. Frontend → CloudFront → API Gateway (WAF inspects)
3. API Gateway → Lambda (validates JWT, parses request)
4. Lambda → Secrets Manager (fetch DB credentials)
5. Lambda → RDS (store transaction record)
6. Lambda → DynamoDB (write audit log)
7. Lambda → SNS (trigger notifications)
8. Response flows back through the chain
```
