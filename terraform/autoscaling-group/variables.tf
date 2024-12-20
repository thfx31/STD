variable "launch_template_id" {
  description = "The ID of the Launch Template."
  type        = string
}

variable "target_group_arns" {
  description = "The ARNs of the target groups."
  type        = list(string)
}


variable "public_subnets" {
  description = "The IDs of the public subnets."
  type        = list(string)
}
