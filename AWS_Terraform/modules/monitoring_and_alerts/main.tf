resource "aws_sns_topic" "ss-app-resource-sns-alerts" {
  name = "shopsphere-app-resource-sns-alerts"

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_sns_topic_subscription" "email-alert-sns-subscription" {
  topic_arn = aws_sns_topic.ss-app-resource-sns-alerts.arn
  protocol  = "email"
  endpoint  = var.sns_alert_email
}

resource "aws_cloudwatch_metric_alarm" "eks-node-cpu-alarm" {
  alarm_name          = "eks-node-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "EKS node CPU utilization exceeded 70%"
  alarm_actions       = [aws_sns_topic.ss-app-resource-sns-alerts.arn]

  tags = {
    Project = "EKS_Project"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds-cpu-alarm" {
  alarm_name          = "rds-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "RDS CPU utilization exceeded 70%"
  alarm_actions       = [aws_sns_topic.ss-app-resource-sns-alerts.arn]

  tags = {
    Project = "EKS_Project"
  }
}