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
  region = var.region
}

module "loadbalancer" {
  source         = "./loadbalancer"
  vpc_id         = var.vpc_id
  public_subnets = var.public_subnets
}


module "ec2_launch_template" {
  source               = "./ec2-launch-template"
  region               = var.region
  instance_type        = var.instance_type
  load_balancer_sg_id  = module.loadbalancer.load_balancer_sg_id
  vpc_id               = var.vpc_id
  elasticache_endpoint = module.elasticache.elastic_cache_endpoint
}

module "autoscaling_group" {
  source             = "./autoscaling-group"
  launch_template_id = module.ec2_launch_template.launch_template_id
  target_group_arns  = [module.loadbalancer.target_group_arn]
  public_subnets     = var.public_subnets
}

module "elasticache" {
  source                = "./elastic-cache"
  ec2_security_group_id = module.ec2_launch_template.ec2_security_group_id
}


# resource "aws_security_group" "elasticache_sg" {
#   name        = "std-elasticache-sg"
#   description = "Security group for Elasticache"

#   ingress {
#     description     = "Allow inbound traffic from EC2 instances"
#     from_port       = 6379
#     to_port         = 6379
#     protocol        = "tcp"
#     security_groups = [aws_security_group.allow_http_ssh.id]
#   }

#   egress {
#     description = "Allow all outbound traffic"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_elasticache_replication_group" "elasticache" {
#   replication_group_id = "std-elasticache"
#   description          = "STD Elasticache"
#   node_type            = "cache.t2.micro"
#   num_cache_clusters   = 1
#   engine               = "redis"

#   security_group_ids = [aws_security_group.elasticache_sg.id]
# }






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

