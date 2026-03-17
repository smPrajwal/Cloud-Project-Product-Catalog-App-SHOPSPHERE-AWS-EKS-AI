output "db_conn_string" {
  description = "Database connection string for the application"
  value       = "${aws_db_instance.rds-db.address}:${var.db_un}:${var.db_pwd}:${var.db_name}"
  sensitive   = true
}
output "rds_sg_id" {
  description = "This represents the Security Group of RDS"
  value       = aws_security_group.rds-sg.id
}