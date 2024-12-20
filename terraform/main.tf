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
  source                        = "./elastic-cache"
  ec2_security_group_id         = module.ec2_launch_template.ec2_security_group_id
  vpc_id                        = var.vpc_id
  ecs_security_group_fargate_id = module.ecs.ecs_security_group_fargate_id
}


module "ecs" {
  source               = "./ecs"
  public_subnets       = var.public_subnets
  vpc_id               = var.vpc_id
  elasticache_endpoint = module.elasticache.elastic_cache_endpoint
  region               = var.region
}
