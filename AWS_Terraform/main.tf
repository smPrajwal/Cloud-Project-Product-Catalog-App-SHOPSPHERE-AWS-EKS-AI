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

  vpc_cidr       = var.vpc_cidr
  subnet_details = var.subnet_details
  default_region = var.default_region
}

module "compute_EKS" {
  source = "./modules/compute_EKS"

  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.subnet_ids
  eks_cluster_name    = var.eks_cluster_name
  eks_version         = var.eks_version
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size
}

module "database" {
  source = "./modules/database"

  vpc_id               = module.network.vpc_id
  db_un                = var.db_un
  db_pwd               = var.db_pwd
  db_name              = var.db_name
  db_instance_class    = var.db_instance_class
  db_engine_version    = var.db_engine_version
  db_allocated_storage = var.db_allocated_storage
  subnet_ids           = module.network.subnet_ids
  eks_node_sg_id       = module.compute_EKS.eks_node_sg_id
  lambda_sg_id         = module.aws_lambda.lambda_sg_id
}

module "storage" {
  source = "./modules/storage"

  s3_bucket_name = var.s3_bucket_name
}

module "aws_lambda" {
  source = "./modules/aws_lambda"

  vpc_id         = module.network.vpc_id
  subnet_ids     = module.network.subnet_ids
  s3_bucket_name = module.storage.s3_bucket_name
  db_endpoint    = module.database.db_conn_string
  rds_sg_id      = module.database.rds_sg_id
  lambda_runtime = var.lambda_runtime
}

module "monitoring_and_alerts" {
  source = "./modules/monitoring_and_alerts"

  sns_alert_email = var.sns_alert_email
}