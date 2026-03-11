output "eks_node_sg_id" {
  description = "This represents the Security Group of EKS nodes"
  value       = aws_security_group.eks-nodes-sg.id
}