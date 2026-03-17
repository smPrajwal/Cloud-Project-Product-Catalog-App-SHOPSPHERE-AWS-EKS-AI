variable "default_region" {
  description = "This represents the default region"
  default     = "ap-south-1"
  type        = string
}

variable "db_un" {
  description = "This will hold the username of SQL DB"
  type        = string
}

variable "db_pwd" {
  description = "This will hold the password of SQL DB"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "This represents the default S3 bucket name"
  default     = "shopsphere-app-images-bucket"
  type        = string
}

variable "sns_alert_email" {
  description = "This represents the Mail ID which is subscribed to the SNS Topic"
  default     = "prajwalprajwal1999@gmail.com"
  type        = string
}

variable "subnet_details" {
  description = "This contains all the necessary details related to the subnets and their resources"
  type = map(object({
    cidr   = string
    access = string
    role   = string
    az     = string
  }))
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "eks-cluster"
  type        = string
}

variable "eks_version" {
  description = "Kubernetes version for the EKS cluster"
  default     = "1.35"
  type        = string
}

variable "node_instance_types" {
  description = "Instance types for the EKS worker nodes"
  default     = ["t3.small"]
  type        = list(string)
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS worker nodes (ON_DEMAND or SPOT)"
  default     = "SPOT"
  type        = string
}

variable "node_desired_size" {
  description = "Desired number of worker nodes in the EKS node group"
  default     = 1
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes in the EKS node group"
  default     = 2
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes in the EKS node group"
  default     = 1
  type        = number
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  default     = "db.t3.micro"
  type        = string
}

variable "db_engine_version" {
  description = "MySQL engine version for the RDS database"
  default     = "8.0"
  type        = string
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB for the RDS database"
  default     = 20
  type        = number
}

variable "db_name" {
  description = "Name of the database to create in the RDS instance"
  default     = "shopsphere"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  default     = "python3.12"
  type        = string
}
