resource "aws_db_subnet_group" "rds-db-sub-group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [var.subnet_ids["rds-AZ1"], var.subnet_ids["rds-AZ2"]]

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_db_instance" "rds-db" {
  allocated_storage      = 20
  engine                 = "sqlserver-ex"
  engine_version         = "16.00.4236.2.v1"
  instance_class         = "db.t3.micro"
  username               = var.db_un
  password               = var.db_pwd
  skip_final_snapshot    = true
  license_model          = "license-included"
  identifier             = "ss-rds-db"
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-db-sub-group.name

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "Security group for RDS SQL Server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from EKS nodes"
    from_port       = 1433
    to_port         = 1433
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_security_group_rule" "rds-ingress-sg-rule" {
  type                     = "ingress"
  description              = "Allow traffic from Lambda"
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds-sg.id
  source_security_group_id = var.lambda_sg_id
}