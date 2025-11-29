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

  tags = {
    Name = "${var.environment}-${var.task_name}"
  }
}
