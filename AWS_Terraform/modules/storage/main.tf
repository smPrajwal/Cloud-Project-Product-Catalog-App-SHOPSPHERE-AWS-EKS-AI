resource "aws_s3_bucket" "ss-app-images" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Project = "EKS_Project"
  }
}