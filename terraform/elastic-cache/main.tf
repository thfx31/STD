resource "aws_security_group" "elasticache_sg" {
  name        = "std-elasticache-sg"
  description = "Security group for Elasticache"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound traffic from ECS and EC2 instances"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  ingress {
    description     = "Allow inbound traffic from ECS Fargate tasks"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_fargate_id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id = "std-elasticache"
  description          = "STD Elasticache"
  node_type            = "cache.t2.micro"
  num_cache_clusters   = 1
  engine               = "redis"

  security_group_ids = [aws_security_group.elasticache_sg.id]
}
