resource "aws_ecs_cluster" "app" {
  name = "app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "app" {
  cluster_name = aws_ecs_cluster.app.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  # https://raw.githubusercontent.com/aws-observability/aws-otel-collector/main/deployment-template/ecs/aws-otel-fargate-sidecar-deployment-cfn.yaml
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "eduardoferro/basic-node-metrics:v3" # https://hub.docker.com/r/eduardoferro/basic-node-metrics
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app"
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs-app"
        }
      }
      environment = [
        {
          name  = "PORT"
          value = "3000"
        },
        {
          name  = "OLTP_TRACES_ENDPOINT"
          value = "http://localhost:4318/v1/traces"
        },
        {
          name  = "OLTP_METRICS_ENDPOINT"
          value = "http://localhost:4318/v1/metrics"
        },
      ]
    },
    {
      name   = "aws-otel-collector"
      image  = "public.ecr.aws/aws-observability/aws-otel-collector:latest"
      # https://github.com/aws-observability/aws-otel-collector/blob/5053e4f02294549909e61490a3ac72fe15d245c6/config/ecs/ecs-cloudwatch-xray.yaml
      command = ["--config=/etc/ecs/ecs-default-config.yaml"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/app"
          "awslogs-region"        = data.aws_region.current.id
          "awslogs-stream-prefix" = "ecs-app"
        }
      }
      healthCheck = {
        command     = ["/healthcheck"]
        interval    = 10
        timeout     = 5
        retries     = 3
        startPeriod = 15
      }
    },
  ])

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  depends_on = [
    aws_cloudwatch_log_group.app,
  ]
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    assign_public_ip = true
    security_groups = [
      aws_security_group.main.id
    ]
    subnets = [for subnet in aws_subnet.main : subnet.id]
  }

  depends_on = []
}
