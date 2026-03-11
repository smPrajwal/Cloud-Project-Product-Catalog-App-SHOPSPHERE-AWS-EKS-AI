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

