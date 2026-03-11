output "lambda_sg_id" {
  description = "This represents the Security Group of lambda function"
  value       = aws_security_group.lambda-sg.id
}