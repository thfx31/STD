
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
}

# Création du groupe de sécurité pour les instances EC2
resource "aws_security_group" "std_ec2_sg" {
  name        = "std-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Autoriser l'accès HTTP (port 80) uniquement depuis le Load Balancer
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.load_balancer_sg_id]
  }

  # Permettre la sortie vers n'importe quelle adresse
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "std-ec2-sg"
  }
}

# Launch template pour l'instance EC2
resource "aws_launch_template" "std_launch_template" {
  name_prefix   = "std-launch-template"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.instance_type
  placement {
    availability_zone = "${var.region}a"
  }

  key_name = "SRE-KeyPair"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              docker pull ghcr.io/thfx31/std/chat-server:latest
              docker run -d -p 80:3000 \
                -e ELASTICACHE_ENDPOINT=${var.elasticache_endpoint} \
                ghcr.io/thfx31/std/chat-server:latest
              EOF
  )

  network_interfaces {
    security_groups = [aws_security_group.std_ec2_sg.id]
  }
}
