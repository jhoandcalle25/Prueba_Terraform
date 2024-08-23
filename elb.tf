resource "aws_lb" "alb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG_JFK.id]
  subnets            = [aws_subnet.subred_publica_1.id, aws_subnet.subred_publica2.id]
}

resource "aws_lb_target_group" "target" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-infra.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target.arn
  }
}



