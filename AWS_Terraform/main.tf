terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.35.0, < 7.0.0"
    }
    archive = {
      source = "hashicorp/archive"
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

  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.subnet_ids
}

module "database" {
  source = "./modules/database"

  vpc_id         = module.network.vpc_id
  db_un          = var.db_un
  db_pwd         = var.db_pwd
  subnet_ids     = module.network.subnet_ids
  eks_node_sg_id = module.compute_EKS.eks_node_sg_id
  lambda_sg_id   = module.aws_lambda.lambda_sg_id
}

module "storage" {
  source = "./modules/storage"

  s3_bucket_name = var.s3_bucket_name
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.subnet_ids
  default_region = var.default_region
  s3_bucket_name = module.storage.s3_bucket_name
  db_endpoint    = module.database.db_endpoint
  rds_sg_id      = module.database.rds_sg_id
}

module "monitoring_and_alerts" {
  source = "./modules/monitoring_and_alerts"

  sns_alert_email = var.sns_alert_email
}