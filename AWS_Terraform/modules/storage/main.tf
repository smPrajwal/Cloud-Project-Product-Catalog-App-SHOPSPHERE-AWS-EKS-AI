resource "aws_s3_bucket" "ss-app-images" {
  bucket = var.s3_bucket_name

  tags = {
    Project = "EKS_Project"
  }
}