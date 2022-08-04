# Allow all traffic to the internet through the internet gateway
resource "aws_route_table" "public_router" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IG.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.IG.id
  }

  tags = {
    Name = "router1"
  }
}

#**********************Allow all traffic to the Nat gateway **********************
resource "aws_route_table" "private_router" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_G.id
  }

 

  tags = {
    Name = "router1"
  }
}