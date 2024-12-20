# variable "ec2_security_group_id" {
#   description = "The ID of the EC2 security group."
#   type        = string
# }

variable "ecs_security_group_fargate_id" {
  description = "The ID of the ECS security group for Fargate."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}
