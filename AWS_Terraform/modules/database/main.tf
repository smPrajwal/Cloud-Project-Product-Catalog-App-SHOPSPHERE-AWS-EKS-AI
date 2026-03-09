resource "aws_db_subnet_group" "rds-db-sub-group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [var.subnet_ids["rds-AZ1"], var.subnet_ids["rds-AZ2"]]

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_db_instance" "rds-db" {
  allocated_storage    = 20
  engine               = "sqlserver-ex"
  engine_version       = "16.00.4236.2.v1"
  instance_class       = "db.t3.micro"
  username             = var.db_un
  password             = var.db_pwd
  skip_final_snapshot  = true
  license_model        = "license-included"
  identifier           = "ss-rds-db"
  db_subnet_group_name = aws_db_subnet_group.rds-db-sub-group.name

  tags = {
    Project = "EKS_Project"
  }
}