# ------------------------------------------------------------------------------
# ECS Task Definition
# ------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.environment}-${var.task_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode(var.container_definitions)

  dynamic "volume" {
    for_each = {
      for container in var.container_definitions : container.name => container
    }
    content {
      name = "${var.task_name}-${volume.key}-config"

      efs_volume_configuration {
        file_system_id     = var.efs_file_system_id
        transit_encryption = "ENABLED"

        authorization_config {
          access_point_id = aws_efs_access_point.config[volume.key].id
        }
      }
    }
  }

  dynamic "volume" {
    for_each = {
      for volume in var.ebs_volumes : volume.name => volume
    }
    content {
      name                = volume.key
      host_path           = volume.value.host_path
      configure_at_launch = true
    }
  }

  tags = {
    Name = "${var.environment}-${var.task_name}"
  }
}
