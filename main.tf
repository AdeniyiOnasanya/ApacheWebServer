terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}
# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr[0].cidr

  tags = {
    Name = "main"
  }
}