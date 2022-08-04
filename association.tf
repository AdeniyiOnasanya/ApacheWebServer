#**********************associate public route table to subnetA**********************
resource "aws_route_table_association" "public_subnet1" {
  subnet_id      = aws_subnet.subnetA.id
  route_table_id = aws_route_table.public_router.id
}

#**********************associate public route table to subnetAA**********************
resource "aws_route_table_association" "public_subnet2" {
  subnet_id      = aws_subnet.subnetAA.id
  route_table_id = aws_route_table.public_router.id
}