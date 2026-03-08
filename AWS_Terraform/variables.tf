variable "default_region" {
  description = "This represents the default region"
  default     = "ap-south-1"
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

