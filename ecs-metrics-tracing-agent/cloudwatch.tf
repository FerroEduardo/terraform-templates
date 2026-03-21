resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/app"
  retention_in_days = 1
}

resource "aws_cloudwatch_dashboard" "app" {
  dashboard_name = "app-metrics"
  dashboard_body = file("${path.module}/dashboard.json")
}