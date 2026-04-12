terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.33"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Name = "terraform-test"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
