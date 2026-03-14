resource "aws_ecs_cluster" "nginx" {
  name = "nginx-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "nginx" {
  cluster_name = aws_ecs_cluster.nginx.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"
  cpu    = 256
  memory = 512
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:alpine"
      essential = true
      cpu       = 128
      memory    = 256
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    },
  ])

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

# terraform destroy -target aws_ecs_service.nginx
resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.nginx.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.main.id
    ]
    subnets = [
      aws_subnet.main.id
    ]
  }
}

