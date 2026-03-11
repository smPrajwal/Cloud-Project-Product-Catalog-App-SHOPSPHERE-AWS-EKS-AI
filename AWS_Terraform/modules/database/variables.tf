variable "db_un" {}
variable "vpc_id" {}
variable "eks_node_sg_id" {}
variable "lambda_sg_id" {}
variable "db_pwd" {
  sensitive = true
}
variable "subnet_ids" {
  type = map(string)
}