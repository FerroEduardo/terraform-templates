# Terraform ECS with NGINX, LB and Auto Scaling

This project provisions an ECS Fargate cluster running an Nginx container behind an Application Load Balancer with CPU-based auto scaling.

> [!TIP]
> The infrastructure details can be found in the `.tf` files.

## Requirements

1. Install [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
0. Install [Terraform CLI](https://developer.hashicorp.com/terraform/install)

## How to execute

### Create and setup resources

1. Log in to AWS
    ```
    aws login
    ```

0. Initialize Terraform
    ```
    terraform init
    ```

0. Create all AWS resources
    ```shell
    terraform apply
    ```

0. Access the load balancer URL
    ```shell
    curl "$(terraform output -raw lb-url)"
    ```

### Trigger auto scaling

Use the included script to generate load and trigger scaling:
```shell
./trigger_lb_load.sh 50 500
```

### Delete all resources

```shell
terraform destroy
```