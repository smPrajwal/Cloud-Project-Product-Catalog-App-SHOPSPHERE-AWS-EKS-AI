variable "vpc_cidr" {}
variable "default_region" {}
variable "subnet_details" {
  type = map(object({
    cidr   = string
    access = string
    role   = string
    az     = string
  }))
}
