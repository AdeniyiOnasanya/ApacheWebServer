#**********************Internet Gateway**********************
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}