default_region = "ap-south-1"



subnet_details = {
  "public" = {
    cidr   = "10.0.1.0/24"
    access = "public"
    role   = "public"
    az     = "a"
  }
  "application-EKS-AZ1" = {
    cidr   = "10.0.2.0/24"
    access = "private"
    role   = "application-EKS"
    az     = "a"
  }
  "application-EKS-AZ2" = {
    cidr   = "10.0.3.0/24"
    access = "private"
    role   = "application-EKS"
    az     = "b"
  }
  "rds-AZ1" = {
    cidr   = "10.0.4.0/24"
    access = "private"
    role   = "rds-sub"
    az     = "a"
  }
  "rds-AZ2" = {
    cidr   = "10.0.5.0/24"
    access = "private"
    role   = "rds-sub"
    az     = "b"
  }
}