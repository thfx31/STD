variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnets" {
  description = "The IDs of the public subnets."
  type        = list(string)
}
