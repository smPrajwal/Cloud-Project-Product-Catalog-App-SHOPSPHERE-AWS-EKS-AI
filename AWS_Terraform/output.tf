output "ecr_frontend_url" {
  description = "ECR repository URL for frontend application image"
  value       = module.compute_EKS.ecr_frontend_url
}
output "ecr_backend_url" {
  description = "ECR repository URL for backend application image"
  value       = module.compute_EKS.ecr_backend_url
}
output "ecr_registry_url" {
  description = "ECR registry URL for docker login and logout"
  value       = module.compute_EKS.ecr_registry_url
}
output "s3_bucket_name" {
  description = "Name of the S3 bucket used for storing product images"
  value       = module.storage.s3_bucket_name
}
output "db_conn_string" {
  description = "Full database connection string for the application"
  value       = module.database.db_conn_string
  sensitive   = true
}
output "vpc_id" {
  description = "This holds the vpc ID"
  value       = module.network.vpc_id
}