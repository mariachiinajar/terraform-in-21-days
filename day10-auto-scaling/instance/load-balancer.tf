resource "aws_security_group" "tf-load-balancer-sg" {
  name        = "tf-load-balancer-sg-${var.env_code}"
  description = "allows orivate traffic"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "HTTP from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.env_code}-load-balancer-sg"
  }
}

resource "aws_lb" "tf-load-balancer" {
  name               = "tf-load-balancer-${var.env_code}"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.tf-load-balancer-sg.id]
  subnets            = data.terraform_remote_state.network.outputs.public_subnet_id

  tags = {
    Name = var.env_code
  }
}

resource "aws_lb_target_group" "tf-load-balancer-tg" {
  name     = "tf-load-balancer-tg-${var.env_code}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
    matcher             = 200
  }
}

resource "aws_lb_listener" "tf-load-balancer-listener" {
  load_balancer_arn = aws_lb.tf-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf-load-balancer-tg.arn
  }
}
