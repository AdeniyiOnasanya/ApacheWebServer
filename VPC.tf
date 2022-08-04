# **********************VPC **********************
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr[0].cidr

  tags = {
    Name = var.vpc_cidr[0].name
  }
}