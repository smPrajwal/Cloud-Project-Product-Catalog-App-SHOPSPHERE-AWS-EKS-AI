variable "s3_bucket_name" {}
variable "vpc_id" {}
variable "rds_sg_id" {}
variable "db_endpoint" {
  sensitive = true
}
variable "subnet_ids" {
  type = map(string)
}