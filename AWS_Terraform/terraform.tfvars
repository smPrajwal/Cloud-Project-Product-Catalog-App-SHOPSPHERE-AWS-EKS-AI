default_region = "ap-south-1"
vpc_cidr       = "10.0.0.0/16"
subnet_details = {
  "public-AZ1" = {
    cidr   = "10.0.1.0/24"
    access = "public"
    role   = "public-infra"
    az     = "a"
  }
  "public-AZ2" = {
    cidr   = "10.0.2.0/24"
    access = "public"
    role   = "alb-ingress"
    az     = "b"
  }
  "application-EKS-AZ1" = {
    cidr   = "10.0.3.0/24"
    access = "private"
    role   = "application-EKS"
    az     = "a"
  }
  "application-EKS-AZ2" = {
    cidr   = "10.0.4.0/24"
    access = "private"
    role   = "application-EKS"
    az     = "b"
  }
  "rds-AZ1" = {
    cidr   = "10.0.5.0/24"
    access = "private"
    role   = "rds-sub"
    az     = "a"
  }
  "rds-AZ2" = {
    cidr   = "10.0.6.0/24"
    access = "private"
    role   = "rds-sub"
    az     = "b"
  }
}

eks_cluster_name    = "eks-cluster"
eks_version         = "1.35"
node_instance_types = ["t3.small"]
node_capacity_type  = "SPOT"
node_desired_size   = 1
node_max_size       = 2
node_min_size       = 1

db_un                = "prajwalsm"
db_pwd               = "Prajwalsm53"
db_name              = "shopsphere"
db_instance_class    = "db.t3.micro"
db_engine_version    = "8.0"
db_allocated_storage = 20

s3_bucket_name  = "shopsphere-app-images-bucket"
lambda_runtime  = "python3.12"
sns_alert_email = "prajwalprajwal1999@gmail.com"