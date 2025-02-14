resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name              = "/ecs/std-ecs-cluster"
  retention_in_days = 7
}

resource "aws_ecs_cluster" "std-ecs-cluster" {
  name = "std-ecs-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_cluster.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "std-ecs-task" {
  family                   = "std-ecs-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048

  task_role_arn      = aws_iam_role.ecs_task_role_chat.arn
  execution_role_arn = aws_iam_role.ecs_execution_role_chat.arn

  container_definitions = jsonencode([
    {
      name   = "std-ecs-chat"
      image  = "ghcr.io/thfx31/std/chat-server:latest"
      cpu    = 1024
      memory = 2048
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]

      environment = [
        {
          name  = "ELASTICACHE_ENDPOINT"
          value = var.elasticache_endpoint
        }
      ]

      logConfiguration = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_cluster.name,
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "std-ecs-task"
        }
      },

      linuxParameters = {
        "initProcessEnabled" = true
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "std-ecs-service" {
  name            = "std-ecs-service"
  cluster         = aws_ecs_cluster.std-ecs-cluster.id
  task_definition = aws_ecs_task_definition.std-ecs-task.arn
  desired_count   = 3

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200


  enable_execute_command = true
  launch_type            = "FARGATE"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "std-ecs-chat"
    container_port   = 3000
  }

  network_configuration {
    subnets          = var.public_subnets
    security_groups  = [aws_security_group.chat.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
}

resource "aws_iam_role" "ecs_execution_role_chat" {
  name = "std-ecs-execution-role-chat"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "requirements-for-log-driver"

    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}


resource "aws_iam_role" "ecs_task_role_chat" {
  name = "std-ecs-task-role-chat"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "requirements-for-ecs-exec"

    policy = jsonencode({
      Version : "2012-10-17",
      Statement : [
        {
          Sid : "AllowECSExecActions",
          Effect : "Allow",
          Action : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "ecs:ExecuteCommand",
            "ssm:SendCommand",
            "ssm:DescribeInstanceInformation",
            "ssm:ListCommandInvocations",
            "ssm:ListCommands"
          ],
          Resource : "*"
        },
        {
          Sid : "AllowCloudWatchLogs",
          Effect : "Allow",
          Action : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          Resource : "*"
        }
      ]
    })
  }
}

resource "aws_security_group" "chat" {
  name        = "std-sg-chat"
  description = "Allow traffic for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 3
  resource_id        = "service/${aws_ecs_cluster.std-ecs-cluster.name}/${aws_ecs_service.std-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "ecs-cpu-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 50.0 # Se scale quand CPU > 50%
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "ecs-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 75.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

