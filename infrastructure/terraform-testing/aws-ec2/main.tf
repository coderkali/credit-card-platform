terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.54.1"
    }
  }
}

provider "aws" {
    region = var.region
}

resource "aws_instance" "myFirstapplication" {
    ami = "ami-0ea87431b78a82070"
    instance_type = "t3.nano"
}

