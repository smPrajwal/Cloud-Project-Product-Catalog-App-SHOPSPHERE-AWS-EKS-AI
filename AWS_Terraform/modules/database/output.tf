output "db_endpoint" {
  description = "RDS database endpoint used for connecting to SQL Server"
  value       = aws_db_instance.rds-db.address
  sensitive   = true
}
output "db_conn_string" {
  description = "Full database connection string for the application"
  value       = "DRIVER={ODBC Driver 18 for SQL Server};SERVER=${aws_db_instance.rds-db.address};DATABASE=shopsphere;UID=${var.db_un};PWD=${var.db_pwd}"
  sensitive   = true
}
output "rds_sg_id" {
  description = "This represents the Security Group of RDS"
  value       = aws_security_group.rds-sg.id
}