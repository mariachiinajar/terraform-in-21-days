terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"

    backend "s3" {
        bucket         = "terraform-in-21-days-remote-state"
        key            = "level1-network.tfstate"
        region         = "us-east-1"
        dynamodb_table = "terraform-in-21-days-remote-state"
    }
}

provider "aws" {
    region = "us-east-1"
}

