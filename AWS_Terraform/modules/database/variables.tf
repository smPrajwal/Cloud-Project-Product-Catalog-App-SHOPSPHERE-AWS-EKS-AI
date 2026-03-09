variable "db_un" {}

variable "db_pwd" {
  sensitive = true
}

variable "subnet_ids" {
  description = "This holds all the subnet IDs"
  type        = map(string)
}