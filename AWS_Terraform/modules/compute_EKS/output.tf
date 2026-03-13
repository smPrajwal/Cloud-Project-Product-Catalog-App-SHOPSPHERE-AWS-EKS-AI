output "eks_node_sg_id" {
  description = "This represents the Security Group of EKS nodes"
  value       = aws_security_group.eks-nodes-sg.id
}
output "ecr_frontend_url" {
  value = aws_ecr_repository.ss-application-ecr["ss-application-frontend"].repository_url
}
output "ecr_backend_url" {
  value = aws_ecr_repository.ss-application-ecr["ss-application-backend"].repository_url
}
output "ecr_registry_url" {
  value = split("/", aws_ecr_repository.ss-application-ecr["ss-application-frontend"].repository_url)[0]
}