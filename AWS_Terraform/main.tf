terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 6.35.0, < 7.0.0"
    }
  }
  cloud {
    organization = "Practice_and_Project"
    workspaces {
      name = "AWS_Cloud_Project"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "terraform-cloud-test-bucket-123456"
}