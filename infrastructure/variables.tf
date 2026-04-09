variable "environment" {
    description = "Environment name (non-prod or prod)"
    type = string
    default = "non-prod"
}

variable "app_name" {
  description = "Application name"
  type = string
  default = "credit-card-platform"
}

variable "region_non_prod" {
    description = "Non-Prod Region"
    type = string
    default = "us-east-1"
}

variable "region_prod" {
  description = "Prod region"
  type        = string
  default     = "us-west-2"
}
