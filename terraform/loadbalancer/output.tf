output "load_balancer_sg_id" {
  value = aws_security_group.std_lb_sg.id
}

output "target_group_arn" {
  value = aws_lb_target_group.std_target_group.arn
}

output "load_balancer_dns_name" {
  value = aws_lb.std_lb.dns_name

}
