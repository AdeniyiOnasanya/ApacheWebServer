#**********************Subnet**********************
resource "aws_subnet" "subnetA" {
    availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnetA"
  }
}

#**********************Public Subnet 2**********************
resource "aws_subnet" "subnetAA" {
  availability_zone = "us-east-1b"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnetAA"
  }
}
#**********************associate private route table to Private Subnet**********************
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnetB.id
  route_table_id = aws_route_table.private_router.id
}