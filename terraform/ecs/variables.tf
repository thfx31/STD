variable "public_subnets" {
  description = "The IDs of the public subnets."
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string

}

variable "elasticache_endpoint" {
  description = "The endpoint of the Elasticache cluster."
  type        = string
}

variable "region" {
  description = "The AWS region to launch the resources."
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the target group."
  type        = string

}
