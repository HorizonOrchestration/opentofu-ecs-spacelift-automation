terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      deployed   = "spacelift"
      managed    = "tofu"
      repository = "opentofu-ecs-spacelift-automation"
      layer      = "prerequisites"
    }
  }
}

data "aws_caller_identity" "current" {}
