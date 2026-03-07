default_region = "ap-south-1"



subnet_details = {
  "public" = {
    cidr   = "10.0.1.0/24"
    access = "public"
    role   = "public"
  }
  "application-EKS" = {
    cidr   = "10.0.2.0/24"
    access = "private"
    role   = "application-EKS"
  }
  "rds-AZ1" = {
    cidr   = "10.0.3.0/24"
    access = "private"
    role   = "rds-az-1"
  }
  "rds-AZ2" = {
    cidr   = "10.0.4.0/24"
    access = "private"
    role   = "rds-az-2"
  }
}