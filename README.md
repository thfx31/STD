# SDT - Projet Chat Server

Ce document a pour objectif de détailler les étapes de conception, d'implémentation et d'évolution d'un
projet de serveur de chat. L’architecture s’améliore au fil des itérations, chaque étape apportant des
améliorations en termes de performances, de scalabilité et de résilience.

&nbsp;

- [Paramétrage initial](#paramétrage-initial)
  - [Création du repo GitHub STD](#création-du-repo-github-std)
  - [Création d'un compte Terraform Cloud par membre](#création-dun-compte-terraform-cloud-par-membre)
  - [Mise en place des accès AWS dans Terraform Cloud](#mise-en-place-des-accès-aws-dans-terraform-cloud)
  - [Push du code sur GitHub repo STD](#push-du-code-sur-github-repo-std)
  - [Connexion entre GitHub Actions et Terraform Cloud](#connexion-entre-github-actions-et-terraform-cloud)

- [Itération 2 - Ajout de scalabilité avec Auto-scaling, Load Balancer et Elastic Cache](#itération-2---ajout-de-scalabilité-avec-auto-scaling-load-balancer-et-elastic-cache)
  - [Elastic Cache](#elastic-cache)
  - [Launch Template](#launch-template)
  - [Auto Scaling Group](#auto-scaling-group)
  - [Load Balancer](#load-balancer)
  - [Stickiness](#stickiness)
---
&nbsp;

## Paramétrage initial

&nbsp;


### Création du repo github STD
- ajout des membres du groupe

&nbsp;


### Création d'un compte Terraform Cloud par membre
- Création commpte Hashicorp https://portal.cloud.hashicorp.com/sign-up
- Création d'une organisation
- Invitation des membres du groupe dans l'organisation

&nbsp;


### Mise en place des accès AWS dans terraform cloud
- Création d'une clé API AWS


> IAM > Security credentials > Create access key

&nbsp;

### Push du code sur github repo STD

```bash
git add .
git commit -m "change_message"
git push
```
&nbsp;

### Connexion entre Github Actions et Terraform Cloud
- Création TF_API_TOKEN sur Terraform Cloud pour permettre à Github Actions de faire un "terraform login"

&nbsp;

> STD > Settings > API Tokens > Teams Tokens

&nbsp;

## Itération 2 - Ajout de scalabilité avec Auto-scaling, Load Balancer et Elastic Cache

&nbsp;

### Elastic cache
Ajout d'un replication_group
```HCL
resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id = "std-elasticache"
  description          = "STD Elasticache"
  node_type            = "cache.t2.micro"
  num_cache_clusters   = 1
  engine               = "redis"
```
&nbsp;


### Launch Template 
```HCL
resource "aws_launch_template" "std_launch_template" {
  name_prefix   = "std-launch-template"
  image_id      = data.aws_ami.ecs_optimized_ami.id
  instance_type = var.instance_type
  placement {
    availability_zone = "${var.region}a"
  }

  key_name = "SRE-KeyPair"

  user_data = base64encode(<<-EOF
              #!/bin/bash
              docker pull ghcr.io/thfx31/std/chat-server:latest
              docker run -d -p 80:3000 \
                -e ELASTICACHE_ENDPOINT=${var.elasticache_endpoint} \
                ghcr.io/thfx31/std/chat-server:latest
              EOF
  )

  network_interfaces {
    security_groups = [aws_security_group.std_ec2_sg.id]
  }
}
```

&nbsp;

### Auto Scaling Group
```HCL
resource "aws_autoscaling_group" "std_asg" {
  desired_capacity = 2
  max_size         = 4
  min_size         = 1

  launch_template {
    id      = var.launch_template_id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns
}
```
&nbsp;

### Load Balancer
```HCL
resource "aws_lb" "std_lb" {
  name                       = "std-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.std_lb_sg.id]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Name = "std-lb"
  }
}
```
&nbsp;

### Stickiness
> Nous utilisons le websocket entre l'instance et notre client.
L'activation de la stickiness (persistance de session) permet de maintenir une session stable entre le client et le serveur

```hcl
  # Configuration des sessions persistantes pour WebSocket
  stickiness {
    enabled         = true
    type            = "lb_cookie"
    cookie_duration = 86400
  }
```
&nbsp;
