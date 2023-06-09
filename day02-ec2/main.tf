terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.16"
      }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "app_server" {
    ami           = "ami-0715c1897453cabd1"  # Amazon Linux 2023 AMI, free tier eligible official Amazon linux image.
    instance_type = "t3.micro" 
}

