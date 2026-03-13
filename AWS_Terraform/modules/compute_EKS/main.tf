resource "aws_eks_cluster" "eks-cluster" {
  name = "eks-cluster"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.eks-cluster-role.arn
  version  = "1.35"

  vpc_config {
    subnet_ids = [
      var.subnet_ids["application-EKS-AZ1"],
      var.subnet_ids["application-EKS-AZ2"]
    ]
    security_group_ids = [aws_security_group.eks-nodes-sg.id]
  }

  tags = {
    Project = "EKS_Project"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]
}

resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["sts:AssumeRole", "sts:TagSession"]
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_eks_node_group" "eks-cluster-ng" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "eks-cluster-node-group"
  node_role_arn   = aws_iam_role.eks-cluster-ng-role.arn
  subnet_ids = [
    var.subnet_ids["application-EKS-AZ1"],
    var.subnet_ids["application-EKS-AZ2"]
  ]
  instance_types = ["t3.small"]
  capacity_type  = "SPOT"

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Project = "EKS_Project"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_ng_role_policies,
  ]
}

resource "aws_iam_role" "eks-cluster-ng-role" {
  name = "eks-cluster-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_iam_role_policy_attachment" "eks_ng_role_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/ComprehendFullAccess"
  ])

  policy_arn = each.value
  role       = aws_iam_role.eks-cluster-ng-role.name
}

resource "aws_eks_access_entry" "eks-access-entry" {
  for_each = toset([
    "arn:aws:iam::676290433104:root",
    "arn:aws:iam::676290433104:user/Prajwal"
  ])

  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = each.value
  type          = "STANDARD"

  tags = {
    Name    = "eks-access-entry"
    Project = "EKS_Project"
  }
}

resource "aws_eks_access_policy_association" "admin-eks-access" {
  for_each = toset([
    "arn:aws:iam::676290433104:root",
    "arn:aws:iam::676290433104:user/Prajwal"
  ])

  cluster_name  = aws_eks_cluster.eks-cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_ecr_repository" "ss-application-ecr" {
  for_each = toset([
    "ss-application-frontend",
    "ss-application-backend"
  ])
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_security_group" "eks-nodes-sg" {
  name        = "eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic from ALB"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "EKS_Project"
  }
}