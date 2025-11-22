# ECS Task Definition

locals {
  container_definitions = [
    {
      name      = var.container_name
      image     = var.container_image
      essential = true

      portMappings = var.container_port != null ? [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ] : []

      environment = [
        for key, value in var.environment_variables : {
          name  = key
          value = value
        }
      ]

      secrets = [
        for key, value in var.secrets : {
          name      = key
          valueFrom = value
        }
      ]

      logConfiguration = var.log_group_name != null ? {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = var.task_name
        }
      } : null

      healthCheck = var.health_check != null ? {
        command     = var.health_check.command
        interval    = var.health_check.interval
        timeout     = var.health_check.timeout
        retries     = var.health_check.retries
        startPeriod = var.health_check.start_period
      } : null

      mountPoints = [
        for mount in var.mount_points : {
          sourceVolume  = mount.source_volume
          containerPath = mount.container_path
          readOnly      = mount.read_only
        }
      ]
    }
  ]
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-${var.task_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode(local.container_definitions)

  tags = {
    Name = "${var.environment}-${var.task_name}"
  }
}
