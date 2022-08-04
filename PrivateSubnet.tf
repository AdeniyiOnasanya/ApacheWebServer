#**********************Private Subnet**********************
resource "aws_subnet" "subnetB" {
    availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"
  

  tags = {
    Name = "subnetA"
  }
}