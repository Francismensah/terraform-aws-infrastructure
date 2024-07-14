terraform {
    backend "s3" {
      bucket = "morkeh-terraform-state"
      key = "terraform-state"
      region = "eu-north-1"
      dynamodb_table = "Terraform-backend-lock"
    }
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~> 4.50"
      }
    }
}

provider "aws" {
  profile = "terraform"
  assume_role {
    role_arn = "arn:aws:iam::637423233233:role/terraform-role"
    session_name = "AWS_Session"
  }
}