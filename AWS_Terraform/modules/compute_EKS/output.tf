output "eks_node_sg_id" {
  description = "This represents the Security Group of EKS nodes"
  value       = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
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
output "lbc_policy_arn" {
  description = "ARN of the IAM policy for the AWS Load Balancer Controller"
  value       = aws_iam_policy.aws-lb-controller-IAMPolicy.arn
}