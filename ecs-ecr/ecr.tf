resource "aws_ecr_repository" "main" {
  name                 = "my-nginx"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "null_resource" "docker_image_push" {
  triggers = {
    run_at = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      REPO_URL="${aws_ecr_repository.main.repository_url}"
      AWS_ACCOUNT_ID="${data.aws_caller_identity.current.account_id}"
      REGION="${data.aws_region.current.id}"
      IMAGE_TAG="latest"

      # Authenticate Docker with ECR
      aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

      # Pull the nginx image from Docker Hub
      docker image pull --platform linux/arm64 nginx:alpine

      # Tag the image for ECR
      docker image tag nginx:alpine $REPO_URL:$IMAGE_TAG

      # Push the image to ECR
      docker image push --platform linux/arm64 $REPO_URL:$IMAGE_TAG
    EOF
  }

  depends_on = [
    aws_ecr_repository.main,
  ]
}