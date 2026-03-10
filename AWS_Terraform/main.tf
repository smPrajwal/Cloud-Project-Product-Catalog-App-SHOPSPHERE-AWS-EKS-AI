terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
  region = var.default_region
}

module "network" {
  source = "./modules/network"

  subnet_details = var.subnet_details
  default_region = var.default_region
}

module "compute_EKS" {
  source = "./modules/compute_EKS"

  subnet_ids = module.network.subnet_ids
}

module "database" {
  source = "./modules/database"

  db_un      = var.db_un
  db_pwd     = var.db_pwd
  subnet_ids = module.network.subnet_ids
}

module "storage" {
  source = "./modules/storage"

  s3_bucket_name = var.s3_bucket_name
}