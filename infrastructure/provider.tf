terraform {
    required_version = ">=1.0"

    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
      }
    }
}

# Non-Prod: us-east-1 (Dev/Staging)
provider "aws" {
  alias  = "non-prod"
  region = "us-east-1"
}

# Prod: us-west-2 (Live + Failover)
provider "aws" {
  alias  = "prod"
  region = "us-west-2"
}



