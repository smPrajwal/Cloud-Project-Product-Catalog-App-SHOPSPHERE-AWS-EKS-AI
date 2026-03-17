variable "vpc_id" {}
variable "subnet_ids" {
  type = map(string)
}
variable "eks_cluster_name" {}
variable "eks_version" {}
variable "node_instance_types" {
  type = list(string)
}
variable "node_capacity_type" {}
variable "node_desired_size" {}
variable "node_max_size" {}
variable "node_min_size" {}