terraform {
  backend "s3" {
    bucket = "credit-card-platform-tfstate-940278683030"
    key = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
    
  }
}