resource "aws_alb" "howto_grpc" {
  name = "${var.project_name}-lb"
  internal = true
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb.id]
  subnets = [data.aws_subnet.public_a.id, data.aws_subnet.public_c.id]
}

resource "aws_alb_target_group" "howto_grpc" {
  health_check {
    enabled = true
    interval = 6
    path = "/ping"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  target_type = "ip"
  name = "${var.project_name}-tg"
  port = 80
  protocol = "HTTP"
  deregistration_delay = 120
  vpc_id = data.aws_vpc.howto_grpc.id
}

resource "aws_alb_listener" "howto_grpc" {
  load_balancer_arn = aws_alb.howto_grpc.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.howto_grpc.arn
  }
}

resource "aws_alb_listener_rule" "howto_grpc" {
  listener_arn = aws_alb_listener.howto_grpc.arn
  priority = 1
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.howto_grpc.arn
  }
  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}