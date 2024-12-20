# Création du groupe de sécurité pour le Load Balancer dans le même VPC
resource "aws_security_group" "std_lb_sg" {
  name        = "std-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permet l'accès HTTP depuis partout
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "std-lb-sg"
  }
}


resource "aws_alb" "std_lb" {
  name            = "std-alb"
  security_groups = [aws_security_group.std_lb_sg.id]
  subnets         = var.public_subnets

  tags = {
    Name = "std-alb"
  }
}

# Création d'un listener HTTP pour le load balancer
resource "aws_alb_listener" "std_listener" {
  load_balancer_arn = aws_alb.std_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.std_target_group.arn
  }
}

resource "aws_alb_target_group" "std_target_group" {
  name                 = "std-target-group"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = 5

  target_type = "ip"

  stickiness {
    type            = "lb_cookie"
    cookie_duration = 3600
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 60
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
  }

  tags = {
    Name = "std-target-group"
  }

  depends_on = [aws_alb.std_lb]
}
