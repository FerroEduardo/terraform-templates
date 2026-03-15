# ECS Task Execution Role
# This role is required for Fargate tasks to pull images from ECR and send logs to CloudWatch.
# The trust policy allows only ECS tasks (ecs-tasks.amazonaws.com) to assume this role.
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
  description = "Role for ECS tasks to pull images from ECR and send logs to CloudWatch"

  # Trust policy: defines which AWS service can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS managed policy for ECS task execution
# This policy grants permissions to:
#   - Pull images from ECR (ecr:GetAuthorizationToken, ecr:BatchGetImage, etc.)
#   - Write logs to CloudWatch (logs:CreateLogStream, logs:PutLogEvents)
# Note: This managed policy uses Resource: "*" (all resources), which is convenient
# but grants broader permissions than strictly necessary. For production, consider
# using a custom inline policy scoped to specific ECR repositories and log groups.
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}