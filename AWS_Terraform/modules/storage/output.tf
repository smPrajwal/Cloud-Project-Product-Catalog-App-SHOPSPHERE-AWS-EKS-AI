output "s3_bucket_name" {
  description = "Name of the S3 bucket used for storing product images"
  value       = aws_s3_bucket.ss-app-images.bucket
}