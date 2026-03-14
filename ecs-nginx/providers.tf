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
  region = "ap-south-1" # Mumbai

  default_tags {
    tags = {
      name = "terraform-test"
    }
  }
}
