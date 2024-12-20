variable "instance_type" {
  description = "The instance type to use for the EC2 instance."
  type        = string
}

variable "region" {
  description = "The AWS region to launch the resources."
  type        = string
}

variable "load_balancer_sg_id" {
  description = "The ID of the security group for the Load Balancer."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "elasticache_endpoint" {
  description = "The endpoint of the Elasticache cluster."
  type        = string
}
