# ECS Services

module "services" {
  source   = "./service"
  for_each = var.ecs_services

  # General
  environment = var.environment
  task_name   = each.key
  aws_region  = var.aws_region

  # Task Configuration
  task_cpu           = each.value.task_cpu
  task_memory        = each.value.task_memory
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn

  # Container Configuration
  container_name        = lookup(each.value, "container_name", each.key)
  container_image       = each.value.container_image
  container_port        = lookup(each.value, "container_port", null)
  environment_variables = lookup(each.value, "environment_variables", {})
  secrets               = lookup(each.value, "secrets", {})

  # Logging
  log_group_name = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.ecs_tasks[0].name : null

  # Health Check
  health_check = lookup(each.value, "health_check", null)

  # Volumes
  mount_points = lookup(each.value, "mount_points", [])
  efs_volumes  = lookup(each.value, "efs_volumes", [])
}
