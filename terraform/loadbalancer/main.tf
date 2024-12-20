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

# Création de l'Application Load Balancer
resource "aws_lb" "std_lb" {
  name                       = "std-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.std_lb_sg.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Name = "std-lb"
  }
}

# Création d'un listener HTTP pour le load balancer
resource "aws_lb_listener" "std_listener" {
  load_balancer_arn = aws_lb.std_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.std_target_group.arn
  }
}

# Création du Target Group pour le Load Balancer
resource "aws_lb_target_group" "std_target_group" {
  name     = "std-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "std-target-group"
  }
}
