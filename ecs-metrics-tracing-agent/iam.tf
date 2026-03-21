# References:
# - https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy-container-insights-ECS-adot.html
# - https://aws-otel.github.io/docs/setup/ecs

# IAM Roles for ECS Task Execution and Task Runtime
#
# ECS uses TWO different IAM roles:
#
# 1. EXECUTION ROLE (ecs_task_execution):
#    - Used by Fargate infrastructure to set up the task
#    - Runs BEFORE the container starts
#    - Permissions needed:
#      * Pull images from ECR
#      * Create CloudWatch log streams (for container logs)
#      * Read SSM parameters (for secrets/config)
#    - Specified in task_definition.execution_role_arn
#
# 2. TASK ROLE (ecs_task):
#    - Used by the RUNNING container to make AWS API calls
#    - Assumed by the application code inside the container
#    - Permissions needed:
#      * Send metrics to CloudWatch
#      * Send traces to X-Ray
#      * Access AWS services (S3, DynamoDB, etc.)
#    - Specified in task_definition.task_role_arn
#    - Exposed to container via AWS_CONTAINER_CREDENTIALS_RELATIVE_URI
#

# -----------------------------------------------------------------------------
# EXECUTION ROLE - For Fargate infrastructure to pull images and create log streams
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  # Trust policy: only ECS tasks can assume this role
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

# Managed policy that grants:
# - ECR pull access (ecr:GetAuthorizationToken, etc.)
# - CloudWatch Logs create/put access (for container logs)
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional SSM access for reading configuration/secrets at startup
resource "aws_iam_role_policy_attachment" "amazon_ssm_read_only" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# -----------------------------------------------------------------------------
# TASK ROLE - For the running ADOT collector to send metrics and traces
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ecs_task" {
  name = "ecsTaskRole"

  # Trust policy: only ECS tasks can assume this role
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

# Custom policy for ADOT collector-specific permissions
# Combines CloudWatch Logs, SSM, and X-Ray access in one policy
resource "aws_iam_policy" "aws_distro_otel_policy" {
  name = "AWSDistroOpenTelemetryPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsAccess"
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMParameterAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = "*"
      },
      {
        Sid    = "XRayAccess"
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the custom ADOT policy to the task role
resource "aws_iam_role_policy_attachment" "aws_distro_otel_policy_attachment" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.aws_distro_otel_policy.arn
}

# CloudWatch metrics access for sending EMF (Embedded Metric Format) data
resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch_metrics" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# X-Ray daemon write access for sending traces
resource "aws_iam_role_policy_attachment" "ecs_task_xray" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

