# ------------------------------------------------------------------------------
# ECS Cluster
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = {
    Name = "${var.environment}-ecs-cluster"
  }
}

# ------------------------------------------------------------------------------
# Cluster Capacity Providers
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [var.capacity_provider]
}

# ------------------------------------------------------------------------------
# CloudWatch Log Group for ECS Tasks
# ------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "ecs_tasks" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = "/aws/ecs/${var.environment}"
  retention_in_days = var.cloudwatch_log_retention_days
  kms_key_id        = aws_kms_key.customer_managed_key[0].arn

  tags = {
    Name = "${var.environment}-ecs-tasks-logs"
  }
}
