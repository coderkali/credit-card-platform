terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.54.1"
    }
    random = {
        source = "hashicorp/random"
        version = "3.6.2"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "default"
}

resource "random_id" "ran_id" {
    byte_length = 9
  
}


output "name" {
    value = random_id.ran_id.hex
}

# Create S3 Bucket
resource "aws_s3_bucket" "demo-bucket" {
    bucket = "demo-bucket-kali-${random_id.ran_id.hex}"
}

resource "aws_s3_object" "bucketData" {
  bucket = aws_s3_bucket.demo-bucket.bucket
  source = "./myfile.txt"  # Just the filename, same directory
  key    = "mydata.txt"
}

