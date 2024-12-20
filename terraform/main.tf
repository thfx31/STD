terraform {
  cloud {
    organization = "STD"

    workspaces {
      name = "STD"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.202*-x86_64-ebs"]
  }
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "std-allow-http-ssh"
  description = "Security group to allow HTTP and SSH access"

  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elasticache_sg" {
  name        = "std-elasticache-sg"
  description = "Security group for Elasticache"

  ingress {
    description     = "Allow inbound traffic from EC2 instances"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_http_ssh.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id = "std-elasticache"
  description          = "STD Elasticache"
  node_type            = "cache.t2.micro"
  num_cache_clusters   = 1
  engine               = "redis"

  security_group_ids = [aws_security_group.elasticache_sg.id]
}

resource "aws_launch_template" "std_launch_template" {
  name_prefix   = "std-launch-template"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = "t2.micro"
  key_name      = "SRE-KeyPair"

  user_data = <<-EOF
              #!/bin/bash
              docker pull ghcr.io/thfx31/std/chat-server:latest
              docker run -d -p 80:3000 \
                -e ELASTICACHE_ENDPOINT=${aws_elasticache_replication_group.elasticache.primary_endpoint_address} \
                ghcr.io/thfx31/std/chat-server:latest
              EOF

  security_group_names = [aws_security_group.allow_http_ssh.name]

  tags = {
    Name = "STD-EC2"
  }
}

resource "aws_autoscaling_group" "std_asg" {
  desired_capacity    = 2
  max_size            = 1
  min_size            = 3
  vpc_zone_identifier = ["subnet-02ae3d0545ef9967e", "subnet-01bac5268bd103c55", "subnet-0655f72c900baddc5"]
  launch_template {
    id      = aws_launch_template.std_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.TP_TargetGroup.arn]

  tag {
    key                 = "Name"
    value               = "STD-EC2"
    propagate_at_launch = true
  }
}


# resource "aws_instance" "ecs_instance" {
#   vpc_security_group_ids = [aws_security_group.allow_http_ssh.id]

#   ami           = data.aws_ami.ecs_optimized_ami.id
#   instance_type = "t2.micro"
#   key_name      = "SRE-KeyPair"

#   user_data = <<-EOF
#               #!/bin/bash
#               docker pull ghcr.io/thfx31/std/chat-server:latest
#               docker run -d -p 80:3000 \
#                 -e ELASTICACHE_ENDPOINT=${aws_elasticache_replication_group.elasticache.primary_endpoint_address} \
#                 ghcr.io/thfx31/std/chat-server:latest
#               EOF


#   tags = {
#     Name = "STD-EC2"
#   }
# }

output "elasticache_endpoint" {
  value = aws_elasticache_replication_group.elasticache.primary_endpoint_address
}

resource "aws_lb" "TP_LoadBalancer" {
  name               = "STD-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "TP_TargetGroup" {
  name        = "tp-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
}

resource "aws_lb_listener" "TP_Listener" {
  load_balancer_arn = aws_lb.TP_LoadBalancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TP_TargetGroup.arn
  }
}
