terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      deployed    = "spacelift"
      managed     = "tofu"
      repository  = "opentofu-ecs-spacelift-automation"
      layer       = "prerequisites"
      environment = var.environment
    }
  }
}

# tflint-ignore: terraform_unused_declarations
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
