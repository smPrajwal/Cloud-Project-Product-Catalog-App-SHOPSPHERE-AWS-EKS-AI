output "vpc_id" {
  description = "This holds the vpc ID"
  value       = aws_vpc.vpc.id
}

output "subnet_ids" {
  description = "This holds all the subnet IDs"
  value = {
    for k, v in aws_subnet.subnet : k => v.id
  }
}