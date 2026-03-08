output "subnet_ids" {
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}