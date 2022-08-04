
#**********************Nat Gateway**********************
resource "aws_nat_gateway" "Nat_G" {
  allocation_id = aws_eip.lb1.id
  subnet_id     = aws_subnet.subnetA.id

  tags = {
    Name = "NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.IG]
}

#**********************Elastic IP Address for Nat**********************
resource "aws_eip" "lb1" {
  vpc                       = true
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.IG]
}