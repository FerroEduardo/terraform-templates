output "lb-url" {
  value = "http://${aws_lb.ecs-nginx.dns_name}"
}