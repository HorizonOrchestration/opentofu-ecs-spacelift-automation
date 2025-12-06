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

  # Service Configuration
  cluster_arn       = aws_ecs_cluster.main.arn
  capacity_provider = var.capacity_provider
  infra_role_arn    = aws_iam_role.ecs_infrastructure.arn

  # Storage
  shared_efs_access_point_id = aws_efs_access_point.shared.id
  ebs_volumes                = each.value.ebs_volumes
  efs_file_system_id         = aws_efs_file_system.ecs_efs.id

  # Networking Configuration
  namespace_id             = aws_service_discovery_private_dns_namespace.ecs.id
  task_security_group_id   = aws_security_group.ecs_tasks.id
  subnet_ids               = var.use_private_cidrs ? aws_subnet.ecs_private[*].id : aws_subnet.ecs_public[*].id
  create_discovery_service = each.value.create_discovery_service
}
