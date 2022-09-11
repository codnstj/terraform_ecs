provider "aws" {
  region = var.region
}

terraform {
  backend "remote" {
    organization = "codns"
    workspaces {
      name = "TerraForm_tutorial"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

resource "aws_route53_zone" "chaewoon" {
  name = var.domain
  force_destroy = true
}