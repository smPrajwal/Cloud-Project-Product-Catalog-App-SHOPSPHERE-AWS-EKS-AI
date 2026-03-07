variable "default_region" {}

variable "subnet_details" {
  description = "This contains all the necessary details related to the subnets and their resources"
  type = map(object({
    cidr   = string
    access = string
    role   = string
  }))
}
