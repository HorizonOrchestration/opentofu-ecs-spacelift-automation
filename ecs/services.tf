# ------------------------------------------------------------------------------
# ECS Services
# ------------------------------------------------------------------------------

module "services" {
  source   = "./service"
  for_each = var.ecs_services

  # General
  environment = var.environment
  task_name   = each.key
  aws_region  = var.aws_region

  # Task Configuration
  task_cpu              = each.value.task_cpu
  task_memory           = each.value.task_memory
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  task_role_arn         = aws_iam_role.ecs_task.arn
  container_definitions = each.value.container_definitions

  # Storage
  shared_efs_access_point_id = aws_efs_access_point.shared.id
  ebs_volumes                = each.value.ebs_volumes
  efs_file_system_id         = aws_efs_file_system.ecs_efs.id
}
