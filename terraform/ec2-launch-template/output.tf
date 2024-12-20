output "launch_template_id" {
  value = aws_launch_template.std_launch_template.id
}

output "ec2_security_group_id" {
  value = aws_security_group.std_ec2_sg.id
}
