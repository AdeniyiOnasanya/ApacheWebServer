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
# **********************VPC **********************
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr[0].cidr

  tags = {
    Name = var.vpc_cidr[0].name
  }
}


#**********************Internet Gateway**********************
resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}
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


#*********Custom Route Tables***************

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

#**********************Security Group**********************

resource "aws_security_group" "web" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


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

#**********************Subnet**********************
resource "aws_subnet" "subnetA" {
    availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnetA"
  }
}

#**********************Public Subnet 2**********************
resource "aws_subnet" "subnetAA" {
  availability_zone = "us-east-1b"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "subnetAA"
  }
}
#**********************associate private route table to Private Subnet**********************
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnetB.id
  route_table_id = aws_route_table.private_router.id
}

#**********************Private Subnet**********************
resource "aws_subnet" "subnetB" {
    availability_zone = "us-east-1a"
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "subnetA"
  }
}
#*****************Lauch Template**********************
resource "aws_launch_template" "Temp" {
  name_prefix   = "Temp"
  image_id      = "ami-090fa75af13c156b4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = filebase64("${path.module}/apache.sh")
  

              
}
#******************Autoscaling_group*********************
resource "aws_autoscaling_group" "bar" {
  desired_capacity   = 2
  max_size           = 3
  min_size           = 1
  vpc_zone_identifier =[aws_subnet.subnetA.id,aws_subnet.subnetAA.id]
  

  launch_template {
    id      = aws_launch_template.Temp.id
    version = "1"
  }
}

#******************Application loadbalancer*********************
resource "aws_lb" "alb" {
  name               = "main-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets=[aws_subnet.subnetA.id,aws_subnet.subnetAA.id]
  

  
}

#******************lb_target_group*********************
resource "aws_lb_target_group" "alb_tgp" {
  name        = "MainAlbTgp"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
}

#******************lb_listener*********************

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tgp.arn
  }
}
resource "aws_autoscaling_attachment" "associate" {
  autoscaling_group_name = aws_autoscaling_group.bar.id
  lb_target_group_arn   = aws_lb_target_group.alb_tgp.arn
}


