output "db_endpoint" {
  description = "RDS database endpoint used for connecting to SQL Server"
  value       = aws_db_instance.rds-db.address
  sensitive   = true
}
output "rds_sg_id" {
  description = "This represents the Security Group of RDS"
  value       = aws_security_group.rds-sg.id
}