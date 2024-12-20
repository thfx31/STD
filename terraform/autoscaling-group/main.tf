# Création de l'Auto Scaling Group
resource "aws_autoscaling_group" "std_asg" {
  desired_capacity = 2
  max_size         = 4 # Modifié pour pouvoir ajouter plus d'instances si nécessaire
  min_size         = 1

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  # Configuration de la vérification de l'état de l'instance pour le Load Balancer
  health_check_type         = "ELB"
  health_check_grace_period = 300


  vpc_zone_identifier = var.public_subnets
}
