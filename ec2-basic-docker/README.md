# Basic Terraform EC2 Setup

This project provisions basic AWS network resources such as VPC, subnet, and security group, and then creates an EC2 instance.


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

0. Create all AWS resources such as VPC, security group, and EC2 instance
    ```shell
    terraform apply
    ```

0. After Nginx is running, access the public IP in your browser or use curl
    ```shell
    curl "http://$(terraform output -raw instance-ip)"
    ```

### Access EC2 instance using SSH

```shell
ssh -i keys/rsa-4096.pem "ubuntu@$(terraform output -raw instance-ip)"
```

### Delete all resources

```shell
terraform destroy
```

## Note

This project uses a basic ARM instance (`t4g.nano`) in the Mumbai region (`ap-south-1`). Running it for a few hours should not generate significant costs.