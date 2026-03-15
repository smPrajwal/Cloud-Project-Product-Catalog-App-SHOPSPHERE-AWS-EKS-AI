resource "aws_s3_bucket" "ss-app-images" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_s3_bucket_public_access_block" "ss-app-s3-bucket-images-public" {
  bucket = aws_s3_bucket.ss-app-images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "ss-app-s3-bucket-policy" {
  bucket     = aws_s3_bucket.ss-app-images.id
  depends_on = [aws_s3_bucket_public_access_block.ss-app-s3-bucket-images-public]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.ss-app-images.arn}/product_images/*"
    }]
  })
}