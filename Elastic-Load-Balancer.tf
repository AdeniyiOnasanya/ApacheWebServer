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
