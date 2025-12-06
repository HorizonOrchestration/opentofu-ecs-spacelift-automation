# ------------------------------------------------------------------------------
# ECS Service Resources
# ------------------------------------------------------------------------------

resource "aws_service_discovery_service" "service" {
  count = var.namespace_id != null ? 1 : 0
  name  = local.definition_name

  dns_config {
    namespace_id = var.namespace_id

    dns_records {
      ttl  = 15
      type = "A"
    }
  }
}

resource "aws_ecs_service" "service" {
  name                               = local.definition_name
  cluster                            = var.cluster_arn
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.desired_count
  launch_type                        = "FARGATE"
  propagate_tags                     = "TASK_DEFINITION"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  enable_ecs_managed_tags            = true
  enable_execute_command             = true
  force_new_deployment               = true

  network_configuration {
    assign_public_ip = true
    security_groups  = [var.task_security_group_id]
    subnets          = var.subnet_ids
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider
    weight            = 100
  }

  dynamic "volume_configuration" {
    for_each = var.ebs_volumes
    content {
      name = each.key

      managed_ebs_volume {
        file_system_type = "ext4"
        role_arn         = var.infra_role_arn
        size_in_gb       = each.value.size_in_gb
      }
    }
  }

  # service_connect_configuration {
  #   enabled = true
  #   namespace = ""#"${var.namespace}"
  #   service {
  #     discovery_name = ""#"${var.task_name}"
  #   }
  # }
}