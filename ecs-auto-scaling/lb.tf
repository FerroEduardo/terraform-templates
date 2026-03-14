resource "aws_lb_target_group" "ecs-nginx" {
  name        = "tf-ecs-nginx-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled  = true
    path     = "/"
    interval = 30
    timeout  = 5
  }
}

resource "aws_lb" "ecs-nginx" {
  name               = "ecs-nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = [for subnet in aws_subnet.main : subnet.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ecs-nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-nginx.arn
  }
}