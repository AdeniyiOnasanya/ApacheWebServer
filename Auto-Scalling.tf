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