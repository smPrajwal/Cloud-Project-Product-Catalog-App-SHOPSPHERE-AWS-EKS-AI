resource "aws_lambda_function" "lambda-function" {
  filename      = data.archive_file.lambda_code.output_path
  function_name = "lambda_function_for_ai_image_tag"
  role          = aws_iam_role.lambda-role.arn
  handler       = "lambda_function.lambda_handler"
  code_sha256   = data.archive_file.lambda_code.output_base64sha256

  runtime = "python3.12"
  timeout = 30

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
      DB_CONN_STRING = var.db_endpoint
    }
  }

  vpc_config {
    subnet_ids         = [var.subnet_ids["application-EKS-AZ1"]]
    security_group_ids = [aws_security_group.lambda-sg.id]
  }

  tags = {
    Project = "EKS_Project"
  }
}

data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_package"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_iam_role" "lambda-role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_iam_role_policy_attachment" "lambda-role-policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonRekognitionFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  ])

  policy_arn = each.value
  role       = aws_iam_role.lambda-role.name
}

resource "aws_s3_bucket_notification" "s3-trigger" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda-function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.s3-invoke
  ]
}

resource "aws_lambda_permission" "s3-invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda-function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_bucket_name}"
}

resource "aws_security_group" "lambda-sg" {
  name        = "lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow HTTPS for Rekognition and S3"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Allow traffic to RDS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.rds_sg_id]
  }

  tags = {
    Project = "EKS_Project"
  }
}
