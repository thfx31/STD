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


module "elasticache" {
  source                        = "./elastic-cache"
  vpc_id                        = var.vpc_id
  ecs_security_group_fargate_id = module.ecs.ecs_security_group_fargate_id
}


module "ecs" {
  source               = "./ecs"
  public_subnets       = var.public_subnets
  vpc_id               = var.vpc_id
  elasticache_endpoint = module.elasticache.elastic_cache_endpoint
  region               = var.region
  target_group_arn     = module.loadbalancer.target_group_arn
}
